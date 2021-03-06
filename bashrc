#-----------------------------------------------------------------------------
# Steve's .bashrc stuff
#
alias l='/bin/ls -F --color=auto'
alias ls='l -lh'
alias la='l -A'
alias df='df -h'
alias lsa='ls -A'
m() { less -R "$@"; }
alias md='mkdir -p'
alias h=history

alias hf='history|grep -i'
alias ef='printenv|grep -i'
alias rm='rm -i'
alias j=jobs

alias apc='sudo aptitude clean'
alias apd='sudo aptitude update'
alias apg='sudo aptitude safe-upgrade'

alias http="python -m SimpleHTTPServer"

set -o vi
shopt -s dotglob histappend

has() { type -t "$@" > /dev/null; }

echoerr() { echo $* 1>&2; }

ismacos() { [[ "$OSTYPE" =~ darwin ]]; }

# Solarized is now the default. If non-solarized is required,
# source unsolarized.sh from bashrc.local
export SOLARIZED=dark

# remove ':' from completion word breaks so man Some::Perl doesn't escape
# http://tiswww.case.edu/php/chet/bash/FAQ   /E13
export COMP_WORDBREAKS=${COMP_WORDBREAKS//:}

export NETHACKOPTIONS='color, catname:Coco, dogname:Walter the farting dog, fixinv, fruit:bum nugget, hilite_pet, runmode:walk, disclose:yi ya yv yg yc, noautopickup, nocmdassist, boulder:0'

export IGNOREEOF=1

_make_color() {
    local code
    for i in $@; do
        eval "color=\$_$i"
        if [ -z $color ]; then
            echoerr Unknown color $i
            return 1
        fi
        code="$code;$color"
    done
    echo -n $code
}

ansicode() {

    local _black=30
    local _red=31
    local _green=32
    local _yellow=33
    local _blue=34
    local _magenta=35
    local _cyan=36
    local _white=37
    local _default=39

    local _bgblack=40
    local _bgred=41
    local _bggreen=42
    local _bgyellow=43
    local _bgblue=44
    local _bgmagenta=45
    local _bgcyan=46
    local _bgwhite=47
    local _bgdefault=49

    local _bold=1
    local _italics=3
    local _underline=4
    local _inverse=7
    local _strikeout=9

    local _nobold=22
    local _noitalics=23
    local _nounderline=24
    local _noinverse=27
    local _nostrikeout=29

    local _reset=0

    _make_color $@
}

solarized_code() {

    local _base03='1;30'
    local _base02='22;30'
    local _base01='1;32'
    local _base00='1;33'
    local _base0='1;34'
    local _base1='1;36'
    local _base2='22;37'
    local _base3='1;37'
    local _yellow='22;33'
    local _orange='1;31'
    local _red='22;31'
    local _magenta='22;35'
    local _violet='1;35'
    local _blue='22;34'
    local _cyan='22;36'
    local _green='22;32'

    local _bgbase02=40
    local _bgbase2=47
    local _bgyellow=43
    local _bgred=41
    local _bgmagenta=45
    local _bgblue=44
    local _bgcyan=46
    local _bggreen=42

    local _underline=4
    local _nounderline=24

    local _reset=0

    _make_color $@
}

ansicolor() { printf '\e[%sm' $( ansicode "$@" ); }
solacolor() { printf '\e[%sm' $( solarized_code "$@" ); }
bashcolor() { printf '\[%s\]' $( ansicolor "$@" ); }

PS1=""
PS1+="$(bashcolor reset)"
PS1+="${debian_chroot:+($debian_chroot)}"
PS1+="$(bashcolor magenta)\$(__git_ps1 '(%s) ')"
PS1+="$(bashcolor blue)\w"
PS1+="\n"
PS1+="$(bashcolor green)\u@\h \t"
PS1+="$(bashcolor reset)\$"
PS1+=" "

# Less Colors for Man Pages
if true; then
    export LESS_TERMCAP_mb=$(ansicolor red)                 # begin blinking
    export LESS_TERMCAP_md=$(ansicolor yellow)              # begin bold
    export LESS_TERMCAP_me=$(ansicolor reset)               # end mode
    export LESS_TERMCAP_se=$(ansicolor reset)               # end standout-mode
    export LESS_TERMCAP_so=$(ansicolor magenta)             # begin standout-mode – info box
    export LESS_TERMCAP_ue=$(ansicolor nounderline)         # end underline
    export LESS_TERMCAP_us=$(ansicolor underline green)     # begin underline
fi


_yes_or_no() {
    local default=$1 ; shift
    local ucdefault=$(echo $default | tr '[:lower:]' '[:upper:]')
    local yesno=yes/no
    local yn=${yesno/$default/$ucdefault}
    local prompt="$@ ($yn)? "

    while true; do
        local input; read -p "$prompt" input

        [ -z $input ] && input=$default

        case $input in
            yes|y)
                return 0
                ;;
            no|n|)
                return 1
                ;;
        esac
    done
}

