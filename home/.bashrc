# .bashrc

export TERM=xterm-256color

export EDITOR=vim
export VISUAL=vim

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

#-------------------------------------------------------------
# Colors
#-------------------------------------------------------------

red='\[\e[0;31m\]'
RED='\[\e[1;31m\]'
green='\[\e[0;32m\]'
GREEN='\[\e[1;32m\]'
yellow='\[\e[0;33m\]'
YELLOW='\[\e[1;33m\]'
blue='\[\e[0;34m\]'
BLUE='\[\e[1;34m\]'
magenta='\[\e[0;34m\]'
MAGENTA='\[\e[1;34m\]'
cyan='\[\e[0;36m\]'
CYAN='\[\e[1;36m\]'
white='\[\e[0;37m\]'
WHITE='\[\e[1;37m\]'
NC='\[\e[0m\]' # No Color
# --> Nice. Has the same effect as using "ansi.sys" in DOS.

#-------------------------------------------------------------
# Dynamic Definitions
#-------------------------------------------------------------

# Source host- and application-specific definitions.
if [ -d $HOME/.bashrc.d ]; then
    for def in `ls $HOME/.bashrc.d/`; do
        . $HOME/.bashrc.d/$def
    done
fi

#-------------------------------------------------------------
# Aliases & Functions
#-------------------------------------------------------------

alias l='ls -l'
alias ..='cd ..'
alias v='vim'

alias rs='source $HOME/.bashrc'

source $HOME/.homesick/repos/homeshick/homeshick.sh;

function repeat()
{
    local i max
    max=$1; shift;
    for ((i=1; i <= max ; i++)); do  # --> C-like syntax
        eval "$@";
    done
}

function ask() # useful for integration with other functions
{
    echo -n "$@" '[y/n]: ' ; read ans
    case "$ans" in
        y*|Y*) return 0 ;;
        *) return 1 ;;
    esac
}

#-------------------------------------------------------------
# Homeshick
#-------------------------------------------------------------

if [ -f "$HOME/.homesick/repos/homeshick/completions/homeshick-completion.bash" ]; then
    . "$HOME/.homesick/repos/homeshick/completions/homeshick-completion.bash"
fi

#-------------------------------------------------------------
# NPM
#-------------------------------------------------------------

if hash npm 2>/dev/null; then
    source <(npm completion);
fi

#-------------------------------------------------------------
# Grunt
#-------------------------------------------------------------

if hash grunt 2>/dev/null; then
    eval "$(grunt --completion=bash)"
fi

#-------------------------------------------------------------
# Git
#-------------------------------------------------------------

if [ -f /etc/bash_completion.d/git ]; then
    . /etc/bash_completion.d/git
fi

# Git Colors.
if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
    c_reset="$NC"
    c_git_clean="$green"
    c_git_staged="$yellow"
    c_git_unstaged="$red"
else
    c_reset=
    c_git_clean=
    c_git_staged=
    c_git_unstaged=
fi

