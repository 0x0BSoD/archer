# Arch bootstrapper by 0x0BSoD

You may use fdisk for or sfdisk for partitioning.

Link to tar.gz: https://github.com/0x0BSoD/archer/releases/download/1.0/archer.tar.gz

```bash
wget https://github.com/0x0BSoD/archer/releases/download/1.0/archer.tar.gz && tar -xzvf archer.tar.gz
cd build
./run.sh -f params
```

Layout example:
```
label:dos
label-id:0x1df0f4b1
device:/dev/sda
unit:sectors

/dev/sda1:start=2048,size=409600,type=83
/dev/sda2:start=411648,size=16777216,type=83
/dev/sda3:start=17188864,size=104857600,type=83
/dev/sda4:start=122046464,size=815656624,type=83
```

Parameters example for non interactive install:

```bash
HOST_NAME="Test_pc"
IP="STATIC" # DHCP | STATIC
# if STATIC
ADDR=192.168.1.2
NETMASK=255.255.255.0
GATEWAY=192.168.1.1
DNS-NAMESERVERS=192.168.1.1

DISK_TO_INSTALL="/dev/sda"
USE_EFI=0
PARTITIONING="sfdisk" # fdisk | sfdisk
# if sfdisk
SF_LAYOUT="sda.sfdisk"

SWAP=0 # 0 | s | sf
# if s - swap partition
SWAP_PART=4 # sda2 i.e
# if sf - swap file placed on root (/swapfile)
SWAP_SIZE=200M # M - Mebibytes, G - Gibibytes
SWAP_ON_SSD=0 # 0 | 1

SINGLE_PARTITION=0 # 0 | 1
# if 0
PARTITIONS=('/boot;1' '/;2' '/home;3') # 'path;num Y on sdXY'

ROOT_PASSWORD="123123123"
```
