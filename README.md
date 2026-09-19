# 发烧游戏旧版 Windows 下载器

英文项目名：**FeverGames Legacy Windows Downloader**

这是一个面向 **Windows 7 SP1 x64** 的社区兼容项目，用于恢复 **发烧游戏（FeverGames）新版游戏下载后端** 在旧系统上的运行能力。

当前正式版：**v1.3.5**

- [下载最新正式版](https://github.com/yuyu107/FeverGames-LegacyWindows-Downloader/releases/tag/v1.3.5)
- [查看更新日志](CHANGELOG.md)
- [查看 v1.3.5 Release Notes](docs/releases/v1.3.5.md)

> [!IMPORTANT]
> 本项目解决的是 **发烧游戏平台的游戏下载流程兼容**，不是游戏本体的 Windows 7 运行兼容。
>
> 如果你要解决中国版《我的世界》基岩客户端在 Windows 7 / Windows 8.1 上的启动问题，请查看 [MCBedrock-LegacyWindows](https://github.com/yuyu107/MCBedrock-LegacyWindows)。

## 这个项目解决什么？

新版 FeverGames 的下载链在 Windows 7 上存在兼容问题，可能导致游戏下载无法开始、下载后端无法运行或任务无法正常完成。

本项目通过：

- 对已验证的 `FeverGamesInstaller.exe` 前端布局进行精确字节匹配与兼容修补；
- 使用 Windows 7 可运行的 .NET `downloadIPC.exe` 替代原版新下载后端；
- 在 v1.3.5 中改为进程内调用 **libzstd.dll 1.5.6** 解压 Zstandard 数据；
- 保留下载任务所需的 Manifest、Index、Chunk、文件重组和校验流程；
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
| Windows 8.1 | ℹ️ 官方新版 downloader 当前可直接使用，通常无需本项目 |
| Windows 10 / 11 | ℹ️ 不属于本项目目标，应优先使用官方程序 |

> [!NOTE]
> FeverGames 的**版本文件夹名称不能单独代表二进制布局**。同一个版本号可能出现不同布局，因此安装器会检查 5 个目标位置是否与已知 profile 完整匹配；未知或发生变化的布局会安全停止，不会强行修改。

更完整的测试记录见：[兼容性记录](docs/COMPATIBILITY.md)。

## 下载与使用

普通用户建议直接下载 Release ZIP：

**[FeverGames Legacy Windows Downloader v1.3.5](https://github.com/yuyu107/FeverGames-LegacyWindows-Downloader/releases/tag/v1.3.5)**

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
4. 运行：

```text
01_一键安装.cmd
```

v1.3.5 Release ZIP 已经自带 `libzstd.dll`，**不再要求用户另外安装 7-Zip 或 zstd.exe**。

安装完成后可运行：

```text
02_检查状态.cmd
```

正常结果应包含：

```text
Frontend patch count: 5/5
downloadIPC.exe = managed Win7 replacement
decoder = libzstd.dll ... (in-process)
rollback backup = COMPLETE
RESULT=READY_FOR_WIN7_FEVERGAMES_DOWNLOAD
```

如果需要恢复 FeverGames 官方文件：

```text
03_恢复官方文件.cmd
```

如果遇到问题：

```text
04_收集诊断.cmd
```

## 系统环境要求

推荐使用接近原版的 **Windows 7 SP1 x64**。

安装器需要系统保留：

- `cmd.exe`
- `powershell.exe`
- .NET Framework 2.0 / 3.5 / 4.x 中至少一个可用的 `csc.exe`
- 管理员权限
- 基本注册表、文件系统和进程查询能力

**不再要求安装 7-Zip。** Release ZIP 中已经包含 Win7 实机验证过的 `libzstd.dll 1.5.6 x64`。

深度精简版 / Ghost / 魔改 Windows 7 如果删除了 PowerShell、.NET 编译器、UAC 或其它基础组件，安装器可能无法正常运行。

详细说明见：[系统环境要求](docs/ENVIRONMENT.md)。

## 安全与回滚

项目不会只根据 FeverGames 版本号直接修改文件。

安装前会先确认目标文件与已知补丁布局匹配，并为官方文件建立 rollback backup。如果安装后的验证失败，安装流程会尽量自动回滚。

v1.3.5 安装时复制的 `libzstd.dll` 会记录 SHA-256；恢复官方文件时，只有在该 DLL 仍与安装时记录一致的情况下才会删除，避免误删用户后来替换的文件。

项目不实现：

- 账号登录绕过；
- 内容授权绕过；
- 游戏文件分发；
- 账号密码收集。

公开 Issue、日志和诊断信息中请不要上传 PRIVATE Manifest response、AES key、Token / Cookie、deviceId / uid、sig / secKey 等账号或临时鉴权信息。

## 性能说明

当前正式版优先保证 **正确性、兼容性和可恢复性**。

Test2 / Test3 / Test4 曾测试文件级和 Chunk 级并行，但不同游戏的 Manifest、文件数量、Chunk 分布和 CDN 环境差异很大，因此这些实验参数**没有进入 v1.3.5 正式版**。正式版仍采用经过验证的保守串行路径。

与 Windows 8.1 上的官方下载器相比，Windows 7 下的 .NET 替代 downloader 在大文件重组、MD5 校验以及大量小 chunk / 小文件阶段仍可能更慢，短暂显示 `0 B/s` 不一定表示任务已经卡死。

## 文档

- [文档索引](docs/README.md)
- [兼容性记录](docs/COMPATIBILITY.md)
- [系统环境要求](docs/ENVIRONMENT.md)
- [技术说明](docs/TECHNICAL.md)
- [更新日志](CHANGELOG.md)
- [v1.3.5 Release Notes](docs/releases/v1.3.5.md)
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
