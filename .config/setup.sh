#!/bin/bash

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

echo "Hello, we will start to setup your new mac :)"

restore_brew
install_asdf_tools
install_elixir_ls

echo "Your mac is ready to be used, enjoy"
