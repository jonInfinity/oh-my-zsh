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

else

ZSH=$HOME/.oh-my-zsh
ZSH_THEME="jesus"
CASE_SENSITIVE="true"
DISABLE_AUTO_UPDATE="true"
# DISABLE_LS_COLORS="true"
# DISABLE_AUTO_TITLE="true"
DISABLE_CORRECTION="true"
# DISABLE_UNTRACKED_FILES_DIRTY="true"
plugins=(git gitfast)
. $ZSH/oh-my-zsh.sh

GPG_TTY=`tty`
export GPG_TTY
# Customize to your needs...
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

export COPYFILE_DISABLE=true
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
  mkdir -p ~/.ssh
  AKEY=~/.ssh/authorized_keys2
  if [ -e ~/.ssh/authorized_keys ]; then
    AKEY=~/.ssh/authorized_keys
  fi
  if [ ! -e $AKEY ]; then
    touch $AKEY
    chmod 644 $AKEY
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
