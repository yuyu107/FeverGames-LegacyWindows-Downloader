# FeverGames Legacy Windows Downloader

A community compatibility project for the FeverGames download pipeline on **Windows 7 SP1 x64**.

Current stable release: **v1.4.0**

- [Download v1.4.0](https://github.com/yuyu107/FeverGames-LegacyWindows-Downloader/releases/tag/v1.4.0)
- [Changelog](CHANGELOG.md)
- [v1.4.0 Release Notes](docs/releases/v1.4.0.md)

v1.4.0 keeps the existing exact-byte / Auto Profile frontend patch and adds a standalone Manifest/Index/Chunk downloader, installed-game update checks and repair, plus a separate `downloadIPC.exe`-only patch mode.

The standalone downloader supports the newer FeverGames distribution chain (`Manifest -> Index -> AES-CTR -> Zstd -> Protobuf -> Chunk -> Build -> MD5`). Games that use Aria2 / the classic download path should still be downloaded through the official FeverGames client.

The exact v1.4.0 Release source snapshot is stored under `src/v1.4.0/`. Third-party `libzstd.dll` binaries are not committed to the source repository; use the GitHub Release ZIP for normal use.

This project fixes download-pipeline compatibility; it does not guarantee that every downloaded game itself runs on Windows 7.
