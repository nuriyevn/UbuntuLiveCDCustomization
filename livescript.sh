#!/bin/bash
#echo "Warning! If you run this script from root you should stop. It might be dangerous Press anything to continue or Ctrl + C to stop"
#read answer

SCRIPT=`realpath $0`
SCRIPTPATH=`dirname $SCRIPT`
#echo "$SCRIPT"
#echo "$SCRIPTPATH"
SECONDSCRIPT="part2_chroot.sh"
THIRDSCRIPT="part3_chroot.sh"   

INPUT_ISO="ubuntu-16.04.7-desktop-amd64.iso"
OUTPUT_ISO="custom-12-16-cores-16.04.7-desktop-amd64.iso"
OUTPUT_ISO_LABEL="My Ubuntu 12-16 cores-16.04"
MNT="mnt"
EXTRACT_CD="extract-cd"
squashfile="casper/filesystem.squashfs"
squashmanifest="casper/filesystem.manifest"
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
echo "Are you sure to remove $OUTPUT_ISO ? y/n"
read answer
if [ "$answer" == "y" ]; then
	sudo rm -f "$OUTPUT_ISO"
else
	echo "Exiting."
	exit 1
fi


echo "----PREPARING A BLANK NEW EDIT----"
echo "Creating new folder for mount point $MNT"
mkdir "$MNT"
echo "Actually mounting $INPUT_ISO to $MNT mounting point"
sudo mount -o loop "$INPUT_ISO" "$MNT"
echo "Creating and extracting folder($EXTRACT_CD) for the actual desktop OS files"
mkdir "$EXTRACT_CD"
echo "Copying a single squash file for further unsquashing"
sudo rsync --exclude="/$squashfile" -a "$MNT/" "$EXTRACT_CD"
sudo unsquashfs "$MNT/$squashfile"
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

echo "Copying second script $SECONDSCRIPT to execute inside of chroot folder $EDIT"
sudo cp -P "$SECONDSCRIPT" "$EDIT/"
#ls "$EDIT"
echo "Copying third script $THIRDSCRIPT to execute inside of chroot folder $EDIT"
sudo cp -P "$THIRDSCRIPT" "$EDIT/"




echo "Copying additional crontab files commands"
sudo cp -P per_minute "$EDIT/"
sudo cp -P start_miner.sh "$EDIT/"


echo "Copying boot options configuration to automatically load  try ubuntu option "
sudo cp -P isolinux.cfg "$EXTRACT_CD/isolinux/isolinux.cfg"
sudo chmod 777 "$EXTRACT_CD/isolinux/isolinux.cfg"

echo "Immersing into to chroot..."
sudo chroot "$EDIT/" "./$SECONDSCRIPT"


echo "----Back on the first script----FINALIZATION-----"

#echo "Continue?"
#read continue

echo "Generating manifest: information about packages"
#sudo su
sudo chmod +w "$EXTRACT_CD/$squashmanifest"
sudo chroot "$EDIT/" "./$THIRDSCRIPT"
#su $USER

echo "Copying manifest from $EDIT to $EXTRACT_CD/casper, removing temporary file"
sudo cp "$EDIT/tmp.filesystem.manifest" "$EXTRACT_CD/$squashmanifest"
sudo rm -f "$EDIT/tmp.filesystem.manifest"


echo "Making new squash filesystem based of $EXTRACT_CD files desktop bundle and manifest"
#echo "Continue?"
#read continue

sudo cp "$EXTRACT_CD/$squashmanifest" "$EXTRACT_CD/$squashmanifest-desktop"
sudo sed -i '/ubiquity/d' "$EXTRACT_CD/$squashmanifest-desktop"
sudo sed -i '/casper/d' "$EXTRACT_CD/$squashmanifest-desktop"

echo "We have excluded $EXTRACT_CD/$squashfile during extraction, removing if it exsists, it should say error because file not found, that's what we need, we will create it now."
sudo rm "$EXTRACT_CD/$squashfile"
sudo mksquashfs "$EDIT" "$EXTRACT_CD/$squashfile" -b 4096
#sudo su
printf $(du -sx --block-size=1 edit | cut -f1) > "$EXTRACT_CD/casper/filesystem.size"
#exit

echo "Making iso filesystem"

#echo "Continue?"
#read continue

cd "$EXTRACT_CD"
sudo rm md5sum.txt
find -type f -print0 | sudo xargs -0 md5sum | grep -v isolinux/boot.cat | sudo tee md5sum.txt
sudo mkisofs -D -r -V "$OUTPUT_ISO_LABEL" -cache-inodes -J -l -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -o "../$OUTPUT_ISO" .

#echo "Continue?"
#read continue

echo "ISO 9660 filesystems created by the mkisofs command as described in the ISOLINUX article will boot via BIOS firmware, but only from optical media like CD, DVD, or BD.
The isohybrid feature enhances such filesystems by a Master Boot Record (MBR) for booting via BIOS from disk storage devices like USB flash drives."
cd ..
sudo isohybrid "$OUTPUT_ISO"


echo "Starting a program which can flash final result to the media, just navigate to the $OUTPUT_ISO file and pick up the flash media drive among the list"
sudo usb-creator-gtk

sudo umount "$MNT"
