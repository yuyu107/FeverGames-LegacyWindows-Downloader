# 发烧游戏旧版 Windows 下载器 v1.3.2

英文项目名：**FeverGames Legacy Windows Downloader**

用于恢复 **发烧游戏（FeverGames）新版下载后端在 Windows 7 SP1 x64 上的运行能力**。

v1.3.2 是 v1.3.1 的小型兼容性修复版本。本版本继续沿用已经完成端到端验证的 v1.2 .NET 下载核心，不修改 5 点前端补丁逻辑，也不合入实验性的并发、流水线或 DLL 直解 Zstd 重构。

> [!IMPORTANT]
> 这个项目解决的是 **发烧游戏下载器 / 下载流程兼容**，不是某一个游戏客户端本身的运行兼容。
>
> 《我的世界》基岩互通版在 Windows 7 / Windows 8.1 上的客户端运行兼容请见：[MCBedrock-LegacyWindows](https://github.com/yuyu107/MCBedrock-LegacyWindows)。

> [!NOTE]
> Windows 8.1 当前可以直接使用发烧游戏官方新版下载器；本项目主要面向 Windows 7。如果官方方案本来能正常工作，不建议替换官方下载器。

## 下载

当前正式版：**v1.3.2**

- [前往 GitHub Releases 下载 v1.3.2](https://github.com/yuyu107/FeverGames-LegacyWindows-Downloader/releases/tag/v1.3.2)

Release ZIP 根目录：

```text
01_一键安装.cmd
02_检查状态.cmd
03_恢复官方文件.cmd
04_收集诊断.cmd
使用说明.txt
core\
```

直接下载仓库源码时，脚本仍使用英文文件名，例如 `01_Zero_Start_One_Click_Install.cmd`。

## v1.3.2 主要修复

部分较原生的 Windows 7 / PowerShell 2.0 环境中，v1.3.1 会在完成 C# 编译后报：

```text
Compiled downloader did not validate as a managed .NET executable.
```

实际问题不是前端 layout、5 点补丁或 C# 编译失败，而是 v1.3.1 使用当前 PowerShell / CLR 去加载刚由 .NET 4 `csc.exe` 生成的程序集；旧 CLR 可能无法用这种方式识别目标文件，于是把“当前 CLR 无法加载”误判成“不是有效的托管 EXE”。

v1.3.2 改为直接读取 EXE 的 PE Optional Header 并检查 **CLR / COM Descriptor**：

- 不再要求当前 PowerShell CLR 能加载目标程序集；
- 安装脚本和状态检查脚本使用同一套 CLR-independent 判断；
- 仍保留 fail-safe：如果 PE 中没有有效 CLR Descriptor，会在正式覆盖前安全停止；
- 验证失败时额外输出生成文件大小和 SHA-256，方便继续诊断。

该修复已经由一台此前 v1.3.1 会稳定出现上述错误的 Windows 7 实机复测，修正后的测试包可以正常完成安装。

## v1.3.1 延续内容

v1.3.2 保持 v1.3.1 已验证行为不变：

- FeverGames `1.18.42.12`；
- FeverGames `1.18.42.14 / layout A`；
- FeverGames `1.18.42.14 / layout B`；
- 同版本多布局时要求 5 个目标位置全部精确匹配；
- 自定义 FeverGames 安装路径发现与拖入兜底；
- 自定义 7-Zip 路径发现；
- 一键安装 UAC 等待与自动状态检查；
- rollback backup、恢复与诊断流程。

## 已验证状态

| 项目 | 状态 |
|---|---|
| Windows 7 SP1 x64 | ✅ 完整端到端验证 |
| 发烧游戏 1.18.42.12 | ✅ 已验证 |
| 发烧游戏 1.18.42.14 / layout A | ✅ 已验证 |
| 发烧游戏 1.18.42.14 / layout B | ✅ 已验证 |
| PowerShell 2.0 / 旧 CLR 托管 EXE 验证 | ✅ v1.3.2 修复并实机复测 |
| FeverGames 自定义安装目录 | ✅ `D:\FeverGames` 实机验证 |
| 7-Zip 自定义安装目录 | ✅ `D:\7-Zip` 实机验证 |
| ZMTP / ZMQ | ✅ 握手、heartbeat、暂停、恢复、取消 |
| Manifest / Index / Chunk / SumBuf | ✅ 动态处理 |
| MD5 文件校验 | ✅ |
| 下载完成状态 | ✅ 发烧游戏可正常完成任务 |
| 《我的世界》基岩互通版 | ✅ 完整下载、启动并进入世界 |

`1.18.42.14 / layout B` 原版 `FeverGamesInstaller.exe` SHA256：

```text
0a2a9568ac788227f0815e3c23761cadc11b51ee4ba9b86336cb2abf61e178e9
```

## 快速开始

1. 正常安装 / 更新发烧游戏，然后**完全退出平台**；
2. 安装支持 `.zst` 的 7-Zip，或者准备 Windows 7 可用的独立 `zstd.exe`；
3. 从 Releases 下载 v1.3.2 后运行：

```text
01_一键安装.cmd
```

源码仓库运行：

```text
01_Zero_Start_One_Click_Install.cmd
```

如果自动找不到 FeverGames，可以把 FeverGames 根目录、数字版本目录或 `FeverGamesInstaller.exe` 拖到提示窗口中。

正常结果应包含：

```text
Frontend patch count: 5/5
downloadIPC.exe = managed Win7 replacement
rollback backup = COMPLETE
RESULT=READY_FOR_WIN7_FEVERGAMES_DOWNLOAD
```

## 已知性能特征

v1.3.2 仍优先保证 **正确性、兼容性和可恢复性**。当前 .NET 下载核心相比 Windows 8.1 上的官方下载器可能更慢，尤其在大文件本地拼接 / MD5，以及尾部大量小 chunk / 小文件阶段；这些阶段短暂显示 `0 B/s` 不一定代表网络卡死。

实验性的 DLL 直解 Zstd、并发与流水线优化暂不合入 v1.3.2。

## 隐私与边界

本项目不实现账号登录绕过，不提供游戏内容，也不需要用户提交账号密码。公开仓库、Issue 和诊断包不应包含 PRIVATE Manifest response、AES key、Token / Cookie、deviceId / uid、sig / secKey 或其它账号 / 临时鉴权信息。

## License

本项目自行编写的代码、脚本和文档采用 [MIT License](LICENSE)。第三方软件、商标、游戏内容及相关资源的权利归各自权利人所有。
