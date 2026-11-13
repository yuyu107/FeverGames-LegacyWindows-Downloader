# 发烧游戏旧版 Windows 下载器

英文项目名：**FeverGames Legacy Windows Downloader**

这是一个面向 **Windows 7 SP1 x64** 的社区兼容项目，用于恢复发烧游戏平台的游戏下载、更新和校验修复功能。项目同时处理前端系统版本检查与下载组件的兼容问题。

当前正式版：**v1.5.0**。

> **普通用户请下载 [v1.5.0 正式安装包](https://github.com/yuyu107/FeverGames-LegacyWindows-Downloader/releases/download/v1.5.0/FGWin7_v1.5.0.zip)。**
> GitHub 的 **Code → Download ZIP** 下载的是仓库源码，不是正式安装包。请完整解压后运行中文编号入口。

- [Release 与附件](https://github.com/yuyu107/FeverGames-LegacyWindows-Downloader/releases/tag/v1.5.0)
- [v1.5.0 更新说明](docs/releases/v1.5.0.md)
- [使用说明](docs/使用说明.txt) · [环境要求](docs/ENVIRONMENT.md) · [兼容性记录](docs/COMPATIBILITY.md)
- [反馈问题](https://github.com/yuyu107/FeverGames-LegacyWindows-Downloader/issues/new/choose) · [反馈指南](docs/FEEDBACK.md)

## 为什么需要这个项目

在 Windows 7 上，平台前端可能在发起下载前根据系统版本阻止操作，官方下载组件也存在系统 API 兼容问题。仅修补其中一部分，不一定能恢复完整下载链路。

v1.5.0 对前端进行五点兼容修补，并让已验证的官方 Go 版 `downloadIPC.exe` 在 Win7 上工作，保留官方的下载、暂停恢复、断点保存和文件校验逻辑。此前的 C# 独立下载器继续作为 05 入口保留，用于受支持游戏的独立安装、更新和修复。

本项目解决的是**平台下载兼容性**，不保证下载后的每个游戏本体都能在 Win7 上运行。

## 快速使用

1. 完全退出发烧游戏，包括托盘中的客户端及 `downloadIPC.exe`。
2. 下载并完整解压 `FGWin7_v1.5.0.zip`，建议放在当前用户可写的文件夹。
3. 运行 `01_一键安装.cmd`。自动识别目录、校验、备份并修补，无需输入 `INSTALL`。
4. 安装成功后，正常打开平台下载、更新或修复游戏。

目录和文件可写时直接执行；写入受限时才申请管理员权限。文件被占用也可能导致写入失败，请先退出平台。

已经安装成功的 RC5 无需为了正式版先恢复或重装；重复运行会检查当前已修补状态。

自动识别不到目录时，可以传入版本目录：

```bat
"01_一键安装.cmd" "D:\Program Files\FeverGames\1.18.45.8"
```

## 中文编号入口

| 入口 | 功能 |
| --- | --- |
| `00_Package_SelfCheck.cmd` | 安装包自检，可选运行 |
| `01_一键安装.cmd` | 前端五点补丁与官方 Go 下载组件兼容修补 |
| `02_检查状态.cmd` | 只读检查前端、下载组件与备份状态 |
| `03_恢复官方文件.cmd` | 校验并恢复原版文件，输入 `RESTORE` 执行 |
| `04_收集诊断.cmd` | 保存版本目录、两个 EXE 的哈希及备份存在状态 |
| `05_独立下载_检查更新与修复.cmd` | 独立下载安装、更新和校验修复 |
| `06_仅修补downloadIPC.cmd` | 仅修补官方 Go 下载组件，不修改前端 |

## 两条下载路径与依赖

| 路径 | 实现与依赖 |
| --- | --- |
| 平台内下载（01/06 修补后） | 官方 Go 核心；安装器使用 WSH、MSXML3/6、ADODB.Stream、certutil，无需 PowerShell、Python 或 .NET 编译 |
| 05 独立下载器 | 沿用 v1.4.2 的 PowerShell/C# 实现，需要 PowerShell、兼容的 .NET C# 编译器及包内 `app/libzstd.dll` |

05 直接回车默认 App ID `81`（我的世界基岩互通版），支持自选安装目录、已有安装检测、更新和校验修复，保留 Zstd 与 Legacy AES-CTR + GZip 支持。首次运行会在 `app` 目录编译核心，请保持该目录可写。

部分 Aria2/经典分发游戏不适用于 05，请使用平台原生下载。05 尚未改为官方 Go 核心；在线游戏列表/搜索等 GamePicker 实验功能不包含在正式包中。

## 自动识别范围

前端内置精确配置：`1.18.42.12-A`、`1.18.42.14-A/B`、`1.18.43.22-A`、`1.18.44.2-A`、`1.18.45.8-A/B`。没有精确匹配时，只有通过 Auto Profile v2 的结构验证才允许修补。

Go 组件支持已验证的 A/B/C 签名变体，以及程序主体哈希相同的其他签名变体。**重新编译、程序主体改变的新 Go 构建仍需适配**；当前没有通用 Go 结构迁移能力，不承诺所有未来版本自动兼容。

内置旧前端配置不等于它们与新 Go 核心的全部组合都已重新实测。当前 v1.5.0 核心测试集中在 FeverGames `1.18.45.8`，详见[兼容性记录](docs/COMPATIBILITY.md)。

## 备份与恢复

原版文件保存在对应版本目录下的 `.FGWin7_150_Backup`。安装、恢复及失败回滚会核对文件哈希，兼容旧版已知备份位置。恢复成功后保留备份，再次安装可复用通过校验的原版备份。

请保留备份。修改 EXE 后原有数字签名会失效；本包不分发网易官方完整 EXE。平台更新后若出现未知布局或 Go 构建，请通过 Issue 模板提交状态输出，不要跳过校验强行覆盖。

## 验证情况

官方 Go 方案已在 Win7 虚拟机完成完整下载、迅速暂停恢复、重启续传及校验修复；RC5 已在实体机 Win7 上修补并完成游戏下载。正式版沿用相同的核心补丁配置。

正式包已通过离线字节、哈希和 ZIP 完整性检查；新增按需提权流程及最终组合尚未完成 Win7 实机回归。

## 源码与历史实现

仓库根目录的英文 CMD、`scripts/current/` 及压缩源码快照主要保留早期实现，**不等同于 v1.5.0 正式安装入口**。v1.5.0 平台安装脚本为正式 ZIP 内的 `FG150_*.vbs/.cmd`。参见[源码索引](src/README.md)及[技术说明](docs/TECHNICAL.md)。

- [更新日志](CHANGELOG.md) · [文档索引](docs/README.md)
- [第三方组件](docs/THIRD_PARTY_NOTICES.md) · [校验值](docs/releases/checksums/v1.5.0.txt)

项目自行编写的代码、脚本与文档采用 [MIT License](LICENSE)。Zstandard/libzstd 按其 BSD 条款再分发，见包内及仓库中的许可文本。
