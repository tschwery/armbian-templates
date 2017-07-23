#!/bin/sh

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

    sudo umount $MOUNTDIR
    rmdir $MOUNTDIR
}

build_image "20" "1"    "ceph-master" "Armbian_5.20_Orangepione_Debian_jessie_3.4.112.img"
build_image "20" "10"   "ceph-mon0"   "Armbian_5.20_Orangepione_Debian_jessie_3.4.112.img"

build_image "20" "100"  "ceph-osd0"   "Armbian_5.20_Bananapi_Debian_jessie_4.7.3.img"
build_image "20" "101"  "ceph-osd1"   "Armbian_5.20_Bananapi_Debian_jessie_4.7.3.img"
build_image "20" "102"  "ceph-osd2"   "Armbian_5.20_Bananapi_Debian_jessie_4.7.3.img"
build_image "20" "103"  "ceph-osd3"   "Armbian_5.20_Bananapi_Debian_jessie_4.7.3.img"
build_image "20" "104"  "ceph-osd4"   "Armbian_5.20_Bananapi_Debian_jessie_4.7.3.img"