YES_or_no() { _yes_or_no yes "$@"; }
yes_or_NO() { _yes_or_no no  "$@"; }

export HISTSIZE=2000
export HISTFILESIZE=2000
export HISTCONTROL=erasedups
export EDITOR=vim

export DBIC_TRACE_PROFILE=console

uselect() {
	$HOME/.dotfiles/uselect/uselect "$@"
}
UEDITOR=vi
source $HOME/.dotfiles/uselect/example.bashrc

find_file_upwards() {
    local dir="$PWD"

    until [ -f $dir/$1 ] ; do
        if [ $dir = '/' ]; then
            return 1
        fi
        dir=$(dirname $dir)
    done
    echo "$dir/$1"
}

if has mvim && ! has gvim; then
    gvim() { mvim "$@"; }
fi

vs()  { find . -type f -iname '.*.sw?'; }
vsd() { find . -type f -iname '.*.sw?' -delete -exec echo Deleting {} ... \; ; }

yamldump() {
    has p || cpanm App::p
    p 'dd yl r \*STDIN'
}

xmldump() {
    has p || cpanm App::p
    p 'dd xl r \*STDIN'
}

jsondump() {
    has p || cpanm App::p
    p 'dd jl r \*STDIN'
}

upload-tpg() {
    local dir="$1"
    local file="$2"
    curl --user morepats ftp://users.tpg.com.au/"$dir" --upload-file "$file"
}

# locate variants - only files or only dirs
flocate() {
    locate "$@" | perl -nlE 'say if -f'
}

dirlocate() {   # dlocate already exists
    locate "$@" | perl -nlE 'say if -d'
}

