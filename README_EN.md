# FeverGames Legacy Windows Downloader

> **Download the ready-to-use [v1.4.2 Release ZIP](https://github.com/yuyu107/FeverGames-LegacyWindows-Downloader/releases/download/v1.4.2/FGWin7_v1.4.2.zip). Do NOT use GitHub's Code → Download ZIP for installation.** That downloads source code, not the stable package. The release ZIP contains Chinese launchers including `01_一键安装.cmd` and `05_独立下载_检查更新与修复.cmd`.

Community compatibility support for the FeverGames download pipeline on **Windows 7 SP1 x64**.

Current stable release: **v1.4.2**.

- [Download v1.4.2](https://github.com/yuyu107/FeverGames-LegacyWindows-Downloader/releases/tag/v1.4.2)
- [Changelog](CHANGELOG.md)
- [v1.4.2 Release Notes](docs/releases/v1.4.2.md)

v1.4.2 includes support for a verified FeverGames 1.18.45.8 frontend layout and Auto Profile v2, while retaining v1.4.1 legacy GZip download compatibility and the base App ID selector. The default App ID on Enter is 81 (Minecraft Bedrock cross-platform edition). Experimental GamePicker list/online search is not included.

The `01_Zero_Start_One_Click_Install.cmd` in the GitHub source tree is a **historical developer bootstrap**, NOT the v1.4.2 installer. It now requires typing `DEV` before running. Historical compressed source has been restored to a decodable revision.

The standalone downloader supports newer Manifest/Index/Chunk distribution flows; games using Aria2/classic downloads still require the official FeverGames client. This project helps with downloads, not the game's own OS compatibility.
