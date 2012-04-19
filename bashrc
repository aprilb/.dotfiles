#-----------------------------------------------------------------------------
# Steve's .bashrc stuff
#
alias l='/bin/ls -F --color=auto'
alias ls='l -lh'
alias la='l -A'
alias lsa='ls -A'
m() { less -R "$@"; }
alias md='mkdir -p'
alias h=history

alias hf='history|grep -i'
alias ef='printenv|grep -i'
alias rm='rm -i'
alias j=jobs

alias http="plackup -MPlack::App::Directory -e'Plack::App::Directory->new->to_app'"

set -o vi
shopt -s dotglob

ismacos() { [[ "$OSTYPE" =~ darwin ]]; }

# remove ':' from completion word breaks so man Some::Perl doesn't escape
# http://tiswww.case.edu/php/chet/bash/FAQ   /E13
export COMP_WORDBREAKS=${COMP_WORDBREAKS//:}

export NETHACKOPTIONS='color, catname:Coco, dogname:Walter the farting dog, fixinv, fruit:bum nugget, hilite_pet, runmode:walk, disclose:yi ya yv yg yc, noautopickup, nocmdassist, boulder:0'

export IGNOREEOF=1

joinstr() {
    local sep=$1
    shift
    [ $# -gt 0 ] || return
    local str=$1
    shift
    while [ $# -gt 0 ]; do
        str=$str$sep$1
        shift
    done
    echo "$str"
}

ansicolor() { printf '\e[%sm' $( joinstr ';' $@ ); }

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

NOBOLD=22
NOITALICS=23
NOUNDERLINE=24
NOINVERSE=27
NOSTRIKE=29

RESET=0

PS1="$(ansicolor $RESET)"
PS1+="${debian_chroot:+($debian_chroot)}"
PS1+="$(ansicolor $MAGENTA)\$(__git_ps1 '(%s) ')"
PS1+="$(ansicolor $BLUE)\w"
PS1+="\n"
PS1+="$(ansicolor $GREEN)\u@\h \t"
PS1+="$(ansicolor $RESET)\$"
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

echoerr() { echo $* 1>&2; }

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

HISTSIZE=2000
export EDITOR=vim

export DBIC_TRACE_PROFILE=console

ff() {
    ack -a -f | fgrep "$@" ;
}

ffu() {
    ff "$@" | uselect;
}

fx() {
    # eg. fx $command-and-args $ff-search-term
    # "${!#}"              == $ARGV[n-1]
    # "${@:1:$(($# - 1))}" == $ARGV[0..n-2]
    "${@:1:$(($# - 1))}" $( ff "${!#}" | uselect );
}

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
    type -t "$@" > /dev/null
}

if has mvim && ! has gvim; then
    gvim() { mvim "$@"; }
fi

# If gvim exists set up our gvim-in-tabs system

vs()  { find . -type f -iname '.*.sw?'; }
vsd() { find . -type f -iname '.*.sw?' -delete -exec echo Deleting {} ... \; ; }

yamldump() {
    perl -MData::Dumper::Concise -MYAML -e \
        'print qq("$_" =>\n), Dumper(YAML::LoadFile($_)) for @ARGV' $@
}

xmldump() {
    perl -MData::Dumper::Concise -MXML::Simple -e \
        'local $/;$x=<>; print Dumper(XMLin($x, ForceArray => ["entry"]));'
}

update-uselect() {
    local url=http://users.tpg.com.au/morepats/;
    local file=$(curl -s $url |\
                    egrep -o 'App-USelect-[0-9._]*.tar.gz' |\
                        tail -n 1);
    PERL_CPANM_OPT='' cpanm $url$file && unset -f uselect;
}

upload-tpg() {
    curl --user morepats ftp://users.tpg.com.au --upload-file "$@"
}

upload-uselect() {
    find . -name 'App-USelect*.tar.gz' | uselect | ixargs upload-tpg
}

# locate variants - only files or only dirs
flocate() {
    locate "$@" | perl -nlE 'say if -f'
}

dirlocate() {   # dlocate already exists
    locate "$@" | perl -nlE 'say if -d'
}

# ixargs is used similar to xargs, but works with interactive programs
ixargs() {
    # Read files from stdin into the $files array
    IFS=$'\n';
    set -f ;
    trap 'echo Or maybe not...' INT
    local files=( $(cat) )   # read files from stdin
    trap INT
    set +f ;
    IFS=$' \t\n'

    # Reopen stdin to /dev/tty so that interactive programs work properly
    exec 0</dev/tty

    # Run specified command with the files from stdin
    [ -n "$files" ] && $@ "${files[@]}"
}

evi() {
    echo vi $@
    vi "$@"
}

# Grep-and-Vi
gv() {
    ack --heading --break "$@" | uselect -s '!/^\d+[:-]/' | ixargs evi
}

# Find-and-Vi
fv() {
    ff "$@" | uselect | ixargs evi
}

fvi() { fv -i "$@"; }

# Locate-and-Vi
lv() {
    flocate "$@" | uselect | ixargs evi
}

# find-Perl-module-and-Vi
pv() {
    find $(perl -le 'pop @INC; print for @INC' | uniq) -type f -iname '*.pm' |\
            fgrep "$@" | uselect | ixargs evi;
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

export ACKRC="$HOME/.dotfiles/ackrc"

export INPUTRC="$HOME/.dotfiles/inputrc"

export SCREENRC="$HOME/.dotfiles/screenrc"

export CPAN_MINI_CONFIG="$HOME/.dotfiles/minicpanrc"
export CPAN_MINI_PATH=$(grep local: $CPAN_MINI_CONFIG | sed -e "s!^.*~!$HOME!")
if [ -e $CPAN_MINI_PATH/authors/01mailrc.txt.gz ]; then
    export PERL_CPANM_OPT="--mirror $CPAN_MINI_PATH --mirror-only"
fi

export SCR_IW_FG=W
export SCR_IW_BG=b
export SCR_AW_FG=k
export SCR_AW_BG=c
export SCR_FG=Y
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

relpath() {
    perl -MPath::Class=file,dir -E '$f=dir(shift)->absolute;$t=file(shift)->absolute;say $f->subsumes($t)?$t->relative($f):$t' "$@" ;
}

if [[ -n $TMUX ]]; then

    # Inside TMUX-only stuff

    tvim_running() { tmux lsp -F '#{pane_id}' | grep -q '^'$TVIM'$'; }

    # tvim [width]
    # - split a new tmux pane and start vim in it
    # - the pane id is stored in $TVIM
    tvim() {
        if [[ -n $TVIM ]] && tvim_running; then
            # TVIM already exists - try to select that pane
            tmux select-pane -t $TVIM && return

            # If we get here, that pane no longer exists, so fall thru
            # (shouldn't happen)
        fi

        local width=$1
        if [[ -z $width ]]; then
            # /dev/pts/0: 0 [364x89 xterm-color] (utf8)
            #                ^^^ width
            local scwidth=$(tmux lsc -t $TMUX_PANE |\
                egrep -o '[0-9]+x[0-9]+' | cut -d x -f 2 )
            if [[ $scwidth -ge 242 ]]; then
                width=2
            else
                width=1
            fi
        fi

        # Split a new pane, start vim in it, and record the pane index
        local tvim_pane=$(tmux split-window -P -h -l $[ 81 * $width - 1 ] 'exec vim')

        # Extract just the pane index from session:window.pane
        local tvim_index=$(echo $tvim_pane | cut -d . -f 2)

        # Now convert the pane index into a global persistent id
        # 1: [100x88] [history 0/10000, 0 bytes] %2
        # ^^ index                           id  ^^
        export TDIR="$PWD"
        export TVIM=$(tmux lsp | grep ^${tvim_index}: | grep -o '%[0-9]\+')
    }

    # invim [keystrokes...]
    # - sends keystrokes to the vim instance created by tvim
    # - if no vim instance exists, one is created
    # - keystroke syntax is the same as tmux send-keys
    invim() {
        ( [[ -n $TVIM ]] && tmux send-keys -t $TVIM escape ) || tvim
        tmux send-keys -t $TVIM escape
        tmux send-keys -t $TVIM "$@"
    }

    # gvim begone!
    unset -f vi
    vi() {
        [[ -n "$@" ]] || return; # do nothing if no files

        tvim
        for file in "$@"; do
            local newfile=$( relpath "$TDIR" "$file" )
            #echo $TDIR '+' $file '=>' $newfile
            invim :e space "${newfile// /\\ }" enter
        done
        tmux select-pane -t $TVIM
    }

    unset -f fv gv lv
    fv() {
        vi $( ff "$@" | uselect )
    }

    gv() {
        vi $( ack --heading --break "$@" | uselect -s '!/^\d+[:-]/' )
    }

    lv() {
        vi $( flocate "$@" | uselect )
    }

    pv() {
        vi $( find $(perl -le 'pop @INC; print for @INC' | sort -u ) \
                    -type f -iname '*.pm' | sort -u | fgrep "$@" | uselect )
    }

    reauth() {
        printenv SSH_AUTH_SOCK
        eval $( tmux show-environment | grep SSH_AUTH_SOCK )
        printenv SSH_AUTH_SOCK
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
                tmux attach-session -t $(unattached-tmux-sessions | uselect | cut -d: -f 1)
                ;;
        esac
    }

fi

mcd() { mkdir -p $1; cd $1; }

if has colordiff; then
    alias diff="colordiff -u"
else
    alias diff="diff -u"
fi

# Changes git remotes to be read-only url for fetch and read-write for push
fixgitremote() {
    local remote=${1:-origin}
    if ! ( git remote | grep -q ^$remote$ ) ; then
        echo "Remote $remote not found"
        git remote
        return 1
    fi

    remote_url() {
        git remote -v | grep ^$remote | grep -m 1 \($1\) | awk '{ print $2 }'
    }

    local push_url=$( \
        remote_url push |\
        sed -e 's#^git://\([^/]*\)/\(.*\)$#git@\1:\2#' \
    )
    local fetch_url=$(
        remote_url fetch |
        sed -e 's#^git@\([^:]*\):\([^/]*\)/\(.*\)#git://\1/\2/\3#'
    )

    # Can't seem to do set-url --fetch, so set them both to fetch url,
    # and then switch the push url back again.
    git remote set-url $remote $fetch_url
    git remote set-url --push $remote $push_url

    git remote -v show | grep $remote
}

# Git submodules helpers
crgit() {
    "$@"
    git submodule foreach --recursive "$@"
}

rgit() {
    crgit git "$@"
}

fixgitemail() {
    uselect sdt@dr.com stephent@strategicdata.com.au |\
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

# somewhat clunky attempt at using git with uselect
# eg. ugit diff
# eg. ugit add
# eg. ugit checkout --
# CAREFUL!
ugit () {
    git status -s | uselect | sed -e 's/^...//' | xargs git "$@"
}

# Difference between two file trees
#  difftree -q to show only the filenames
alias difftree="diff -x .git -r"

if has lesspipe; then
    eval $(lesspipe)
fi

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
    local ret=1
    pushd ~/.dotfiles > /dev/null
    if ! git diff --quiet --exit-code origin/master; then
        echo You have local changes. Sort those out and try again.
    else
        git fetch
        if git diff --quiet --exit-code origin/master; then
            echo Dotfiles up to date.
        else
            git merge origin/master
            rebash
            source install.sh
            ret=0
        fi
    fi
    popd > /dev/null
    return $ret
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

source_if ~/perl5/perlbrew/etc/bashrc
source_if ~/.dotfiles/bashrc.local
source ~/.dotfiles/tmux_colors.sh

if ismacos ; then
    source_if ~/.dotfiles/bashrc.macosx
fi

if ! ( has uselect ) ; then
    uselect() {
        if tty -s; then
            echoerr -n 'uselect not installed - '
            yes_or_NO 'install uselect' && update-uselect
        else
            echoerr 'uselect not installed - use update-uselect'
        fi
    }
fi