evi() {
    [ $# -gt 0 ] || return
    runv vi "$@"
}

# Rename some commands from uselect/example.bashrc
alias fv=fe
alias gv=ge
alias lv=le

TEST=/a/test/path/../dir
EXPECTED=/a/test/dir
if GOT=$( readlink -m $TEST 2> /dev/null ) && [ "$GOT" == "$EXPECTED" ]; then
    # Use readlink if we have the gnu version
    fullpath() { readlink -m "$@"; }
elif GOT=$( greadlink -m $TEST 2> /dev/null ) && [ "$GOT" == "$EXPECTED" ]; then
    # Use greadlink if we installed that with homebrew
    fullpath() { greadlink -m "$@"; }
else
    # Fall back to python
    fullpath() { python -c \
        'import os.path; import sys; print os.path.abspath(sys.argv[1])' "$@"; }
fi
unset TEST EXPECTED GOT

strip_envvar() {
    [ $# -gt 1 ] || return;

    local pathsep=${PATHSEP:-:}

    # Add an extra pathsep to each end to avoid special cases
    local haystack=$pathsep$1$pathsep
    local needle=$pathsep$2$pathsep

    # This needs to be in a loop, multiples don't work properly if we use the
    # 'replace all' mode.
    while true; do
        local h2=${haystack/$needle/$pathsep}
        [ $h2 == $haystack ] && break
        haystack=$h2
    done
    h2=${h2#$pathsep}     # strip the initial pathsep
    echo ${h2%$pathsep}   # strip the final pathsep
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

prepend_envvar_here()    { prepend_envvar $1 $PWD; }

prepend_envvar_at() {
    local var=$1
    shift
    for i in $@; do
        local path=$( fullpath "$i" )
        if [ -d $path ]; then
            prepend_envvar $var $path
        fi
    done
}

perlhere() { PATHSEP=: prepend_envvar_here PERL5LIB; }
perlat()   { prepend_envvar_at PERL5LIB   "$@"; }
pathat()   { prepend_envvar_at PATH       "$@"; }
pythat()   { prepend_envvar_at PYTHONPATH "$@"; }

export ACKRC="$HOME/.dotfiles/ackrc"
export CPAN_MINI_CONFIG="$HOME/.dotfiles/minicpanrc"
export INPUTRC="$HOME/.dotfiles/inputrc"
export SCREENRC="$HOME/.dotfiles/screenrc"
export TERM_ANSICOLOR_CONFIG="$HOME/.dotfiles/ansicolorrc"
export TMUX_VIM_CONFIG="$HOME/.dotfiles/tmux-vim.conf"
export TMUX_VIM_INI="$HOME/.dotfiles/tmux-vim.ini"
export USELECTRC="$HOME/.dotfiles/uselectrc"

export CPAN_MINI_PATH=$(grep local: $CPAN_MINI_CONFIG | sed -e "s!^.*~!$HOME!")
export PERL_CPANM_OPT="-q"
if [ -e $CPAN_MINI_PATH/authors/01mailrc.txt.gz ]; then
    PERL_CPANM_OPT="$PERL_CPANM_OPT --mirror $CPAN_MINI_PATH --mirror-only"
fi


# Screen colors (solarized)
export SCR_IW_FG=G
export SCR_IW_BG=k
export SCR_AW_FG=y
export SCR_AW_BG=.
export SCR_FG=.
export SCR_BG=.

# Start up screen in an intelligentish fashion
#
start_screen() {
    case $(screen -ls | fgrep -c '(Detached)') in
        0)
            # No detached sessions - start a new session
            exec screen
            ;;
        1)
            # One detached session - connect to it
            exec screen -r
            ;;
        *)
            # More that one detached session - let the user decide
            echo
            screen -r       # this will fail and list the sessions
            ;;
    esac
}

alias sc='screen -X'
alias sch='sc title $(hostname)'

# Leaky pipes! (with output prefix)
leak() { perl -ple "print STDERR '$*', \$_"; }

if [[ -n $TMUX ]]; then

    vi() { ~/.dotfiles/tmux-vim/tmux-vim "$@"; }

    reauth() {
        printenv SSH_AUTH_SOCK
        eval $( tmux show-environment | grep SSH_AUTH_SOCK )
        printenv SSH_AUTH_SOCK
    }

    # tmouse on/off
    tmouse() {
        for i in resize-pane select-pane select-window; do
            tmux set mouse-$i $1
        done
        if [[ -n "$1" ]]; then
            tmux set mode-mouse $1
        else
            local onoff=$( \
                tmux show-options | grep resize-pane | cut -d' ' -f2 )
            tmux set mode-mouse ${onoff:-off}
        fi
    }

else

    # Outside TMUX-only

    # Start up tmux in an intelligentish fashion
    gotmux () {
        unattached-tmux-sessions() {
            tmux ls 2> /dev/null | fgrep -v '(attached)' "$@"
        }
        cd ~
        case $(unattached-tmux-sessions -c) in
            0)
                # No detached sessions - start a new session
                tmux
                ;;
            1)
                # One detached session - connect to it
                tmux attach-session -t $(unattached-tmux-sessions | cut -d: -f 1)
                ;;
            *)
                # More that one detached session - choose one
                tmux attach-session -t $(unattached-tmux-sessions | uselect -1 -s 'select session' | cut -d: -f 1)
                ;;
        esac
        [ $? = 0 ] && logout # logout if all is well
    }

fi

mcd() { mkdir -p "$1"; cd "$1"; }

if has colordiff; then
    alias diff="colordiff -u"
else
    alias diff="diff -u"
fi

# Git submodules helpers
crgit() {
    "$@"
    git submodule foreach --recursive "$@"
}

rgit() {
    crgit git "$@"
}

fixgitemail() {
    uselect -1 -s 'select commit email' sdt@dr.com stephent@strategicdata.com.au |\
        xargs git config user.email
}

do_or_dry() {
    if [[ -n $DRY ]]; then
        echo "$@"
    else
        eval "$@"
    fi
}

gitbranchtotag() {

    if [[ $1 = -n ]]; then
        local DRY=1
    elif [[ $1 = -f ]]; then
        local DRY=
    else
        echo "Please specify -n (dry-run) or -f (force)"
        return 1
    fi
    shift   # get rid of -n / -f

    local lbr=$1
    local rbr=origin/$1
    local tag=attic/$lbr

    git fetch origin            # get the latest version from origin
    if ! git diff --exit-code --stat $lbr $rbr; then
        echo
        echo Local branch differs from remote.
        echo Please merge remote changes and try again.
        return 1
    fi

    do_or_dry git tag $tag $lbr            # create tag from branch
    do_or_dry git branch -D $lbr           # delete branch
    do_or_dry git push origin :$lbr $tag   # update origin with new tag / deleted branch
}

# Difference between two file trees
#  difftree -q to show only the filenames
alias difftree="diff -x .git -r"

for lp in lesspipe lesspipe.sh; do
    if has $lp; then
        eval $( $lp )
    fi
done

# Dist::Zilla config lives in ~/.dotfiles/dzil
export DZIL_GLOBAL_CONFIG_ROOT=${HOME}/.dotfiles/dzil

