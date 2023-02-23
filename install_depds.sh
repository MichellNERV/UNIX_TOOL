#!/bin/bash
SHELL_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
echo SHELL_ROOT $SHELL_ROOT
INSTALL_ROOT=$SHELL_ROOT/tools
echo INSTALL_ROOT $INSTALL_ROOT
M4_V=1.4.13
autoconf_V=2.66
automake_V=1.11
libtool_V=2.2.6b
function install_depds(){

  #pack=${1%-*}
  if [ ! -f ${1}.tar.gz ]; then
    wget -O ${1}.tar.gz http://mirrors.kernel.org/gnu/${1%-*}/${1}.tar.gz
  fi
  #echo $pack
  #wget -O ${1}.tar.gz http://mirrors.kernel.org/gnu/${1%-*}/${1}.tar.gz \
  tar -xzvf ${1}.tar.gz
  if [ $? ]; then
    rm -r ${1}.*
    wget -O ${1}.tar.gz http://mirrors.kernel.org/gnu/${1%-*}/${1}.tar.gz
    tar -xzvf ${1}.tar.gz
  fi
  cd ${1} \
  && ./configure –prefix=$INSTALL_ROOT/usr/local
  make -j64 && make install
}

function install_m4(){
  wget -O a.gz http://mirrors.kernel.org/gnu/m4/m4-${M4_V}.tar.gz \
  && tar -xzvf m4-${M4_V}.tar.gz \
  && cd m4-${M4_V} \
  && ./configure –prefix=$INSTALL_ROOT/usr/local
  make && make install
}

function install_autoconf(){
wget http://mirrors.kernel.org/gnu/autoconf/autoconf-${autoconf_V}.tar.gz \
&& tar -xzvf autoconf-${autoconf_V}.tar.gz \
&& cd autoconf-${autoconf_V}\
&& ./configure –prefix=$INSTALL_ROOT/usr/local
make && make install
}

function install_automake(){
wget http://mirrors.kernel.org/gnu/automake/automake-${automake_V}.tar.gz \
&& tar xzvf automake-${automake_V}.tar.gz \
&& cd automake-${automake_V} \
&& ./configure –prefix=$INSTALL_ROOT/usr/local
make && make install
}

function install_alibtool(){
wget http://mirrors.kernel.org/gnu/libtool/libtool-${libtool_V}.tar.gz \
&& tar xzvf libtool-${libtool_V}.tar.gz \
&& cd libtool-${libtool_V} \
&& ./configure –prefix=$INSTALL_ROOT/usr/local
make && make install
}
deps=("m4-1.4.13" "autoconf-2.66" "automake-1.11" "libtool-2.2.6b")
for item in ${deps[*]}
do
    install_depds $item
done
#install_m4
#install_autoconf
#install_automake
#install_alibtool