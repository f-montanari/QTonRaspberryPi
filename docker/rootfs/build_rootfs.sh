docker buildx build --platform linux/arm64 --load -f docker/rootfs/Dockerfile -t crossbuild-rootfs .
docker create -v ./docker/rootfs/build:/build --name cross-rootfs crossbuild-rootfs
cp docker/rootfs/build/rasp.tar.gz ./rasp.tar.gz