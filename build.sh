#!/bin/bash

mkdir -p output

build_image() {
    NETWORK="$1"
    SUFFIX="$2"
    HOST="$3"
    IMAGE="$4"
    
    echo "Building the $HOST image from $IMAGE"

    pv armbian/$IMAGE > output/image-$HOST

    MOUNTDIR=$(mktemp -p . -d)
    sudo mount -o loop,offset=1048576 output/image-$HOST $MOUNTDIR

    cat templates/hostname   | IP=10.42.$NETWORK.$SUFFIX CLIENT=$HOST    ./mo | sudo tee $MOUNTDIR/etc/hostname              >/dev/null
    cat templates/hosts      | IP=10.42.$NETWORK.$SUFFIX CLIENT=$HOST    ./mo | sudo tee  $MOUNTDIR/etc/hosts                >/dev/null
    cat templates/interfaces | IP=10.42.$NETWORK.$SUFFIX CLIENT=$HOST    ./mo | sudo tee  $MOUNTDIR/etc/network/interfaces   >/dev/null

    sudo mkdir $MOUNTDIR/root/.ssh/
    cat ~/.ssh/id_*.pub | sudo tee -a $MOUNTDIR/root/.ssh/authorized_keys >/dev/null

    sudo rm $MOUNTDIR/root/.not_logged_in_yet
    days=$(($(date --utc --date "$1" +%s)/86400))
    sudo sed -ri 's/^(([^:]*:){2})0([^:]*)/\1'$days'\3/' $MOUNTDIR/etc/shadow 

    sudo umount $MOUNTDIR
    rmdir $MOUNTDIR
}

#build_image "20" "1"    "ceph-master" "Armbian_5.20_Orangepione_Debian_jessie_3.4.112.img"
#build_image "20" "10"   "ceph-mon0"   "Armbian_5.20_Orangepione_Debian_jessie_3.4.112.img"

build_image "20" "100"  "test0"   "Armbian_5.31_Bananapi_Debian_jessie_next_4.11.5.img"
build_image "20" "101"  "test1"   "Armbian_5.31_Bananapi_Debian_jessie_next_4.11.5.img"
build_image "20" "102"  "test2"   "Armbian_5.31_Bananapi_Debian_jessie_next_4.11.5.img"
build_image "20" "103"  "test3"   "Armbian_5.31_Bananapi_Debian_jessie_next_4.11.5.img"
build_image "20" "104"  "test4"   "Armbian_5.31_Bananapi_Debian_jessie_next_4.11.5.img"
