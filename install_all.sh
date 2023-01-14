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
#git submodule update --init --depth 1


function Build_CMake(){
# Build CMake
cd $SHELL_ROOT
cd third_party/CMake
./bootstrap
#if [ $? -eq 0 ] fail
make
make install DESTDIR=$SHELL_ROOT/tools/
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

function Build_zsh(){
cd $SHELL_ROOT
cd third_party/zsh
git checkout remotes/origin/5.9
./Util/preconfig
./configure --prefix=$SHELL_ROOT/tools/
#echo $?
make
make install
sed -i '$aZSH_PATH='"$SHELL_ROOT"'/tools/bin/' ~/.bashrc
sed -i '$aexport PATH=$ZSH_PATH:$PATH' ~/.bashrc
}


function install_ohmyzsh(){
export ZSH="$SHELL_ROOT/tools/.oh-my-zsh"
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
#ZSH="$SHELL_ROOT/tools/.oh-my-zsh" sh ./third_party/oh-my-zsh/tools/install.sh
sh ./third_party/oh-my-zsh/tools/install.sh --unattended
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$ZSH/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$ZSH/custom}/plugins/zsh-syntax-highlighting

sed -i -e "s:plugins=(git):plugins=(git zsh-syntax-highlighting zsh-autosuggestions):g" ~/.zshrc
sed -i '$abindkey '"'"'`'"'"' autosuggest-accept' ~/.zshrc
}

function install_neovim(){


}
#Build_CMake
#Build_zsh
#install_ohmyzsh

# at final, do source
#source_file
