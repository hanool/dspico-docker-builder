# DSPico Docker Builder

[![English](https://img.shields.io/badge/lang-English-blue)](README.md)
[![한국어](https://img.shields.io/badge/lang-한국어-red)](README.ko.md)

This repository provides a Docker-based build flow for DSPico projects.

It supports three modes:

- `loader-launcher`: build Pico Loader and Pico Launcher only
- `firmware`: build DSPico firmware pipeline only
- `all`: build firmware, loader, and launcher in one run

## Requirements

- Docker
- Local files required for `firmware` and `all` modes (not needed for loader/launcher-only builds), placed under `assets/`:
  - NTR blowfish source: `biosnds7.rom` or `ntrBlowfish.bin`
  - TWL blowfish source: `biosdsi7.rom` or `twlBlowfish.bin`
  - Blowfish table reference: https://github.com/Gericom/DSRomEncryptor?tab=readme-ov-file#blowfish-tables
- Optional only with `--wrfuxxed`:
  - `wrfu.srl` (WRFU Tester v0.60)

Firmware and all-mode builds follow the official guide:
- https://github.com/LNH-team/dspico/blob/develop/GUIDE.md

## Build commands

Run from the repository root:

```bash
./build.sh loader-launcher
./build.sh firmware
./build.sh all
```

WRFUxxed is disabled by default. To enable it in firmware/all mode:

```bash
./build.sh firmware --wrfuxxed
./build.sh all --wrfuxxed
```

## Output

Artifacts are written to `out/`:

```text
out/
  loader/
    picoLoader7.bin
    picoLoader9_DSPICO.bin
    aplist.bin
    savelist.bin
    patchlist.bin
  launcher/
    LAUNCHER.nds
    _pico/
  firmware/
    DSpico.uf2
    default.nds
    DSpico.dldi
    BOOTLOADER.nds
    uartBufv060.bin    # only with --wrfuxxed
```
