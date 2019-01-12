#!/usr/bin/env bash
# Helpers ====================
red='\e[91m'
green='\e[92m'
blue='\e[96m'
def='\e[0m'

print_msg () {
    color=$1
    text=$2
    echo -e "${color}${text}${def}"
}

check_efi () {
    ls /sys/firmware/efi/efivars &>> /dev/null
    RC=$?
    if [[ ${RC} != 0 ]]
    then
        echo -e "Using BIOS"
    else
        echo -e "Using EFI"
        read -p "[?] Use EFI install? y/n: "  answer
        if [[ ${answer} == 'y' ]]
        then
            ${USE_EFI}=1
        else
            echo -e "Using BIOS for boot"
        fi
    fi
}

status_checker () {
    MSG_TEXT=$1
    RC=$2
    if [[ ${RC} != 0 ]]
    then
        echo -e "\e[91m${MSG_TEXT} Error\e[0m"
        exit $RC
    else
        echo -e "\e[90m${MSG_TEXT} OK\e[0m"
    fi
}

install_grub () {
    if [[ ${USE_EFI} == 0 ]]
    then
        start_spinner "[!] Installing EFI GRUB"
        pacman --noconfirm -S grub os-prober > /dev/null
        grub-install ${DISK} 1> /dev/null 2> /bootstrap/err.log
        grub-install --recheck ${DISK} 1> /dev/null 2> /bootstrap/err.log
        grub-mkconfig -o /boot/grub/grub.cfg 1> /dev/null 2> /bootstrap/err.log
        stop_spinner $?
    else
        start_spinner "[!] Installing EFI GRUB"
        pacman --noconfirm -S grub efibootmgr 1> /dev/null 2> /bootstrap/err.log
        grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=grub 1> /dev/null 2> /bootstrap/err.log
        grub-mkconfig -o /boot/grub/grub.cfg 1> /dev/null 2> /bootstrap/err.log
        stop_spinner $?
    fi
}

install_packages() {
    f="/bootstrap/package_list.txt"
    if [[ -r  ${f} ]]
    then
        set +eo pipefail
        while read line
        do
            if  echo ${line} | grep -vq "^#"
            then
                start_spinner "[!] Installing ${line}"
                pacman --noconfirm -S ${line} 1> /dev/null 2> /bootstrap/err.log
                stop_spinner $?
            fi
        done <"$f"
    else
        echo "package_list.txt not found"
        exit 1
    fi
    set -eo pipefail
}

install_aur_packages() {
    f="/bootstrap/aur_package_list.txt"
    if [[ -r  ${f} ]]
    then
        while IFS= read line
        do
            if  echo line | grep -vq "^#"
            then
#                start_spinner "[!] Installing ${line}"
                runuser -l  ${USER_NAME} -c "/opt/aur_helper/ah.py -a install ${line}"
#                stop_spinner $?
            fi
        done <"$f"
    else
        echo "aur_package_list.txt not found"
        exit 1
    fi
}
