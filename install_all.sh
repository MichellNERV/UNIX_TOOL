#!/bin/bash
# CMake
# https://github.com/Kitware/CMake.git
# Neovim
# https://github.com/neovim/neovim.git
# zsh
# https://github.com/zsh-users/zsh.git
# oh-my-zsh

RED='\e[1;31m' # 红
GREEN='\e[1;32m' # 绿
YELLOW='\e[1;33m' # 黄
BLUE='\e[1;34m' # 蓝
PINK='\e[1;35m' # 粉红
RES='\e[0m' # 清除颜色

#
SHELL_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
echo SHELL_ROOT $SHELL_ROOT
INSTALL_ROOT=$SHELL_ROOT/tools
echo INSTALL_ROOT $INSTALL_ROOT

function source_file() {
  echo function source_file
  list=(~/.bashrc ~/.zshrc)
  for item in "${list[@]}"; do
    if [ -e $item ]; then
      echo "source $item"
      source $item
    else
      echo "not exist: $item"
    fi
  done
}

function init_submodule() {
  echo function init_submodule
  git submodule update --init --depth 1
  git config --global core.editor "vim"
}

function install_CMake() {
  echo function install_CMak
  # Build CMake
  cd $SHELL_ROOT/third_party/CMake
  ./bootstrap
  #if [ $? -eq 0 ] fail
  make
  make install DESTDIR=$INSTALL_ROOT/
  sed -i '$aCMAKE_PATH='"$INSTALL_ROOT"'/usr/local/bin' ~/.bashrc
  sed -i '$aexport PATH=$CMAKE_PATH:$PATH' ~/.bashrc
}

function install_zsh() {
  echo function install_zsh
  cd $SHELL_ROOT/third_party/zsh
  git checkout remotes/origin/5.9
  ./Util/preconfig
  ./configure --prefix=$INSTALL_ROOT/usr/local
  #echo $?
  make -j64
  make install
  sed -i '$aZSH_PATH='"$INSTALL_ROOT"'/usr/local/bin' ~/.bashrc
  sed -i '$aexport PATH=$ZSH_PATH:$PATH' ~/.bashrc
}

function install_ohmyzsh() {
  echo function install_ohmyzsh
  export ZSH="$INSTALL_ROOT/.oh-my-zsh"
  # code annotation
: <<!
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

function install_zplug() {
  echo function install_zplug
  ZPLUG_DIR=$INSTALL_ROOT/zplug
  if [ -d $ZPLUG_DIR ]; then
    mv -f ${ZPLUG_DIR} ${ZPLUG_DIR}_$(date +%Y-%m-%d-%H-%M-%S)
    echo -e  "${YELLOW}Backup ${ZPLUG_DIR} to ${ZPLUG_DIR}_$(date +%Y-%m-%d-%H-%M-%S)${RES}"
  fi
  cp -r $SHELL_ROOT/third_party/zplug $ZPLUG_DIR
}

function install_ohmytmux() {
  echo function install_ohmytmux
  # code annotation
: <<!
    $ git clone https://github.com/gpakosz/.tmux.git /path/to/oh-my-tmux
    $ ln -s -f /path/to/oh-my-tmux/.tmux.conf ~/.tmux.conf
    $ cp /path/to/oh-my-tmux/.tmux.conf.local ~/.tmux.conf.local
!
  cd $SHELL_ROOT/third_party/oh-my-tmux
  ln -s -f $PWD/.tmux.conf ~/.tmux.conf
  cp .tmux.conf.local ~/.tmux.conf.local
}

function install_neovim() {
  echo function install_neovim
  cd $SHELL_ROOT/third_party/neovim/
  rm -r build/
  if [ ! -d "build" ]; then
    mkdir build
  fi
  # code annotation
: <<!
    git clone https://github.com/neovim/neovim.git
    cd neovim
    sudo apt-get install ninja-build gettext libtool libtool-bin autoconf automake cmake g++ pkg-config unzip

    sudo make CMAKE_BUILD_TYPE=Release
    sudo make install
    cd
    source .bashrc
!
  make -j64 CMAKE_EXTRA_FLAGS="-DCMAKE_INSTALL_PREFIX=$INSTALL_ROOT/usr/local"
  #make -j64 CMAKE_BUILD_TYPE=RelWithDebInfo CMAKE_INSTALL_PREFIX=$INSTALL_ROOT
  make install
}

function copy_neovim_configs() {
  echo function copy_neovim_configs
  cd $INSTALL_ROOT
  mkdir -vp local/share/nvim/site/pack/packer/start/
  ln -snfv $INSTALL_ROOT/local/share/nvim ~/.local/share/nvim
  cd $SHELL_ROOT/third_party
  cp -r packer_nvim $INSTALL_ROOT/local/share/nvim/site/pack/packer/start/packer.nvim
  ##ln -s $INSTALL_ROOT/packer.nvim ~/.local/share/nvim/site/pack/packer/start/packer.nvim
  cd $SHELL_ROOT/configs/neovim
  NVIMCFG_DIR=~/.config/nvim
  if [ -d $NVIMCFG_DIR ]; then
    mv -f ${NVIMCFG_DIR} ${NVIMCFG_DIR}_$(date +%Y-%m-%d-%H-%M-%S)
    echo -e  "${YELLOW}Backup ${NVIMCFG_DIR} to ${NVIMCFG_DIR}_$(date +%Y-%m-%d-%H-%M-%S)${RES}"
  fi
  cp -r nvim ~/.config/nvim
}

function copy_zplug_configs() {
  echo function copy_zplug_configs
  cd $SHELL_ROOT/configs/zsh/zplug
  ZSHRC_FILE=~/.zshrc
  if [ -f $ZSHRC_FILE ]; then
    mv -f ${ZSHRC_FILE} ${ZSHRC_FILE}_$(date +%Y-%m-%d-%H-%M-%S)
    echo -e  "${YELLOW}Backup ${ZSHRC_FILE} to ${ZSHRC_FILE}_$(date +%Y-%m-%d-%H-%M-%S)${RES}"
  fi
  cp zshrc ~/.zshrc
  sed -i -e "s:path/to/zplug/:$INSTALL_ROOT/zplug:g" ~/.zshrc
  sed -i '$aCMAKE_PATH='"$INSTALL_ROOT"'/usr/local/bin' ~/.zshrc
  sed -i '$aexport PATH=$CMAKE_PATH:$PATH' ~/.zshrc
  zsh -c "source ~/.zshrc;zplug install"
  sleep 2
}

function mainMenu() {
  title="Main Menu"

  title=$(echo -e "\033[32;40m  ${title} \033[0m")

  url="https://github.com/MichellNERV/UNIX_TOOL"

  time=$(date +%Y-%m-%d)
  clear
  cat << EOF

    ##########################################
                    $title
    ##########################################

    *    1)    init_submodule
    *    2)    install_CMake
    *    3)    install_zsh
    *    4)    install_ohmyzsh
    *    5)    install_zplug
    *    6)    install_ohmytmux
    *    7)    install_neovim
    *    u)    utils Menu
    *    q)    quit
    ##########################################
    $url
    $time
