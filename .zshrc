# Enable Powerlevel10k instant prompt. Keep this block at the top of the file.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Homebrew on Apple Silicon (no-op when brew is already on PATH)
[ -x /opt/homebrew/bin/brew ] && eval "$(/opt/homebrew/bin/brew shellenv)"

ZSH_DISABLE_COMPFIX=true
# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# theme
#ZSH_THEME="robbyrussell"
ZSH_THEME="powerlevel10k/powerlevel10k"

# PLUGINS 
plugins=(
  docker
  fzf
  git
  kubectl
  zsh-autosuggestions
  zsh-completions
  zsh-syntax-highlighting
  zsh-vi-mode
)

# config autosuggestions color
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#696969,bold"

source "$ZSH/oh-my-zsh.sh"

export EDITOR='nvim'

####### ALIAS #############

alias mf="mix format"
alias vim="nvim"
# set lsd package as ls default
alias ls="lsd"
alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
alias good_morning='~/.scripts/new_journal_entry.sh'
alias reader='sioyek'
##############################

# run a test inside iex, e.g. `debug test/foo_test.exs:42`
debug() { iex -S mix test "$@" --timeout=99999999999; }

# kep iex history in different session
export ERL_AFLAGS="-kernel shell_history enabled"
# compile new versions of erlang with docs
export KERL_BUILD_DOCS=yes

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh" || true

# fzf config
FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude deps/ --exclude _build/ --exclude .elixir --exclude .git'

# function that enables fzf in zsh-vi-mode, it is called after the plugin initiation
function zsh_vi_init() {
  # enable fzh 
  [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
}

# this function overwrite the de default one, enabling to yank to clipboard when using zsh_vi_mode
function zvm_vi_yank() {
	zvm_yank
	echo ${CUTBUFFER} | pbcopy
	zvm_exit_visual_mode
}

zvm_after_init_commands+=(zsh_vi_init)

export PATH="/opt/homebrew/opt/libpq/bin:$PATH"

# 1Password completention
command -v op >/dev/null && { eval "$(op completion zsh)"; compdef _op op; }

command -v mise >/dev/null && eval "$(mise activate zsh)"

# machine-local secrets/overrides, never committed
[ -f ~/.zshrc.local ] && source ~/.zshrc.local
