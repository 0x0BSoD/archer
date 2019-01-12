#!/bin/bash
set -eo pipefail

source /bootstrap/vars
source /bootstrap/helpers.sh
source /bootstrap/spinner.sh
source /bootstrap/customize_user_env.sh

print_msg ${red} "==> Resume System configuration"
print_msg ${red} "====================================="

print_msg ${red} "==> Making swap"
if [[ $SWAP == "s" ]]
then
    mkswap ${DISK}${SWAP_PART}
    swapon ${DISK}${SWAP_PART}
elif [[ ${SWAP} == "sf" ]]
then
    fallocate -l ${SWAP_SIZE} /swapfile
    chmod 600 /swapfile
    mkswap /swapfile
    if [[ ${SWAP_ON_SSD} == 1 ]]
    then
        swapon --discard /swapfile
    else
        swapon /swapfile
    fi
else
    echo "Ok"
fi

print_msg ${red} "====================================="
print_msg ${red} "==> Sed config files"
print_msg ${green} "==> Locales"
ln -sf /usr/share/zoneinfo/Europe/Moscow /etc/localtime
hwclock --systohc
sed -i -e 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
sed -i -e 's/#ru_RU.UTF-8 UTF-8/ru_RU.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
touch /etc/locale.conf
touch /etc/hostname 

print_msg ${green} "==> Setting hostname and hosts"
echo 'LANG="en_US.UTF-8"' > /etc/locale.conf
echo 'LC_ALL="en_US.UTF-8"' >> /etc/locale.conf
echo ${HOST_NAME} > /etc/hostname
echo "127.0.0.1	localhost.localdomain	localhost" > /etc/hosts
echo "::1		localhost.localdomain	localhost" >> /etc/hosts
echo "127.0.1.1	${HOST_NAME}.localdomain	${HOST_NAME}" >> /etc/hosts
print_msg ${red} "====================================="

print_msg ${green} "==> Installing GRUB"
install_grub
print_msg ${red} "====================================="

print_msg ${green} "==> Set Root password"
if [[ ${SILENT} == 0 ]]
then
    echo "Set root password: "
    passwd
else
    echo "root:123123" | chpasswd
fi
print_msg ${red} "====================================="

print_msg ${red} "==> Installing packages"
install_packages
print_msg ${red} "====================================="

print_msg ${red} "==> Set ${USER_NAME} password"
useradd -mG wheel ${USER_NAME}
echo '%wheel ALL=(ALL) NOPASSWD: ALL' | EDITOR='tee -a' visudo

if [[ ${SILENT} == 0 ]]
then
    echo "Set ${USER_NAME} password: "
    passwd ${USER_NAME}
else
    echo "${USER_NAME}:123123" | chpasswd
fi
print_msg ${red} "====================================="

print_msg ${red} "==> Installing AUR packages"
pip install tabulate
install_aur_packages
print_msg ${red} "====================================="

print_msg ${red} "==> Building ST"
cd /bootstrap/st
make
make install
print_msg ${red} "====================================="

print_msg ${red} "==> Change shell to ZSH"
chsh -s /bin/zsh ${USER_NAME}
print_msg ${red} "====================================="

print_msg ${red} "==> Enable DHCP"
addr=$(lspci | grep Ethernet | awk '{print $1}')
eth_dev=$(ls /sys/bus/pci/devices/0000:${addr}/net)
sed -i -e "s/Interface={{eth_dev}}/Interface=${eth_dev}/" /etc/netctl/dhcp
print_msg ${red} "====================================="

print_msg ${red} "==> Enabling services"
systemctl enable sshd
systemctl enable lightdm
netctl enable dhcp
print_msg ${red} "====================================="

print_msg ${red} "==> customize ${USER_NAME} env"
custom_run
print_msg ${red} "====================================="

print_msg ${green} "==> Second Part Complete"
print_msg ${red} "====================================="