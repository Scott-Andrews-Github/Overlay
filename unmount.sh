#!/bin/bash
mountpoint -q CHROOT/run  && umount CHROOT/run
mountpoint -q CHROOT/sys  && umount CHROOT/sys
mountpoint -q CHROOT/proc && umount CHROOT/proc
mountpoint -q CHROOT/dev/pts && umount CHROOT/dev/pts
mountpoint -q CHROOT/dev && umount  CHROOT/dev
mountpoint -q CHROOT && umount CHROOT
true
