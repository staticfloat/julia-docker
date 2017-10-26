docker export $1 > rootfs.tar
mkdir root
cd root
tar xf ../rootfs.tar
mkdir workspace
touch dev/null
touch dev/ptmx
