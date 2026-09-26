# 兼容性记录

本页主要记录 Windows 7 SP1 x64 上已经实际验证过的结果。

当前建议使用正式版：**v1.3.7**。

## 发烧游戏平台版本

| 发烧游戏版本 | 状态 | 说明 |
|---|---|---|
| 1.18.42.12 / layout A | ✅ 已验证 | 早期完整端到端验证基准 |
| 1.18.42.14 / layout A | ✅ 已验证 | v1.3.0 已验证布局；旧 CLR 验证修复也在此类环境中获得反馈 |
| 1.18.42.14 / layout B | ✅ 已验证 | v1.3.1 新增精确补丁配置；Win7 实机完成完整下载、启动并进入世界 |
| 1.18.43.22 / layout A | ✅ 已验证 | v1.3.4 新增精确补丁配置；Win7 实机完成补丁安装、完整下载并成功进入游戏 |
| 1.18.44.2 / layout A | ✅ 已验证 | v1.3.6 新增精确补丁配置；Win7 实机完成 5/5 补丁、3133/3133 文件完整下载、游戏启动并成功进入世界 |
| 未知未来版本 / 未知布局 | ⚠️ 实验性 | v1.3.7 可尝试 Auto Profile；必须全部目标通过结构与字节验证，否则安全停止。尚未在真正未来新版上实测 |

同一个版本文件夹名称不能单独代表实际二进制布局。已知版本优先使用 Built-in Exact Profile；只有没有已知 profile 时才会尝试 Auto Profile。

## v1.3.7：Auto Profile

Auto Profile 是未知布局的备用结构识别机制，不是对未来版本兼容性的承诺。

- 仅在已知 Built-in Exact Profile 无法匹配时尝试；
- 需要识别并验证全部目标；
- 只有全部结构与字节条件通过才允许继续；
- 任一目标不确定或不满足条件都会安全停止；
- 后续真正出现新 FeverGames 版本后，应先实机测试；验证成功后再将该布局固化成 Built-in Exact Profile。

目前最新已知版本仍为 1.18.44.2，因此这条未来布局路径暂时无法完成真正的新版本实机验证。

## v1.3.5：libzstd 后端

v1.3.5 将 Zstandard 解压从外部 `7z.exe / zstd.exe` 改为进程内 `libzstd.dll 1.5.6`。已经完成的验证包括：

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

当前实现直接读取 PE Optional Header 的 CLR / COM Descriptor，不依赖当前 PowerShell CLR 加载目标程序集。该路径已经在对应 Win7 环境中复测。

### Release CMD 编码 / 换行

历史 Release 曾出现 UTF-8 BOM / LF 导致 Windows 7 `cmd.exe` 将 `@echo off` 解析成 `锘緻echo off` 等异常。当前 Release ZIP 的常用 CMD 入口继续保持**无 BOM + CRLF**。

### ZIP 内直接运行

如果直接在 Windows 资源管理器的 ZIP 视图中双击 CMD，Windows 可能只临时解出当前 CMD，导致 `core\*.ps1` 不存在。常用 Release CMD 已有检测提示；仍建议始终先完整解压 ZIP。

## 安装路径

FeverGames 自定义安装根目录已经验证可用，例如：

```text
D:\FeverGames
```

滚动版本目录选择器会寻找包含 `FeverGamesInstaller.exe` 和 `downloadIPC.exe` 的最新完整版本目录。v1.3.7 Release ZIP 不依赖系统 7-Zip 安装路径。

## downloader / 解压器

| 项目 | v1.3.7 状态 |
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

## v1.3.7 性能路径

v1.3.7 正式采用此前测试中表现较稳定的方案：

- Manifest 先解析，再进入 Index 状态，索引总大小可立即获得；
- Index 保持 Manifest 原始顺序，不再按最终文件 StageSize 排序；
- Index 并发为 HDD 64 / SSD 96，并提高 HTTP 连接上限；
- Index 在内存中完成 AES-CTR 解密、libzstd 解压和 Protobuf 解析，减少临时文件 I/O；
- 减少 Index 热路径同步日志，并缓存成功 AES Key；
- 主下载平衡管线：HDD `8 + 6 + 1`，SSD `12 + 10 + 2`。

这些优化已经在 Windows 7 实机下载链路中测试，但不同游戏的 Manifest、Chunk 分布、CDN、磁盘与网络差异很大，因此实际速度仍会变化。替代 downloader 不保证达到 Windows 10 / 11 官方 downloader 的同等吞吐。

## 其它系统

- **Windows 8.1**：当前官方下载器通常可以直接工作，一般无需本项目。
- **Windows 10 / 11**：不属于本项目目标，应优先使用官方程序。

## 不属于本项目保证范围

本项目只解决 FeverGames 下载流程兼容，不保证下载后的每个游戏本体都能在 Windows 7 上运行。

遇到新 FeverGames 版本 / 新布局时，请先收集诊断；即使 Auto Profile 能识别，也建议先完成实机验证后再作为已支持布局使用。
