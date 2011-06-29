#-----------------------------------------------------------------------------
# Steve's .bashrc stuff
#
alias l='/bin/ls -F --color=auto'
alias ls='/bin/ls -lF --color=auto'
alias la='l -A'
alias lsa='ls -A'
m() { less -R $*; }
alias md=mkdir
alias h=history

alias hf='history|grep -i'
alias ef='printenv|grep -i'
alias rm='rm -i'
alias j=jobs

alias http="plackup -MPlack::App::Directory -e 'Plack::App::Directory->new({ root => \$ENV{PWD} })->to_app;'"

#set -o vi
shopt -s dotglob

ismacos() { [[ "$OSTYPE" =~ darwin ]]; }

# remove ':' from completion word breaks so man Some::Perl doesn't escape
# http://tiswww.case.edu/php/chet/bash/FAQ   /E13
export COMP_WORDBREAKS=${COMP_WORDBREAKS//:}

setcolor() { echo "\[\033[$1m\]"; }
resetcolor() { echo "\[\033[2$1m\]"; }

BLACK=30
RED=31
GREEN=32
YELLOW=33
BLUE=34
MAGENTA=35
CYAN=36
WHITE=37
BOLD=1
ITALICS=3
UNDERLINE=4
INVERSE=7
STRIKE=9

SETBLACK=$(setcolor $BLACK)
SETRED=$(setcolor $RED)
SETGREEN=$(setcolor $GREEN)
SETYELLOW=$(setcolor $YELLOW)
SETBLUE=$(setcolor $BLUE)
SETMAGENTA=$(setcolor $MAGENTA)
SETCYAN=$(setcolor $CYAN)
SETWHITE=$(setcolor $WHITE)

RESETALL=$(setcolor 0)

SETBOLD=$(setcolor $BOLD)
SETITALICS=$(setcolor $ITALICS)
SETUNDERLINE=$(setcolor $UNDERLINE)
SETINVERSE=$(setcolor $INVERSE)
SETSTRIKE=$(setcolor $STRIKE)

RESETBOLD=$(resetcolor 2)
RESETITALICS=$(resetcolor $ITALICS)
RESETUNDERLINE=$(resetcolor $UNDERLINE)
RESETINVERSE=$(resetcolor $INVERSE)
RESETSTRIKE=$(resetcolor $STRIKE)

PS1="${debian_chroot:+($debian_chroot)}"
PS1+="$SETMAGENTA\$(__git_ps1 '(%s) ')"
PS1+="$SETBLUE\w"
PS1+="\n"
PS1+="$SETGREEN\u@\h \t"
PS1+="$RESETALL\$"
PS1+=" "

# Less Colors for Man Pages
if true; then
    export LESS_TERMCAP_mb=$'\E[01;32m'       # begin blinking
    export LESS_TERMCAP_md=$'\E[01;36m'       # begin bold
    export LESS_TERMCAP_me=$'\E[0m'           # end mode
    export LESS_TERMCAP_se=$'\E[0m'           # end standout-mode
    export LESS_TERMCAP_so=$'\E[00;44m'       # begin standout-mode – info box
    export LESS_TERMCAP_ue=$'\E[0m'           # end underlin
    export LESS_TERMCAP_us=$'\E[04;32m'       # begin underline
else
    # Not sure what these ones are for anymore....
    export LESS_TERMCAP_mb=$'\E[01;31m'       # begin blinking
    export LESS_TERMCAP_md=$'\E[01;38;5;74m'  # begin bold
    export LESS_TERMCAP_me=$'\E[0m'           # end mode
    export LESS_TERMCAP_se=$'\E[0m'           # end standout-mode
    export LESS_TERMCAP_so=$'\E[38;5;246m'    # begin standout-mode - info box
    export LESS_TERMCAP_ue=$'\E[0m'           # end underline
    export LESS_TERMCAP_us=$'\E[04;38;5;146m' # begin underline
fi

HISTSIZE=2000
export EDITOR=vim

export DBIC_TRACE_PROFILE=console

find_file_upwards() {
    local dir=`pwd`

    until [ -f $dir/$1 ] ; do
        if [ $dir = '/' ]; then
            return 1
        fi
        dir=$(dirname $dir)
    done
    echo $dir/$1
}

has() {
    which $1 > /dev/null
    return $?
}

# If gvim exists set up our gvim-in-tabs system
if has gvim; then
    is_vim_server_running() {
        gvim --serverlist | grep -q -i `hostname`
    }

    vi() {
        local vimcmd="gvim --servername `hostname`"

#TODO:  cannot find a way of passing this to vim as one argument
#       keeps getting sent as qw/ '+set tags=$tagsfile' /
#    local tagsfile=$(find_file_upwards .ptags)
#    if [ -n "$tagsfile" ]; then
#        vimcmd+=" '+set tags=$tagsfile'"
#    fi

        if is_vim_server_running ; then
            if [ $# == 0 ]; then
                vimcmd+=" --remote-send :tablast<CR> --remote-send :tabnew<CR>"
            else
                vimcmd+=" --remote-tab-silent"
            fi
        else
            vimcmd+=" -p"
        fi

        #echo $vimcmd
        $vimcmd "$@"
    }
fi

vs()  { find . -type f -iname '.*.sw?'; }
vsd() { find . -type f -iname '.*.sw?' -delete -exec echo Deleting {} ... \; ; }

yamldump() {
    perl -MData::Dumper::Concise -MYAML -e \
        'print qq("$_" =>\n), Dumper(YAML::LoadFile($_)) for @ARGV' $@
}

if ! ( has iselect ) ; then
    iselect() { echo iselect not installed 1>&2 ; }
fi

vi_from_stdin() {

    # Read files from stdin into the $files array
    local OIFS="$IFS"
    IFS=$'\n';
    set -f ;
    trap 'echo Or maybe not...' INT
    local files=( $(cat) )   # read files from stdin
    trap INT
    set +f ;
    IFS="$OIFS"

    # Reopen stdin to /dev/tty so that vim works properly
    exec 0</dev/tty

    # Run vim with the files
    [ -n "$files" ] && echo vi $@ ${files[@]} && vi $@ ${files[@]};
}

gv() {
    ack --heading --break $@ |\
        perl -pe '(/^\d+:/ and s/^/\t/) or (/./ and do { chomp; $_ = "<S:$_>$_\n" })' |\
            iselect -f -m | vi_from_stdin
}

fv() {
    find . \( -name .git -prune \) -o -type f -not -iname '.*.sw?' \
                | sort | grep $@ | iselect -a -f -m | vi_from_stdin
}

lv() {
    locate $@ | iselect -a -f -m | vi_from_stdin
}

envvar_contains() {
    local pathsep=${PATHSEP:-:}
    eval "echo \$$1" | egrep -q "(^|$pathsep)$2($pathsep|\$)";
}

strip_envvar() {
    [ $# -gt 1 ] || return;

    local pathsep=${PATHSEP:-:}
    local haystack=$1
    local needle=$2
    echo $haystack | sed -e "s%^${needle}\$%%"  \
                   | sed -e "s%^${needle}${pathsep}%%"   \
                   | sed -e "s%${pathsep}${needle}\$%%"  \
                   | sed -e "s%${pathsep}${needle}${pathsep}%${pathsep}%"
}

prepend_envvar() {
    local envvar=$1
    local pathsep=${PATHSEP:-:}
    eval "local envval=\$(strip_envvar \$$envvar $2)"
    if test -z $envval; then
        eval "export $envvar=\"$2\""
    else
        eval "export $envvar=\"$2$pathsep$envval\""
    fi
    #eval "echo \$envvar=\$$envvar"
}

prepend_envvar_here()    { prepend_envvar $1 $(pwd); }

prepend_envvar_at() {
    cd $2 || return
    prepend_envvar_here $1
    cd - >> /dev/null
}

perlhere() { PATHSEP=: prepend_envvar_here PERL5LIB; }
perlat()   { for i in $@; do PATHSEP=: prepend_envvar_at PERL5LIB $i; done; }
pathat()   { for i in $@; do PATHSEP=: prepend_envvar_at PATH $i; done; }

mcd() { mkdir -p $1; cd $1; }

if has colordiff; then
    alias diff="colordiff -u"
else
    alias diff="diff -u"
fi

if has lesspipe; then
    eval $(lesspipe)
fi

# Handy alias for unravelling tricky perl constructs
alias perlparse='perl -MO=Deparse,-p -e'

alias mydebuild='debuild -uc -us -i -I -tc'

if [ -e $HOME/perl5/perlbrew/etc/bashrc ]; then
    source $HOME/perl5/perlbrew/etc/bashrc
fi

if [ -d $HOME/git/git-achievements ]; then
    PATH="$PATH:$HOME/git/git-achievements"
    alias git="git-achievements"
fi

if [ -e ~/.dotfiles/bashrc.local ]; then
    source ~/.dotfiles/bashrc.local
fi

alias rebash='source ~/.bashrc'
