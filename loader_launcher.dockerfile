FROM skylyrac/blocksds:slim-latest

RUN apt update && apt install -y \
  build-essential \
  cmake \
  curl \
  gcc-arm-none-eabi \
  git \
  python3

ENV DLDITOOL=/opt/wonderful/thirdparty/blocksds/core/tools/dlditool/dlditool
ENV DOTNET_ROOT=/opt/dotnet
ENV PATH="${DOTNET_ROOT}:${PATH}"

WORKDIR /opt

RUN mkdir -p dotnet && curl -s -L https://builds.dotnet.microsoft.com/dotnet/Sdk/9.0.308/dotnet-sdk-9.0.308-linux-x64.tar.gz | tar xzf - -C dotnet

RUN mkdir -p /work /out /assets

COPY scripts/build-inside.sh /usr/local/bin/build-inside.sh
RUN chmod +x /usr/local/bin/build-inside.sh

WORKDIR /work
ENTRYPOINT ["/usr/local/bin/build-inside.sh"]
