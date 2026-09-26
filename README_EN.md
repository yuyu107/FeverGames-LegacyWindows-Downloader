# FeverGames Legacy Windows Downloader

A community compatibility project that restores the newer FeverGames game-download backend on **Windows 7 SP1 x64**.

Current stable release: **v1.3.7**

- [Download v1.3.7](https://github.com/yuyu107/FeverGames-LegacyWindows-Downloader/releases/tag/v1.3.7)
- [Changelog](CHANGELOG.md)
- [v1.3.7 Release Notes](docs/releases/v1.3.7.md)

v1.3.7 promotes the tested **Index-stage optimizations and balanced Chunk / Build pipeline** into the stable release and adds an experimental **Auto Profile** fallback for unknown frontend layouts. Known builds still use Built-in Exact Profiles first. Auto Profile has not yet been validated against a genuinely newer FeverGames release.

> This project fixes **FeverGames download-pipeline compatibility**. It does not make every downloaded game itself compatible with Windows 7.

## What it does

The project combines:

- exact-byte patch profiles for verified `FeverGamesInstaller.exe` layouts;
- an experimental Auto Profile structural-detection fallback for unknown layouts, gated by full validation;
- a Windows 7-compatible managed replacement for `downloadIPC.exe`;
- Manifest / Index / Chunk retrieval, reconstruction and integrity checks;
- an in-process **libzstd.dll 1.5.6** backend for Zstandard data;
- optimized Index preparation and a balanced Chunk / Build pipeline;
- install, status, restore and diagnostic workflows.

## Verified configurations

| Environment / build | Status |
|---|---|
| Windows 7 SP1 x64 | ✅ Primary target, real-machine verified |
| FeverGames 1.18.42.12 / layout A | ✅ Verified |
| FeverGames 1.18.42.14 / layout A | ✅ Verified |
| FeverGames 1.18.42.14 / layout B | ✅ Verified |
| FeverGames 1.18.43.22 / layout A | ✅ Full download and game launch verified |
| FeverGames 1.18.44.2 / layout A | ✅ Full download, game launch and world entry verified |
| Unknown future build / layout | ⚠️ Experimental Auto Profile; not yet validated on a truly newer build |
| Windows 8.1 | ℹ️ Official downloader currently works directly in normal cases |
| Windows 10 / 11 | ℹ️ Outside this project's target; prefer the official client |

Known layouts are handled through Built-in Exact Profiles. If no known profile matches, v1.3.7 may attempt experimental Auto Profile structural detection. It proceeds only when every required target passes structural and byte validation; otherwise it stops safely.

See [compatibility notes](docs/COMPATIBILITY.md) for details.

## Download and quick start

Use the Release ZIP for normal use:

**[FeverGames Legacy Windows Downloader v1.3.7](https://github.com/yuyu107/FeverGames-LegacyWindows-Downloader/releases/tag/v1.3.7)**

Release layout:

```text
01_一键安装.cmd
02_检查状态.cmd
03_恢复官方文件.cmd
04_收集诊断.cmd
使用说明.txt
core\
```

1. Install/update FeverGames normally.
2. Extract the entire Release ZIP. Do not run CMD files directly from the ZIP view.
3. Fully exit FeverGames.
4. Run `01_一键安装.cmd`.

The Release ZIP bundles `libzstd.dll 1.5.6 x64`, so users **do not need to install 7-Zip or zstd.exe**.

A ready installation should include:

```text
Frontend patch count: 5/5
downloadIPC.exe = managed Win7 replacement
decoder = libzstd.dll ... (in-process)
rollback backup = COMPLETE
RESULT=READY_FOR_WIN7_FEVERGAMES_DOWNLOAD
```

## System requirements

The recommended target is a reasonably intact **Windows 7 SP1 x64** installation with:

- `cmd.exe`;
- `powershell.exe`;
- a usable `csc.exe` from .NET Framework 2.0 / 3.5 / 4.x;
- administrator access;
- normal registry, process and file-system functionality.

Highly stripped or modified Windows 7 images may fail if PowerShell, the .NET compiler, UAC, or other base components were removed. See [environment requirements](docs/ENVIRONMENT.md).

## v1.3.7 download pipeline

v1.3.7 includes the tuning that remained stable during the test series:

- the Manifest is parsed before entering the Index stage, so the Index total size is available immediately;
- Index requests keep Manifest order instead of sorting by final file size;
- Index concurrency uses 64 workers on HDD and 96 on SSD, with a higher HTTP connection limit;
- Index data follows an in-memory `AES-CTR -> libzstd -> Protobuf` path, reducing temporary-file I/O, synchronous hot-path logging, and repeated AES-key probing;
- the main download uses a balanced Chunk / Build pipeline: HDD `8 + 6 + 1`, SSD `12 + 10 + 2`.

Actual throughput still depends on the game, CDN node, disk and network. The Windows 7 replacement downloader is not guaranteed to match the official Windows 10 / 11 downloader's throughput.

## Safety and rollback

The installer never trusts a folder version alone. Known layouts use Built-in Exact Profiles; unknown layouts may enter the experimental Auto Profile fallback. Both paths require complete validation before any patch is accepted.

A rollback backup is created before replacement. The SHA-256 of a patch-supplied `libzstd.dll` is recorded; restore removes that DLL only when it is still unchanged.

> **Auto Profile is not a promise of future-version compatibility.** There is currently no genuinely newer FeverGames build available for validation. New layouts should be tested first and then promoted to a Built-in Exact Profile after verification.

This project does not bypass account login or content entitlement and does not distribute game content. Do not publish PRIVATE Manifest responses, AES keys, tokens/cookies, device identifiers, signatures, or security keys.

## Source checkout

The packed managed downloader source is stored as:

```text
src/downloadIPC_Win7_v1.2.cs.gz.b64
```

`scripts/current/Prepare_Source_v1.2.ps1` reconstructs it before compilation.

The Release ZIP bundles `libzstd.dll`. A source checkout does not store the third-party DLL binary; for source testing, place the official Zstandard v1.5.6 x64 `libzstd.dll` at:

```text
tools\libzstd.dll
```

## Documentation

- [Documentation index](docs/README.md)
- [Compatibility notes](docs/COMPATIBILITY.md)
- [Environment requirements](docs/ENVIRONMENT.md)
- [Technical notes](docs/TECHNICAL.md)
- [Changelog](CHANGELOG.md)
- [v1.3.7 Release Notes](docs/releases/v1.3.7.md)
- [Third-party notices](docs/THIRD_PARTY_NOTICES.md)

Project-authored code, scripts and documentation are licensed under the MIT License. Zstandard/libzstd is used under its BSD license option; see the third-party notices for details.
