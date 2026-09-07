# FeverGames Legacy Windows Downloader v1.3.1

A community compatibility project that restores the newer FeverGames download backend on **Windows 7 SP1 x64**.

v1.3.1 is a stability and compatibility update over v1.3.0. It keeps the already end-to-end verified v1.2 .NET download core and does not merge the experimental parallel, pipelined, or DLL-based Zstd redesign.

## Highlights

- Windows 7 SP1 x64 end-to-end download verified.
- FeverGames 1.18.42.12 verified.
- FeverGames 1.18.42.14 now supports multiple known binary layouts, including the newly added **layout B** profile.
- Profile selection for same-version layouts requires all five target locations to match exactly; the patcher does not trust the folder version alone.
- Custom FeverGames installation paths are supported through saved paths, uninstall information, shortcuts, common folders, and manual drag-and-drop fallback.
- Custom 7-Zip installation paths are supported through Program Files, registry, PATH, and saved decoder paths.
- UAC flow fixed so the launcher waits for the elevated install process to finish before status verification.
- Windows 7 / PowerShell 2.0 custom path persistence fixed.
- Automatic backup, status check, restore, and privacy-safe diagnostics remain available.

## Download

Current stable release: **v1.3.1**

https://github.com/yuyu107/FeverGames-LegacyWindows-Downloader/releases/tag/v1.3.1

The Release ZIP uses simplified Chinese entry names:

```text
01_一键安装.cmd
02_检查状态.cmd
03_恢复官方文件.cmd
04_收集诊断.cmd
使用说明.txt
core\
```

The source repository keeps the original English script names such as `01_Zero_Start_One_Click_Install.cmd`.

## Verified v1.3.1 configuration

The following configuration has been verified on Windows 7 SP1 x64:

- FeverGames `1.18.42.14 / layout B`
- FeverGames custom root: `D:\FeverGames`
- 7-Zip custom root: `D:\7-Zip`
- Frontend patch: `5/5`
- Managed Win7 `downloadIPC.exe` replacement installed
- Rollback backup complete
- Minecraft Bedrock interoperability edition downloaded completely
- Game launched successfully
- Successfully entered a world

Original `FeverGamesInstaller.exe` SHA256 for `1.18.42.14 / layout B`:

```text
0a2a9568ac788227f0815e3c23761cadc11b51ee4ba9b86336cb2abf61e178e9
```

## Quick start

1. Install/update FeverGames normally and fully exit it.
2. Install a `.zst`-capable 7-Zip, or place a Windows 7 compatible `zstd.exe` in `tools\zstd.exe`.
3. For the v1.3.1 Release ZIP, run:

```text
01_一键安装.cmd
```

For a source checkout, run:

```text
01_Zero_Start_One_Click_Install.cmd
```

If automatic FeverGames discovery fails, the installer can accept a dragged FeverGames root folder, numeric version folder, or `FeverGamesInstaller.exe`.

A ready installation should include:

```text
Patch profile: 1.18.42.14 / layout B
Frontend patch count: 5/5
downloadIPC.exe = managed Win7 replacement
rollback backup = COMPLETE
RESULT=READY_FOR_WIN7_FEVERGAMES_DOWNLOAD
```

## Known performance behavior

v1.3.1 prioritizes compatibility and correctness. The replacement .NET downloader can be slower than the official downloader on Windows 8.1, particularly during large-file local reconstruction/MD5 and the final stage with many tiny chunks/files. A temporary 0 B/s display can represent local build/verification rather than a network failure.

Experimental DLL-based Zstd, parallel, and pipelined downloader changes are intentionally not included in v1.3.1.

## Privacy and scope

This project does not bypass account login or content entitlement and does not distribute game content. Do not publish PRIVATE Manifest responses, AES keys, tokens/cookies, device identifiers, signatures, security keys, proprietary FeverGames executables, or game files.

Project-authored code/scripts/docs are licensed under the MIT License. Third-party software and content remain the property of their respective owners.
