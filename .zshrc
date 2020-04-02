DIRS="/home/jesus/bin
/home/jesus/src/go/bin
/opt/circonus/bin
/opt/omni/bin
/bin
/usr/bin
/sbin
/usr/sbin
/usr/local/bin
/usr/local/sbin
/usr/ccs/bin
/usr/proc/bin
/opt/llvm-5.0.0/bin
/opt/gcc-4.8.1/bin
/opt/gcc-4.7.2/bin
/opt/gcc-4.6.3/bin
/opt/circonus/go/bin
/opt/onbld/bin/i386
/usr/local/go/bin
/opt/local/bin"

PATH=~/bin
echo $DIRS | while read dir; do
	if [[ -d $dir ]]; then
		PATH=$PATH:$dir
	fi
done
PATH=$PATH:.
export PATH
export GOPATH=$HOME/src/go

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

if [ -n "$SSH_AUTH_SOCK" ]; then
	ssh-add -l >/dev/null 2>&1
	if [ "0" -ne "$?" ]; then
		echo "ssh-agent not working, clearing."
		unset SSH_AUTH_SOCK
	fi
fi
# OMG a mess
#
# On Window under WSL...
# We use WinCrypt SSH Agent to expose the Yubikey as pagent and over
# openssh-style auth sockets at $WINCRYPTSOCK.. however, WSL1 can
# connect to such a socket on the host, but WSL2 cannot.
# For WSL1, we will use it directly, but for WSL2 we need to use
# the weasel-pageant assist that will map it in other ways.
WINCRYPTSOCK=/mnt/c/Users/jesus/wincrypt-wsl.sock
WEASEL="/mnt/c/Program Files/weasel-pageant-1.4/weasel-pageant"
# We detect WSL2 b/c WSL1 does not have / mounted as ext4
WSL2=`mount -l -t ext4 | awk '{if($3 == "/"){print $1;}}'`
if [ -z "$SSH_AUTH_SOCK" ]; then
	if [ -e "$WINCRYPTSOCK" ]; then
		if [ -z "$WSL2" ]; then
			# Windows WinCryptSSHAgent
			export SSH_AUTH_SOCK=$WINCRYPTSOCK
		elif [ -x "$WEASEL" ]; then
			# Potentially WSL1
			if [ -e ~/.ssh_weasel ]; then
				source ~/.ssh_weasel
			fi
			WPID=`pgrep weasel-pageant`
			if [ "$WPID" -lt "1" -o "$WPID" != "$SSH_PAGEANT_PID" ]; then
				unset SSH_PAGENT_PID
				unset SSH_AUTH_SOCK
				rm -f ~/.ssh_weasel
			fi
			if [ -z "$SSH_AUTH_SOCK" ]; then
				$WEASEL | grep -v echo > ~/.ssh_weasel
				source ~/.ssh_weasel
			fi
		else
			echo "Appear to be on WSL2, no $WEASEL"
		fi
	fi
fi

if [[ -z "$SSH_AUTH_SOCK" ]]; then
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
fi

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
