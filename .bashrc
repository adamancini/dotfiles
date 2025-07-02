# Bash customisation file
#General configuration starts: stuff that you always want executed

export PATH=~/bin:$PATH
#export DRONE_SERVER='http://git.jbanetwork.com:8080'
#export DRONE_TOKEN='eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0ZXh0IjoiYWRhbWFuY2luaSIsInR5cGUiOiJ1c2VyIn0.aLKFZlOAOmJR5vh1_CKk9P1iuDCYC-6Pc9jJAXkxLO4'
#export ANSIBLE_INVENTORY=/etc/ansible/puppetdb-inventory.sh

[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

#General configuration ends

if [[ -n $PS1 ]]; then
    : # These are executed only for interactive shells
    #    echo "interactive"
    #if [ -z "$SSH_AUTH_SOCK"  ] ; then
    #  eval `ssh-agent -s`
    #  ssh-add ~/.ssh/jba_rsa
    #fi
    #source ~/ansible/hacking/env-setup -q

else
    : # Only for NON-interactive shells
fi

if shopt -q login_shell ; then
    : # These are executed only when it is a login shell
    # echo "login"
    settitle() {
      printf "\033k$1\033\\"
    }

    ssh() {
      settitle "$*"
      command ssh "$@"
      settitle "bash"
    }

else
    : # Only when it is NOT a login shell
    # echo "nonlogin"
fi

source ~/.bash_aliases

[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# Load direnv
eval "$(direnv hook bash)"
