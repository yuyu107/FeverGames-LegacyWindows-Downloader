# FeverGames Legacy Windows Downloader

Community download compatibility support for **Windows 7 SP1 x64**. Current stable release: **v1.5.0**.

**Download the [ready-to-use v1.5.0 ZIP](https://github.com/yuyu107/FeverGames-LegacyWindows-Downloader/releases/download/v1.5.0/FGWin7_v1.5.0.zip).** GitHub's Code → Download ZIP downloads repository sources, not the release installer.

## Getting started

1. Exit FeverGames completely, including the tray client and `downloadIPC.exe`.
2. Fully extract the release ZIP into a writable folder.
3. Run `01_一键安装.cmd`. It detects the installation, validates files, saves backups and applies the frontend and official Go downloader patches without an INSTALL prompt.
4. Use FeverGames normally to download, update or repair games. Elevation is requested only if the write check fails.

## Download paths

| Path | Implementation and requirements |
| --- | --- |
| Platform downloads after 01/06 | Patched official Go downloader. The installer uses WSH, MSXML3/6, ADODB.Stream and certutil; no PowerShell, Python or C# compilation is needed. |
| 05 standalone download/update/repair | Preserves the v1.4.2 PowerShell/C# implementation, requiring PowerShell, a compatible .NET C# compiler and bundled `app/libzstd.dll`. Enter defaults to App ID 81. |

05 supports the Manifest/Index/Chunk pipeline, including Zstd and legacy AES-CTR/GZip. Aria2/classic downloads should use the platform. The standalone core has not been replaced with the official Go core.

Frontend detection uses exact profiles followed by strict Auto Profile v2 structural checks. Go detection supports known builds and identical program bodies with different signatures; recompiled Go builds still require adaptation. Future-version compatibility is not guaranteed.

The Go approach passed download, pause/resume, restart continuation and repair tests on Win7. RC5 also patched and downloaded successfully on a physical Win7 machine. The final package retains those patch algorithms; its new conditional-elevation flow has not completed a further Win7 runtime regression test.

Backups are stored in `.FGWin7_150_Backup` under the client version folder. Use 02 for status, 03 for restoration, 04 for diagnostics and 06 for Go-only patching. Modified EXEs no longer retain a valid original signature. Compatibility of each downloaded game itself is outside this project's scope.

The repository's root English CMD scripts and `scripts/current/` are historical developer paths, not the v1.5.0 installer.

- [Chinese README](README.md)
- [Release notes](docs/releases/v1.5.0.md)
- [Report an issue](https://github.com/yuyu107/FeverGames-LegacyWindows-Downloader/issues/new/choose)
- [Feedback guide](docs/FEEDBACK.md)
- [Source index](src/README.md)
