#!/bin/bash

# Utils
function is_installed {
  # set to 1 initially
  local return_=1
  # set to 0 if not found
  type $1 >/dev/null 2>&1 || { local return_=0;  }
  # return
  echo "$return_"
}

function install_macos {
  if [[ $OSTYPE != darwin* ]]; then
    return
  fi
  echo "MacOS detected"
  xcode-select --install

  if [ "$(is_installed brew)" == "0" ]; then
    echo "Installing Homebrew"
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  fi

  if [ $TERM_PROGRAM != "iTerm.app" ]; then
    echo "Installing iTerm2"
    brew tap caskroom/cask
    brew cask install iterm2
  fi

  if [ "$(is_installed zsh)" == "0" ]; then
    echo "Installing zsh"
    brew install zsh zsh-completions
  fi

  if [ "$(is_installed ag)" == "0" ]; then
    echo "Installing The silver searcher"
    brew install the_silver_searcher
  fi

  if [ "$(is_installed fzf)" == "0" ]; then
    echo "Installing fzf"
    brew install fzf
  fi

  if [ "$(is_installed tmux)" == "0" ]; then
    echo "Installing tmux"
    brew install tmux
    echo "Installing reattach-to-user-namespace"
    brew install reattach-to-user-namespace
    echo "Installing tmux-plugin-manager"
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
  fi

  if [ "$(is_installed git)" == "0" ]; then
    echo "Installing Git"
    brew install git
  fi

  if [ "$(is_installed node)" == "0" ]; then
    echo "Installing Node"
    brew install node
  fi

  if [ "$(is_installed nvim)" == "0" ]; then
    echo "Install neovim"
    brew install neovim
    if [ "$(is_installed pip3)" == "1" ]; then
      pip3 install neovim --upgrade
    fi
  fi
}

function install_linux {
  if [[ $OSTYPE != linux* ]]; then
    return
  fi
  echo "LINUX detected"

  if [ $TERM_PROGRAM != "terminal.app" ]; then
    echo "Installing terminator"
    apt install terminator
  fi

  if [ "$(is_installed zsh)" == "0" ]; then
    echo "Installing zsh"
    apt install zsh
    apt install zsh-completions
  fi

  if [ "$(is_installed ag)" == "0" ]; then
    echo "Installing The silver searcher"
    apt install silversearcher-ag
  fi

  if [ "$(is_installed fzf)" == "0" ]; then
    echo "Installing fzf"
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install
  fi

  if [ "$(is_installed tmux)" == "0" ]; then
    echo "Installing tmux"
    apt install tmux
    echo "Installing tmux-plugin-manager"
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
  fi

  if [ "$(is_installed git)" == "0" ]; then
    echo "Installing Git"
    apt install git
  fi

  if [ "$(is_installed node)" == "0" ]; then
    echo "Installing Node"
    apt install npm
    sudo npm cache clean -f 
    sudo n stable
  fi

  if [ "$(is_installed nvim)" == "0" ]; then
    echo "Install neovim"
    apt install neovim
    git clone https://github.com/neovim/neovim.git
    cd neovim && apt-get install ninja-build gettext libtool libtool-bin autoconf automake cmake g++ pkg-config unzip
    sudo make CMAKE_BUILD_TYPE=RelWithDebInfo && sudo make install

    if [ "$(is_installed pip3)" == "1" ]; then
      pip3 install neovim --upgrade
    fi
  fi
}

function backup {
  echo "Backing up dotfiles"
  local current_date=$(date +%s)
  local backup_dir=dotfiles_$current_date

  mkdir ~/$backup_dir

  mv ~/.zshrc ~/$backup_dir/.zshrc
  mv ~/.tmux.conf ~/$backup_dir/.tmux.conf
  mv ~/.vim ~/$backup_dir/.vim
  mv ~/.vimrc ~/$backup_dir/.vimrc
  mv ~/.vimrc.bundles ~/$backup_dir/.vimrc.bundles
}

function link_dotfiles {
  echo "Linking dotfiles"

  ln -s $(pwd)/zshrc ~/.zshrc
  ln -s $(pwd)/tmux.conf ~/.tmux.conf
  ln -s $(pwd)/vim ~/.vim
  ln -s $(pwd)/vimrc ~/.vimrc
  ln -s $(pwd)/vimrc.bundles ~/.vimrc.bundles

  echo "Installing oh-my-zsh"
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

  if [ ! -d "$ZSH/custom/plugins/zsh-autosuggestions" ]; then
    echo "Installing zsh-autosuggestions"
    git clone git://github.com/zsh-users/zsh-autosuggestions $ZSH/custom/plugins/zsh-autosuggestions
  fi

  echo "Get dracula theme"
  git clone https://github.com/dracula/zsh.git
  mv ./zsh/dracula.zsh-theme $ZSH/themes/dracula.zsh-theme
  mv ./zsh/lib $ZSH/themes/lib

  curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

  if [[ $vim_version == 'nvim' ]];then
    rm -rf $HOME/.config/nvim/init.vim
    rm -rf $HOME/.config/nvim
    mkdir -p ${XDG_CONFIG_HOME:=$HOME/.config}
    ln -s $(pwd)/vim $XDG_CONFIG_HOME/nvim
    ln -s $(pwd)/vimrc $XDG_CONFIG_HOME/nvim/init.vim
  fi
}

while test $# -gt 0; do 
  vim_version=$2
  export ZSH=$HOME/.oh-my-zsh
  case "$1" in
    --help)
      echo "Help"
      exit
      ;;
    --macos)
      install_macos
      backup
      link_dotfiles
      zsh
      source ~/.zshrc
      exit
      ;;
    --linux)
      install_linux
      backup
      link_dotfiles
      zsh
      source ~/.zshrc
      exit
      ;;
    --backup)
      backup
      exit
      ;;
    --dotfiles)
      link_dotfiles
      exit
      ;;
  esac

  shift
done
