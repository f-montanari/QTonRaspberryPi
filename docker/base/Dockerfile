# -----------------------------------------------------
# Base image for cross-compilation on Raspberry Pi
# Includes system dependencies, compilers, sysroot, and CMake
# -----------------------------------------------------

FROM debian:trixie

ENV DEBIAN_FRONTEND=noninteractive

# Install build dependencies
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
    wget git build-essential make rsync sed ninja-build gcc g++ bison python3 gperf pkg-config \
    libfontconfig1-dev libfreetype6-dev libx11-dev libx11-xcb-dev libxext-dev libxfixes-dev \
    libxi-dev libxrender-dev libxcb1-dev libxcb-glx0-dev libxcb-keysyms1-dev libxcb-image0-dev \
    libxcb-shm0-dev libxcb-icccm4-dev libxcb-sync-dev libxcb-xfixes0-dev libxcb-shape0-dev \
    libxcb-randr0-dev libxcb-render-util0-dev libxcb-util-dev libxcb-xinerama0-dev \
    libxcb-xkb-dev libxkbcommon-dev libxkbcommon-x11-dev libatspi2.0-dev libgl1-mesa-dev \
    libglu1-mesa-dev freeglut3-dev libssl-dev libgmp-dev libmpfr-dev libmpc-dev libpq-dev flex \
    gawk texinfo libisl-dev zlib1g-dev libtool autoconf automake libgdbm-dev libdb-dev \
    libbz2-dev libreadline-dev libexpat1-dev liblzma-dev libffi-dev libsqlite3-dev libbsd-dev \
    perl patch m4 libncurses-dev gettext \
    gcc-14-aarch64-linux-gnu g++-14-aarch64-linux-gnu \
    binutils-aarch64-linux-gnu libc6-arm64-cross libc6-dev-arm64-cross glibc-source \
    ca-certificates curl; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*

WORKDIR /build

# -----------------------------------------------------
# Build and install CMake from source (latest)
# -----------------------------------------------------
RUN set -eux; \
    git clone https://github.com/Kitware/CMake.git cmake_src; \
    cd cmake_src; \
    ./bootstrap; \
    make -j$(nproc); \
    make install; \
    cd ..; rm -rf cmake_src

# -----------------------------------------------------
# Copy Raspberry Pi sysroot
# -----------------------------------------------------
COPY rasp.tar.gz /build/
RUN mkdir -p /build/sysroot && tar -xzf /build/rasp.tar.gz -C /build/sysroot
COPY docker/base/sysroot-relativelinks.py /tmp/sysroot-relativelinks.py

# Fix relative links in sysroot
RUN chmod +x /tmp/sysroot-relativelinks.py \
    && python3 /tmp/sysroot-relativelinks.py /build/sysroot \
    && rm /tmp/sysroot-relativelinks.py
# Default workdir for derived images
WORKDIR /build