ZSH_DISABLE_COMPFIX=true
# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# theme
#ZSH_THEME="robbyrussell"
ZSH_THEME="powerlevel10k/powerlevel10k"

# PLUGINS 
plugins=(
  zsh-vi-mode
  zsh-autosuggestions
  zsh-completions
  git
  asdf
  docker
  fzf
  zsh-syntax-highlighting
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
alias debug='iex -S mix test $1 --timeout=99999999999'
##############################

# use vim in terminal
set -o vi

# asdf
. /opt/homebrew/opt/asdf/libexec/asdf.sh

# Yank to the system clipboard without using zsh-vi-mode
function vi-yank-clipboard {
    zle vi-yank
   echo -n "$CUTBUFFER" | pbcopy -i
}

zle -N vi-yank-clipboard
bindkey -M vicmd 'y' vi-yank-clipboard
#######################################################

# kep iex history in different session
export ERL_AFLAGS="-kernel shell_history enabled"
# compile new versions of erlang with docs
export KERL_BUILD_DOCS=yes

if (( ! ${fpath[(I)/usr/local/share/zsh/site-functions]} )); then
  FPATH=/usr/local/share/zsh/site-functions:$FPATH
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh" || true

export PATH="/usr/local/sbin:$PATH"

export PATH=$PATH:/usr/local/sbin

# fzf config
FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude deps/ --exclude _build/ --exclude .elixir --exclude .git'

# function that enables fzf in zsh-vi-mode, it is called after the plugin initiation
function zsh_vi_init() {
  # enable fzh 
  [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
}

# temporary fix to make the zsh-highlighting work
function zvm_after_init() {
  autoload add-zle-hook-widget
  add-zle-hook-widget zle-line-pre-redraw zvm_zle-line-pre-redraw
}
# this function overwrite the de default one, enabling to yank to clipboard when using zsh_vi_mode
function zvm_vi_yank() {
	zvm_yank
	echo ${CUTBUFFER} | pbcopy
	zvm_exit_visual_mode
}

zvm_after_init_commands+=(zsh_vi_init)

export PATH="/usr/local/opt/libpq/bin:$PATH"
export PATH="/opt/homebrew/opt/libpq/bin:$PATH"

# import scripts
export PATH="~/.config/kindcompletion:$PATH"

# 1Password completention
eval "$(op completion zsh)"; compdef _op op
