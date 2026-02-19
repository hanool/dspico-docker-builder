FROM skylyrac/blocksds:slim-latest AS builder

RUN apt update && apt install -y \
  build-essential \
  cmake \
  gcc-arm-none-eabi \
  git \
  python3

ENV DOTNET_ROOT=/opt/dotnet
ENV PATH="${DOTNET_ROOT}:${PATH}"

WORKDIR /opt

RUN mkdir -p dotnet && curl -s -L https://builds.dotnet.microsoft.com/dotnet/Sdk/9.0.308/dotnet-sdk-9.0.308-linux-x64.tar.gz | tar xzf - -C dotnet

RUN git clone https://github.com/LNH-team/pico-loader.git
RUN git clone https://github.com/LNH-team/pico-launcher.git

RUN cd /opt/pico-loader && git submodule update --init && make
RUN cd /opt/pico-launcher && git submodule update --init && make

RUN mkdir -p /build/loader /build/launcher && \
  cp /opt/pico-loader/picoLoader7.bin /build/loader/ && \
  cp /opt/pico-loader/picoLoader9_DSPICO.bin /build/loader/ && \
  cp /opt/pico-loader/data/aplist.bin /build/loader/ && \
  cp /opt/pico-loader/data/savelist.bin /build/loader/ && \
  cp /opt/pico-launcher/LAUNCHER.nds /build/launcher/ && \
  cp -r /opt/pico-launcher/_pico /build/launcher/

FROM scratch

COPY --from=builder /build /build
