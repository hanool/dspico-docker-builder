# DSPico Docker 빌더

[![English](https://img.shields.io/badge/lang-English-blue)](README.md)
[![한국어](https://img.shields.io/badge/lang-한국어-red)](README.ko.md)

DSPico 프로젝트를 Docker로 쉽게 빌드하기

## 빠른 시작

```bash
git clone https://github.com/hanool/dspico-docker-builder.git
cd dspico-docker-builder
./build.sh
```

각 단계에 대한 설명은 아래를 참조하세요.

### 1) Docker 설치

- Docker Desktop 설치: https://www.docker.com/get-started/
- 설치 후 터미널에서 Docker가 동작하는지 확인:

```bash
docker --version
```

### 2) BIOS 파일 준비

펌웨어를 빌드하려면 다음 중 하나가 필요합니다. 처음 DSPico를 구매하면 펌웨어가 이미 설치되어 있으니 일단 넘어가도 괜찮습니다.

- `biosnds7.rom` (권장)
- `ntrBlowfish.bin`

`biosnds7.rom` 덤프 방법:
- https://wiki.ds-homebrew.com/ds-index/ds-bios-firmware-dump

준비한 파일을 `assets/` 폴더에 넣어주세요.

선택 파일:
- TWL 하이브리드/전용 롬 암호화 시:
  - `biosdsi7.rom` 또는 `twlBlowfish.bin`
- `--wrfuxxed` 사용 시:
  - `wrfu.srl` (WRFU Tester v0.60)

### 3) 소스 코드 받기

방법 A (Git 사용):

```bash
git clone https://github.com/hanool/dspico-docker-builder.git
cd dspico-docker-builder
```

방법 B (Git 없이):

- GitHub 저장소 페이지를 엽니다.
- `Code` -> `Download ZIP`을 클릭합니다.
- ZIP 압축을 해제합니다.
- 해제한 `dspico-docker-builder` 폴더에서 터미널을 엽니다.

### 4) 빌드 스크립트 실행 권한 부여 (macOS/Linux)

```bash
chmod +x build.sh
```

### 5) 빌드 실행

`./build.sh`를 실행한 뒤 번호를 선택하세요.

```text
Select build mode:
  1) loader-launcher
  2) firmware
  3) all
Enter choice [1-3]:
```

또는 모드를 직접 지정할 수도 있습니다.

```bash
./build.sh loader-launcher
./build.sh firmware
./build.sh all
```

- `loader-launcher`: Pico Loader + Pico Launcher만 빌드 (BIOS 파일 불필요). SD 카드 복사 준비가 된 파일은 `out/sdcard/`에 생성됩니다.
- `firmware`: DSPico 펌웨어만 빌드 (BIOS 파일 필요)
- `all`: 펌웨어 + 로더 + 런처 모두 빌드 (BIOS 파일 필요)

기본값은 WRFUxxed 비활성화입니다. WRFUxxed 사용 시:

```bash
./build.sh firmware --wrfuxxed
./build.sh all --wrfuxxed
```

펌웨어와 all 모드는 공식 가이드를 기준으로 동작합니다.
- https://github.com/LNH-team/dspico/blob/develop/GUIDE.md

## 출력

결과물은 `out/`에 생성됩니다.

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
    uartBufv060.bin    # --wrfuxxed 사용 시에만 생성
```

SD 카드 준비는 `out/sdcard/` 안의 내용을 SD 카드 루트에 그대로 복사하면 됩니다.
