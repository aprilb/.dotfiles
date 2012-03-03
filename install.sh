#!/bin/bash

do_install() {
    local basefile=$1
    local rccmd=$2

    [ -z $rccmd ] && rccmd="source ~/.dotfiles/$basefile"

    local sysfile=~/.${basefile}
    local dotfile="~/.dotfiles/${basefile}"

    echo -n "Installing ${dotfile} to ${sysfile} ... "
    if [ -e $sysfile ] && grep -F -q $dotfile $sysfile; then
        echo already installed.
    else
        echo ${rccmd} >> ${sysfile}
        echo ok.
    fi
}

do_install bashrc
do_install vimrc
do_install gvimrc
do_install tmux.conf

echo "Installing ~/.dotfiles/gitignore to ~/.gitconfig ... ok."
git config --global core.excludesfile ~/.dotfiles/gitignore
git config --global color.ui true
git config --global alias.llog 'log --date=local'
git config --global alias.ds 'diff --stat'
git config --global alias.dc 'diff --cached'
git config --global alias.dsc 'diff --stat --cached'
git config --global alias.steve 'tag -f steve-was-here'
git config --global alias.lg "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative"
git config --global alias.wu 'log --stat origin..@{0}'
git config --global alias.wup 'log -p origin..@{0} --'
git config --global alias.w 'whatchanged -M -C -B'
git config --global alias.cv 'commit -v'
git config --global alias.st 'status'
