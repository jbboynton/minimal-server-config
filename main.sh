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

echo "Connected to the droplet again, in main.sh."
echo "Getting elevated privileges..."
echo "root ALL = NOPASSWD:ALL" >> /etc/sudoers
echo "Installing zsh..."
sudo apt update
sudo apt install -y zsh zsh-doc zsh-syntax-highlighting

echo "Setting zsh as the default shell..."
sudo chsh -s /bin/zsh james

echo "Installing tmux v2.5 and a couple dependencies..."
sudo apt update
sudo apt install -y autogen automake libevent-2.0-5 libevent-dev libncurses5 libncursesw5 libncurses5-dev libncursesw5-dev
cd /opt
sudo wget https://github.com/tmux/tmux/releases/download/2.5/tmux-2.5.tar.gz
sudo tar -xzvf tmux-2.5.tar.gz
sudo rm tmux-2.5.tar.gz
cd tmux-2.5
sudo ./configure && make
sudo make install
echo "Done installing tmux, revoking permissions..."
sed -i '$d' /etc/sudoers

echo "Done, closing connection."
exit
