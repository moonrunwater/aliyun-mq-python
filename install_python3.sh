#!/bin/bash
# author:huohu

# 适用于 centos7

# 打印正在执行的命令
set -v

python3 --version

# 注: 须 cd 到 project 根目录下
cur_dir=`pwd`
echo $cur_dir

echo -e "\nboost lib\n"
mkdir -p /usr/boost/
cp -r $cur_dir/boost/lib /usr/boost/

echo -e "\n/usr/boost/lib\n" > /etc/ld.so.conf.d/boost.conf
ldconfig
ldconfig -v | grep boost
ldconfig -v | grep python

echo -e "\nlibonsclient4cpp.so\n"
mkdir -p /usr/aliyun/lib
cp $cur_dir/lib/libonsclient4cpp.so /usr/aliyun/lib

echo -e "\n/usr/aliyun/lib\n" > /etc/ld.so.conf.d/aliyun.conf
ldconfig
ldconfig -v | grep libonsclient4cpp

echo -e "\nlibaliyunmqclientpython.so\n"
# site_packages=`python3 -c "import site; print(site.getsitepackages()[0])"`
site_packages=`python3 -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())"`
echo $site_packages
cp $cur_dir/lib/python3/libaliyunmqclientpython.so $site_packages
python3 -c "import libaliyunmqclientpython; print('succeed to import libaliyunmqclientpython')"

echo -e "\nlog dir ...\n"
mkdir -p $HOME/logs/metaq-client4cpp
