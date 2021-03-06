#!/usr/bin/python
# -*- coding: UTF-8 -*-

import libaliyunmqclientpython
import time
from settings import NAMESRV_ADDR, ACCESS_KEY, SECRET_KEY, GID_CONSUMER

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
    
    # 必须要有返回值, 否则报如下错误:
    # terminate called after throwing an instance of 'boost::python::error_already_set'
    # Aborted
    return 1

consumer = libaliyunmqclientpython.AliyunConsumer(NAMESRV_ADDR, ACCESS_KEY, SECRET_KEY, GID_CONSUMER)
consumer.subscribe("TOPIC_huohu_test", "tag_1 || tag_2", consume_msg)
consumer.start()
print("aliyun consumer started .....")

# sleep 30 minutes
time.sleep(30 * 60)

consumer.shutdown()
print("aliyun consumer shutdown.")
