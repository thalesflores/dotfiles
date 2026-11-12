#!/bin/bash
# Sets up a new Mac from the dotfiles: Homebrew + Brewfile apps, Oh My Zsh with
# its theme and plugins, mise tools, tmux plugin manager, the Claude Code config and
# the macOS settings from ~/.config/macos.sh.
# Run it after `dotfiles checkout`. Safe to re-run: every step skips what is already there.
set -euo pipefail

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# clone <repo> <dir>, skipping when the dir already exists
clone() {
  [ -d "$2" ] || git clone --depth=1 "$1" "$2"
}

install_homebrew() {
  if ! command -v brew >/dev/null && [ ! -x /opt/homebrew/bin/brew ]; then
    echo "Installing Homebrew"
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
  # puts brew on PATH for the rest of this script (Apple Silicon or Intel)
  eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv)"
}

restore_brew() {
  echo "Installing everything from the Brewfile"
  # one failing cask should not stop the rest of the setup
  brew bundle --file="$HOME/Brewfile" || echo "Some Brewfile entries failed, check the output above"
}

install_oh_my_zsh() {
  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Installing Oh My Zsh"
    # KEEP_ZSHRC keeps the .zshrc from the dotfiles; zsh is already the default shell on macOS
    ZSH="$HOME/.oh-my-zsh" RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  fi

  echo "Installing the zsh theme and plugins"
  clone https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
  clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
  clone https://github.com/zsh-users/zsh-completions "$ZSH_CUSTOM/plugins/zsh-completions"
  clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
  clone https://github.com/jeffreytse/zsh-vi-mode "$ZSH_CUSTOM/plugins/zsh-vi-mode"
}

install_mise_tools() {
  echo "Installing the tools from ~/.config/mise/config.toml"
  mise install
}

install_tmux_tpm() {
  echo "Installing Tmux package manager"
  clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
}

link_claude() {
  echo "Linking Claude Code config from ~/.config/claude-personal"
  mkdir -p "$HOME/.claude"
  for src in "$HOME/.config/claude-personal"/*; do
    dst="$HOME/.claude/$(basename "$src")"
    # keep whatever was there before as .bak instead of overwriting it
    if [ -e "$dst" ] && [ ! -L "$dst" ]; then mv "$dst" "$dst.bak"; fi
    ln -sfn "$src" "$dst"
  done
}

echo "Hello, we will start to setup your new mac :)"

install_homebrew
restore_brew
install_oh_my_zsh
install_mise_tools
install_tmux_tpm
link_claude
bash "$HOME/.config/macos.sh"

echo "Your mac is ready to be used, enjoy"
