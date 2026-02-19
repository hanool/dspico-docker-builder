# DSPico Docker Builder

This repository provides a Docker-based build flow for DSPico projects.

It supports three modes:

- `loader-launcher`: build Pico Loader and Pico Launcher only
- `firmware`: build DSPico firmware pipeline only
- `all`: build firmware, loader, and launcher in one run

Upstream repositories are cloned fresh on every run, so each build uses the latest upstream state.

## Requirements

- Docker
- Local assets for firmware mode (see `assets/README.md`)

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

## Output layout

Artifacts are exported to `out/`:

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

## Notes

- `assets/` is intentionally excluded from git (except placeholders/docs) for copyrighted files.
- `out/` is generated and ignored.
