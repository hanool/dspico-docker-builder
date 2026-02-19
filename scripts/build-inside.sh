#!/usr/bin/env bash
set -euo pipefail

MODE="${1:-loader-launcher}"
shift || true

ENABLE_WRFUXXED=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --wrfuxxed)
      ENABLE_WRFUXXED=1
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 1
      ;;
  esac
  shift
done

ROOT_DIR="/work"
SRC_DIR="${ROOT_DIR}/src"
OUT_DIR="/out"
ASSETS_DIR="/assets"

clone_latest() {
  local repo_url="$1"
  local repo_dir="$2"
  git clone --depth 1 "$repo_url" "${SRC_DIR}/${repo_dir}"
}

require_any_asset() {
  local first="$1"
  local second="$2"
  local label="$3"
  if [[ ! -f "${ASSETS_DIR}/${first}" && ! -f "${ASSETS_DIR}/${second}" ]]; then
    echo "Missing ${label}: add ${first} or ${second} under ${ASSETS_DIR}" >&2
    exit 1
  fi
}

prepare_workspace() {
  rm -rf "${SRC_DIR}" "${OUT_DIR}"
  mkdir -p "${SRC_DIR}" "${OUT_DIR}"
}

build_loader_launcher() {
  clone_latest https://github.com/LNH-team/pico-loader.git pico-loader
  clone_latest https://github.com/LNH-team/pico-launcher.git pico-launcher

  (
    cd "${SRC_DIR}/pico-loader"
    git submodule update --init
    make
  )

  (
    cd "${SRC_DIR}/pico-launcher"
    git submodule update --init
    make
  )

  mkdir -p "${OUT_DIR}/loader" "${OUT_DIR}/launcher"

  cp "${SRC_DIR}/pico-loader/picoLoader7.bin" "${OUT_DIR}/loader/"
  cp "${SRC_DIR}/pico-loader/picoLoader9_DSPICO.bin" "${OUT_DIR}/loader/"
  cp "${SRC_DIR}/pico-loader/data/aplist.bin" "${OUT_DIR}/loader/"
  cp "${SRC_DIR}/pico-loader/data/savelist.bin" "${OUT_DIR}/loader/"
  if [[ -f "${SRC_DIR}/pico-loader/data/patchlist.bin" ]]; then
    cp "${SRC_DIR}/pico-loader/data/patchlist.bin" "${OUT_DIR}/loader/"
  fi

  cp "${SRC_DIR}/pico-launcher/LAUNCHER.nds" "${OUT_DIR}/launcher/"
  cp -r "${SRC_DIR}/pico-launcher/_pico" "${OUT_DIR}/launcher/"
}

build_firmware() {
  require_any_asset biosnds7.rom ntrBlowfish.bin "NTR blowfish source"
  require_any_asset biosdsi7.rom twlBlowfish.bin "TWL blowfish source"

  clone_latest https://github.com/Gericom/DSRomEncryptor.git DSRomEncryptor
  clone_latest https://github.com/LNH-team/dspico-dldi.git dspico-dldi
  clone_latest https://github.com/LNH-team/dspico-bootloader.git dspico-bootloader
  clone_latest https://github.com/LNH-team/dspico-firmware.git dspico-firmware

  (
    cd "${SRC_DIR}/dspico-dldi"
    make
  )

  (
    cd "${SRC_DIR}/dspico-bootloader"
    git submodule update --init
    make
  )

  "${DLDITOOL}" \
    "${SRC_DIR}/dspico-dldi/DSpico.dldi" \
    "${SRC_DIR}/dspico-bootloader/BOOTLOADER.nds"

  (
    cd "${SRC_DIR}/DSRomEncryptor"
    dotnet build
  )

  local encryptor_dir
  encryptor_dir="${SRC_DIR}/DSRomEncryptor/DSRomEncryptor/bin/Debug/net9.0"

  for filename in biosnds7.rom biosdsi7.rom ntrBlowfish.bin twlBlowfish.bin twlDevBlowfish.bin; do
    if [[ -f "${ASSETS_DIR}/${filename}" ]]; then
      cp "${ASSETS_DIR}/${filename}" "${encryptor_dir}/"
    fi
  done

  "${encryptor_dir}/DSRomEncryptor" \
    "${SRC_DIR}/dspico-bootloader/BOOTLOADER.nds" \
    "${SRC_DIR}/dspico-firmware/roms/default.nds"

  if [[ "${ENABLE_WRFUXXED}" -eq 1 ]]; then
    if [[ ! -f "${ASSETS_DIR}/wrfu.srl" ]]; then
      echo "Missing WRFU tester payload: add wrfu.srl under ${ASSETS_DIR}" >&2
      exit 1
    fi

    clone_latest https://github.com/LNH-team/dspico-wrfuxxed.git dspico-wrfuxxed

    (
      cd "${SRC_DIR}/dspico-wrfuxxed"
      make
    )

    "${DLDITOOL}" \
      "${SRC_DIR}/dspico-dldi/DSpico.dldi" \
      "${SRC_DIR}/dspico-wrfuxxed/uartBufv060.bin"

    cp "${ASSETS_DIR}/wrfu.srl" "${SRC_DIR}/dspico-firmware/roms/dsimode.nds"
    cp "${SRC_DIR}/dspico-wrfuxxed/uartBufv060.bin" "${SRC_DIR}/dspico-firmware/data/"
    sed -i 's/^.*DSPICO_ENABLE_WRFUXXED.*$/  DSPICO_ENABLE_WRFUXXED/' "${SRC_DIR}/dspico-firmware/CMakeLists.txt"
  fi

  (
    cd "${SRC_DIR}/dspico-firmware"
    git submodule update --init
    cd pico-sdk
    git submodule update --init
  )

  (
    cd "${SRC_DIR}/dspico-firmware"
    chmod +x compile.sh
    ./compile.sh
  )

  mkdir -p "${OUT_DIR}/firmware"
  cp "${SRC_DIR}/dspico-firmware/build/DSpico.uf2" "${OUT_DIR}/firmware/"
  cp "${SRC_DIR}/dspico-firmware/roms/default.nds" "${OUT_DIR}/firmware/"
  cp "${SRC_DIR}/dspico-dldi/DSpico.dldi" "${OUT_DIR}/firmware/"
  cp "${SRC_DIR}/dspico-bootloader/BOOTLOADER.nds" "${OUT_DIR}/firmware/"

  if [[ "${ENABLE_WRFUXXED}" -eq 1 ]]; then
    cp "${SRC_DIR}/dspico-wrfuxxed/uartBufv060.bin" "${OUT_DIR}/firmware/"
  fi
}

prepare_workspace

case "${MODE}" in
  loader-launcher)
    build_loader_launcher
    ;;
  firmware)
    build_firmware
    ;;
  all)
    build_firmware
    build_loader_launcher
    ;;
  *)
    echo "Unknown mode: ${MODE}" >&2
    echo "Supported modes: loader-launcher, firmware, all" >&2
    exit 1
    ;;
esac
