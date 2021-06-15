# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# theme
#ZSH_THEME="robbyrussell"
ZSH_THEME="powerlevel10k/powerlevel10k"

# PLUGINS 
plugins=(
  zsh-autosuggestions
  zsh-completions
  git
  fzf
  zsh-syntax-highlighting
)

source "$ZSH/oh-my-zsh.sh"

export EDITOR='nvim'

####### ALIAS #############
alias mf="mix format"
alias vim="nvim"
# set lsd package as ls default
alias ls="lsd"
alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
##############################

# use vim in terminal
set -o vi

# ASDF export config
# . $HOME/.asdf/asdf.sh
#
# . $HOME/.asdf/completions/asdf.bash

# kep iex history in different session
export ERL_AFLAGS="-kernel shell_history enabled"


function code {
    if [[ $# = 0 ]]
    then
        open -a "Visual Studio Code"
    else
        local argPath="$1"
        [[ $1 = /* ]] && argPath="$1" || argPath="$PWD/${1#./}"
        open -a "Visual Studio Code" "$argPath"
    fi
}

# export PATH="$PATH:$HOME/.elixir-ls/release"

if (( ! ${fpath[(I)/usr/local/share/zsh/site-functions]} )); then
  FPATH=/usr/local/share/zsh/site-functions:$FPATH
fi

# fzf config
FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude deps/ --exclude _build/ --exclude .elixir*'

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh" || true
