#!/usr/bin/env bash
custom_run () {
        start_spinner "[!] Cloning oh-my-zsh"
        runuser -l  ${USER_NAME} -c "git clone https://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh &>/dev/null"
        stop_spinner $?

        start_spinner "[!] Cloning vim Vundle"
        runuser -l  ${USER_NAME} -c "git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim &>/dev/null"
        stop_spinner $?

        start_spinner "[!] Cloning dotfiles and setting up"
        runuser -l  ${USER_NAME} -c "git clone https://github.com/0x0BSoD/dotfiles.git ~/Projects/dotfiles &>/dev/null"
        runuser -l  ${USER_NAME} -c "cd ~/Projects/dotfiles; ./init.sh silent &>/dev/null"
        stop_spinner $?

        start_spinner "[!] Cloning vim zsh-autosuggestions"
        runuser -l  ${USER_NAME} -c "git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions &>/dev/null"
        stop_spinner $?

        start_spinner "[!] Cloning bumblebee-status"
        runuser -l  ${USER_NAME} -c "git clone git://github.com/tobi-wan-kenobi/bumblebee-status ~/.bumblebee-status &>/dev/null"
        stop_spinner $?

        start_spinner "[!] Pip packages"
        ln -s /usr/bin/gcc /usr/local/bin/gcc-4.2
        runuser -l  ${USER_NAME} -c "pip install --user i3ipc psutil netifaces  &>/dev/null"
        stop_spinner $?
}
