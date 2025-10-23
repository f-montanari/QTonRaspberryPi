docker buildx build --platform linux/arm64 --load -t crossbuild-rootfs .
docker create -v ./build:/build --name cross-rootfs crossbuild-rootfs