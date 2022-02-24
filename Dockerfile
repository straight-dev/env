# Initialize
FROM ubuntu:focal
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    cmake \
    g++ \
    golang-go \
    make \
    ninja-build \
    perl \
    python3 \
    wget \
    xz-utils \
&& apt-get clean

# Transfer data
RUN mkdir /work/ && cd /work/ && wget https://github.com/llvm/llvm-project/releases/download/llvmorg-12.0.1/clang+llvm-12.0.1-x86_64-linux-gnu-ubuntu-16.04.tar.xz && tar xf clang+llvm-12.0.1-x86_64-linux-gnu-ubuntu-16.04.tar.xz && mv clang+llvm-12.0.1-x86_64-linux-gnu-ubuntu- clang+llvm-12.0.1-x86_64-linux-gnu-ubuntu-16.04
COPY . /work/

# Build llc and onikiri
RUN cd /work/ && mkdir ninja && cd ninja && cmake -G Ninja -DCMAKE_CXX_STANDARD=17 ../llvm && ninja llc
RUN cd /work/onikiri2/project/gcc/ && make -j$(nproc)

# Run tests
RUN cd /work/toolchain/Test/dhrystone && make test -j$(nproc)
RUN cd /work/toolchain/Test/coremark && make test -j$(nproc)
RUN cd /work/toolchain/Test/hello_musl && make test -j$(nproc)
