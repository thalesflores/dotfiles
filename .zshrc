# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
#ZSH_THEME="robbyrussell"
ZSH_THEME="powerlevel10k/powerlevel10k"
# 

# PLUGINS 
plugins=(
  zsh-autosuggestions
  zsh-completions
  git
  fzf
  zsh-syntax-highlighting
)

fpath=(path/to/zsh-completions/src $fpath)
source $ZSH/oh-my-zsh.sh

export EDITOR='nvim'

#alias ngrok="~/./ngrok http $1"

####### ALIAS #############
alias force-push="git commit --amend && git push -f"
alias mf="mix format"
alias gdlb="git fetch -p && for branch in `git branch -vv | grep ': gone]' | awk '{print $1}'`; do git branch -D $branch; done"
alias vim="nvim"
# set lsd package as ls default
alias ls="lsd"
alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
##############################

# use vim in terminal
set -o vi

# ASDF export config
. $HOME/.asdf/asdf.sh

. $HOME/.asdf/completions/asdf.bash


export PATH="$HOME/.exenv/bin:$PATH"

eval "$(exenv init -)"
export PATH="$HOME/.exenv/bin:$PATH"

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

export PATH="$HOME/.exenv/bin:$PATH"
export PATH="$HOME/.exenv/bin:$PATH"
export PATH="$HOME/.asdf/installs/elixir/1.10.2/.mix/escripts:$PATH"
export PATH="$PATH:$HOME/.elixir-ls/release"
export PATH="$HOME/.emacs.d/bin:$PATH"

if (( ! ${fpath[(I)/usr/local/share/zsh/site-functions]} )); then
  FPATH=/usr/local/share/zsh/site-functions:$FPATH
fi
export PATH="/usr/local/sbin:$PATH"

# fzf config
FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude deps/ --exclude _build/ --exclude .elixir*'

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

