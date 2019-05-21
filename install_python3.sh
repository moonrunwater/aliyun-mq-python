#!/bin/bash
# author:huohu

# 适用于 centos7

# 打印正在执行的命令
set -v

python3 --version

# 注: 须 cd 到 project 根目录下
cur_dir=`pwd`
echo $cur_dir

echo -e "boost lib\n"
mkdir -p /usr/boost/
cp -r $cur_dir/boost/lib /usr/boost/

echo -e "/usr/boost/lib\n" > /etc/ld.so.conf.d/boost.conf
ldconfig
ldconfig -v | grep boost
ldconfig -v | grep python

echo -e "libonsclient4cpp.so\n"
mkdir -p /usr/aliyun/lib
cp $cur_dir/lib/libonsclient4cpp.so /usr/aliyun/lib

echo -e "/usr/aliyun/lib\n" > /etc/ld.so.conf.d/aliyun.conf
ldconfig
ldconfig -v | grep libonsclient4cpp

echo -e "libaliyunmqclientpython.so\n"
site_packages=`python3 -c "import site; print(site.getsitepackages()[0])"`
cp $cur_dir/lib/python3/libaliyunmqclientpython.so $site_packages
python3 -c "import libaliyunmqclientpython; print('succeed to import libaliyunmqclientpython')"

echo -e "log dir ...\n"
mkdir -p $HOME/logs/metaq-client4cpp
