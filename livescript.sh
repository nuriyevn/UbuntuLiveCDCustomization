#!/bin/bash
#echo "Warning! If you run this script from root you should stop. Press anything to continue or Ctrl + C to stop"
#read answer


SCRIPT=`realpath $0`
SCRIPTPATH=`dirname $SCRIPT`
echo "$SCRIPT"
echo "$SCRIPTPATH"
SECONDSCRIPT="part2_chroot.sh"


INPUT_ISO="ubuntu-16.04.7-desktop-amd64.iso"
MNT="mnt"
EXTRACT_CD="extract-cd"
squashfile="/casper/filesystem.squashfs"
squashfs_root="squashfs-root"
EDIT="edit"

echo "----INITIALIZING----"
echo "Unmounting $INPUT_ISO $MNT"
sudo umount "$SCRIPTPATH/$MNT"
echo "unmounting $EDIT/run and $EDIT/dev"
sudo umount "$EDIT/run"
sudo umount "$EDIT/dev"
echo "Removing $MNT $EDIT $EXTRACT_CD and $squashfs_root folders..."
sudo rm -rf "$MNT" "$EDIT" "$EXTRACT_CD" "$squashfs_root"


echo "----PREPARING A BLANK NEW EDIT----"
echo "Creating new folder for mount point $MNT"
mkdir "$MNT"
echo "Actually mounting $INPUT_ISO to $MNT mounting point"
sudo mount -o loop "$INPUT_ISO" "$MNT"
echo "Creating and extracting folder($EXTRACT_CD) for the actual desktop OS files"
mkdir "$EXTRACT_CD"
echo "Copying a single squash file for further unsquashing"
sudo rsync --exclude="$squashfile" -a "$MNT/" "$EXTRACT_CD"
sudo unsquashfs "$MNT$squashfile"
echo "Renaming $squashfs_root, the root of desktop system to $EDIT"
mv "$squashfs_root" "$EDIT"


echo "----DEALING WITH THE INTERNET CONNECTION----"
echo "Copying resolv.conf file from host to $EDIT/etc folder"
sudo cp /etc/resolv.conf "$EDIT/etc/"
echo "Duplicate step: creating a new directory($EDIT/etc/resolvconf) for resolv.conf if not exists"
echo "and copying resolv.conf there "
mkdir -p "$EDIT/etc/resolvconf/"
sudo cp /etc/resolv.conf "$EDIT/etc/resolvconf/"

echo "----MOUNTING FOR FURTHER CHROOT----"
#echo "Mounting /run/ to $EDIT/run"
#sudo mount -o bind /run/ "$EDIT/run"
echo "Mounting /dev/ to $EDIT/dev"
sudo mount --bind /dev/ "$EDIT/dev"

echo "Copying second script $SECONDSCRIP to execute inside of chroot folder $EDIT"
sudo cp -P "$SECONDSCRIPT" "$EDIT/"
ls "$EDIT"

echo "Copying additional crontab files commands which will be executed twice"
sudo cp -P r12_per_minute "$EDIT/"
sudo cp -P r16_per_minute "$EDIT/"


echo "Immersing into to chroot..."
sudo chroot "$EDIT/" "./$SECONDSCRIPT"
