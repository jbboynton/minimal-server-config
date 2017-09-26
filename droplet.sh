#!/bin/bash

# Log the output of this script by redirecting stdout and stderr to a pipe
# running tee.
exec > >(tee -i ./setup.log)
exec 2>&1

# Color output in the terminal
fancy_echo() {
  local fmt="$1"; shift

  printf "\n$fmt\n" "$@"
}


# Bail if a nonzero exit code is returned.
msg="Something went wrong, check setup.log for more info."
trap 'ret=$?; test $ret -ne 0 && fancy_echo "$msg" >&2; exit $ret' EXIT
set -e

echo "Connected to the droplet."
echo "Creating a new user..."
if [ "$(id -u)" -eq 0 ]; then
  username="james"
  password="$(perl -e 'print crypt($ARGV[0], "teamvalue99")' 'teamvalue99')"
  useradd -m -p $password $username
else
	echo "Only root may add a user to the system"
	exit 1
fi

echo "Adding new user to groups..."
usermod -aG sudo,docker james

key="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCx0kXokmPb3lLecBB5bhhK4NjP16u1gtnuKTz9hDZ7mY39qmvG3Ou6uLlt+PJtSvkHNXAlOpYth2rfl43qB5w619n++8KpdvAnb9wsKFHwkLiwXR9N6vnwMjl2LKf+61zMdgPqfHEe7WIHLtm2K7czwW7YqOfv+g3PHit+VPYcRg/w6cT6tdNTqWpCv/Qez9wuO9ptfT8Qq0SlHycfo5IX4q3mcXfVK44rpoUAm+F3L5XYYUT1VIJ9ua3Qg71+BCrFCw2a+QqLrkTqiclSGGi5DmUuK51OH6CaJE6aYqoeEvWYn/CDMkP3cBwzPWlKOLYiPR1Vr/jmLlm5TbjPv2Ed computer14@computer14.fios-router.home"

echo "Setting up SSH for the new user..."
mkdir /home/james/.ssh
chmod 700 /home/james/.ssh
chown james:james /home/james/.ssh
echo "$key" >> /home/james/.ssh/authorized_keys
chmod 600 /home/james/.ssh/authorized_keys
chown james:james /home/james/.ssh/authorized_keys

# echo "Creating paths for dotfiles..."
# mkdir -p /home/james/dotfiles/zsh
# touch /home/james/dotfiles/zsh/aliases
# touch /home/james/dotfiles/zsh/functions
# touch /home/james/dotfiles/zsh/prompt
# touch /home/james/dotfiles/zsh/completion
# touch /home/james/.zshrc
# touch /home/james/.vimrc
# touch /home/james/.tmux.conf
# touch /home/james/.gitignore
#
# chown -R james:james /home/james/dotfiles
# chown james:james /home/james/.zshrc
# chown james:james /home/james/.vimrc
# chown james:james /home/james/.tmux.conf
# chown james:james /home/james/.gitignore


echo "Done. Closing SSH connection..."
exit
