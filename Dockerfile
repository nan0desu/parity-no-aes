FROM ubuntu:18.04 AS builder
RUN true && \
  apt-get update && \
  apt-get -y install curl  gcc g++ libudev-dev pkg-config file make cmake git vim yasm llvm clang clang-tools && \
  (curl https://sh.rustup.rs -sSf | sh -s -- -y) && \
  true
WORKDIR /
RUN git clone --depth=1 https://github.com/openethereum/openethereum /openethereum
RUN cd /openethereum && sed -i 's/+aes,+sse2/+sse2/g' .cargo/config scripts/actions/build-linux.sh
ENV RUSTFLAGS="-Ctarget-feature=+sse2,+ssse3"
ENV PATH=/root/.cargo/bin:$PATH
RUN cd /openethereum && cargo build --release --features final

FROM ubuntu:18.04
COPY --from=builder /openethereum/target/release/openethereum /bin/openethereum
RUN adduser --disabled-password --home "/home/openethereum" "openethereum" --gecos "openethereum"
USER openethereum
ENTRYPOINT [ "/bin/openethereum" ]

