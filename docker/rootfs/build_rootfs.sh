docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
# Do these two only once.
# docker buildx create --use --name mybuilder
# docker buildx inspect mybuilder --bootstrap
docker buildx build --platform linux/arm64 --load -t crossbuild-rootfs .
docker create --name cross-rootfs crossbuild-rootfs
docker cp cross-rootfs:/build.log ./build/build.log
docker cp cross-rootfs:/build/rasp.tar.gz ./build/rasp.tar.gz