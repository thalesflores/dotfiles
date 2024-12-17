# dotfiles

## Setup

### Cloning the repo

First of all, let's clone this repo

```sh
git clone --bare https://github.com/thalesflores/dotfiles.git $HOME/.dotfiles
```

Then we need to setup a new alias to dotfiles(on `.zshrc` it will be already there, so you just need to setup it in the current shell session).

```sh
alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
```
And lastly just run `dotfiles checkout` to set the files on your root

NOTE: if you already have some of the files locally, you could run the following command to create a backup of it:

```sh
mkdir -p .config-backup && \
dotfiles checkout 2>&1 | egrep "\s+\." | awk {'print $1'} | \
xargs -I{} mv {} .config-backup/{}
```

or just this one to delete all: 

```sh
dotfiles checkout 2>&1 | egrep "\s+\." | awk {'print $1'} | \
xargs -I{} rm -rf {} 
```

EXTRAS:

To make the `dotfiles` command more straightforward, you could run the following command to stop to show the untracked files:

```sh
dotfiles config --local status.showUntrackedFiles no
```


### Running setup script

The script `.config/setup.sh` is responsible to download all brew applications, setup `zsh` and it  plugins and theme.
In addition, the script will install vim, ASDF plugins and tools, and `elixir-ls` to be used on VIM

To execute it, just run: 

```sh
bash ~/.config/setup.sh
```

### Update terminal profile

This one is useful if you want to keep the consistence between all your iTerms, to do this just go to `profiles -> Default -> Edit Profiles -> Other Actions -> Import JSON profiles` and there select `~/thalesflores_terminal.json`

### Install VIM and TMUX plugins
As a last step, you need to enter in your vim and run `:Lazy` to see the extension installation status.

To install `TMUX` ones, open a new session `tmux`, and just run `prefix + I`, where prefix is configured to be `ctrl + e`

## Update dotfile configurations

### Generate/Update Brewfile

First we should install the bundle in the machine

```sh
brew tap Homebrew/bundle
```

Then, to generate/restore the Brewfile run

```sh
brew bundle dump
```

Once the Brewfile is generated, you could copy that to any machine and restore the same configurations
running 

```sh
brew bundle
```

and in case of you want to add/remove one specific installation from your Brewfile, update the file with

```sh
vim ~/Brewfile
```
