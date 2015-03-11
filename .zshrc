DIRS="/opt/circonus/bin
/opt/omni/bin
/bin
/usr/bin
/sbin
/usr/sbin
/usr/local/bin
/usr/local/sbin
/usr/ccs/bin
/usr/proc/bin
/opt/gcc-4.8.1/bin
/opt/gcc-4.7.2/bin
/opt/gcc-4.6.3/bin
/opt/sunstudio12.1/bin
/opt/SUNWspro/bin
/opt/onbld/bin/i386
/opt/local/bin"

PATH=~/bin
echo $DIRS | while read dir; do
	if [[ -d $dir ]]; then
		PATH=$PATH:$dir
	fi
done
PATH=$PATH:.
export PATH

if [ ! -d ~/.oh-my-zsh ]; then

git clone https://github.com/postwait/oh-my-zsh.git .oh-my-zsh 2>/dev/null

if [ -r .oh-my-zsh/.zshrc ]; then
	(cd ~ && ln -fs .oh-my-zsh/.zshrc .zshrc)
	(cd ~ && ln -fs .oh-my-zsh/.bash_profile .bash_profile)
fi

if [[ -e .noco ]]; then
  umask 22
else
  umask 2
fi

EDITOR=${$(whence vim):-$(whence vi)}
export EDITOR
if [[ -n $(whence vim) ]]; then
  alias vi=vim
fi

# Setup out key bindings
bindkey -e
bindkey '^w' kill-region
WORDCHARS=${WORDCHARS//[=\/&.;]}
# Make my old csh habits not piss me off continually
setenv() { typeset -x "${1}${1:+=}${(@)argv[2,$#]}" }

setopt multios notify bash_auto_list auto_menu
setopt hist_find_no_dups hist_ignore_dups
setopt extended_history append_history
unsetopt auto_list

HISTFILE=$HOME/.zhist
SAVEHIST=500
HISTSIZE=500
watch=(all)
LOGCHECK=30
WATCHFMT='%n %a %l from %m at %t.'

# Setup out hosttags
HOSTTAG=$(hostname)" [set /etc/.hosttag]"
[[ -f /etc/.hosttag ]] && HOSTTAG=$(</etc/.hosttag)

if [[ $TERM == *xterm* ]]; then
  PROMPT="%{]2;$HOSTTAG%}%(!.#.;) "
else
  PROMPT="%(!.#.;) "
fi

[[ -f ~/.oracle_profile ]] && . ~/.oracle_profile

autoload -U compinit
compinit
if [[ -f $HOME/.ssh/known_hosts ]] then
  _myhosts=( ${${${${${(f)"$(<$HOME/.ssh/known_hosts)"}:#[0-9]*}%%\ *}%%,*}:#[0-9]*.[0-9]*.[0-9]*.[0-9]*} )
  zstyle ':completion:*:*:ssh:*:*' hosts $_myhosts
fi

psargs="x"
[[ `uname` == "SunOS" ]] && psargs="-fu$USER"
SSHAGENTENV="$HOME/.ssh_agent_env"
if [[ -z ${(M)$(ps $psargs):#ssh-agent} &&
      `id -u` != 0 &&
      ( -f $HOME/.ssh/id_dsa ||
        -f $HOME/.ssh/id_rsa ||
        -f $HOME/.ssh/identity ) ]] then
  ssh-agent | grep -v '^echo' > $SSHAGENTENV
fi
[[ -r $SSHAGENTENV ]] && . $SSHAGENTENV

growl() {
  echo -e $'\e]9;'${1}'\007'
}
else

# Path to your oh-my-zsh configuration.
ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME="jesus"

# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# Set to this to use case-sensitive completion
CASE_SENSITIVE="true"

# Comment this out to disable bi-weekly auto-update checks
DISABLE_AUTO_UPDATE="true"

# Uncomment to change how often before auto-updates occur? (in days)
# export UPDATE_ZSH_DAYS=13

# Uncomment following line if you want to disable colors in ls
# DISABLE_LS_COLORS="true"

# Uncomment following line if you want to disable autosetting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment following line if you want to disable command autocorrection
DISABLE_CORRECTION="true"

# Uncomment following line if you want red dots to be displayed while waiting for completion
# COMPLETION_WAITING_DOTS="true"

# Uncomment following line if you want to disable marking untracked files under
# VCS as dirty. This makes repository status check for large repositories much,
# much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
plugins=(git)

source $ZSH/oh-my-zsh.sh

GPG_TTY=`tty`
export GPG_TTY
# Customize to your needs...
fi

pushzshrc() {
  print "Pushing .zshrc to ${1}..."
	curl -s https://raw.githubusercontent.com/postwait/oh-my-zsh/master/.zshrc | \
    ssh ${1} "rm -f .zshrc; cat > .zshrc"
}
pushbash() {
  print "Pushing .bash_profile to ${1}..."
	curl -s https://raw.githubusercontent.com/postwait/oh-my-zsh/master/.bash_profile | \
    ssh ${1} "rm -f .bash_profile; cat > .bash_profile"
}
authids() {
  print "Integrating SSH identities..."
	AKEY=~/.ssh/authorized_keys2
	if [ -e ~/.ssh/authorized_keys ]; then
		AKEY=~/.ssh/authorized_keys
	fi
	for i in ~/.oh-my-zsh/pubkeys/*; do
		OUTPUT=`fgrep -v -f $AKEY $i`
		if [ -n "$OUTPUT" ]; then
			echo " <<< $i"
			echo $OUTPUT >> $AKEY
		fi
	done
}
renv() {
  pushzshrc ${1}
  pushbash ${1}
}
