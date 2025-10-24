# -----------------------------------------------------
# Qt 6 + optional OpenCV cross-build environment
# -----------------------------------------------------
FROM crossbuild-base:latest

ARG BUILD_OPENCV=OFF

WORKDIR /build

# Copy toolchain files
COPY opencvToolchain.cmake /build/
COPY toolchain.cmake /build/

# -----------------------------------------------------
# Optionally build OpenCV
# -----------------------------------------------------
RUN if [ "$BUILD_OPENCV" = "ON" ]; then \
    echo "Building OpenCV 4.9.0 for Raspberry Pi..."; \
    git clone --branch 4.9.0 --depth=1 https://github.com/opencv/opencv.git; \
    git clone --branch 4.9.0 --depth=1 https://github.com/opencv/opencv_contrib.git; \
    mkdir -p /build/opencv/build && cd /build/opencv/build && \
    cmake -G "Unix Makefiles" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX=/build/opencvBuild \
        -DCMAKE_TOOLCHAIN_FILE=/build/opencvToolchain.cmake \
        -DOPENCV_EXTRA_MODULES_PATH=../../opencv_contrib/modules \
        -DOPENCV_ENABLE_NONFREE=ON \
        -DWITH_GSTREAMER=ON -DWITH_FFMPEG=ON -DWITH_V4L=ON -DWITH_OPENGL=ON \
        -DWITH_QT=OFF -DWITH_GTK=OFF -DWITH_X11=ON \
        -DBUILD_opencv_highgui=ON -DBUILD_TESTS=OFF -DBUILD_PERF_TESTS=OFF \
        -DBUILD_EXAMPLES=OFF -DENABLE_NEON=ON \
        -DCMAKE_C_FLAGS="--sysroot=/build/sysroot -march=armv8-a -mtune=cortex-a53 -O2" \
        -DCMAKE_CXX_FLAGS="--sysroot=/build/sysroot -march=armv8-a -mtune=cortex-a53 -O2"; \
    make -j$(nproc); \
    cmake --install .; \
    tar -czf /build/opencv-binaries.tar.gz -C /build/opencvBuild .; \
fi

# -----------------------------------------------------
# Build Qt 6.8.1 (host + Pi)
# -----------------------------------------------------
RUN set -eux; \
    mkdir -p /build/qt6/src; cd /build/qt6/src; \
    wget -q https://download.qt.io/official_releases/qt/6.8/6.8.1/submodules/qtbase-everywhere-src-6.8.1.tar.xz; \
    wget -q https://download.qt.io/official_releases/qt/6.8/6.8.1/submodules/qtshadertools-everywhere-src-6.8.1.tar.xz; \
    wget -q https://download.qt.io/official_releases/qt/6.8/6.8.1/submodules/qtdeclarative-everywhere-src-6.8.1.tar.xz

    RUN set -eux; \
    cd /build/qt6; mkdir -p host host-build; cd host-build; \
    tar xf ../src/qtbase-everywhere-src-6.8.1.tar.xz; \
    tar xf ../src/qtshadertools-everywhere-src-6.8.1.tar.xz; \
    tar xf ../src/qtdeclarative-everywhere-src-6.8.1.tar.xz; \
    echo "Building Qt Host..."; \
    cd qtbase-everywhere-src-6.8.1; \
    cmake -GNinja -DCMAKE_BUILD_TYPE=Release -DQT_BUILD_EXAMPLES=OFF -DQT_BUILD_TESTS=OFF \
          -DCMAKE_INSTALL_PREFIX=/build/qt6/host; \
    cmake --build . --parallel $(nproc); cmake --install .; \
    cd ../qtshadertools-everywhere-src-6.8.1; \
    /build/qt6/host/bin/qt-configure-module .; cmake --build . --parallel $(nproc); cmake --install .; \
    cd ../qtdeclarative-everywhere-src-6.8.1; \
    /build/qt6/host/bin/qt-configure-module .; cmake --build . --parallel $(nproc); cmake --install .;

RUN set -eux; \
    cd /build/qt6; mkdir -p pi pi-build; cd pi-build; \
    tar xf ../src/qtbase-everywhere-src-6.8.1.tar.xz; \
    tar xf ../src/qtshadertools-everywhere-src-6.8.1.tar.xz; \
    tar xf ../src/qtdeclarative-everywhere-src-6.8.1.tar.xz; \
    echo "Building Qt for Raspberry Pi..."; \
    cd qtbase-everywhere-src-6.8.1; \
    cmake -GNinja \
        -DCMAKE_BUILD_TYPE=Release \
        -DQT_BUILD_EXAMPLES=OFF -DQT_BUILD_TESTS=OFF \
        -DQT_HOST_PATH=/build/qt6/host \
        -DCMAKE_STAGING_PREFIX=/build/qt6/pi \
        -DCMAKE_INSTALL_PREFIX=/usr/local/qt6 \
        -DCMAKE_TOOLCHAIN_FILE=/build/toolchain.cmake \
        -DINPUT_opengl=es2 \
        -DQT_FEATURE_xcb=ON -DQT_FEATURE_xlib=ON -DQT_FEATURE_sql_psql=ON; \
    cmake --build . --parallel $(nproc); cmake --install .; \
    cd ../qtshadertools-everywhere-src-6.8.1; \
    /build/qt6/pi/bin/qt-configure-module .; cmake --build . --parallel $(nproc); cmake --install .; \
    cd ../qtdeclarative-everywhere-src-6.8.1; \
    /build/qt6/pi/bin/qt-configure-module .; cmake --build . --parallel $(nproc); cmake --install .; \
    echo "Qt cross-build complete."

RUN tar -czf /build/qt-host-binaries.tar.gz -C /build/qt6/host . && \
    tar -czf /build/qt-pi-binaries.tar.gz -C /build/qt6/pi .

LABEL stage="qt" description="Qt6 and OpenCV cross-compilation environment for Raspberry Pi"