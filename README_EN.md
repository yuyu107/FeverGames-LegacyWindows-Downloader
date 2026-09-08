# FeverGames Legacy Windows Downloader v1.3.3

A community compatibility project that restores the newer FeverGames download backend on **Windows 7 SP1 x64**.

v1.3.3 is the current recommended stable release. Since the v1.3.2 release was removed, v1.3.3 includes both:

1. the v1.3.2 PowerShell 2.0 / older-CLR managed EXE validation fix;
2. the v1.3.3 Release CMD encoding / line-ending fix.

It keeps the already end-to-end verified v1.2 .NET download core, the five exact-byte frontend patch points, layout A/B handling, custom-path detection, backup/restore, and UAC flow unchanged.

## Download

Current stable release: **v1.3.3**

https://github.com/yuyu107/FeverGames-LegacyWindows-Downloader/releases/tag/v1.3.3

Release ZIP:

```text
01_一键安装.cmd
02_检查状态.cmd
03_恢复官方文件.cmd
04_收集诊断.cmd
使用说明.txt
core\
```

A source checkout keeps only the CMD entry points in the repository root. PowerShell implementation details are organized under `scripts/`.

## Repository layout

```text
/
├─ 01_Zero_Start_One_Click_Install.cmd
├─ 02_Check_Status.cmd
├─ 03_Restore_Official_Original.cmd
├─ 04_Collect_Diagnostics.cmd
├─ 05_Clear_Win7_Downloader_Cache_Optional.cmd
├─ scripts/
│  ├─ current/          # current v1.3.x implementation
│  └─ legacy-v1.2/      # historical v1.2 scripts
├─ docs/
│  ├─ COMPATIBILITY.md
│  ├─ TECHNICAL.md
│  └─ releases/         # historical release notes and checksums
└─ src/                 # packed downloadIPC C# source
```

- [Compatibility notes](docs/COMPATIBILITY.md)
- [Technical notes](docs/TECHNICAL.md)
- [Documentation index](docs/README.md)
- [v1.3.3 Release Notes](docs/releases/v1.3.3.md)

Normal users should prefer the Release ZIP. `scripts/legacy-v1.2/` is retained only for historical reference, regression work, and old-install recovery context.

## v1.3.3 integrated fixes

### 1. Managed EXE validation fix retained from v1.3.2

On some relatively stock Windows 7 / PowerShell 2.0 systems, v1.3.1 could successfully invoke the .NET 4 C# compiler and create the replacement downloader, but then stop with:

```text
Compiled downloader did not validate as a managed .NET executable.
```

The issue was the validation method rather than the frontend patch or the C# compilation itself. Older scripts asked the current PowerShell CLR to load/identify the newly compiled assembly. An older CLR can fail that operation even when the file itself is a valid newer managed executable.

The installer and status checker now validate managed executables by reading the PE Optional Header and checking the **CLR / COM Descriptor** directly. Invalid PE/CLR output still fails safely before replacement.

### 2. Release CMD encoding / line-ending fix in v1.3.3

The removed v1.3.2 Release ZIP could contain CMD wrappers that Windows 7 `cmd.exe` parsed incorrectly, causing symptoms such as:

```text
锘緻echo off
powershell.exe -> hell.exe
echo -> ho
goto -> to
```

v1.3.3 Release CMD wrappers are encoded as **BOM-less ASCII with CRLF line endings**, while keeping the Chinese file names such as `01_一键安装.cmd`.

## Verified configurations

- Windows 7 SP1 x64
- FeverGames `1.18.42.12`
- FeverGames `1.18.42.14 / layout A`
- FeverGames `1.18.42.14 / layout B`
- Custom FeverGames root `D:\FeverGames`
- Custom 7-Zip root `D:\7-Zip`
- PowerShell 2.0 / older-CLR managed EXE validation path fixed and re-tested
- Release CMD encoding / line-ending issue fixed and re-tested
- Minecraft Bedrock interoperability edition fully downloaded, launched, and entered a world

Original `FeverGamesInstaller.exe` SHA256 for `1.18.42.14 / layout B`:

```text
0a2a9568ac788227f0815e3c23761cadc11b51ee4ba9b86336cb2abf61e178e9
```

## Quick start

1. Install/update FeverGames normally and fully exit it.
2. Install a `.zst`-capable 7-Zip, or provide a Windows 7 compatible `zstd.exe`.
3. Run `01_一键安装.cmd` from the v1.3.3 Release ZIP, or `01_Zero_Start_One_Click_Install.cmd` from a source checkout.

A ready installation should include:

```text
Frontend patch count: 5/5
downloadIPC.exe = managed Win7 replacement
rollback backup = COMPLETE
RESULT=READY_FOR_WIN7_FEVERGAMES_DOWNLOAD
```

## Performance and scope

v1.3.3 still prioritizes correctness and compatibility. Large-file local reconstruction/MD5 and the final stage with many tiny chunks/files can be slower than the official Windows 8.1 downloader and may temporarily show 0 B/s.

Experimental DLL-based Zstd, parallel, and pipelined downloader changes are intentionally not included in v1.3.3.

This project does not bypass account login or content entitlement and does not distribute game content. Do not publish PRIVATE Manifest responses, AES keys, tokens/cookies, device identifiers, signatures, security keys, proprietary FeverGames executables, or game files.

Project-authored code/scripts/docs are licensed under the MIT License. Third-party software and content remain the property of their respective owners.
