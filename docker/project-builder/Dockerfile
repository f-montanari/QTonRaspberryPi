# -----------------------------------------------------
# Project build image
# -----------------------------------------------------
FROM crossbuild-qt:latest

WORKDIR /build

# Copy project sources
COPY project /build/project
COPY QtOpencvExample /build/QtOpencvExample

# Build main project
RUN set -eux; \
    cd /build/project; \
    /build/qt6/pi/bin/qt-cmake .; \
    cmake --build . --parallel $(nproc)

# Build OpenCV example (if enabled)
ARG BUILD_OPENCV=OFF
RUN if [ "$BUILD_OPENCV" = "ON" ]; then \
    cd /build/QtOpencvExample; \
    mkdir -p build && cd build; \
    cmake -DCMAKE_TOOLCHAIN_FILE=/build/QtOpencvExample/toolchain.cmake ..; \
    make -j$(nproc); \
fi

LABEL stage="project" description="Project compilation layer for Raspberry Pi"