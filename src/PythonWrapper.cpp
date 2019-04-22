#include <iostream>
#include <boost/python.hpp>

#include "ONSFactory.h"
#include "Message.h"
#include "MessageListener.h"
#include "ONSClientException.h"

using namespace boost::python;
using namespace std;
using namespace ons;

#define ALIYUN_MQ_PYTHON_VERSION "1.0.0"
const char *VERSION = "ALIYUN_MQ_PYTHON_VERSION: " ALIYUN_MQ_PYTHON_VERSION;

class PyThreadStateLock {
    public:
        PyThreadStateLock()
        {
            state = PyGILState_Ensure();
        }

        ~PyThreadStateLock()
        {
            // NOTE: must paired with PyGILState_Ensure, otherwise it will cause deadlock!!!
            PyGILState_Release(state);
        }

    private:
        PyGILState_STATE state;
};

class PyThreadStateUnlock {
    public:
        PyThreadStateUnlock() : _save(NULL)
        {
            Py_UNBLOCK_THREADS
        }

        ~PyThreadStateUnlock()
        {
            Py_BLOCK_THREADS
        }

    private:
        PyThreadState *_save;
};

class ONSCLIENT_API CustomMsgListener : public MessageListener {
    public:
        CustomMsgListener(PyObject* pcb) : pCallback(pcb) {}
        virtual ~CustomMsgListener() {}

        Action consume(Message& message, ConsumeContext& context)
        {
            // cout << "CustomMsgListener: topic=" << message.getTopic() 
            //      << ", tag=" << message.getTag()
            //      << ", key=" << message.getKey()
            //      << ", msgId=" << message.getMsgID()
            //      << ", body=" << message.getBody() << endl;
            try {
                // ensure hold GIL, before call python callback
                PyThreadStateLock PyThreadLock;
                int status = boost::python::call<int>(pCallback, message);
                return status == 1 ? CommitMessage : ReconsumeLater;
            } catch (exception &e) {
                cerr << e.what() << endl;
            }
            return ReconsumeLater;
        }

    private:
        PyObject* pCallback;
};

class AliyunProducer {
    public:
        AliyunProducer(const char* namesrv_addr,
            const char* access_key, const char* secret_key, const char* group_id);

        void start();
        const char* send(const char* topic, const char* tag, const char* body, const char* key);
        void shutdown();

    private:
        Producer *pProducer;
};

class AliyunConsumer {
    public:
        AliyunConsumer(const char* namesrv_addr,
            const char* access_key, const char* secret_key, const char* group_id);

        void subscribe(const char* topic, const char* subExpression, PyObject* pCallback);
        void start();
        void shutdown();

    private:
        PushConsumer* pushConsumer;
};

AliyunProducer::AliyunProducer(const char* namesrv_addr,
    const char* access_key, const char* secret_key, const char* group_id)
{
    // producer 创建、正常工作的参数，必须输入
    ONSFactoryProperty factoryInfo;
    factoryInfo.setFactoryProperty(ONSFactoryProperty::NAMESRV_ADDR, namesrv_addr);
    factoryInfo.setFactoryProperty(ONSFactoryProperty::AccessKey, access_key);
    factoryInfo.setFactoryProperty(ONSFactoryProperty::SecretKey, secret_key);
    factoryInfo.setFactoryProperty(ONSFactoryProperty::ProducerId, group_id);
    // 创建producer
    this->pProducer = ONSFactory::getInstance()->createProducer(factoryInfo);
}

void AliyunProducer::start()
{
    //在发送消息前，必须调用start方法来启动Producer，只需调用一次即可
    this->pProducer->start();
}

const char* AliyunProducer::send(const char* topic, const char* tag, const char* body, const char* key)
{
    Message msg(
        topic,// Message Topic
        tag && *tag != '\0' ? tag : "*",// Message Tag,可理解为Gmail中的标签，对消息进行再归类，方便Consumer指定过滤条件在ONS服务器过滤    
        body);// Message Body，任何二进制形式的数据，ONS不做任何干预，需要Producer与Consumer协商好一致的序列化和反序列化方式

    // 设置代表消息的业务关键属性，请尽可能全局唯一：以方便您在无法正常收到消息情况下，可通过ONS Console查询消息并补发
    // 注意：不设置也不会影响消息正常收发
    if (key && *key != '\0')
        msg.setKey(key);

    //发送消息，只要不抛异常就是成功
    try {
        SendResultONS result = pProducer->send(msg);
        return result.getMessageId();
    } catch (ONSClientException &e) {
        cerr << e.what() << endl;
    }
    return "send error";
}

void AliyunProducer::shutdown()
{
    // 在应用退出前，必须销毁Producer对象，否则会导致内存泄露等问题
    pProducer->shutdown();
}

AliyunConsumer::AliyunConsumer(const char* namesrv_addr,
    const char* access_key, const char* secret_key, const char* group_id)
{
    // consumer 创建、正常工作的参数，必须输入
    ONSFactoryProperty factoryInfo;
    factoryInfo.setFactoryProperty(ONSFactoryProperty::MessageModel, ONSFactoryProperty::CLUSTERING);
    factoryInfo.setFactoryProperty(ONSFactoryProperty::NAMESRV_ADDR, namesrv_addr);
    factoryInfo.setFactoryProperty(ONSFactoryProperty::AccessKey, access_key);
    factoryInfo.setFactoryProperty(ONSFactoryProperty::SecretKey, secret_key);
    factoryInfo.setFactoryProperty(ONSFactoryProperty::ConsumerId, group_id);
    // ensure create GIL, for call Python callback from C
    PyEval_InitThreads();
    // 创建 pushConsumer
    this->pushConsumer = ONSFactory::getInstance()->createPushConsumer(factoryInfo);
}

void AliyunConsumer::subscribe(const char* topic, const char* subExpression, PyObject* pCallback)
{
    pushConsumer->subscribe(topic, subExpression, new CustomMsgListener(pCallback));
}

void AliyunConsumer::start()
{
    this->pushConsumer->start();
}

void AliyunConsumer::shutdown()
{
    // shutdown is a block call, ensure thread don't hold GIL
    PyThreadStateUnlock PyThreadUnlock;
    // 在应用退出前，必须销毁 Consumer 对象，否则会导致内存泄露等问题
    pushConsumer->shutdown();
}

void hello(const char* name)
{
    cout << "hello, " << name << "!" << endl;
}


BOOST_PYTHON_MODULE(libaliyunmqclientpython)
{
    // 类导出成Python可调用的动态链接库文件的方式
    class_<AliyunProducer/* 类名 */, boost::noncopyable /* 单例模式 */ >
        ("AliyunProducer", init<const char*, const char*, const char*, const char*>())
        .def("start", &AliyunProducer::start)
        .def("send", &AliyunProducer::send)
        .def("shutdown", &AliyunProducer::shutdown)
        ;

    class_<AliyunConsumer, boost::noncopyable>
        ("AliyunConsumer", init<const char*, const char*, const char*, const char*>())
        .def("subscribe", &AliyunConsumer::subscribe)
        .def("start", &AliyunConsumer::start)
        .def("shutdown", &AliyunConsumer::shutdown)
        ;

    class_<Message>("Message")
        .def("getTopic", &Message::getTopic)
        .def("getTag", &Message::getTag)
        .def("getKey", &Message::getKey)
        .def("getMsgID", &Message::getMsgID)
        .def("getBody", &Message::getBody)
        ;

    // 普通函数, 导出成Python可调用的动态链接库文件的方式
    def("hello", &hello);
}
