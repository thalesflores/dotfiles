#!/bin/bash

install_homebrew() {
  printf "installing Homebrew\n"

  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  printf "Homebrew instalation finished\n"
}


restore_brew() {
  # install things throug brew
  echo "Installing Brew bundle"
  brew tap Homebrew/bundle
  echo "Running brew bundle to recover applicattions"
  brew bundle
}

delete_current_files() {
  echo "Deleting current files"
  config=$HOME/.config
  files=("$config/nvim/init.vim"
         "$config/gitui/key_config.ron"
         "$config/gh/hosts.yml" 
         "$config/gh/config.yml"
         "$HOME/.zshrc"
         "$HOME/.tmux.conf"
         "$HOME/.gitconfig"
         "$HOME/.p10k.zsh"
         "$HOME/.fzf.zsh"
         "$HOME/.tool-versions")

  for file in ${files[*]}; do
    echo "Deleting $file"
   rm -rf "$file"
  done

  echo "All files were deleted"
}

restore_dotfiles() {
  echo "Restoring dotfiles"
  alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

  dotfiles checkout

  echo "Dotfiles restored"
}

install_asdf_tools() {
  echo "Installing tools via ASDF"

  asdf install

  echo "Tools installed"
}

install_elixir_ls() {
  echo "Cloning and installing elixirLS"

  git clone https://github.com/elixir-lsp/elixir-ls.git ~/.elixir-ls
  cd ~/.elixir-ls || return
  mix deps.get && mix compile && mix elixir_ls.release -o release
  cd ~ || return

  echo "elixirLS was installed"
}

install_oh_my_zsh() {
  printf "Installing OhMyZSH\n"
  
  mv .zshrc .zshrc.bkp

  brew install zsh
  chsh -s /usr/local/bin/zsh

  rm -rf .zshrc
  mv .zshrc.bkp .zshrc
  
  printf "OhMyZSH instalation finished\n"
}

install_powerlevel10k() {
  printf "Installing terminal theme POWERLEVEL10K\n"
  "git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"

  printf "POWERLEVEL10K instalation finished\n"
}

install_vim_plug() {
  printf "Installing the amazing Vim Plug\n"

  sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

  printf "Vim Plug was installed"
}

echo "Hello, we will start to setup your new mac :)"

install_homebrew
restore_brew
install_powerlevel10k
install_asdf_tools
install_elixir_ls
install_vim_plug
install_oh_my_zsh

echo "Your mac is ready to be used, enjoy"
