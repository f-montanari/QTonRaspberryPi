docker buildx build --platform linux/arm64 --load -f docker/rootfs/Dockerfile -t crossbuild-rootfs .
docker create --name cross-rootfs crossbuild-rootfs
docker cp cross-rootfs:/build/rasp.tar.gz ./rasp.tar.gz

docker build -t crossbuild-base:latest -f docker/base/Dockerfile .

docker build -t crossbuild-qt:latest -f docker/qt/Dockerfile --build-arg BUILD_OPENCV=OFF .

docker build -t myproject-builder:latest -f docker/project-builder/Dockerfile .
docker create --name cross-output myproject-builder
docker cp cross-output:/build/project/HelloQt6 ./output/HelloQt6
docker rm cross-output