EOF
  #cat << EOF的作用是按源代码输出
}

function utilsMenu() {
  title="Utils Menu"

  title=$(echo -e "\033[32;40m  ${title} \033[0m")

  url="https://github.com/MichellNERV/UNIX_TOOL"

  time=$(date +%Y-%m-%d)
  clear
  cat <<  EOF

    ##########################################
                    $title
    ##########################################

    *    1)    copy_neovim_configs
    *    2)    copy_zplug_configs
    *    3)    source_file
    *    r)    return Main Menu
    *    q)    quit
    ##########################################
    $url
    $time
EOF
  #cat <<  EOF的作用是按源代码输出
  read -n 1 -p "please input your option:" option
  option=${option:-r}
  case $option in
  1)
    echo copy_neovim_configs
    copy_neovim_configs
    ask_func utilsMenu
    ;;
  2)
    echo copy_zplug_configs
    copy_zplug_configs
    ask_func utilsMenu
    ;;
  3)
    echo source_file
    ask_func utilsMenu
    ;;
  r)
    mainMenu
    return
    ;;
  q)
    echo -e "\n\033[31;47m quit successful \033[0m"
    exit
    ;;
  *)
    utilsMenu
    ;;
  esac
}

function ask_func() {
  RETURN_MENU=$1
  while [[ true ]]; do
    echo -e "${GREEN}return to Menu? (Y/n):${RES}"
    read -n 1 option
    #echo -e "\n"
    option=${option:-y}
    case $option in
      [yY])
        echo Y
        $RETURN_MENU
        break
      ;;
      [nN])
        echo -e "\033[31;47m quit successful \033[0m"
        exit 0
      ;;
      *)
        echo -e  "${YELLOW}Choose option in [Y/N]!${RES}"
      ;;
    esac
  done


}
#init_submodule
#install_CMake
#install_zsh
#install_ohmyzsh
#install_ohmytmux
#install_neovim
#copy_configs
# at final, do source
#source_file

function main() {
  mainMenu
  while [[ true ]]; do
    read -n 1 -p "please input your option:" option
    option=${option:-q}
    case $option in
    1)
      echo init_submodule
      init_submodule
      ;;
    2)
      echo install_CMake
      install_CMake
      ;;
    3)
      echo install_zsh
      install_zsh
      ;;
    4)
      echo install_ohmyzsh
      install_ohmyzsh
      ;;
    5)
      echo install_zplug
      install_zplug
      ask_func mainMenu
      ;;
    6)
      echo install_ohmytmux
      install_ohmytmux
      ;;
    7)
      echo install_neovim
      install_neovim
      ask_func mainMenu
      ;;
    u)
      utilsMenu
      ;;
    q)
      echo -e "\n${GREEN} quit successful ${RES}"
      break
      ;;
    *)
      mainMenu
      ;;
    esac
  done
}
#ask_func
main