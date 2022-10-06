FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

# Install apt packages for Qt build
RUN \
    set -eux && \
    apt-get update && \
    apt-get -y upgrade && \
    apt-get -y install \
        autoconf \
        automake \
        autopoint \
        bash \
        bison \
        build-essential \
        bzip2 \
        flex \
        g++ \
        g++-multilib \
        gdb \
        gettext \
        git \
        gnupg \
        gperf \
        intltool \
        libc6-dev-i386 \
        libclang-dev \
        libgdk-pixbuf2.0-dev \
        libltdl-dev \
        libssl-dev \
        libtool-bin \
        lsb-release \
        lzip \
        make \
        mesa-common-dev \
        ninja-build \
        openssl \
        p7zip-full \
        patch \
        perl \
        pkg-config \
        python-is-python3 \
        python3 \
        python3-mako \
        ruby \
        sed \
        software-properties-common \
        unzip \
        wget \
        xz-utils \
        && \
    apt-get -y autoremove && \
    apt-get -y autoclean && \
    apt-get -y clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    exit 0

RUN \
    cd /opt && \
    git clone https://github.com/mxe/mxe.git && \
    exit 0
