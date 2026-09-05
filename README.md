# FeverGames Legacy Windows Downloader v1.3.0

用于恢复 **FeverGames 新版下载后端在 Windows 7 SP1 x64 上的运行能力**。

v1.3.0 已在 Windows 7 SP1 x64 上完成实际端到端测试，并针对 FeverGames **1.18.42.12** 与 **1.18.42.14** 建立独立的、精确字节校验的前端补丁配置。

> [!IMPORTANT]
> 这个项目解决的是 **FeverGames 下载器 / 下载流程兼容**，不是某一个游戏客户端本身的运行兼容。
>
> 《我的世界》基岩互通版在 Windows 7 / Windows 8.1 上的客户端运行兼容请见：[MCBedrock-LegacyWindows](https://github.com/yuyu107/MCBedrock-LegacyWindows)。

> [!NOTE]
> Windows 8.1 当前可以直接使用 FeverGames 官方新版下载器；本项目主要面向 Windows 7。如果官方方案本来能正常工作，不建议为了速度或功能替换官方 downloader。

> [!WARNING]
> 对未知 FeverGames 平台版本，本项目不会仅凭“版本号更高”强行写入旧偏移。只有目标位置与某个已知布局全部精确匹配时才允许复用；否则会安全停止。

## v1.3.0 主要变化

- 新增 FeverGames **1.18.42.14** 前端补丁配置，并完成 Win7 实机完整下载验证；
- 保留 **1.18.42.12** 支持；
- 自动扫描并选择最新的完整数字版本目录；
- 多版本补丁表 + 每处原始字节精确校验；
- 修复 Windows 7 PowerShell 2.0 / .NET 3.5 下 SHA256 清理兼容问题；
- 状态结果统一为 `READY_FOR_WIN7_FEVERGAMES_DOWNLOAD`；
- 新版通用备份目录：`Win7_Downloader_Fix_Backup_v1.3`；
- 恢复脚本同时兼容旧 v1.2 备份；
- 状态检查、恢复、诊断流程适配滚动版本目录；
- 下载核心继续沿用已经完整验证成功的 v1.2 .NET 实现，本正式版不合入实验性的并发 / 流水线重写。

## 已验证状态

| 项目 | 状态 |
|---|---|
| Windows 7 SP1 x64 | ✅ 完整端到端验证 |
| FeverGames 1.18.42.12 | ✅ 已验证 |
| FeverGames 1.18.42.14 | ✅ 已验证 |
| ZMTP / ZMQ | ✅ 握手、heartbeat、暂停、恢复、取消 |
| Manifest / Index / Chunk / SumBuf | ✅ 动态处理 |
| MD5 文件校验 | ✅ |
| 下载完成状态 | ✅ FeverGames 可正常完成任务 |
| 游戏内容版本 | ✅ 动态 `targetVersion` |
| 跨游戏下载 | ✅ 已有实际成功案例 |

1.18.42.14 的 Win7 实测确认：

```text
FILE 3130/3130
mainPercent=1.000000
RESULT=SUCCESS_FULL_DOWNLOAD_VIA_FEVERGAMES
```

详细游戏验证见 [COMPATIBILITY.md](COMPATIBILITY.md)。

## 快速开始

1. 正常安装 / 更新 FeverGames，然后**完全退出平台**；
2. 安装支持 `.zst` 的 7-Zip，或者把可在 Windows 7 使用的独立 `zstd.exe` 放到 `tools\zstd.exe`；
3. 完整下载本仓库 ZIP / Release 后运行：

```text
01_Zero_Start_One_Click_Install.cmd
```

脚本会自动扫描常见安装目录，并按真实 `[version]` 顺序选择最新同时包含 `FeverGamesInstaller.exe` 与 `downloadIPC.exe` 的完整版本目录。

安装后运行：

```text
02_Check_Status.cmd
```

正常应看到类似：

```text
Patch profile: 1.18.42.14
Frontend patch count: 5/5
downloadIPC.exe = managed Win7 replacement
RESULT=READY_FOR_WIN7_FEVERGAMES_DOWNLOAD
```

需要恢复官方文件时，完全退出 FeverGames 后运行：

```text
03_Restore_Official_Original.cmd
```

遇到问题可运行：

```text
04_Collect_Diagnostics.cmd
```

## 已知性能特征

v1.3.0 的发布目标优先是 **正确性、兼容性和可恢复性**。当前 .NET 下载核心相较 Windows 8.1 上的官方 downloader 可能更慢，尤其在：

- 大文件下载完成后的本地拼接 / MD5 阶段；
- 最后大量极小 chunk / 小文件阶段；
- 使用外部 `7z.exe` 频繁解压 Zstd 数据时。

这些阶段可能暂时显示 `0 B/s`，或者最后几个百分点推进较慢。这不一定表示网络卡死。我们已经抓取过 Win8.1 官方完整下载过程用于后续性能重构；为了保持 v1.3.0 稳定，本次正式版不把实验性的并发 / 流水线重写合入。

## 前端补丁

已知平台 build 使用 5 个修补点：

1. Gate A：中央 Win10 版本检查 helper；
2. Gate B：`checkSystemVersion` 调用方；
3. `download_check` OS 字符串：Windows 7 -> Windows 8.1；
4. `download_check` minor：6.1 -> 6.3；
5. `downloadIPC --sysVer` getter：返回 `8.1`。

具体偏移与字节见 `FeverGames_PatchProfiles_v1.3.ps1` 和 [TECHNICAL.md](TECHNICAL.md)。

## downloadIPC.exe 为什么需要替换

已确认 FeverGames 原版 downloader 为 Go 1.23.x 构建，并在 Windows 7 上进入 Go runtime 的 `ProcessPrng` 路径时发生兼容问题。

v1.3.0 继续使用已完成完整下载验证的 .NET 替代 downloader，支持 FeverGames ZMTP 3.x PUB/SUB、heartbeat、暂停 / 恢复 / 取消、官方 Manifest API、动态游戏内容版本、AES-CTR、Zstd、Protobuf SumHead、CDN chunk、SumBuf 文件重组、MD5、进度与完成状态。

## 隐私与边界

本项目不实现账号登录绕过，不提供游戏内容，也不需要用户提交账号密码。公开仓库和诊断包不应包含 PRIVATE Manifest response、AES key、Token / Cookie、deviceId / uid、sig / secKey、FeverGames 原版专有 EXE、游戏内容或第三方解压器二进制。

## License

本项目自行编写的代码、脚本和文档采用 [MIT License](LICENSE)。第三方软件、商标、游戏内容及相关资源的权利归各自权利人所有。
