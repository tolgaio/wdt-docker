FROM ubuntu:16.04 AS BASE

WORKDIR /

# Install basic deps for all packages
RUN apt-get update && \
    apt-get install -y \
      cmake \
      git \
      wget \
      g++ \
      software-properties-common

# Install folly package deps
RUN apt-get install -y \
    g++ \
    cmake \
    libboost-all-dev \
    libevent-dev \
    libdouble-conversion-dev \
    libgoogle-glog-dev \
    libgflags-dev \
    libiberty-dev \
    liblz4-dev \
    liblzma-dev \
    libsnappy-dev \
    make \
    zlib1g-dev \
    binutils-dev \
    libjemalloc-dev \
    libssl-dev \
    pkg-config \
    libunwind-dev

RUN apt-get install -y \
    libgtest-dev \
    libboost-all-dev

# install latest gcc7
RUN apt-get install -y \
      software-properties-common && \
    add-apt-repository ppa:ubuntu-toolchain-r/test && \
    apt update && \
    apt install -y g++-7 && \
    update-alternatives \
      --install /usr/bin/gcc gcc /usr/bin/gcc-7 60 \
      --slave /usr/bin/g++ g++ /usr/bin/g++-7 \
      --slave /usr/bin/gcc-ar gcc-ar /usr/bin/gcc-ar-7 \
      --slave /usr/bin/gcc-nm gcc-nm /usr/bin/gcc-nm-7 \
      --slave /usr/bin/gcc-ranlib gcc-ranlib /usr/bin/gcc-ranlib-7 && \
    update-alternatives --config gcc


FROM BASE AS DEPS

# Folly requires fmt, which *must* be built from source--libfmt-dev doesn't work
RUN git clone https://github.com/fmtlib/fmt.git && \
    cd fmt && \
    mkdir _build && cd _build && \
    cmake .. \
      -DCMAKE_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu/ \
      -DBUILD_SHARED_LIBS=ON \
      -DCMAKE_POSITION_INDEPENDENT_CODE=ON && \
    make -j$(nproc) && \
    make install && \
    cd /

# Build folly itself from source
RUN git clone https://github.com/facebook/folly.git && \
    cd folly && \
    mkdir _build && \
    cd _build && \
    cmake .. && \
    make -j$(nproc) && \
    make install && \
    cd /

FROM DEPS AS RELEASE

RUN git clone https://github.com/facebook/wdt.git
COPY ./CMakeLists.txt /wdt/
RUN cd wdt && \
    mkdir _build && cd _build && \
    cmake .. -DBUILD_TESTING=off && \
    make -j$(nproc) && \
    make install && \
    cd /

# Clean Up
RUN rm -rf fmt \
    folly \
    wdt && \
    rm -rf /var/lib/apt/lists/*

ENV WDTDATA /data
VOLUME ["/data"]
RUN mkdir -p /data
WORKDIR /data
COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["wdt"]
