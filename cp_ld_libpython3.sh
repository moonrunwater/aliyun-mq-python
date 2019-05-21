#!/bin/bash
# author:huohu

# 适用于 centos7

# 打印正在执行的命令
set -v

python3 --version

# 注: 须 cd 到 project 根目录下
cur_dir=`pwd`
echo $cur_dir

echo -e "\libpython3.so\n"
mkdir -p /usr/python3/lib
cp $cur_dir/python3/lib/* /usr/python3/lib
echo -e "/usr/python3/lib\n" > /etc/ld.so.conf.d/python3.conf

ldconfig
ldconfig -v | grep python
