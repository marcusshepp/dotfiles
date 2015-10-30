
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git)

# User configuration

export PATH="/usr/local/heroku/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:/usr/local/munki"
# export MANPATH="/usr/local/man:$MANPATH"

source $ZSH/oh-my-zsh.sh

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/dsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
alias vpn="osascript ~/projects/tech-ops/scripts/vpn.applescript"
alias thetime='date +%H:%M:%S'

# vagrant
alias vst='vagrant status'
alias vup='vagrant up'
alias vhalt='vagrant halt'
alias vdest='vagrant destroy'
alias vre='vagrant reload'
alias vgs='vagrant global-status'
alias vremk='vagrant destroy && vagrant up'
alias boxes='cd ~/vagrant-novice/boxes'
alias killvms="for VM in `VBoxManage list runningvms | awk '{ print $2; }'`; do VBoxManage controlvm $VM poweroff; done"

alias prof='vim ~/.zshrc'
alias rc='vim ~/.bashrc'

alias c='clear'
alias cbash='source ~/.bash_profile'
alias cbashrc='source ~/.bashrc'
alias src='source ~/.zshrc'

alias ls='ls -FGlAhp'
alias la='ls -la'
alias ll='ls -R'
alias l1='ls -1'

alias f='open -a Finder ./'
alias h='history'

trash () { command mv "$@" ~/.Trash ; }
zipf () { zip -r "$1".zip "$1" ; }          # To create a ZIP archive of a folder
#   mans:   Search manpage given in agument '1' for term given in argument '2' (case insensitive)
#           displays paginated result with colored search terms and two lines surrounding each hit.             Example: mans mplayer codec
#   --------------------------------------------------------------------
    mans () {
        man $1 | grep -iC2 --color=always $2 | less
    }

alias du='du -kh'    # Makes a more readable output.
alias df='df -kTh'

# cd
alias .='cd ..'
alias ..='cd ../../'
alias ...='cd ../../../'
alias ....='cd ../../../../'
alias .....='cd ../../../../'
alias .3='cd ../../../'
alias .4='cd ../../../../'
alias .5='cd ../../../../..'

alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'
alias ports='netstat -tulanp'

#django
alias delmi='find . -name "0*" -delete' # deletes migration files
alias m='./manage.py'
alias rs='./manage.py runserver'
alias bootserver='echo "http://141.209.28.124:8000/"; ./manage.py runserver 0.0.0.0:8000'

# git
alias a='git add . && git status'
alias s='git status'
alias gfo='git fetch origin'
alias gco='git checkout'
alias psmaster='git push origin master'
alias plmaster='git pull origin master'


export WORKON_HOME=~/.virtualenvs
export PROJECT_HOME=$HOME/sheph2mj
source /usr/local/bin/virtualenvwrapper.sh
