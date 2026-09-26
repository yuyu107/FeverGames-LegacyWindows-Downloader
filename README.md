# 发烧游戏旧版 Windows 下载器

英文项目名：**FeverGames Legacy Windows Downloader**

这是一个面向 **Windows 7 SP1 x64** 的社区兼容项目，用于恢复 **发烧游戏（FeverGames）新版游戏下载后端** 在旧系统上的运行能力。

当前正式版：**v1.3.7**

- [下载最新正式版](https://github.com/yuyu107/FeverGames-LegacyWindows-Downloader/releases/tag/v1.3.7)
- [查看更新日志](CHANGELOG.md)
- [查看 v1.3.7 Release Notes](docs/releases/v1.3.7.md)

v1.3.7 将实机测试中验证可用的 **Index 下载优化、平衡型 Chunk / Build 管线**整理为正式版，并加入实验性的 **Auto Profile** 结构识别备用路径。已知版本仍优先使用 Built-in Exact Profile；Auto Profile 尚未经过真正未来新版 FeverGames 的实机验证。

> [!IMPORTANT]
> 本项目解决的是 **发烧游戏平台的游戏下载流程兼容**，不是游戏本体的 Windows 7 运行兼容。
>
> 如果你要解决中国版《我的世界》基岩客户端在 Windows 7 / Windows 8.1 上的启动问题，请查看 [MCBedrock-LegacyWindows](https://github.com/yuyu107/MCBedrock-LegacyWindows)。

## 这个项目解决什么？

新版 FeverGames 的下载链在 Windows 7 上存在兼容问题，可能导致游戏下载无法开始、下载后端无法运行或任务无法正常完成。

本项目通过：

- 对已验证的 `FeverGamesInstaller.exe` 前端布局进行 5 点精确字节匹配与兼容修补；
- 对未收录的新布局提供实验性的 Auto Profile 结构识别备用路径，只有全部目标通过验证才允许继续；
- 使用 Windows 7 可运行的 .NET `downloadIPC.exe` 替代原版新下载后端；
- 进程内调用 **libzstd.dll 1.5.6** 解压 Zstandard 数据；
- 保留 Manifest、Index、Chunk、文件重组和最终校验流程；
- 在 v1.3.7 中优化 Index 阶段和 Chunk / Build 下载管线；
- 提供安装、状态检查、官方文件恢复和诊断入口；

让受支持的 FeverGames 版本可以继续在 Windows 7 上完成游戏下载。

## 当前兼容情况

| 环境 / 版本 | 状态 |
|---|---|
| Windows 7 SP1 x64 | ✅ 主要目标系统，已完成实机验证 |
| FeverGames 1.18.42.12 / layout A | ✅ 已验证 |
| FeverGames 1.18.42.14 / layout A | ✅ 已验证 |
| FeverGames 1.18.42.14 / layout B | ✅ 已验证 |
| FeverGames 1.18.43.22 / layout A | ✅ 已验证完整下载并进入游戏 |
| FeverGames 1.18.44.2 / layout A | ✅ 已验证完整下载、启动并进入世界 |
| 未知未来版本 / 未知布局 | ⚠️ 实验性 Auto Profile；尚未经过真正新版实机验证 |
| Windows 8.1 | ℹ️ 官方新版 downloader 当前可直接使用，通常无需本项目 |
| Windows 10 / 11 | ℹ️ 不属于本项目目标，应优先使用官方程序 |

> [!NOTE]
> FeverGames 的**版本文件夹名称不能单独代表二进制布局**。已知版本优先使用 Built-in Exact Profile 并检查 5 个目标位置；没有已知 profile 时才尝试实验性的 Auto Profile。只有全部目标通过结构与字节验证才会继续，否则安全停止。

更完整的测试记录见：[兼容性记录](docs/COMPATIBILITY.md)。

## 下载与使用

普通用户建议直接下载 Release ZIP：

**[FeverGames Legacy Windows Downloader v1.3.7](https://github.com/yuyu107/FeverGames-LegacyWindows-Downloader/releases/tag/v1.3.7)**

解压后会看到：

```text
01_一键安装.cmd
02_检查状态.cmd
03_恢复官方文件.cmd
04_收集诊断.cmd
使用说明.txt
core\
```

使用步骤：

1. 正常安装 / 更新 FeverGames；
2. **完整解压 Release ZIP**，不要直接在压缩包里运行 CMD；
3. **完全退出发烧游戏平台**；
4. 运行 `01_一键安装.cmd`。

Release ZIP 已经自带 `libzstd.dll 1.5.6`，**不需要另外安装 7-Zip 或 zstd.exe**。

安装完成后可运行 `02_检查状态.cmd`。正常结果应包含：

```text
Frontend patch count: 5/5
downloadIPC.exe = managed Win7 replacement
decoder = libzstd.dll ... (in-process)
rollback backup = COMPLETE
RESULT=READY_FOR_WIN7_FEVERGAMES_DOWNLOAD
```

需要恢复 FeverGames 官方文件时运行 `03_恢复官方文件.cmd`；遇到问题时运行 `04_收集诊断.cmd`。

## 系统环境要求

推荐使用接近原版的 **Windows 7 SP1 x64**。安装器需要系统保留：

- `cmd.exe`
- `powershell.exe`
- .NET Framework 2.0 / 3.5 / 4.x 中至少一个可用的 `csc.exe`
- 管理员权限
- 基本注册表、文件系统和进程查询能力

**不再要求安装 7-Zip。** Release ZIP 中已经包含 Win7 实机验证过的 `libzstd.dll 1.5.6 x64`。

深度精简版 / Ghost / 魔改 Windows 7 如果删除了 PowerShell、.NET 编译器、UAC 或其它基础组件，安装器可能无法正常运行。详细说明见：[系统环境要求](docs/ENVIRONMENT.md)。

## 安全与回滚

项目不会只根据 FeverGames 版本号直接修改文件。

已知布局优先使用 Built-in Exact Profile；未知布局只会进入实验性 Auto Profile 结构识别。无论走哪条路径，都必须完成全部目标验证，失败时会安全停止。安装前会为官方文件建立 rollback backup；安装后的验证失败时也会尽量自动回滚。

安装时复制的 `libzstd.dll` 会记录 SHA-256；恢复官方文件时，只有在该 DLL 仍与安装时记录一致的情况下才会删除，避免误删用户后来替换的文件。

> [!WARNING]
> Auto Profile 是面向未来未知布局的备用机制，目前没有真正更新后的 FeverGames 版本可供验证，因此**不能视为对未来版本兼容性的保证**。新版本出现后应先实测，确认后再将布局固化为 Built-in Exact Profile。

项目不实现账号登录绕过、内容授权绕过或游戏文件分发。公开 Issue、日志和诊断信息中请不要上传 PRIVATE Manifest response、AES key、Token / Cookie、deviceId / uid、sig / secKey 等账号或临时鉴权信息。

## v1.3.7 性能说明

v1.3.7 将此前测试版中验证较稳定的下载优化整理进正式版：

- Manifest 先完成解析，再进入 Index 状态，因此索引总大小可以在阶段开始时直接获得；
- Index 保持 Manifest 原始顺序，避免按最终文件大小排序后把大量小 Index 集中到尾段；
- Index 并发：HDD 64 worker / SSD 96 worker，并提高 HTTP 连接上限；
- Index 使用内存中的 `AES-CTR -> libzstd -> Protobuf` 路径，减少临时文件 I/O、同步日志和重复 AES Key 探测；
- 主下载采用平衡型 Chunk / Build 管线：HDD `8 + 6 + 1`，SSD `12 + 10 + 2`。

不同游戏、CDN 节点、磁盘和网络环境仍可能产生明显速度差异。Windows 7 下的替代 downloader 不保证达到 Windows 10 / 11 官方 downloader 的同等吞吐。

## 文档

- [文档索引](docs/README.md)
- [兼容性记录](docs/COMPATIBILITY.md)
- [系统环境要求](docs/ENVIRONMENT.md)
- [技术说明](docs/TECHNICAL.md)
- [更新日志](CHANGELOG.md)
- [v1.3.7 Release Notes](docs/releases/v1.3.7.md)
- [历史 Release Notes / SHA-256](docs/releases/)
- [第三方组件说明](docs/THIRD_PARTY_NOTICES.md)

## 源码仓库结构

```text
/
├─ 01_Zero_Start_One_Click_Install.cmd
├─ 02_Check_Status.cmd
├─ 03_Restore_Official_Original.cmd
├─ 04_Collect_Diagnostics.cmd
├─ 05_Clear_Win7_Downloader_Cache_Optional.cmd
├─ scripts/
│  ├─ current/
│  └─ legacy-v1.2/
├─ tools/
├─ docs/
└─ src/
```

普通用户优先使用 Release ZIP。源码根目录中的英文 CMD 入口主要用于开发与测试；从源码运行时需要自行把官方 Zstandard v1.5.6 x64 的 `libzstd.dll` 放到 `tools\libzstd.dll`。

## License

本项目自行编写的代码、脚本和文档采用 [MIT License](LICENSE)。

Zstandard / libzstd 按其 BSD License 条款使用和再分发，详见 [第三方组件说明](docs/THIRD_PARTY_NOTICES.md)。其它第三方软件、商标、游戏内容及相关资源的权利归各自权利人所有。
