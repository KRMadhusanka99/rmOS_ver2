#!/bin/sh

# This script assembles the rmOS bootloader, kernel and programs
# with NASM, and then creates floppy and CD images (on Linux)



if test "`whoami`" != "root" ; then
	echo "You must be logged in as root to build (for loopback mounting)"
	echo "Enter 'su' or 'sudo bash' to switch to root"
	exit
fi


if [ ! -e disk_img/rmOS.flp ]
then
	echo ">>> Creating new rmOS floppy image..."
	mkdosfs -C disk_img/rmOS.flp 1440 || exit
fi


echo ">>> Assembling bootloader..."

nasm -O0 -w+orphan-labels -f bin -o bootloader.bin bootloader.asm || exit


echo ">>> Assembling MikeOS kernel..."


nasm -O0 -w+orphan-labels -f bin -o kernel.bin kernel.asm || exit



echo ">>> Assembling programs..."





echo ">>> Adding bootloader to floppy image..."

dd status=noxfer conv=notrunc if=bootloader.bin of=disk_img/rmOS.flp || exit


echo ">>> Copying MikeOS kernel and programs..."

rm -rf tmp-loop

mkdir tmp-loop && mount -o loop -t vfat disk_img/rmOS.flp tmp-loop && cp kernel.bin tmp-loop/



sleep 0.2

echo ">>> Unmounting loopback floppy..."

umount tmp-loop || exit

rm -rf tmp-loop


echo ">>> Creating CD-ROM ISO image..."

rm -f disk_img/rmOS.iso
mkisofs -quiet -V 'MIKEOS' -input-charset iso8859-1 -o disk_img/rmOS.iso -b rmOS.flp disk_img/ || exit

echo '>>> Done!'
