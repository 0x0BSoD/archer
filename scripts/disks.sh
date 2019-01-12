#!/usr/bin/env bash
get_disks () {
    DISKS="$(fdisk -l | grep "Disk /dev" | awk '{print "Path: "substr($2, 1, length($2)-1)" Size: "$3 substr($4, 1, length($4)-1)" Sectors: "$7'})"
    export SECTORS="$(fdisk -l | grep "Disk /dev" | awk '{print $7}')"
    readarray -t dskArr <<< ${DISKS}
    count=1

    for i in "${dskArr[@]}"; do
        echo -e "$count) $i";
        ((count++))
    done

    while true; do
        if [[ ${count} > 1 ]]
        then
            echo -e ""
            read -p  "[?] Select disk to install: " answer
        fi

        i=$((answer - 1))
        disk="${dskArr[$i]}"
        if [[ -z ${disk} ]]
        then
            echo -e "Wrong input, try again."
        else
            break
        fi
    done

    ds_arr=(${disk})

    # Global var ==================
    DISK_TO_INSTALL="${ds_arr[1]}"
    echo -e "Selected: ${DISK_TO_INSTALL}"
}