#!/bin/bash
part_target_disk_silent () {
    DISK=$1
    OIFS="$IFS"
    IFS='/'

    read -a device <<< "${DISK}"
    SECTOR="$(cat /sys/block/${device[2]}/queue/hw_sector_size)"
    IFS="$OIFS"

    # Better ensure ist the right disk
    print_msg ${green} "FDISK"
    print_msg ${green} "====================================="

    fdisk ${DISK}
    print_msg ${green} "Make sfdisk dump"
    print_msg ${green} "====================================="
    sfdisk -d ${DISK} > conf/sda.sfdisk

    print_msg ${blue} "==> Making partitions"
    if [[ ${PARTITIONING} == fdisk ]]
    then
        fdisk ${DISK}
    else
        sfdisk ${DISK} < $SF_LAYOUT
    fi
    print_msg ${blue}  "====================================================="

    mkfs_hlp

    if [[ ${SINGLE_PARTITION} == 0 ]]
    then
        print_msg ${blue}  "==> Mounting root partition"
        for i in "${PARTITIONS[@]}"
        do
            arr=(${i//;/ })
            if [[ ${arr[0]} == "/" ]]
            then
                mount ${DISK}${arr[1]} /mnt
                print_msg ${blue}  "mount ${DISK}${arr[1]} /mnt"
            fi
        done
        print_msg ${blue}  "====================================================="

        print_msg ${blue}  "==> Mounting partition"
        for i in "${PARTITIONS[@]}"
        do
            arr=(${i//;/ })
            if [[ ${arr[0]} != "/" ]]
            then
                mkdir /mnt/${arr[0]}
                mount ${DISK}${arr[1]} /mnt${arr[0]}
                print_msg ${blue} "mount ${DISK}${arr[1]} /mnt${arr[0]}"
            fi
        done
        print_msg ${blue}  "====================================================="

    else
        d=0
        ${MKFS} ${DISK}${d}
        mount ${DISK}${d} /mnt/
    fi

}

part_target_disk () {
    DISK=$1
    OIFS="$IFS"
    IFS='/'

    read -a device <<< "${DISK}"
    SECTOR="$(cat /sys/block${device[2]}/queue/hw_sector_size)"
    IFS="$OIFS"

    read -p "[?] Use 1)fdisk 2)layout for sfdisk install "  answer
    if [[ ${answer} == '1' ]]
    then
        fdisk ${DISK}
    elif [[ ${answer} == '2' ]]
    then
        read -p "[?] Path to layout: "  path

        if [[ -r ${path} ]]
        then
            sfdisk ${DISK} < path
        else
            echo "File not exist"
        fi

    else
        echo "Wrong input."
    fi

    mkfs_hlp

    read -p "[?] Create dirs for mounting and mount? y/n "  answer
    if [[ ${answer} == 'y' ]]
    then
        read -e -p "[?] Drive num for root: "  num
        mount ${DISK}${num} /mnt/

        mkdir /mnt/boot
        mkdir /mnt/home

        read -e -p "[?] Drive num for boot: "  num
        mount ${DISK}${num} /mnt/boot

        read -e -p "[?] Drive num for home: "  num
        mount ${DISK}${num} /mnt/home
    else
        echo "whops"
        exit
    fi
}

mkfs_hlp () {
    FIRST="1"
    print_msg ${blue}  "==> Making fs systems"
    if [[ ${USE_EFI} == 0 ]]
    then
        PART_COUNT=$(("$(fdisk -l ${DISK} | grep /dev/ | wc -l)" - 1))
        for d in $(seq 1 ${PART_COUNT}); do
            ${MKFS} ${DISK}${d} 1> /dev/null
        done
    else
        PART_COUNT=$(("$(fdisk -l ${DISK} | grep /dev/ | wc -l)" - 2))
        print_msg ${blue}  "==> Format ${DISK}${FIRST} to FAT32 "
        ${MKFS_FAT} ${DISK}${FIRST} 1> /dev/null
        for d in $(seq 2 ${PART_COUNT}); do
            ${MKFS} ${DISK}${d} 1> /dev/null
        done
    fi
    print_msg ${blue}  "====================================================="
}

# TODO add layout generator for sfdisk
# echo "Sector size: $SECTOR bytes, overall sectors: $SECTORS"

# $NEED_SIZE * 1024 * 1024 / $SECTOR == MB
# $NEED_SIZE * 1024 * 1024 * 1024 / $SECTOR == GB