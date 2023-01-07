#!/bin/bash
#CMake
#https://github.com/Kitware/CMake.git
#Neovim
#https://github.com/neovim/neovim.git
#zsh
#https://github.com/zsh-users/zsh.git
#oh-my-zsh

#
SHELL_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
echo $SHELL_ROOT

# Build CMake
cd third_party/CMake
./bootstrap
#if
make
make install DESTDIR=$SHELL_ROOT/tools/
sed -i '$aCMAKE_PATH='"$SHELL_ROOT"'/tools/usr/local/bin/' ~/.bashrc
sed -i '$aexport PATH=$CMAKE_PATH:$PATH' ~/.bashrc
