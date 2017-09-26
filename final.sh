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

echo "Connected to the droplet again."
echo "Installing Vundle..."
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
/usr/bin/vim +PluginInstall +qall

echo "Make sure everything is up-to-date and reboot the droplet."
sudo apt update
sudo apt upgrade -y
sleep 20
sudo reboot
