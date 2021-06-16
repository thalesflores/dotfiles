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
  echo "Installing ASDF plugins"

 for plugin in $(cut -d' ' -f1 "$HOME/.tool-versions"); do
   echo "Installing plugin to $plugin"

   asdf plugin add "$plugin"
 done

  echo "Installing tools via ASDF"

  asdf install

  echo "Tools installed"
}

install_elixir_ls() {
  echo "Cloning and installing elixirLS"
  elixirls="$HOME/.elixir-ls"

  if [[ -d "$elixirls" ]]; then rm -rf "$elixirls"; fi 

  git clone https://github.com/elixir-lsp/elixir-ls.git "$elixirls "  
  cd "$elixirls" || return
  mix deps.get && mix compile && mix elixir_ls.release -o release
  cd ~ || return

  echo "elixirLS was installed"
}

install_oh_my_zsh() {
  printf "Installing OhMyZSH\n"
  
  mv "$HOME/.zshrc" "$HOME/.zshrc.bkp"

  brew install zsh
  chsh -s /usr/local/bin/zsh

  rm -rf "$HOME/.zshrc"
  mv "$HOME/.zshrc.bkp" "$HOME/.zshrc"
  
  printf "OhMyZSH instalation finished\n"
}

install_powerlevel10k() {
  printf "Installing terminal theme POWERLEVEL10K\n"

  if [[ -d "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" ]]; then
    printf "POWERLEVEL10K already installed, skipping this step"

  else 
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"

    printf "POWERLEVEL10K instalation finished\n"
  fi
}

install_zsh_tools() {

  printf "Installing ZSH plugins\n"

  # autosuggestions
  git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"

  # auto completions
  git clone https://github.com/zsh-users/zsh-completions "${ZSH_CUSTOM:=$HOME/.oh-my-zsh/custom}/plugins/zsh-completions"

  # syntax highlighting
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"

  printf "ZSH plugins installed\n"
}

install_vim_plug() {
  printf "Installing the amazing Vim Plug\n"

  sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

  printf "Vim Plug was installed"
}

install_tmux_tpm() {

  echo "Installing Tmux package manager..."

  git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"

  echo "... Tmux package manager was installed"
}

echo "Hello, we will start to setup your new mac :)"

install_homebrew
restore_brew
install_oh_my_zsh
install_powerlevel10k
install_zsh_tools
install_asdf_tools
install_elixir_ls
install_vim_plug
install_tmux_tpm


echo "Your mac is ready to be used, enjoy"
