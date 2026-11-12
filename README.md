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
dotfiles checkout 2>&1 | grep -E "\s+\." | awk {'print $1'} | \
xargs -I{} mv {} .config-backup/{}
```

or just this one to delete all: 

```sh
dotfiles checkout 2>&1 | grep -E "\s+\." | awk {'print $1'} | \
xargs -I{} rm -rf {} 
```

EXTRAS:

To make the `dotfiles` command more straightforward, you could run the following command to stop to show the untracked files:

```sh
dotfiles config --local status.showUntrackedFiles no
```

A bare clone doesn't track the remote branches, so run this once to make `dotfiles pull` work (see [Keeping the local up to date](#keeping-the-local-up-to-date-with-the-remote)):

```sh
dotfiles config --local remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"
dotfiles fetch origin
dotfiles branch -u origin/main main
```


### Running setup script

The script `.config/setup.sh` is responsible to install Homebrew and all the applications from the `Brewfile` (Claude Code and terminal-browser included), setup `zsh` with Oh My Zsh, its plugins and theme.
In addition, the script will install the tools from `~/.config/mise/config.toml` using `mise`, the TMUX plugin manager, and link the Claude Code config from `~/.config/claude-personal` into `~/.claude`

It is safe to run it again, every step skips what is already installed.

To execute it, just run: 

```sh
bash ~/.config/setup.sh
```

### Machine only configs and secrets

Things that belongs only to one machine (tokens, a work git identity, extra `PATH`s) must not go to this repo. For that there are two files that are loaded automatically and ignored by git:

* `~/.zshrc.local`: sourced at the end of `.zshrc`
* `~/.gitconfig.local`: included at the end of `.gitconfig`

### Update terminal profile

The Ghostty config is already in place with `~/.config/ghostty/config`, nothing to do there.

For iTerm, this one is useful if you want to keep the consistence between all your iTerms, to do this just go to `profiles -> Default -> Edit Profiles -> Other Actions -> Import JSON profiles` and there select `~/thalesflores_terminal.json`

### Install VIM and TMUX plugins
As a last step, you need to enter in your vim and run `:Lazy` to see the extension installation status.

To install `TMUX` ones, open a new session `tmux`, and just run `prefix + I`, where prefix is configured to be `ctrl + e`

### Finish Claude Code and terminal-browser setup

Run `claude` once to login, and then run the following to configure the terminals and Claude Code to work with terminal-browser

```sh
terminal-browser setup
```

## Update dotfile configurations

### Keeping the local up to date with the remote

To bring the changes from the remote to your machine, just run

```sh
dotfiles pull --rebase --autostash
```

`--autostash` keeps your uncommitted local changes on top of the new ones. After pulling, if the `Brewfile`, `mise` tools or Claude Code config changed, run the setup script again to apply them

```sh
bash ~/.config/setup.sh
```

### Pushing changes

Commit the files you changed with `dotfiles add <file>` and `dotfiles commit`, then just run `dotfiles push`.

NOTE: if the machine also has a work GitHub account, SSH may authenticate as that one and the push fails. To always push with the personal key, save the personal public key to `~/.ssh/thalesflores.pub` and run:

```sh
dotfiles config --local core.sshCommand "ssh -o IdentitiesOnly=yes -i ~/.ssh/thalesflores.pub"
```

### Generate/Update Brewfile

To restore all the applications from the Brewfile in any machine, just run

```sh
brew bundle --file ~/Brewfile
```

To add/remove one specific installation, update the file with

```sh
vim ~/Brewfile
```

You could also regenerate it from what is installed with `brew bundle dump --force --file ~/Brewfile`, but be careful, it will add everything installed in the machine, so on a work machine prefer to edit the file by hand.
