#!/bin/bash

#        __            __
#       / /  ___ ____ / /  ________
#    _ / _ \/ _ `(_-</ _ \/ __/ __/
#   (_)_.__/\_,_/___/_//_/_/  \__/
#

# Jonn 2021

# Dependencies:
# git, wget

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Fetches and runs .git-prompt if git installed but .git-prompt not found.
function git_setup () {
  git --version &> /dev/null
  if [ $? -ne 0 ]; then return; fi

  # Download git-prompt if not found.
  if ! [ -f ~/.git-prompt.sh ]; then
    info 'File ".git-prompt.sh" not found. Fetching it.'
    wget https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh -O ~/.git-prompt.sh
  fi

  # Run .git-prompt. This makes the __git_ps1 function available.
  source ~/.git-prompt.sh
}

# Automatically sets up sys manager if not found.
function sys_setup () {
  if [ -d ~/.sys/ ] && [ -f ~/.sys/sys.sh ]; then return; fi

  info 'File "sys.sh" not found. Fetching it.'

  local SYS_URL='https://raw.githubusercontent.com/KargJonas/jtools/master/.sys/sys.sh'

  mkdir ~/.sys
  wget $SYS_URL -O ~/.sys/sys.sh
}

git_setup
sys_setup

# Getting distro info
DISTRO_NAME=$(cat /etc/*-release | grep 'NAME')

# Prints clean info messages
function info () {
  echo -e '\n\033[33;1m  Info\033[00m  ' $1 '\n'
}

# Enter a docker container using bash
function enter_docker_container () {
  docker exec -it $1 /bin/bash
}

# All data displayed in the PS1 must be evaluated at when the PS1
# is being printed. This prevents showing old data.

# Checks if inside container and returns docker indicator for PS1
function __docker_ps1 () {
  if [ -f /.dockerenv ]; then echo -e '\033[01;32m[\033[01;36mdocker\033[01;32m] '; fi
}

# Checks if user is root and returns root indicator for PS1
function __root_ps1 () {
  if [[ $(id -u) == 0 ]]; then echo -e '\033[01;32m[\033[01;35mroot\033[01;32m]'; fi
}

function __safe_git_ps1 () {
  git --version &> /dev/null
  if [ $? -ne 0 ]; then return; fi

  echo $(__git_ps1)
}

# This is where the PS1 is stitched together.
# The completed string undergoes further decoding by the shell program
# before being displayed (e.g. \w escape character)
PS1='$(__root_ps1)$(__docker_ps1)\[\033[01;32m\][\[\033[01;34m\]\w\[\033[01;32m\]]\[\033[01;33m\] $(__safe_git_ps1)\n \[\033[01;31m\]⇋\[\033[00m\] '

# Aliases
alias ls='ls --color=auto'
alias la='ls -a'
alias ll='ls -l'
alias bashrl='source ~/.bashrc'
alias bashedit='vim ~/.bashrc'
alias brl='source ~/.bashrc'
alias bed='vim ~/.bashrc'
alias cls='clear'
alias chx='sudo chmod +x'
alias gco='git checkout'
alias gpo='git push origin'

alias sys='bash ~/.sys/sys.sh'
alias edc='enter_docker_container'

# Distro specific aliases
case $DISTRO_NAME in
*"Ubuntu"*)
  alias agi='sudo apt-get install'
  alias agr='sudo apt-get remove'
  alias agu='sudo apt-get update'
  ;;
esac
