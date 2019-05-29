#!/usr/bin/python
# -*- coding: UTF-8 -*-

import libaliyunmqclientpython
from settings import NAMESRV_ADDR, ACCESS_KEY, SECRET_KEY

producer = libaliyunmqclientpython.AliyunProducer(NAMESRV_ADDR, ACCESS_KEY, SECRET_KEY, "GID_producer_huohu")
producer.start()
print("aliyun producer started .....")

for i in range(100000):
    msgId = producer.send(
        "TOPIC_huohu_test",
        "tag_%s" % (i%3),
        "this is a msg from huohu. i=%s" % i,
        "898989_900%s" % i)
    print(msgId)

producer.shutdown()
print("aliyun producer shutdown.")
