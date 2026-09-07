# 发烧游戏旧版 Windows 下载器 v1.3.1

英文项目名：**FeverGames Legacy Windows Downloader**

用于恢复 **发烧游戏（FeverGames）新版下载后端在 Windows 7 SP1 x64 上的运行能力**。

v1.3.1 是 v1.3.0 的稳定性 / 兼容性更新。本版本继续沿用已经完成端到端验证的 v1.2 .NET 下载核心，不合入实验性的并发、流水线或 DLL 直解 Zstd 重构。

> [!IMPORTANT]
> 这个项目解决的是 **发烧游戏下载器 / 下载流程兼容**，不是某一个游戏客户端本身的运行兼容。
>
> 《我的世界》基岩互通版在 Windows 7 / Windows 8.1 上的客户端运行兼容请见：[MCBedrock-LegacyWindows](https://github.com/yuyu107/MCBedrock-LegacyWindows)。

> [!NOTE]
> Windows 8.1 当前可以直接使用发烧游戏官方新版下载器；本项目主要面向 Windows 7。如果官方方案本来能正常工作，不建议为了速度或功能替换官方 downloader。

> [!WARNING]
> 对未知发烧游戏平台版本，本项目不会仅凭“版本号更高”或“目录版本相同”强行写入旧偏移。只有 5 个目标位置与某个已知布局全部精确匹配时才允许修补；否则会安全停止。

## 下载

当前正式版：**v1.3.1**

- [前往 GitHub Releases 下载 v1.3.1](https://github.com/yuyu107/FeverGames-LegacyWindows-Downloader/releases/tag/v1.3.1)

Release ZIP 根目录保留普通用户最常用的入口：

```text
01_一键安装.cmd
02_检查状态.cmd
03_恢复官方文件.cmd
04_收集诊断.cmd
使用说明.txt
core\
```

直接下载仓库源码时，脚本仍使用英文文件名，例如 `01_Zero_Start_One_Click_Install.cmd`。

## v1.3.1 主要变化

- 新增发烧游戏 **1.18.42.14 / layout B** 前端精确补丁配置；
- 已确认同一个 `1.18.42.14` 文件夹版本号可能对应不同的 `FeverGamesInstaller.exe` 二进制布局；
- 同版本存在多个布局时，不再只根据版本号选择 profile，而是要求 **5 个目标位置全部精确匹配**；
- 支持发烧游戏安装在自定义目录：
  - 记住上一次成功使用的安装根目录；
  - 检查 Windows 卸载信息；
  - 检查桌面 / 开始菜单快捷方式；
  - 检查各磁盘常见目录；
  - 自动查找失败时，可直接拖入 FeverGames 根目录、数字版本目录或 `FeverGamesInstaller.exe`；
- 支持 7-Zip 安装在自定义目录：
  - 默认 Program Files；
  - 7-Zip 官方注册表路径；
  - PATH；
  - 已保存的 decoder 路径；
- 修复一键安装 UAC 流程：外层脚本会等待管理员安装过程真正完成，再自动运行状态检查；
- 修复 Windows 7 / PowerShell 2.0 下保存 FeverGames 自定义安装根目录失败的问题；
- 修复旧包中残留的 `v1.3.0-rc2` 显示；
- Release ZIP 重新整理，根目录只保留常用入口和一个可直接用记事本打开的 `使用说明.txt`。

## 已验证状态

| 项目 | 状态 |
|---|---|
| Windows 7 SP1 x64 | ✅ 完整端到端验证 |
| 发烧游戏 1.18.42.12 | ✅ 已验证 |
| 发烧游戏 1.18.42.14 / layout A | ✅ 已验证 |
| 发烧游戏 1.18.42.14 / layout B | ✅ v1.3.1 新增并实机验证 |
| FeverGames 自定义安装目录 | ✅ `D:\FeverGames` 实机验证 |
| 7-Zip 自定义安装目录 | ✅ `D:\7-Zip` 实机验证 |
| ZMTP / ZMQ | ✅ 握手、heartbeat、暂停、恢复、取消 |
| Manifest / Index / Chunk / SumBuf | ✅ 动态处理 |
| MD5 文件校验 | ✅ |
| 下载完成状态 | ✅ 发烧游戏可正常完成任务 |
| 游戏内容版本 | ✅ 动态 `targetVersion` |
| 跨游戏下载 | ✅ 已有实际成功案例 |

`1.18.42.14 / layout B` 已在 Windows 7 SP1 x64 上完成：

```text
Frontend patch count: 5/5
downloadIPC.exe = managed Win7 replacement
rollback backup = COMPLETE
《我的世界》基岩互通版完整下载成功
游戏启动成功
成功进入世界
```

原版 `FeverGamesInstaller.exe` SHA256：

```text
0a2a9568ac788227f0815e3c23761cadc11b51ee4ba9b86336cb2abf61e178e9
```

详细游戏验证见 [COMPATIBILITY.md](COMPATIBILITY.md)。

## 快速开始

1. 正常安装 / 更新发烧游戏，然后**完全退出平台**；
2. 安装支持 `.zst` 的 7-Zip，或者把可在 Windows 7 使用的独立 `zstd.exe` 放到 `tools\zstd.exe`；
3. 从 Releases 下载 v1.3.1 后运行：

```text
01_一键安装.cmd
```

如果直接下载仓库源码，则运行：

```text
01_Zero_Start_One_Click_Install.cmd
```

安装程序会自动寻找 FeverGames 与 7-Zip。若 FeverGames 自动查找失败，可直接把 FeverGames 根目录、数字版本目录或 `FeverGamesInstaller.exe` 拖到提示窗口中。

安装结束后会自动进行状态检查。也可手动运行：

```text
02_检查状态.cmd
```

源码对应：

```text
02_Check_Status.cmd
```

正常结果应包含：

```text
Patch profile: 1.18.42.14 / layout B
Frontend patch count: 5/5
downloadIPC.exe = managed Win7 replacement
rollback backup = COMPLETE
RESULT=READY_FOR_WIN7_FEVERGAMES_DOWNLOAD
```

需要恢复官方文件时，完全退出发烧游戏后运行：

```text
03_恢复官方文件.cmd
```

遇到问题可运行：

```text
04_收集诊断.cmd
```

## 已知性能特征

v1.3.1 的发布目标仍然优先是 **正确性、兼容性和可恢复性**。当前 .NET 下载核心相较 Windows 8.1 上的官方 downloader 可能更慢，尤其在：

- 大文件下载完成后的本地拼接 / MD5 阶段；
- 最后大量极小 chunk / 小文件阶段；
- 使用外部 `7z.exe` 频繁解压 Zstd 数据时。

这些阶段可能暂时显示 `0 B/s`，或者最后几个百分点推进较慢。这不一定表示网络卡死。

实验性的 DLL 直解 Zstd、并发与流水线优化暂不合入 v1.3.1。

## 前端补丁

已知平台 build 使用 5 个修补点：

1. Gate A：中央 Win10 版本检查 helper；
2. Gate B：`checkSystemVersion` 调用方；
3. `download_check` OS 字符串：Windows 7 -> Windows 8.1；
4. `download_check` minor：6.1 -> 6.3；
5. `downloadIPC --sysVer` getter：返回 `8.1`。

具体偏移与字节见 `FeverGames_PatchProfiles_v1.3.ps1` 和 [TECHNICAL.md](TECHNICAL.md)。

## downloadIPC.exe 为什么需要替换

已确认发烧游戏原版 downloader 为 Go 1.23.x 构建，并在 Windows 7 上进入 Go runtime 的 `ProcessPrng` 路径时发生兼容问题。

v1.3.1 继续使用已完成完整下载验证的 .NET 替代 downloader，支持发烧游戏 ZMTP 3.x PUB/SUB、heartbeat、暂停 / 恢复 / 取消、官方 Manifest API、动态游戏内容版本、AES-CTR、Zstd、Protobuf SumHead、CDN chunk、SumBuf 文件重组、MD5、进度与完成状态。

## 隐私与边界

本项目不实现账号登录绕过，不提供游戏内容，也不需要用户提交账号密码。公开仓库、Issue 和诊断包不应包含：

- PRIVATE Manifest response；
- AES key；
- Token / Cookie；
- deviceId / uid；
- sig / secKey；
- 其他账号或临时鉴权信息；
- 发烧游戏原版专有 EXE、游戏内容或第三方解压器二进制。

## License

本项目自行编写的代码、脚本和文档采用 [MIT License](LICENSE)。第三方软件、商标、游戏内容及相关资源的权利归各自权利人所有。
