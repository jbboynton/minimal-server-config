#!/bin/bash

# Table of Contents
# -----------------
#
# first update sshconfig with dev@IP address
#
# (config file)
#   line 1: public key
#     - digitalocean_pub_key
#   line 2: IP address of server
#   line 3: ssh config hostname
#
# I. Droplet configuration
#   A. Connect to the server
#     - ssh root@$IP -specify pass < script-below.sh
#     ----------------------------- new script, 
#   B. Create a new user
#     - james
#   C. Add new user to groups
#     - docker, sudo
#   D. Set up SSH for new user
#     - su - james
#     - mkdir .ssh
#     - chmod
#     - add pubkey from config file to authorized_keys
#     - chmod authoized keys
#   E. exit
#   ------------------------ end script
#
# II. Shell configuration
#   A. Connect to the server
#     - ssh newdroplet < setup.sh
#   B. Install zsh
#     - sudo apt update
#     - sudo apt install -y zsh zsh-doc zsh-syntax-highlighting
#   C. Set as default shell
#     - chsh -s /bin/zsh
#
# III. Install tools
#   A. Install tmux
#     - sudo apt update
#     - sudo apt install autogen automake libevent libevent-dev libncurses5 libncursesw5 libncurses5-dev libncursesw5-dev
#     - cd /opt
#     - sudo wget https://github.com/tmux/tmux/releases/download/2.5/tmux-2.5.tar.gz
#     - sudo tar -xzcf tmux-2.5.tar.gz
#     - sudo rm tmux-2.5.tar.gz
#     - cd tmux-2.5
#     - sudo ./configure && make
#     - sudo make install
#     - cd ~
#
# IV. Configure dotfiles
#   A. Rsync dotfiles
#     - rsync -a ./dotfiles/dotfiles newdroplet:dotfiles
#     - rsync -a ./dotfiles/zsh newdroplet:.zshrc
#     - rsync -a ./dotfiles/vim newdroplet:.vimrc
#     - rsync -a ./dotfiles/tmux newdroplet:.tmux.conf
#     - rsync -a ./dotfiles/git newdroplet:.gitconfig
#
# V. Configure vim
#   A. Install Vundle
#     - git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
#     - vim +PluginInstall +qall
#
# VI. Upgrade and reboot
#   A. Upgrade
#     - sudo apt update
#     - sudo apt upgrade -y
#     - sleep 20
#     - sudo reboot
#

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

fancy_echo "Reading the config file and setting state..."
if [ -e "./config" ]; then
  while IFS='' read -r line || [[ -n $line ]]; do
    config_array+=("${line}")
  done < "./config"
  echo "Successfully read the config file."
else
  printf "Didn't find a config file.\n\nExiting...\n"
fi

ip=${config_array[0]}
host=${config_array[1]}
fancy_echo "Done setting state, ready to configure the server."

fancy_echo "Prevent UFW from rate limiting SSH connections..."
ssh -i ~/.ssh/id_rsa_xzito_digitalocean root@$ip 'ufw allow ssh'

fancy_echo "Configuring the droplet..."
ssh -i ~/.ssh/id_rsa_xzito_digitalocean root@$ip 'bash -s' < ./droplet.sh
fancy_echo "Droplet configured.\n"

fancy_echo "Running the main setup script..."
# ssh $host 'bash -s' < ./main.sh
ssh -i ~/.ssh/id_rsa_xzito_digitalocean root@$ip 'bash -s' < ./main.sh
fancy_echo "All software installed."

fancy_echo "Syncing the dotfiles..."
rsync -auv $PWD/dotfiles/dotfiles/ $host:/home/james/dotfiles/
rsync -auv $PWD/dotfiles/.zshrc $host:/home/james/
rsync -auv $PWD/dotfiles/.vimrc $host:/home/james/
rsync -auv $PWD/dotfiles/.tmux.conf $host:/home/james/
rsync -auv $PWD/dotfiles/.gitconfig $host:/home/james/
fancy_echo "Dotfiles sunk."

fancy_echo "Just need to tweak some Vim stuff and update the system..."
ssh $host 'bash -s' < ./final.sh

fancy_echo "Tell UFW to rate limit SSH connections, now that we're done..."
ssh -i ~/.ssh/id_rsa_xzito_digitalocean root@$ip 'ufw limit ssh'

fancy_echo "Everything's all set. Your automated self says \"you\'re welcome.\""

