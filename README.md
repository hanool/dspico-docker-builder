# DSPico Docker Builder

[![English](https://img.shields.io/badge/lang-English-blue)](README.md)
[![한국어](https://img.shields.io/badge/lang-한국어-red)](README.ko.md)

Build DSPico projects with Docker, easily.

## Quick Start

```bash
git clone https://github.com/hanool/dspico-docker-builder.git
cd dspico-docker-builder
./build.sh
```

See below for details on each step.

### 1) Install Docker

- Install Docker Desktop: https://www.docker.com/get-started/
- After installation, verify Docker works in a terminal:

```bash
docker --version
```

### 2) Prepare BIOS files

To build `firmware` or `all` mode, you need one of the following. If you just bought DSPico, firmware is already installed, so you can skip this for now.

- `biosnds7.rom` (recommended)
- `ntrBlowfish.bin`

How to dump `biosnds7.rom`:
- https://wiki.ds-homebrew.com/ds-index/ds-bios-firmware-dump

Place prepared files in this repository's `assets/` directory.

Optional files:

- For TWL hybrid/exclusive ROM encryption:
  - `biosdsi7.rom` or `twlBlowfish.bin`
- When using `--wrfuxxed`:
  - `wrfu.srl` (WRFU Tester v0.60)

Blowfish table reference:
- https://github.com/Gericom/DSRomEncryptor?tab=readme-ov-file#blowfish-tables

### 3) Get the source code

Option A (using Git):

```bash
git clone https://github.com/hanool/dspico-docker-builder.git
cd dspico-docker-builder
```

Option B (without Git):

- Open the GitHub repository page.
- Click `Code` -> `Download ZIP`.
- Extract the ZIP archive.
- Open a terminal in the extracted `dspico-docker-builder` folder.

### 4) Make the build script executable (macOS/Linux)

```bash
chmod +x build.sh
```

### 5) Run the build

Run `./build.sh` and choose a number.

```text
Select build mode:
  1) loader-launcher
  2) firmware
  3) all
Enter choice [1-3]:
```

Or you can specify the mode directly.

```bash
./build.sh loader-launcher
./build.sh firmware # builds firmware
./build.sh all # builds both above
```

- `loader-launcher`: builds Pico Loader + Pico Launcher only (no BIOS file required). SD-card copy-ready files are generated in `out/sdcard/`.
- `firmware`: builds DSPico firmware only (BIOS file required)
- `all`: builds firmware + loader + launcher (BIOS file required)

WRFUxxed is disabled by default. When using WRFUxxed:

```bash
./build.sh firmware --wrfuxxed
./build.sh all --wrfuxxed
```

`firmware` and `all` modes follow the official guide:
- https://github.com/LNH-team/dspico/blob/develop/GUIDE.md

## Output

Artifacts are generated in `out/`.

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
  sdcard/
    _picoboot.nds
    _pico/
      picoLoader7.bin
      picoLoader9.bin
      aplist.bin
      savelist.bin
      patchlist.bin
      themes/
  firmware/
    DSpico.uf2
    default.nds
    DSpico.dldi
    BOOTLOADER.nds
    uartBufv060.bin    # generated only when using --wrfuxxed
```

For SD-card setup, copy everything inside `out/sdcard/` to the root of your micro SD card.
