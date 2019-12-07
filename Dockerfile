FROM ubuntu:18.04 AS builder
RUN true && \
  apt-get update && \
  apt-get -y install curl  gcc g++ libudev-dev pkg-config file make cmake git vim yasm llvm clang clang-tools && \
  (curl https://sh.rustup.rs -sSf | sh -s -- -y) && \
  true
WORKDIR /
RUN git clone --branch=stable --depth=1 https://github.com/paritytech/parity-ethereum.git /parity-ethereum
RUN cd /parity-ethereum && sed -i 's/+aes,+sse2/+sse2/g' .cargo/config scripts/gitlab/build-linux.sh
ENV RUSTFLAGS="-Ctarget-feature=+sse2,+ssse3"
ENV PATH=/root/.cargo/bin:$PATH
RUN cd /parity-ethereum && cargo build --release --features final

FROM ubuntu:18.04
COPY --from=builder /parity-ethereum/target/release/parity /bin/parity
RUN adduser --disabled-password --home "/home/parity" "parity" --gecos "parity"
USER parity
ENTRYPOINT [ "/bin/parity" ]
  