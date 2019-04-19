# import set_env first, then import libaliyunmqclientpython
import set_env
import libaliyunmqclientpython
from settings import ACCESS_KEY, GID_CONSUMER, NAMESRV_ADDR, SECRET_KEY

alimq = libaliyunmqclientpython.AliyunMQClient()
alimq.create_producer(NAMESRV_ADDR, ACCESS_KEY, SECRET_KEY, GID_CONSUMER)
alimq.start_producer()
print("producer started .....")

for i in range(100000):
    msgId = alimq.send(
        "TOPIC_huohu_test",
        "tag_%s" % (i%3),
        "this is a msg from huohu. i=%s" % i,
        "898989_900%s" % i)
    print(msgId)

alimq.shutdown_producer()
print("producer shutdown.")
