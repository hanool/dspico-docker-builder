# DSPico Docker 빌더

[![English](https://img.shields.io/badge/lang-English-blue)](README.md)
[![한국어](https://img.shields.io/badge/lang-한국어-red)](README.ko.md)

이 저장소는 DSPico 프로젝트를 Docker로 빌드하기 위한 워크플로를 제공합니다.

지원 모드:

- `loader-launcher`: Pico Loader와 Pico Launcher만 빌드
- `firmware`: DSPico 펌웨어 파이프라인만 빌드
- `all`: 펌웨어, 로더, 런처를 한 번에 빌드

## 요구사항

- Docker
- `firmware` 및 `all` 모드에 필요한 로컬 파일(loader&launcher만 빌드시 필요 없음)
  - NTR blowfish 소스: `biosnds7.rom` 또는 `ntrBlowfish.bin`
  - 선택 TWL blowfish 소스: `biosdsi7.rom` 또는 `twlBlowfish.bin` (TWL 하이브리드/전용 롬 암호화 시에만 필요)
  - Blowfish 테이블 참고: https://github.com/Gericom/DSRomEncryptor?tab=readme-ov-file#blowfish-tables
- `--wrfuxxed` 사용 시에만 필요한 선택 파일
  - `wrfu.srl` (WRFU Tester v0.60)

펌웨어 및 all 모드는 공식 가이드를 기준으로 동작합니다.
- https://github.com/LNH-team/dspico/blob/develop/GUIDE.md

## 빌드 명령어

```bash
./build.sh loader-launcher
./build.sh firmware
./build.sh all
```

기본값은 WRFUxxed 비활성화입니다. WRFUxxed 사용시 파일을 준비하고 --wrfuxxed 플래그를 사용하세요.

```bash
./build.sh firmware --wrfuxxed
./build.sh all --wrfuxxed
```

## 출력

결과물은 `out/`에 작성됩니다.

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
    uartBufv060.bin    # --wrfuxxed 사용 시에만 생성
```
