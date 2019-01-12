#!/usr/bin/env bash
# store: pacman -Qe | awk '{print $1}' > package_list.txt
# install: for x in $(cat package_list.txt); do pacman -S $x; done
set -eo pipefail

source conf/def_params.sh
source scripts/argparser.sh
source scripts/helpers.sh
source scripts/disks.sh
source scripts/partitions.sh
source scripts/spinner.sh

print_msg ${green} "Arch bootstrapper by 0x0BSoD"
print_msg ${green} "====================================="

MKFS_FAT="mkfs.fat -F32"
if [[ ${SILENT} == 1 ]]
then
    source ${CONFIG_FILE}
    MKFS="mkfs.ext4 -F "
    part_target_disk_silent ${DISK_TO_INSTALL}
else
    MKFS="mkfs.ext4"
    read -p "[?] Enter hostname: "  HOST_NAME

    print_msg ${green} "Getting disks"
    get_disks
    print_msg ${green} "====================================="

    print_msg ${green} "Checking boot method"
    check_efi
    print_msg ${green} "====================================="

    print_msg ${green} "==> Start partitioning disk ${DISK_TO_INSTALL}"
    part_target_disk ${DISK_TO_INSTALL}
    print_msg ${green} "====================================="
fi

print_msg ${green} "==> Setting time synchronization"
timedatectl set-ntp true &>> /dev/null
timedatectl status &>> /dev/null
status_checker "Synchronization" $?
print_msg ${green} "====================================="

print_msg ${green} "==> Installing base packages"
start_spinner "Installing..."
pacstrap /mnt base > /dev/null
stop_spinner $?
status_checker "Installing base packages" $?
print_msg ${green} "====================================="

print_msg ${green} "==> Generate fstab"
genfstab -U /mnt > /mnt/etc/fstab
status_checker "Generate fstab" $?
print_msg ${green} "====================================="

print_msg ${green} "==> Prepare to chrooted part"
mkdir /mnt/bootstrap
cp ./scripts/helpers.sh /mnt/bootstrap/
cp ./scripts/spinner.sh /mnt/bootstrap/
cp ./scripts/second_part.sh /mnt/bootstrap/
cp ./scripts/customize_user_env.sh /mnt/bootstrap/
cp ./package_list.txt /mnt/bootstrap/
cp ./aur_package_list.txt /mnt/bootstrap/
# DHCP
cp ./conf/netctl/dhcp /mnt/etc/netctl/dhcp

print_msg ${green} "Write params to tmp file"
VARS_FILE="/mnt/bootstrap/vars"
touch ${VARS_FILE}
echo -e "HOST_NAME=${HOST_NAME}" >> ${VARS_FILE}
echo -e "USER_NAME=${USER_NAME}" >> ${VARS_FILE}
echo -e "DISK=${DISK_TO_INSTALL}" >> ${VARS_FILE}
echo -e "USE_EFI=${USE_EFI}" >> ${VARS_FILE}
echo -e "SILENT=${SILENT}" >> ${VARS_FILE}
echo -e "SWAP=${SWAP}" >> ${VARS_FILE}
echo -e "SWAP_SIZE=${SWAP_SIZE}" >> ${VARS_FILE}
echo -e "SWAP_PART=${SWAP_PART}" >> ${VARS_FILE}
echo -e "SWAP_ON_SSD=${SWAP_ON_SSD}" >> ${VARS_FILE}
print_msg ${green} "====================================="

print_msg ${green} "==> Copy skel"
cp -R ./skel /mnt/etc/
print_msg ${green} "====================================="

print_msg ${green} "==> Copy AUR helper"
cp -R ./utils/aur_helper /mnt/opt/
print_msg ${green} "====================================="

print_msg ${green} "==> Copy ST"
cp -R ./src/st /mnt/bootstrap/
print_msg ${green} "====================================="

print_msg ${green} "==> Making chroot"
arch-chroot /mnt bash -c /bootstrap/second_part.sh
print_msg ${green} "====================================="

print_msg ${green} "==> Cleaning"
# rm -Rf /mnt/bootstrap
umount -Rl /mnt

print_msg ${green} "==> All Done!! Eject installation media and reboot"


read -p "[?] Reboot? y/n: "  answer
if [[ ${answer} == 'y' ]]
then
    reboot
fi

exit 0
