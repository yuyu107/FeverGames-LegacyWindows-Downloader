# FeverGames Legacy Windows Downloader

用于恢复 **FeverGames 新版下载后端在 Windows 7 上的运行能力**。

当前方案已经在 **Windows 7 SP1 x64** 上完成端到端实机验证：FeverGames 可以正常进入下载流程、获取官方 Manifest、显示真实下载大小与实时百分比，并支持心跳、暂停/恢复、文件校验和完整下载。

## 下载最新版本

当前正式版本：**v1.2 - Windows 7 FeverGames 下载器兼容修复**

[前往 GitHub Releases 下载 v1.2](https://github.com/yuyu107/FeverGames-LegacyWindows-Downloader/releases/tag/v1.2)

> [!NOTE]
> v1.2 Release 附件仍沿用早期研究阶段的文件名 `FeverGames_Win7_Bedrock_ZeroStart_v1.2.zip`。这是历史命名，当前下载核心并不只针对基岩版。

> [!IMPORTANT]
> 这个仓库解决的是 **FeverGames 下载器 / 下载流程兼容**，不是某一个游戏客户端本身的运行兼容。
>
> 《我的世界》基岩互通版在 Windows 7 / Windows 8.1 上的客户端运行兼容，请见：
> [MCBedrock-LegacyWindows](https://github.com/yuyu107/MCBedrock-LegacyWindows)

> [!WARNING]
> FeverGames 前端二进制补丁目前只对平台版本 **1.18.42.12** 做过实机验证。
> 游戏内容版本由下载器动态读取，但如果 `FeverGamesInstaller.exe` 自身更新，前端补丁位置可能需要重新定位。脚本遇到未知字节会拒绝修改，不会盲目写入。

> [!NOTE]
> 本项目为社区兼容项目，与网易、Mojang、Microsoft 及相关游戏开发商无官方关联。仓库不提供或分发游戏内容、账号凭据、AES 密钥、签名或第三方解压器二进制。

## 已验证游戏

目前在 Windows 7 SP1 x64 上实际测试过：

| 游戏 | 状态 | 说明 |
|---|---|---|
| 《我的世界》基岩互通版 | ✅ 完整验证 | 完成 3130 / 3130 文件，进度达到 100%，暂停 / 恢复 / 心跳正常 |
| 《第五人格》 | ✅ 已验证可下载 | 可以正常进入下载流程并下载游戏内容 |

此外还测试到其他 FeverGames 游戏可以正常下载，说明这个方案并不是 Minecraft 专用补丁，而是针对 FeverGames 新版 `downloadIPC.exe` 下载链的兼容实现。

其他使用相同下载后端的游戏也可能兼容，但在逐个实机确认前不会统一标记为“已验证”。详细列表见 [COMPATIBILITY.md](COMPATIBILITY.md)。

## 当前状态

| 项目 | 状态 |
|---|---|
| Windows 7 SP1 x64 | ✅ 已完成端到端下载验证 |
| FeverGames ZMTP / ZMQ | ✅ 握手、心跳、暂停、恢复、取消已验证 |
| Manifest / Index / Chunk / SumBuf | ✅ 动态解析与恢复已验证 |
| 实时下载进度 | ✅ FeverGames 界面实际上涨并到达 100% |
| 文件恢复与 MD5 | ✅ 已验证 |
| 游戏内容版本 | ✅ 动态读取 / 处理，不绑定单一游戏或固定内容版本 |
| FeverGames 平台 build | ⚠️ 前端补丁当前验证于 1.18.42.12 |

## 快速开始

1. 正常安装 / 更新 FeverGames，然后完全退出平台；
2. 准备支持 `.zst` 的 7-Zip，或者把可在 Win7 使用的 `zstd.exe` 放到 `tools\zstd.exe`；
3. 解压 v1.2 Release，运行：

```text
01_Zero_Start_One_Click_Install.cmd
```

安装后可以运行：

```text
02_Check_Status.cmd
```

正常应看到：

```text
Frontend patch count: 5/5
downloadIPC.exe = managed Win7 replacement
RESULT=READY_FOR_WIN7_BEDROCK_DOWNLOAD
```

其中 `READY_FOR_WIN7_BEDROCK_DOWNLOAD` 是早期开发阶段保留下来的内部状态字符串，**不代表 v1.2 只支持基岩版**。

---

## 从 0 开始使用

### 1. 正常安装 FeverGames

先使用官方安装包正常安装 / 更新 FeverGames。

当前已验证平台目录版本：

```text
FeverGames\1.18.42.12
```

然后**完全退出 FeverGames**。任务管理器中最好不要再有：

- `FeverGamesInstaller.exe`
- `FeverGamesLauncher.exe`
- `downloadIPC.exe`

### 2. 准备 Zstd 解压器

当前 Win7 替代下载器仍需要一种 Zstd 解压器，可任选一种：

- 安装支持 `.zst` 的 7-Zip；
- 或把一个可在 Win7 使用的独立 `zstd.exe` 放到 `tools\zstd.exe`。

脚本会自动寻找常见 7-Zip 安装位置。本项目不附带第三方 `zstd.exe` / 7-Zip 二进制。

### 3. 一键修补

运行：

```text
01_Zero_Start_One_Click_Install.cmd
```

PowerShell 会自动申请管理员权限，并自动：

1. 查找 FeverGames 安装目录；
2. 检查 FeverGames 是否已经退出；
3. 检查 .NET C# 编译器；
4. 检查 Zstd / 7-Zip；
5. 验证 1.18.42.12 的目标字节；
6. 创建原版文件备份；
7. 在临时副本上应用前端补丁；
8. 编译 Win7 兼容 `downloadIPC.exe`；
9. 替换正式文件；
10. 再做一轮安装后验证。

任何目标字节异常都会直接停止。如果正式替换后发生错误，脚本会尝试自动恢复备份。

---

## 一键安装修改了什么

### FeverGamesInstaller.exe

当前已验证的前端修补包括：

1. Gate A：中央 Win10 版本检查 helper；
2. Gate B：`checkSystemVersion` 独立调用方；
3. `download_check` 的 `os-ver`：Windows 7 -> Windows 8.1；
4. `download_check` minor：6.1 -> 6.3；
5. `downloadIPC --sysVer`：`7sp1` -> `8.1`。

这些修补负责让 Win7 正常进入 FeverGames 新版下载流程。

### downloadIPC.exe

原版 Go 1.23 downloader 在 Win7 会在很早的 Go runtime / `ProcessPrng` 路径崩溃。

v1.2 会替换为 Win7 兼容的 .NET 下载模块，已实现：

- FeverGames ZMTP 3.x PUB/SUB；
- heartbeat；
- 暂停 / 恢复 / 取消；
- 官方 Manifest API；
- 动态内容版本；
- AES-CTR；
- Zstd；
- Protobuf SumHead；
- Chunk 下载；
- SumBuf 文件重组；
- MD5 校验；
- FeverGames 实时下载百分比；
- 最终完成状态。

技术细节见 [TECHNICAL.md](TECHNICAL.md)。

---

## 备份与恢复

首次安装会在 FeverGames 版本目录建立：

```text
Win7_Bedrock_Fix_Backup_v1.2
```

这个目录名同样是早期基岩版研究阶段保留下来的名称，目前仍用于兼容既有脚本。

其中至少包含：

- `FeverGamesInstaller.exe.original`
- `downloadIPC.exe.original`
- `backup_info.txt`

需要撤销修补时，完全退出 FeverGames 后运行：

```text
03_Restore_Official_Original.cmd
```

它会恢复原版 `FeverGamesInstaller.exe` 和原版 Native `downloadIPC.exe`，不会删除已经下载的游戏文件。

---

## 诊断与缓存

如果某台电脑修补后仍有问题，运行：

```text
04_Collect_Diagnostics.cmd
```

诊断脚本不会主动收集：

- PRIVATE Manifest API response
- AES key
- deviceId
- uid
- sig
- secKey

正常断点恢复时**不要清缓存**。如果确实需要清理替代下载器缓存，可运行：

```text
05_Clear_Win7_Downloader_Cache_Optional.cmd
```

---

## 版本兼容说明

“游戏内容版本”与“FeverGames 平台版本”是两回事。

当前已经证明下载内容可以动态变化；《我的世界》测试期间 FeverGames 后续下发了新的 `targetVersion`，替代下载器仍然成功获取对应 Manifest 并完成下载。《第五人格》等其他游戏的下载成功也进一步说明下载核心并未绑定 Minecraft 文件结构。

因此目前可以概括为：

- **游戏内容 / targetVersion：动态处理**；
- **使用同一 FeverGames 新下载后端的游戏：已有跨游戏实机成功案例**；
- **FeverGamesInstaller.exe：前端二进制补丁目前验证于 1.18.42.12**。

如果 FeverGamesInstaller.exe 自身更新，需要重新验证前端补丁位置；下载核心不需要因为每个游戏或每个内容版本都重新写死。

## License

本仓库自行编写的源代码、脚本和文档采用 [MIT License](LICENSE)。第三方软件、游戏内容、商标和相关资源的权利归各自权利人所有。
