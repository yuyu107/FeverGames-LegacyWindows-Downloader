# 兼容性记录

本页主要记录 Windows 7 SP1 x64 上已经实际验证过的结果。

当前建议使用正式版：**v1.3.6**。

## 发烧游戏平台版本

| 发烧游戏版本 | 状态 | 说明 |
|---|---|---|
| 1.18.42.12 / layout A | ✅ 已验证 | 早期完整端到端验证基准 |
| 1.18.42.14 / layout A | ✅ 已验证 | v1.3.0 已验证布局；旧 CLR 验证修复也在此类环境中获得反馈 |
| 1.18.42.14 / layout B | ✅ 已验证 | v1.3.1 新增精确补丁配置；Win7 实机完成完整下载、启动并进入世界 |
| 1.18.43.22 / layout A | ✅ 已验证 | v1.3.4 新增精确补丁配置；Win7 实机完成补丁安装、完整下载并成功进入游戏 |
| 1.18.44.2 / layout A | ✅ 已验证 | v1.3.6 新增精确补丁配置；Win7 实机完成 5/5 补丁、3133/3133 文件完整下载、游戏启动并成功进入世界 |
| 未知未来版本 / 未知布局 | ⚠️ 条件兼容 | 只有 5 个目标位置完整匹配某个已知布局时才复用，否则安全停止 |

同一个版本文件夹名称不能单独代表实际二进制布局。安装器不会只根据版本号选择补丁，而是要求 5 个目标位置与某个已知 profile 完整匹配。

## v1.3.5：libzstd 后端

v1.3.5 将 Zstandard 解压从外部 `7z.exe / zstd.exe` 改为进程内 `libzstd.dll 1.5.6`。

已经完成的验证包括：

- Windows 7 SP1 x64；
- 64 位进程；
- CLR `2.0.50727.8966`；
- `libzstd.dll 1.5.6`；
- `ZSTD_createDStream / ZSTD_initDStream / ZSTD_decompressStream` 流式 P/Invoke；
- 独立样本完整解压，SHA-256 与预期完全一致；
- 实际 FeverGames 游戏下载完成，确认无需 7-Zip。

v1.3.5 起的正式 Release ZIP 直接包含已经测试过的 x64 `libzstd.dll`。

## 当前版本保留的安装兼容修复

### PowerShell 2.0 / 旧 CLR 托管 EXE 验证

已确认一台 Windows 7 环境中，旧版本可以完成前端 5 点临时修补并调用 .NET 4 `csc.exe` 生成 downloader，但旧 CLR 在程序集验证阶段误报并主动中止。

当前实现直接读取 PE Optional Header 的 CLR / COM Descriptor，不依赖当前 PowerShell CLR 加载目标程序集。该路径已经在对应 Win7 环境中复测。

### Release CMD 编码 / 换行

v1.3.2 Release ZIP 的 `.cmd` 入口在部分 Windows 7 上会被错误解析，表现为 `锘緻echo`、`powershell.exe -> hell.exe`、`echo -> ho` 等。

后续 Release ZIP 将入口 `.cmd` 统一为无 BOM + CRLF，并保持纯 ASCII 命令内容。

### ZIP 内直接运行

如果直接在 Windows 资源管理器的 ZIP 视图中双击 CMD，Windows 可能只临时解出当前 CMD，导致 `core\*.ps1` 不存在。

v1.3.5 起的常用 Release CMD 入口已经加入检测提示；仍建议始终先完整解压 ZIP。

## 安装路径

FeverGames 自定义安装根目录已经验证可用，例如：

```text
D:\FeverGames
```

滚动版本目录选择器会寻找包含 `FeverGamesInstaller.exe` 和 `downloadIPC.exe` 的最新完整版本目录。

v1.3.6 Release ZIP 不依赖系统 7-Zip 安装路径。

## downloader / 解压器

| 项目 | v1.3.6 状态 |
|---|---|
| 托管替代 `downloadIPC.exe` | ✅ |
| `libzstd.dll 1.5.6 x64` | ✅ Release 内置，Win7 实机验证 |
| 系统 7-Zip | ℹ️ 不再需要 |
| 独立 `zstd.exe` | ℹ️ 不再需要 |
| 外部 decoder path 配置 | ℹ️ 保留历史兼容代码，但正式安装要求 libzstd |

状态检查正常时应出现：

```text
Frontend patch count: 5/5
downloadIPC.exe = managed Win7 replacement
decoder = libzstd.dll ... (in-process)
rollback backup = COMPLETE
RESULT=READY_FOR_WIN7_FEVERGAMES_DOWNLOAD
```

## 性能实验说明

Test2 / Test3 / Test4 曾验证：

- 多小文件阶段使用文件级并行可以显著减少串行 HTTP 往返等待；
- 大文件内部 Chunk 并行对部分文件有明显改善；
- 但不同游戏的 Manifest、文件数量、Chunk 分布、共享 Chunk 情况和 CDN 表现差异很大。

因此这些并发参数不进入 v1.3.6 正式版。正式版保持更保守、已经验证过的串行下载 / 重组路径。

## 其它系统

- **Windows 8.1**：当前官方下载器通常可以直接工作，一般无需本项目。
- **Windows 10 / 11**：不属于本项目目标，应优先使用官方程序。

## 不属于本项目保证范围

本项目只解决 FeverGames 下载流程兼容，不保证下载后的每个游戏本体都能在 Windows 7 上运行。

遇到新 FeverGames 版本 / 新布局时，请先收集诊断，不要手动套用旧偏移。