git_prompt ()
{
    # Skip /opt/toysdk, because it's big, slow, and nobody uses git there.
    pwd | grep -q '^/opt/toysdk'
    if [ $? -eq 0 ]; then
        return 0
    fi
    GIT_DIR=`git rev-parse --git-dir 2>/dev/null`
    if [ -z "$GIT_DIR" ]; then
        return 0
    fi
    GIT_HEAD=`cat $GIT_DIR/HEAD`
    GIT_BRANCH=${GIT_HEAD##*/}
    if [ ${#GIT_BRANCH} -eq 40 ]; then
        GIT_BRANCH="(no branch)"
    fi
    STATUS=`git status --porcelain`
    if [ -z "$STATUS" ]; then
        git_color="${c_git_clean}"
    else
        echo -e "$STATUS" | grep -q '^ [A-Z\?]'
        if [ $? -eq 0 ]; then
            git_color="${c_git_unstaged}"
        else
            git_color="${c_git_staged}"
        fi
    fi
    echo ":$git_color$GIT_BRANCH$c_reset"
}

#-------------------------------------------------------------
# Mercurial
#-------------------------------------------------------------

alias hgcm="hg commit -m"

alias hgps='hg push'
alias hgcp='hgcm; hgps;'
alias hgpl='hg in -v;hg pull -v;hg update -v;'
alias hgu='hg update'
alias hgup='hg update'

alias hgf='hg fetch'

alias hgm='hg merge'
alias hgr='hg resolve'

alias hgmv='hg rename'
alias hgrm='hg remove'

alias hgd="hg diff"

alias hga='hg add'
alias hgar='hg addremove'

alias hgs='hg status'
alias hgst='hg status'

function hgmf () {
    echo "Starting full server commit/push with merge...";
    hg status -v;
    hg addremove -v;
    hg pull -u -v;
    if hg merge -v;
    then
        hg commit -m "merging heads" -v;
        hg push -v;
        echo "Full server update with merge complete.";
    else
        echo "Full server update with merge failed."; echo "Try manually resolving and then using hgr -m path/to/file";
    fi
}

function hgcf () {
    echo "Starting full server commit/push with message...";
    hg status -v;

    if [ $# -gt 0 ];
    then
        local MSG="$@";
        hg addremove -v;
        if hg commit -v -m "$MSG";
        then
            hg out -v;
            hg push -v;
            echo "Full server update complete with message '$MSG'.";
        else
            echo "Full server update failed.";
        fi
    else
        echo "Write a commit message! Commit aborted.";
    fi
}

function hgcl () { hg clone /www/docs/$@ --uncompressed; }

#-------------------------------------------------------------
# Automatic setting of $DISPLAY (if not set already).
# This works for linux - your mileage may vary. ...
# The problem is that different types of terminals give
# different answers to 'who am i' (rxvt in particular can be
# troublesome).
# I have not found a 'universal' method yet.
#-------------------------------------------------------------

function get_xserver ()
{
    case $TERM in
        xterm )
            XSERVER=$(who am i | awk '{print $NF}' | tr -d ')''(' )
            # Ane-Pieter Wieringa suggests the following alternative:
            # I_AM=$(who am i)
            # SERVER=${I_AM#*(}
            # SERVER=${SERVER%*)}

            XSERVER=${XSERVER%%:*}
            ;;
        aterm | rxvt)
            # Find some code that works here. ...
            ;;
    esac
}

if [ -z ${DISPLAY:=""} ]; then
    get_xserver
    if [[ -z ${XSERVER}  || ${XSERVER} == $(hostname) || \
      ${XSERVER} == "unix" ]]; then
        DISPLAY=":0.0"          # Display on local host.
    else
        DISPLAY=${XSERVER}:0.0  # Display on remote host.
    fi
fi

export DISPLAY

#-------------------------------------------------------------
# Some settings
#-------------------------------------------------------------

# Enable options:
shopt -s cdspell
#shopt -s cdable_vars
#shopt -s checkhash
#shopt -s checkwinsize
#shopt -s sourcepath
#shopt -s no_empty_cmd_completion
#shopt -s cmdhist
#shopt -s histappend histreedit histverify
#shopt -s extglob        # Necessary for programmable completion.

# Disable options:
# N/A

export TIMEFORMAT=$'\nreal %3R\tuser %3U\tsys %3S\tpcpu %P\n'
export HISTTIMEFORMAT="%H:%M > "
export HISTIGNORE="&:bg:fg:ll:h"

function _exit()        # Function to run upon exit of shell.
{
    echo -e "\e[1;31mBye!\e[0m"
}
trap _exit EXIT

#-------------------------------------------------------------
# File & String-related Functions:
#-------------------------------------------------------------

function swap()  # Swap 2 filenames around, if they exist
{                #(from Uzi's bashrc).
    local TMPFILE=tmp.$$

    [ $# -ne 2 ] && echo "swap: 2 arguments needed" && return 1
    [ ! -e $1 ] && echo "swap: $1 does not exist" && return 1
    [ ! -e $2 ] && echo "swap: $2 does not exist" && return 1

    mv "$1" $TMPFILE
    mv "$2" "$1"
    mv $TMPFILE "$2"
}

function extract()      # Handy Extract Program.
{
     if [ -f $1 ] ; then
         case $1 in
             *.tar.bz2)   tar xvjf $1     ;;
             *.tar.gz)    tar xvzf $1     ;;
             *.bz2)       bunzip2 $1      ;;
             *.rar)       unrar x $1      ;;
             *.gz)        gunzip $1       ;;
             *.tar)       tar xvf $1      ;;
             *.tbz2)      tar xvjf $1     ;;
             *.tgz)       tar xvzf $1     ;;
             *.zip)       unzip $1        ;;
             *.Z)         uncompress $1   ;;
             *.7z)        7z x $1         ;;
             *)           echo "'$1' cannot be extracted via >extract<" ;;
         esac
     else
         echo "'$1' is not a valid file"
     fi
}

#-------------------------------------------------------------
# Shell Prompt
#-------------------------------------------------------------

function fastprompt()
{
    unset PROMPT_COMMAND
    PS1="[\u@\h $cyan\t$NC \w]\$ ";
}

_powerprompt()
{
    LOAD=$(uptime|sed -e "s/.*: \([^,]*\).*/\1/" -e "s/ //g");
    PS1="[\h $cyan\t $LOAD$NC \w$(git_prompt)]\$ "
}

function powerprompt()
{
    PROMPT_COMMAND=_powerprompt
}

powerprompt     # This is the default prompt -- might be slow.
                # If too slow, use fastprompt instead. ...

