all:	

mk-host: 
###     FIXME: This currently is not working
#	create container and populate for host
#	remove fluff 
	@rsync -var /bin HOST
	@rsync -var /boot HOST
	@rsync -var /etc HOST
	@rsync -var /lib HOST
	@rsync -var /sbin HOST
	@rsync -var --exclude /usr/src /usr HOST
	@rsync -var /var/lib HOST/var/
	@rsync -var /var/cache HOST/var/
	@rsync -var --exclude /usr/src /usr HOST
	@rsync -var /var/lib HOST/var/
	@rsync -var /var/cache HOST/var/
setup:
	@install -vdm 755 HOST
	@install -vdm 755 WORK
	@install -vdm 755 CHROOT
	@rm -rf LFS/root
	@install -vdm 755 LFS/root
	@install -vdm 755 LFS/etc/rpm
	@cp macros LFS/etc/rpm/macros
	@install -vdm 777 LFS/tmp
	@touch setup
chroot:
	#	for toolchain build and BLFS
	@echo "Unmounting Virtual Kernel File Systems"
	@mountpoint -q CHROOT/run  && umount CHROOT/run || true
	@mountpoint -q CHROOT/sys  && umount CHROOT/sys || true
	@mountpoint -q CHROOT/proc && umount CHROOT/proc || true
	@mountpoint -q CHROOT/dev/pts && umount CHROOT/dev/pts || true
	@mountpoint -q CHROOT/dev && umount  CHROOT/dev || true
	@mountpoint -q CHROOT && umount CHROOT || true
	@mountpoint -q HOST && umount HOST || true
	@echo "Mounting Overlay"
	@mount -t ext4 HOST.img HOST
	@mount -t overlay overlay -o lowerdir=HOST,upperdir=LFS,workdir=WORK CHROOT
	@echo "Preparing Virtual Kernel File Systems: "
	@[ -d CHROOT/dev ]  || mkdir -p CHROOT/dev
	@[ -d CHROOT/dev/pts ]  || mkdir -p CHROOT/dev/pts
	@[ -d CHROOT/proc ] || mkdir -p CHROOT/proc
	@[ -d CHROOT/sys ]  || mkdir -p CHROOT/sys
	@[ -d CHROOT/run ]  || mkdir -p CHROOT/run
	@echo 'Creating Initial Device Nodes'
	@[ -e CHROOT/dev/console ] || mknod -m 600 CHROOT/dev/console c 5 1
	@[ -e CHROOT/dev/null ] || mknod -m 666 CHROOT/dev/null c 1 3
	@echo "Mounting Virtual Kernel File Systems "
	@mountpoint -q CHROOT/dev || mount --bind /dev CHROOT/dev
	@mountpoint -q CHROOT/dev/pts || mount -t devpts devpts CHROOT/dev/pts -o gid=5,mode=620
	@mountpoint -q CHROOT/proc || mount -t proc proc CHROOT/proc
	@mountpoint -q CHROOT/sys || mount -t sysfs sysfs CHROOT/sys
	@mountpoint -q CHROOT/run || mount -t tmpfs tmpfs CHROOT/run
	@echo 'Chrooting'
	@chroot CHROOT env -i HOME=$$HOME TERM=$$TERM PATH=/bin:/usr/bin:/sbin:/usr/sbin PS1='(Overlay) \u:\w\$$ ' /bin/bash --noprofile --norc --login +h
	@echo "Unmounting Virtual Kernel File Systems: "
	@mountpoint -q CHROOT/run  && umount CHROOT/run || true
	@mountpoint -q CHROOT/sys  && umount CHROOT/sys || true
	@mountpoint -q CHROOT/proc && umount CHROOT/proc || true
	@mountpoint -q CHROOT/dev/pts && umount CHROOT/dev/pts || true
	@mountpoint -q CHROOT/dev && umount  CHROOT/dev || true
	@mountpoint -q CHROOT && umount CHROOT || true
	@mountpoint -q HOST && umount HOST || true
	@echo "Complete"
