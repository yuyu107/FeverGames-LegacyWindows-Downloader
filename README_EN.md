# FeverGames Legacy Windows Downloader v1.3.0

A community compatibility project that restores the newer FeverGames download backend on **Windows 7 SP1 x64**.

The stable v1.3.0 release has verified frontend patch profiles for FeverGames **1.18.42.12** and **1.18.42.14**. The replacement downloader reads the game/content version dynamically and is not hard-coded to one Minecraft build.

## Highlights

- Windows 7 SP1 x64 end-to-end download verified.
- FeverGames 1.18.42.12 and 1.18.42.14 verified.
- Automatically selects the newest complete numeric FeverGames version folder.
- Exact-byte frontend validation; unknown layouts stop safely.
- Compatible with older Windows PowerShell 2.0 / .NET 3.5 environments.
- Automatic backup, status check, restore, and privacy-safe diagnostics.
- ZMTP/ZMQ heartbeat, pause/resume/cancel, Manifest, AES-CTR, Zstd, protobuf SumHead, chunks, SumBuf reconstruction, MD5, progress, and completion state are implemented.

## Quick start

1. Install/update FeverGames normally and fully exit it.
2. Install a `.zst`-capable 7-Zip, or place a Windows 7 compatible `zstd.exe` in `tools\zstd.exe`.
3. Run:

```text
01_Zero_Start_One_Click_Install.cmd
```

Then verify with:

```text
02_Check_Status.cmd
```

A ready installation ends with:

```text
Frontend patch count: 5/5
downloadIPC.exe = managed Win7 replacement
RESULT=READY_FOR_WIN7_FEVERGAMES_DOWNLOAD
```

Restore the official files with:

```text
03_Restore_Official_Original.cmd
```

Collect diagnostics with:

```text
04_Collect_Diagnostics.cmd
```

## Known performance behavior

v1.3.0 prioritizes compatibility and correctness. The replacement .NET downloader can be slower than the official downloader on Windows 8.1, particularly during large-file local reconstruction/MD5 and the final stage with many tiny chunks/files. A temporary 0 B/s display can represent local build/verification rather than a network failure.

Experimental parallel/pipelined downloader changes are intentionally not included in this stable release.

## Privacy and scope

This project does not bypass account login or content entitlement and does not distribute game content. Do not publish PRIVATE Manifest responses, AES keys, tokens/cookies, device identifiers, signatures, security keys, proprietary FeverGames executables, or game files.

Project-authored code/scripts/docs are licensed under the MIT License. Third-party software and content remain the property of their respective owners.
