export VIRTUALENVWRAPPER_PYTHON=/usr/local/bin/python
export VIRTUALENVWRAPPER_VIRTUALENV=/usr/local/bin/virtualenv
source /usr/local/bin/virtualenvwrapper.sh

alias ls='ls -la'

alias prof='vim ~/.bash_profile'
alias rc='vim ~/.bashrc'

alias c='clear && cd ~'
alias t='touch'

# notebook
alias nb="workon notebook && ipython notebook"

# git
alias s='git status'
alias gpom='git push origin master'
alias plmaster='git pull origin master'
add(){
    git add .;
    git status;
    echo "http://www.emoji-cheat-sheet.com/";
}

# restart
alias cbash='source ~/.bash_profile'
alias cbashrc='source ~/.bashrc'

# django
alias m='python manage.py'
alias bootserver='echo "https://40.130.148.7:8000" && python manage.py runserver 0.0.0.0:8000'
alias rs='./manage.py runserver'
alias delmi='rm -rf *.pyc'

alias ld='ls -FGlAhp'
alias lss='ls -la *'
alias ll='ls -h'
alias lk='ls -1'
alias a='&&'

alias f='open -a Finder ./'


## functions

mkmanagementcommand(){
    mkdir $1/management;
    touch $1/__init__.py;
    mkdir $1/management/commands;
    touch $1/management/commands/__init__.py;
    touch $1/management/commands/$2.py;
}
