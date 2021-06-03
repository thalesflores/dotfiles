# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="/Users/thales.flores/.oh-my-zsh"

ZSH_THEME="spaceship"

# PLUGINS 
plugins=(
  zsh-syntax-highlighting
  zsh-autosuggestions
  zsh-completions
  git
  fzf
)

fpath=(path/to/zsh-completions/src $fpath)
source $ZSH/oh-my-zsh.sh

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

SPACESHIP_PROMPT_SEPARATE_LINE=false
SPACESHIP_KUBECONTEXT_SHOW=false
SPACESHIP_CHAR_COLOR_SUCCESS="blue"
SPACESHIP_TIME_SHOW=true
SPACESHIP_VI_MODE_SHOW=false

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
  # Set Spaceship ZSH as a prompt
autoload -U promptinit; promptinit
  prompt spaceship

if (( ! ${fpath[(I)/usr/local/share/zsh/site-functions]} )); then
  FPATH=/usr/local/share/zsh/site-functions:$FPATH
fi
export PATH="/usr/local/sbin:$PATH"

# fzf config
FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude deps/ --exclude _build/ --exclude .elixir*'

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
