#!/bin/bash
# author:huohu

# 适用于 centos7

# 打印正在执行的命令
set -v

v=$1

python$v --version

# 注: 须 cd 到 project 根目录下
cur_dir=`pwd`
echo $cur_dir

echo -e "\libpython$v.so\n"
mkdir -p /usr/python$v/lib
cp $cur_dir/python$v/lib/* /usr/python$v/lib
echo -e "/usr/python$v/lib\n" > /etc/ld.so.conf.d/python3.conf

ldconfig
ldconfig -v | grep python
