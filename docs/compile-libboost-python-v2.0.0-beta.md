# 编译 libboost_python

## libboost_python2

```sh
# 注: 须 cd 到 project 根目录下
cur_dir=`pwd`
echo $cur_dir

echo -e "\ninstall compile tools ...\n"
yum install -y gcc-c++
yum install -y make
yum install -y cmake

echo -e "\ninstall dependency ...\n"
ls /usr/lib64 | grep python
# lrwxrwxrwx.  1 root root      19 May 19 19:17 libpython2.7.so -> libpython2.7.so.1.0
# -rwxr-xr-x.  1 root root 1847496 Apr  9 22:31 libpython2.7.so.1.0

ldconfig -v | grep python

yum install -y zlib-devel
ls /usr/include/python2.7/
yum install -y python-devel
ls /usr/include/python2.7/

# https://sourceforge.net/projects/boost/files/boost/1.62.0/boost_1_62_0.tar.gz
echo -e "\ninstall boost 1.62.0: 编译慢, 要等等 ...\n"
cp $cur_dir/boost/boost_1_62_0.tar.gz ~/
cd
tar -xzf boost_1_62_0.tar.gz
cd boost_1_62_0

./bootstrap.sh --prefix=/usr/boost
./b2 link=shared runtime-link=shared
./b2 install

ls /usr/boost/
ls /usr/boost/include
ls /usr/boost/lib/ | grep python

echo -e "\ninstall libaliyunmqclientpython.so for python2.7\n"
cd $cur_dir
g++ -o libaliyunmqclientpython.so \
    -shared -fPIC -Wall -Wno-deprecated \
    -L /usr/lib64 \
    -I /usr/include/python2.7 \
    -L ./aliyun/v2.0.0-beta/lib \
    -I ./aliyun/v2.0.0-beta/include \
    -L /usr/boost/lib \
    -I /usr/boost/include \
    ./src/PythonWrapper.cpp \
    -lboost_python -lpython2.7 -lonsclient4cpp

strings libaliyunmqclientpython.so | grep ALIYUN_MQ_PYTHON_VERSION
```

## libboost_python3

```sh
# 注: 须 cd 到 project 根目录下
cur_dir=`pwd`
echo $cur_dir

echo -e "\ninstall compile tools ...\n"
yum install -y gcc-c++
yum install -y make
yum install -y cmake

echo -e "\ninstall python3.6 ...\n"
yum install -y python36.x86_64 python36-devel.x86_64
python3 --version
ldconfig -v | grep python
which python3
ls /usr/include/python3.6m
ls /usr/lib64 | grep python3

# https://sourceforge.net/projects/boost/files/boost/1.62.0/boost_1_62_0.tar.gz
# https://www.boost.org/doc/libs/1_65_1/libs/python/doc/html/tutorial/index.html
echo -e "\ninstall boost 1.62.0: 编译慢, 要等等 ...\n"
cp $cur_dir/boost/boost_1_62_0.tar.gz ~/
cd
tar -xzf boost_1_62_0.tar.gz
cd boost_1_62_0

./bootstrap.sh --prefix=/usr/boost --with-python=/usr/bin/python3 --with-python-version=3.6

# 修改 project-config.jam
# using python : 3.6 : /usr ;
# using python : 3.6 : /usr : /usr/include/python3.6m : /usr/lib64 ;
cp project-config.jam project-config.jam.backup
awk '{ sub(/using python \: 3\.6 \: \/usr \;/,"using python : 3.6 : /usr : /usr/include/python3.6m : /usr/lib64 ;"); print $0 }' project-config.jam \
> project-config.jam.tmp && mv -f project-config.jam.tmp project-config.jam

./b2 link=shared runtime-link=shared
./b2 install

ls /usr/boost/
ls /usr/boost/include
ls /usr/boost/lib/ | grep python
ls /usr/boost/lib/ | grep python3

echo -e "\ninstall libaliyunmqclientpython.so for python3\n"
cd $cur_dir
# 默认 /usr/include, /usr/local/include
g++ -o libaliyunmqclientpython.so \
    -shared -fPIC -Wall -Wno-deprecated \
    -L ./aliyun/v2.0.0-beta/lib \
    -I ./aliyun/v2.0.0-beta/include \
    -L /usr/lib64 \
    -I /usr/include/python3.6m \
    -L /usr/boost/lib \
    -I /usr/boost/include \
    ./src/PythonWrapper.cpp \
    -lboost_python3 -lpython3 -lonsclient4cpp

strings libaliyunmqclientpython.so | grep ALIYUN_MQ_PYTHON_VERSION
```

## 附 docker

```sh
docker pull moonrunwater/centos7.6-base:0.2

docker run \
    -itd \
    -h docker \
    --name aliyun-mq-python \
    --privileged \
    moonrunwater/centos7.6-base:0.2

docker cp aliyun-mq-python/ aliyun-mq-python:/root/
docker exec -it -w /root aliyun-mq-python /bin/bash
```