# Handy alias for unravelling tricky perl constructs
alias perlparse='perl -MO=Deparse,-p -e'

# Run perl coverage tests on specified files
# eg. cover_test t/some_test.t && http
cover_test () {
    rm -i -rf cover_db/
    PERL5OPT=-MDevel::Cover env perl -Ilib $* 2> /dev/null
    cover
}

alias mydebuild='debuild -uc -us -i -I -tc'
alias debfiles='dpkg-deb -c'

# Reload .bashrc
rebash() {
    unalias -a
    source ~/.bashrc
}

# Update dotfiles
redot() {
    if update-git-repo ~/.dotfiles; then
        rebash
        source ~/.dotfiles/install.sh
        return 0
    fi
    return 1
}

pod() {
    has perlfind || cpanm App::perlfind
    perlfind "$@"
}

export SSH_ENV="$HOME/.ssh/environment"

# Don't call this directly
_start_ssh_agent() {
     echo "Initialising new SSH agent..."
     /usr/bin/ssh-agent | sed 's/^echo/#echo/' > "${SSH_ENV}"
     chmod 600 "${SSH_ENV}"
     source "${SSH_ENV}"
     /usr/bin/ssh-add;
}

# This should get called by the bashrc.local of personal machines (not servers)
start_ssh_agent() {
    if [ -f "${SSH_ENV}" ]; then
         source "${SSH_ENV}" > /dev/null
         ps -ef | grep $SSH_AGENT_PID | grep -q ssh-agent$ || _start_ssh_agent
    else
         _start_ssh_agent;
    fi
}

socks_proxy() {
    local host=$1
    local port=${2:-1080}

    ssh -f -N -D 0:$port $host
}

# Local bash completion overrides
complete -f -X '!*.db' sqlite3

source_if() {
    if [ -f $1 ]; then
        source $1
    fi
}

cdup() {
    local n=$1
    local d=..
    local i=1

    while [ $i -lt $n ]; do
        d="$d/.."
        i=$(( $i + 1 ))
    done
    cd $d
}

resize_images() {
    isnum() { [[ -n $1 && -z ${1//[0-9]/} ]]; }

    if [[ $# -lt 3 ]] || ! isnum $1 || ! isnum $2 ; then
        echo usage: resize_images max-width max-height files...
        return 1
    fi

    local w=$1; shift
    local h=$1; shift

    # Gamma-correct resizing

    mogrify -verbose \
            -auto-orient \
            -gamma .454545 \
            -resize "${w}x${h}>" \
            -gamma 2.2 \
                "$@" 2>&1 | grep '=>'
}

# Print working directory of a given process id
procwd() {
    local pid=$1;
    lsof -p $pid -a -d cwd -Fn | grep ^n | cut -c 2-;
}

# tt 'some [% template %] stuff'
tt() {
    perl -MTemplate -E "Template->new->process(\'$@', {}, sub { say @_ })"
}

# jn delimiter args - like perl join ("join" was taken)
jn() {
    local _IFS="$IFS"
    IFS="$1"
    shift
    echo "$*"
    IFS="$_IFS"
}

# filter patt1 patt2 ...
# - wrapper around grep -v
# - filters out lines matching any of the given patterns
filter() {
    runv egrep -v "$( jn '|' "$@" )" ;
}

# metacpan_favourites username
# - list perl distributions marked as favourites on metacpan
metacpan_favourites() {
    if [[ -z $1 ]]; then
        echo usage: metacpan_favourites username
        return 1
    fi
    perl -Mojo -E "g('https://metacpan.org/author/$1')->dom('td.release a')->pluck('text')->each(sub{s/-/::/g;say})"
}

mfav() {
    metacpan_favourites SDT
}

refav() {
    cpanm Mojolicious IO::Socket::SSL
    mfav | cpanm
}

any_exists() {
    for i in "$@"; do
        [ -e "$i" ] && return 0
    done
    return 1
}

rsyslog() {
    ssh -AY "$@" tail -f /var/log/syslog
}

pathat ~/.dotfiles/bin

source_if ~/perl5/perlbrew/etc/bashrc
source_if ~/.pythonbrew/etc/bashrc
source_if ~/.pythonz/etc/bashrc
source_if ~/.dotfiles/local/bashrc
source ~/.dotfiles/tmux_colors.sh

if [ -d /usr/local/strategic/perl ]; then
    source ~/.dotfiles/bashrc.strat-perl
fi

if ismacos ; then
    source_if ~/.dotfiles/bashrc.macosx
fi

if any_exists ~/.dotfiles/*.local; then
    echo WARNING: these files should be transferred to ~/.dotfiles/local
    ls ~/.dotfiles/*.local
fi

