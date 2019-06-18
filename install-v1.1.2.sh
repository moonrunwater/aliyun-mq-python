#!/bin/bash
# author:huohu

# 适用于 centos7

# 打印正在执行的命令
set -v

# 适用于 centos
cat /etc/*-release

# 2 or 3
v=$1

python$v --version
ldconfig -v | grep python

# 注: 须 cd 到 project 根目录下
cur_dir=`pwd`
echo $cur_dir


########## 安装之前，先删除可能已安装的依赖共享库 ##########
rm -rf /usr/local/boost_1_62_0
rm -rf /usr/local/alibaba
# /etc/ld.so.conf
# /usr/local/boost_1_62_0/lib64
# /usr/local/alibaba/mq/lib
awk '{ sub(/\/usr\/local\/boost_1_62_0\/lib64/,""); print $0 }' /etc/ld.so.conf > /etc/ld.so.conf.tmp && mv -f /etc/ld.so.conf.tmp /etc/ld.so.conf
awk '{ sub(/\/usr\/local\/alibaba\/mq\/lib/,""); print $0 }' /etc/ld.so.conf > /etc/ld.so.conf.tmp && mv -f /etc/ld.so.conf.tmp /etc/ld.so.conf
cat /etc/ld.so.conf

rm -rf /usr/boost
rm -rf /usr/aliyun
rm -f /etc/ld.so.conf.d/*.conf
ls /etc/ld.so.conf.d

ldconfig
ldconfig -v | grep boost
ldconfig -v | grep libonsclient4cpp
ldconfig -v | grep libaliyunmqclientpython
########## 安装之前，先删除可能已安装的依赖共享库 ##########


echo -e "\nboost lib\n"
mkdir -p /usr/boost/lib
cp -r $cur_dir/boost/lib_python$v/* /usr/boost/lib

echo -e "\n/usr/boost/lib\n" > /etc/ld.so.conf.d/boost.conf
ldconfig
ldconfig -v | grep boost
ldconfig -v | grep python

# https://ons-client-sdk.oss-cn-hangzhou.aliyuncs.com/linux_all_in_one/V1.1.2/aliyun-mq-linux-cpp-sdk.tar.gz
echo -e "\nlibonsclient4cpp.so\n"
mkdir -p /usr/aliyun/lib
cp $cur_dir/aliyun/v1.1.2/lib/libonsclient4cpp.so /usr/aliyun/lib

echo -e "\n/usr/aliyun/lib\n" > /etc/ld.so.conf.d/aliyun.conf
ldconfig
ldconfig -v | grep libonsclient4cpp

echo -e "\nlibaliyunmqclientpython.so\n"
# site_packages=`python$v -c "import site; print(site.getsitepackages()[0])"`
site_packages=`python$v -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())"`
echo $site_packages
cp $cur_dir/aliyun/v1.1.2/lib/python$v/libaliyunmqclientpython.so $site_packages
python$v -c "import libaliyunmqclientpython; print('succeed to import libaliyunmqclientpython')"

echo -e "\nlog dir ...\n"
mkdir -p $HOME/logs/metaq-client4cpp

echo -e "\n===== SUCCESS to install"