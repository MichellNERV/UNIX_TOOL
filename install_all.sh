#!/bin/bash
# CMake
# https://github.com/Kitware/CMake.git
# Neovim
# https://github.com/neovim/neovim.git
# zsh
# https://github.com/zsh-users/zsh.git
# oh-my-zsh

#
SHELL_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
echo SHELL_ROOT $SHELL_ROOT
INSTALL_ROOT=$SHELL_ROOT/tools
echo INSTALL_ROOT $INSTALL_ROOT

function init_submodule(){
git submodule update --init --depth 1
git config --global core.editor "vim"
}

function install_CMake(){
# Build CMake
cd $SHELL_ROOT
cd third_party/CMake
./bootstrap
#if [ $? -eq 0 ] fail
make
make install DESTDIR=$INSTALL_ROOT/
sed -i '$aCMAKE_PATH='"$SHELL_ROOT"'/tools/usr/local/bin/' ~/.bashrc
sed -i '$aexport PATH=$CMAKE_PATH:$PATH' ~/.bashrc
}

function source_file(){
  list=(~/.bashrc ~/.zshrc)
  for item in "${list[@]}" ; do
    if [ -e $item ];then
        echo "source $item"
        source $item
    else
        echo "not exist: $item"
    fi
  done
  }

function install_zsh(){
cd $SHELL_ROOT
cd third_party/zsh
git checkout remotes/origin/5.9
./Util/preconfig
./configure --prefix=$INSTALL_ROOT/
#echo $?
make
make install
sed -i '$aZSH_PATH='"$SHELL_ROOT"'/tools/bin/' ~/.bashrc
sed -i '$aexport PATH=$ZSH_PATH:$PATH' ~/.bashrc
}


function install_ohmyzsh(){
export ZSH="$INSTALL_ROOT/.oh-my-zsh"
:<<!
sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
echo $?
if [ $? -ne 0 ]; then
echo curl
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi
if [ $? -ne 0 ]; then
echo fetch 
#sh -c "$(fetch -o - https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi
!
#ZSH="$INSTALL_ROOT/.oh-my-zsh" sh ./third_party/oh-my-zsh/tools/install.sh
sh ./third_party/oh-my-zsh/tools/install.sh --unattended
git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$ZSH/custom}/plugins/zsh-autosuggestions
git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$ZSH/custom}/plugins/zsh-syntax-highlighting
git clone --depth=1 https://github.com/MichaelAquilina/zsh-you-should-use.git ${ZSH_CUSTOM:-$ZSH/custom}/plugins/you-should-use
sed -i -e "s:plugins=(git):plugins=(git zsh-syntax-highlighting zsh-autosuggestions z safe-paste vi-mode cp gitignore extract themes you-should-use):g" ~/.zshrc
sed -i '$abindkey '"'"'`'"'"' autosuggest-accept' ~/.zshrc
}

function install_ohmytmux(){
:<<!
$ git clone https://github.com/gpakosz/.tmux.git /path/to/oh-my-tmux
$ ln -s -f /path/to/oh-my-tmux/.tmux.conf ~/.tmux.conf
$ cp /path/to/oh-my-tmux/.tmux.conf.local ~/.tmux.conf.local
!
cd $SHELL_ROOT
cd third_party/oh-my-tmux
ln -s -f $PWD/.tmux.conf ~/.tmux.conf
cp .tmux.conf.local ~/.tmux.conf.local
}

function install_neovim(){
cd $SHELL_ROOT/third_party/neovim/

if [ ! -d "build" ];then
    mkdir build
fi
:<<!
git clone https://github.com/neovim/neovim.git
cd neovim
sudo apt-get install ninja-build gettext libtool libtool-bin autoconf automake cmake g++ pkg-config unzip

sudo make CMAKE_BUILD_TYPE=Release
sudo make install
cd
source .bashrc
!
#make -j64 CMAKE_BUILD_TYPE=RelWithDebInfo CMAKE_INSTALL_PREFIX=$INSTALL_ROOT/
make -j64 CMAKE_BUILD_TYPE=RelWithDebInfo CMAKE_INSTALL_PREFIX=$INSTALL_ROOT/
make install
}



#init_submodule
#install_CMake
#install_zsh
install_ohmyzsh
#install_ohmytmux
#install_neovim

# at final, do source
#source_file
