## Aliyun MQ Python SDK

- 适用于 [aliyun rocketmq](https://www.aliyun.com/product/rocketmq)
- aliyun rocketmq 基于开源的 rocketmq，进行了优化、调整，故不能直接使用 github 上的 [apache/rocketmq-client-python](https://github.com/apache/rocketmq-client-python)
- aliyun mq python sdk，通过 [boost::python](https://www.boost.org/doc/libs/release/libs/python/) 库，将 [aliyun mq c++ sdk](https://help.aliyun.com/document_detail/29555.html) 暴露为 python 可用的模块。
- boost::python library is a framework for interfacing Python and C++. It allows you to quickly and seamlessly expose C++ classes functions and objects to Python, and vice-versa, using no special tools -- just your C++ compiler.

### Python Runtime Version
* python 2.7.x
* python 3.6.x, python 3.7.x

### Dependency of Python Client

* aliyun-mq-linux-cpp-sdk [download](https://ons-client-sdk.oss-cn-hangzhou.aliyuncs.com/linux_all_in_one/V1.1.2/aliyun-mq-linux-cpp-sdk.tar.gz)	
* boost-python 1.62.0 [download](https://sourceforge.net/projects/boost/files/boost/1.62.0/boost_1_62_0.tar.gz)

### Build and Install

```sh
# 适用于 centos7
# 注: 须 cd 到 project 根目录下

# use ons-cpp-v2.0.0-beta sdk

# python2
# sh install-v2.0.0-beta.sh 2
# python3.6.x, 3.7.x
sh install-v2.0.0-beta.sh 3
```

> 注: 若安装 python3 时没有将 python3 动态链接库 .so 编译出来（`ldconfig -v | grep python` 没有输出 `libpython3.so -> libpython3.so`）, 还需执行 `sh cp_ld_libpython.sh 3`


### Sample

- sync producer

    ```sh
    python sample/test_producer.py
    python3 sample/test_producer.py
    ```

- push consumer

    ```sh
    python sample/test_consumer.py
    python3 sample/test_consumer.py
    ```