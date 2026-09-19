# FeverGames Legacy Windows Downloader

A community compatibility project that restores the newer FeverGames game-download backend on **Windows 7 SP1 x64**.

Current stable release: **v1.3.5**

- [Download v1.3.5](https://github.com/yuyu107/FeverGames-LegacyWindows-Downloader/releases/tag/v1.3.5)
- [Changelog](CHANGELOG.md)
- [v1.3.5 Release Notes](docs/releases/v1.3.5.md)

> This project fixes **FeverGames download-pipeline compatibility**. It does not make every downloaded game itself compatible with Windows 7.

## What it does

The project combines:

- exact-byte patch profiles for verified `FeverGamesInstaller.exe` layouts;
- a Windows 7-compatible managed replacement for `downloadIPC.exe`;
- Manifest / Index / Chunk retrieval, reconstruction and integrity checks;
- an in-process **libzstd.dll 1.5.6** backend for Zstandard data;
- install, status, restore and diagnostic workflows.

Unknown or changed frontend layouts are rejected unless all five exact target locations match a known profile.

## Verified configurations

| Environment / build | Status |
|---|---|
| Windows 7 SP1 x64 | ✅ Primary target, real-machine verified |
| FeverGames 1.18.42.12 / layout A | ✅ Verified |
| FeverGames 1.18.42.14 / layout A | ✅ Verified |
| FeverGames 1.18.42.14 / layout B | ✅ Verified |
| FeverGames 1.18.43.22 / layout A | ✅ Full download and game launch verified |
| Windows 8.1 | ℹ️ Official downloader currently works directly in normal cases |
| Windows 10 / 11 | ℹ️ Outside this project's target; prefer the official client |

See [compatibility notes](docs/COMPATIBILITY.md) for details.

## Download and quick start

Use the Release ZIP for normal use:

**[FeverGames Legacy Windows Downloader v1.3.5](https://github.com/yuyu107/FeverGames-LegacyWindows-Downloader/releases/tag/v1.3.5)**

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

v1.3.5 bundles `libzstd.dll 1.5.6 x64`, so users **no longer need to install 7-Zip or zstd.exe**.

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

7-Zip is no longer a runtime prerequisite for the Release ZIP.

Highly stripped or modified Windows 7 images may fail if PowerShell, the .NET compiler, UAC, or other base components were removed. See [environment requirements](docs/ENVIRONMENT.md).

## v1.3.5 Zstandard backend

The stable downloader now calls Zstandard in-process:

```text
downloadIPC.exe
  -> P/Invoke
  -> libzstd.dll 1.5.6
  -> ZSTD_decompressStream
```

The standalone P/Invoke path was verified on Windows 7 SP1 x64 under CLR 2.0, and a real FeverGames download completed without using 7-Zip.

Experimental Test2/Test3/Test4 builds also explored file-level and chunk-level concurrency. Those tuning parameters are intentionally **not included in the stable v1.3.5 build**, because different games can have very different manifests, file counts, chunk distributions and CDN behavior.

## Safety and rollback

The installer does not trust a folder version alone. It checks the five target byte sequences against known profiles before making changes.

A rollback backup is created before replacement. The SHA-256 of a patch-supplied `libzstd.dll` is recorded; restore removes that DLL only when it is still unchanged.

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
- [v1.3.5 Release Notes](docs/releases/v1.3.5.md)
- [Third-party notices](docs/THIRD_PARTY_NOTICES.md)

Project-authored code, scripts and documentation are licensed under the MIT License. Zstandard/libzstd is used under its BSD license option; see the third-party notices for details.
