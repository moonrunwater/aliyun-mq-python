#!/bin/bash
# author:huohu

# 适用于 centos7

# 打印正在执行的命令
set -v

# 注: 须 cd 到 project 根目录下
cur_dir=`pwd`
echo $cur_dir

# echo -e "install general tools ...\n"
# yum install -y epel-release
# yum install -y sudo
# yum install -y which
# yum install -y git
# yum install -y tree
# yum install -y net-tools.x86_64
# yum install -y wget
# yum install -y curl

# echo -e "install pip ...\n"
# yum search pip
# yum install -y python2-pip
# pip install --upgrade pip
# pip install setuptools

echo -e "install compile tools ...\n"
yum install -y gcc-c++
yum install -y make
yum install -y cmake

echo -e "install dependency ...\n"
yum install -y python-devel
yum install -y zlib-devel

# https://sourceforge.net/projects/boost/files/boost/1.62.0/boost_1_62_0.tar.gz
echo -e "install boost 1.62.0 编译慢, 要等等 ...\n"
cd $cur_dir/boost/
tar -xzf boost_1_62_0.tar.gz
cd boost_1_62_0
./bootstrap.sh
./b2 link=shared runtime-link=shared
./b2 install

mkdir -p /usr/local/boost_1_62_0/include
cp -rf boost /usr/local/boost_1_62_0/include
mkdir -p /usr/local/boost_1_62_0/lib64
cp -rf stage/lib/* /usr/local/boost_1_62_0/lib64

echo -e '\n/usr/local/boost_1_62_0/lib64' >> /etc/ld.so.conf
ldconfig
ldconfig -v | grep boost

# https://ons-client-sdk.oss-cn-hangzhou.aliyuncs.com/linux_all_in_one/V1.1.2/aliyun-mq-linux-cpp-sdk.tar.gz
echo -e "libonsclient4cpp.so\n"
cd $cur_dir
mkdir -p /usr/local/alibaba/mq/lib
cp lib/libonsclient4cpp.so /usr/local/alibaba/mq/lib
# mkdir -p /usr/local/alibaba/mq/include
# cp -rf include /usr/local/alibaba/mq/include

echo -e '\n/usr/local/alibaba/mq/lib' >> /etc/ld.so.conf
ldconfig
ldconfig -v | grep libonsclient4cpp

echo -e "build libaliyunmqclientpython.so ...\n"
cd $cur_dir
g++ -o libaliyunmqclientpython.so \
    -shared -fPIC -Wall -Wno-deprecated \
    -L ./lib \
    -I /usr/include/python2.7 \
    -I ./include \
    ./src/PythonWrapper.cpp \
    -lboost_system -lboost_thread -lboost_chrono -lboost_filesystem \
    -lboost_python -lpython2.7 -lpthread -lonsclient4cpp

strings libaliyunmqclientpython.so | grep ALIYUN_MQ_PYTHON_VERSION

cp libaliyunmqclientpython.so /usr/local/alibaba/mq/lib
ldconfig
ldconfig -v | grep libaliyunmqclientpython

# echo -e '\nexport LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/alibaba/mq/lib' >> ~/.bashrc
# source ~/.bashrc

echo -e "log dir ...\n"
mkdir -p $HOME/logs/metaq-client4cpp
