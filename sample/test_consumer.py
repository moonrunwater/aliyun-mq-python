# import set_env first, then import libaliyunmqclientpython
import set_env
import libaliyunmqclientpython
import time
from settings import ACCESS_KEY, GID_CONSUMER, NAMESRV_ADDR, SECRET_KEY

total = 0

def consume_msg(msg):
    print(msg.getTopic())
    print(msg.getTag())
    print(msg.getKey())
    print(msg.getMsgID())
    print(msg.getBody())

    global total
    total += 1
    print("total=%d" % total)
    
    return 1

alimq = libaliyunmqclientpython.AliyunMQClient()
alimq.create_consumer(NAMESRV_ADDR, ACCESS_KEY, SECRET_KEY, GID_CONSUMER)
alimq.subscribe("TOPIC_huohu_test", "tag_1 || tag_2", consume_msg)
alimq.start_consumer()
print("consumer started .....")

# sleep 30 minutes
time.sleep(30 * 60)

alimq.shutdown_consumer()
print("consumer shutdown.")
