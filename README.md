# FeverGames Legacy Windows Downloader

用于恢复 **FeverGames 在 Windows 7 上下载《我的世界》基岩互通版** 的能力。

当前方案已经在 **Windows 7 SP1 x64** 上完成端到端实机验证：FeverGames 可以正常进入下载流程、显示真实下载大小与实时百分比，支持心跳、暂停/恢复，并成功完成当前 Manifest 的全部文件下载。

> [!IMPORTANT]
> 当前仓库解决的是 **FeverGames 下载器 / 下载流程兼容**。
> Minecraft 客户端本身在 Windows 7 / Windows 8.1 上的运行兼容，请见：
> [MCBedrock-LegacyWindows](https://github.com/yuyu107/MCBedrock-LegacyWindows)

> [!WARNING]
> FeverGames 前端二进制补丁目前只对平台版本 **1.18.42.12** 做过实机验证。
> 游戏内容 `targetVersion` 是动态读取的，不绑定某个 Minecraft 内容版本；但如果 FeverGamesInstaller.exe 自身更新，前端补丁位置可能需要重新定位。脚本遇到未知字节会拒绝修改。

> [!NOTE]
> 本项目为社区兼容项目，与网易、Mojang、Microsoft 无官方关联。仓库不提供或分发游戏内容、账号凭据、AES 密钥、签名或第三方解压器二进制。

## 当前状态

| 项目 | 状态 |
|---|---|
| Windows 7 SP1 x64 | ✅ 已完成端到端下载验证 |
| FeverGames ZMTP / ZMQ | ✅ 握手、心跳、暂停、恢复、取消已验证 |
| Manifest / Index / Chunk / SumBuf | ✅ 动态解析与恢复已验证 |
| 实时下载进度 | ✅ FeverGames 界面实际上涨并到达 100% |
| 完整文件恢复 | ✅ 实机完成 3130 / 3130 文件 |
| Minecraft `targetVersion` | ✅ 动态读取 |
| FeverGames 平台 build | ⚠️ 前端补丁当前验证于 1.18.42.12 |

## 快速开始

从仓库下载源码 ZIP 后，准备支持 `.zst` 的 7-Zip，或者把可在 Win7 使用的 `zstd.exe` 放到 `tools\zstd.exe`，然后完全退出 FeverGames，运行：

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
RESULT=READY_FOR_WIN7_BEDROCK_DOWNLOAD
```

下面是完整说明。

---

## 已经实机验证到什么程度

当前方案已经在 Windows 7 SP1 上完成真正的端到端下载：

- FeverGames ZMTP / ZMQ 握手成功
- 官方 Manifest API 请求成功
- Manifest 动态解析成功
- AES-CTR / Zstd / Index / Chunk / SumBuf 全流程成功
- 下载百分比、速度、心跳正常
- 暂停 / 恢复正常
- 3130 / 3130 文件全部成功
- 最终 FeverGames 下载任务达到 100%

下载内容版本可以变化；下载器会读取 FeverGames 当前传来的 `targetVersion`，
并动态获取对应 Manifest。

**但是 FeverGamesInstaller.exe 的前端二进制修补位置目前仍只验证于平台版本：**

`1.18.42.12`

如果网易更新 FeverGames 本体导致这些字节位置变化，本包会拒绝修改未知字节，而不是盲目写入。

---

# 从 0 开始使用

## 第 1 步：正常安装 FeverGames

可以先使用官方安装包正常安装/更新 FeverGames。

确认平台目录已经是：

`FeverGames\1.18.42.12`

然后**完全退出 FeverGames**。

任务管理器里最好不要再有：

- `FeverGamesInstaller.exe`
- `FeverGamesLauncher.exe`
- `downloadIPC.exe`

## 第 2 步：准备 Zstd 解压器

当前 Win7 替代下载器仍需要一种 Zstd 解压器。

两种方式任选其一：

### 方法 A

电脑已经安装支持 `.zst` 的 7-Zip。

脚本会自动寻找：

- `C:\Program Files\7-Zip\7z.exe`
- `C:\Program Files (x86)\7-Zip\7z.exe`

### 方法 B

把一个可在 Win7 使用的独立：

`zstd.exe`

放到本包：

`tools\zstd.exe`

安装脚本会自动复制到 FeverGames 的 `downloadIPC.exe` 旁边。

本压缩包**不自带第三方解压器二进制**。

## 第 3 步：一键修补

直接双击：

`01_Zero_Start_One_Click_Install.cmd`

PowerShell 会自动申请管理员权限。

它会自动：

1. 找到 FeverGames 安装目录；
2. 检查 FeverGames 是否已经完全退出；
3. 检查 .NET C# 编译器；
4. 检查 Zstd / 7-Zip；
5. 验证 1.18.42.12 的所有目标字节；
6. 创建干净的官方文件备份；
7. 在临时副本上应用前端补丁；
8. 编译 Win7 兼容 `downloadIPC.exe`；
9. 最后一次性替换正式文件；
10. 再做一轮安装后验证。

任何目标字节异常都会直接停止。

如果在正式替换之后发生错误，脚本会尝试自动恢复备份。

---

# 一键安装到底改了什么

## FeverGamesInstaller.exe

一次应用目前已经验证的 5 处修补：

1. Gate A：中央 Win10 版本检查 helper
2. Gate B：`checkSystemVersion` 独立调用方
3. `download_check` 的 `os-ver`：Windows 7 -> Windows 8.1
4. `download_check` minor：6.1 -> 6.3
5. `downloadIPC --sysVer`：`7sp1` -> `8.1`

这些用于让 Win7 正常进入基岩互通版的下载流程。

## downloadIPC.exe

原版 Go 1.23 downloader 在 Win7 会在很早期的 Go runtime / `ProcessPrng`
路径崩溃。

v1.2 会替换为已经实际验证成功的 .NET Win7 下载器，它实现：

- FeverGames ZMTP 3.x PUB/SUB
- heartbeat
- 暂停 / 恢复 / 取消
- 官方 Manifest API
- 动态 targetVersion
- AES-CTR
- Zstd
- Protobuf SumHead
- Chunk 下载
- SumBuf 文件重组
- MD5 校验
- 实时 FeverGames 下载百分比
- 最终完成状态

---

# 备份

首次安装会在 FeverGames 版本目录建立：

`Win7_Bedrock_Fix_Backup_v1.2`

里面至少有：

- `FeverGamesInstaller.exe.original`
- `downloadIPC.exe.original`
- `backup_info.txt`

即使你运行安装脚本时之前已经用过旧版补丁，
安装器也会尝试把已知旧补丁还原到临时备份副本，
尽量得到一份“干净官方状态”的 Installer 备份。

对于 `downloadIPC.exe`，如果当前文件已经是以前的 .NET 测试版，
安装器会尝试从这些旧备份中寻找原版 Native Go downloader：

- `downloadIPC.before_win7_integrated_v1.1.exe`
- `downloadIPC.before_zmq_emulator_v1.0.exe`
- `downloadIPC.real.exe`
- `downloadIPC.before_legacy_probe.exe`
- `downloadIPC.original.exe`

因此这个包也可以用来整理之前的测试环境。

---

# 检查状态

运行：

`02_Check_Status.cmd`

完整状态应出现：

`Frontend patch count: 5/5`

并且：

`downloadIPC.exe = managed Win7 replacement`

最后：

`RESULT=READY_FOR_WIN7_BEDROCK_DOWNLOAD`

如果网易平台更新后把文件覆盖了，这里会直接显示哪些部分已经失效。

只要平台还是同一个已验证的 1.18.42.12 build，可以重新运行 01。

---

# 恢复官方原版

完全退出 FeverGames，然后运行：

`03_Restore_Official_Original.cmd`

会恢复：

- 原始 `FeverGamesInstaller.exe`
- 原始 Native `downloadIPC.exe`

不会删除：

`D:\FeverApps\MCBedrock`

里的游戏文件。

备份目录本身也不会自动删除。

---

# 收集诊断

如果某台电脑修补后仍有问题，运行：

`04_Collect_Diagnostics.cmd`

会生成：

`ZeroStart_v1.2_Diagnostic_Result`

只收集：

- 当前修补状态
- v1.2 downloader 日志
- 非私密的备份/安装信息

不会收集：

- PRIVATE Manifest API response
- AES key
- deviceId
- uid
- sig
- secKey

---

# 清理替代下载器缓存

正常断点恢复时**不要清缓存**。

如果确实需要从游戏下载缓存重新开始，可以运行：

`05_Clear_Win7_Downloader_Cache_Optional.cmd`

它只删除：

`.dlstorage\legacy_win7_v1.2`

和诊断日志，不删除正常游戏文件。

---

# 一个重要区别

“游戏内容版本”与“FeverGames 平台版本”是两回事。

目前已经证明下载内容可以从之前研究的版本继续变化，例如 FeverGames
后来实际下发了新的 `targetVersion`，v1.1 仍然成功把 3130 个文件全部下载完成。

所以：

- **Minecraft/基岩互通版 targetVersion：动态适配**
- **FeverGamesInstaller.exe 1.18.42.12：当前前端补丁的已验证平台 build**

以后如果 FeverGamesInstaller.exe 自身更新，需要重新定位前端那几处二进制补丁；
下载核心本身不需要因为每个 Minecraft targetVersion 都重新写死。
