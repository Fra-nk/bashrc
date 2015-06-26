#!/bin/bash

BASHRCDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

#general paths
if [ -d /cvmfs/sft.cern.ch ] && [ -d /cvmfs/cms.cern.ch ]; then
    #export ROOTSYS=/cvmfs/sft.cern.ch/lcg/app/releases/ROOT/5.34.13/x86_64-slc5-gcc46-opt/root/
    export ROOTSYS=/cvmfs/sft.cern.ch/lcg/app/releases/ROOT/5.34.13/x86_64-slc6-gcc48-opt/root/
    export GCCLIBS=/cvmfs/sft.cern.ch/lcg/external/gcc/4.7.2/x86_64-slc5/lib64/
    export VO_CMS_SW_DIR=/cvmfs/cms.cern.ch/
else
    [ "$TERM" != "dumb" ] && [ ! -z $ISLOGIN ] && echo "cvmfs not available!"
fi
export PATH=$BASHRCDIR/scripts:$PATH

# TERMINAL COLORS
[ -f "$BASHRCDIR/dir_colors" ] && eval `dircolors $BASHRCDIR/dir_colors` || eval `dircolors -b`

if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias dir='dir --color=auto'
    alias vdir='vdir --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# some more ls aliases
alias ll='ls -l'
alias llt='ll -t'
alias la='ls -A'
alias l='ls -CF'
# history
export HISTFILE=$HOME/.bash_history
export HISTFILESIZE=1000000
export HISTSIZE=100000
export HISTCONTROL=ignoreboth
shopt -s histappend
shopt -s checkwinsize

# This function is needed to display the current git branch in the bash prompt
function parse_git_branch_and_add_brackets {
  git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\ \[\1\]/'
}
if [ $HOSTNAME = "ekpcms6" ]; then
    export PS1HOSTCOLOR="1;33"
elif [ $HOSTNAME = "nafhh-cms01" ]; then
    export PS1HOSTCOLOR="1;36"
elif [[ $HOSTNAME == *cms03* ]]; then
    export PS1HOSTCOLOR="1;35"
else
    export PS1HOSTCOLOR="0;32"
fi
export PS1='\[\e[${PS1HOSTCOLOR}m\][$(date +%H:%M)] \h:\[\e[m\]\[\e[1;34m\]\w\[\e[m\]$(parse_git_branch_and_add_brackets) \[\e[1;32m\]\$\[\e[m\] \[\e[1;37m\]\[\033[00m\]'

# Set terminal title depending on host
if [[ $HOSTNAME == *ekpcms5* ]]; then
        STR="[5]"
elif [[ $HOSTNAME == *ekpcms6* ]]; then
        STR="[6]"
elif [[ $HOSTNAME == *naf* ]]; then
        STR="[NAF]"
elif [[ $HOSTNAME == *ekpsg01* ]]; then
        STR="[SG1]"
elif [[ $HOSTNAME == *lxplus* ]]; then
        STR="[LX]"
else
        STR=""
fi
export PROMPT_COMMAND='echo -ne "\033]0;${STR}${PWD/$HOME/~}\007"'


[ -f $BASHRCDIR/git-completion.bash ] && source $BASHRCDIR/git-completion.bash

# display mensa plan and list of PDG-IDs
alias mensa='curl http://mensa.akk.uni-karlsruhe.de/?DATUM=heute -s | w3m -dump -T text/html| head -n 56 | tail -n 49 | less -p 'Linie''
alias pdgid='curl http://www.physics.ox.ac.uk/CDF/Mphys/old/notes/pythia_codeListing.html -s | w3m -dump -T text/html | head -n 60 | tail -n 55| less'


export GREP_OPTIONS='--color=auto'

# qstat-like script with job summary for all users
myqstat()
{
echo -e "\n   User     Jobs     r   %\n------------------------------------------------------------"; qstat -u "*" -s prs | tail -n+3 | cut -c28-40 | sort | uniq -c | awk ' { t = $1; $1 = $2; $2 = t; print; } ' > /tmp/alljobs_${USER}.txt && qstat -u "*" -s r | tail -n+3 | cut -c28-40 | sort | uniq -c | awk ' { t = $1; $1 = $2; $2 = t; print; } ' > /tmp/rjobs_${USER}.txt && awk 'NR==FNR{a[$1]=$2;k[$1];next}{b[$1]=$2;k[$1]}END{for(x in k)printf"%s %d %d\n",x,a[x],b[x]}'  /tmp/alljobs_${USER}.txt /tmp/rjobs_${USER}.txt  | sort -k2 -n -r | awk -v len=$((`tput cols`-30)) '!max{max=$2;}{r="";i=s=len*($2-$3)/max;while(i-->0)r=r"\033[1;33m#\033[0m";q="";i=s=len*$3/max;while(i-->0)q=q"\033[0;32m#\033[0m";printf "%11s %5d %5d %3d%s %s%s%s",$1,$2,$3,($3/$2*100),"%",q,r,"\n";}' | grep -E "${USER}|$"
}

# special files for ekp, naf, user
if [[ $HOSTNAME == *ekp* ]]; then
    [ -f $BASHRCDIR/ekp.sh ] && source $BASHRCDIR/ekp.sh
elif [[ $HOSTNAME == *naf* ]]; then
    [ -f $BASHRCDIR/naf.sh ] && source $BASHRCDIR/naf.sh
fi
[ -f $BASHRCDIR/users/$USER.sh ] && source $BASHRCDIR/users/$USER.sh
[ -f /usr/users/berger/sw/ekpini.sh ] && source /usr/users/berger/sw/ekpini.sh sge

