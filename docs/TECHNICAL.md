# 技术说明

## 项目结构

FeverGames Legacy Windows Downloader 由两部分组成：

1. 对已知 `FeverGamesInstaller.exe` 布局进行 5 点 exact-byte 兼容补丁；
2. 用 Windows 7 可运行的托管 `downloadIPC.exe` 替代官方下载后端。

当前正式版：**v1.3.6**。

## 前端补丁

安装器不会只根据版本目录名称直接写入固定偏移。

每个已知 profile 都包含 5 个目标位置：

- Gate A
- Gate B
- `download_check` OS label
- `download_check` minor
- `downloadIPC --sysVer` getter

每个目标位置都保存：

- offset；
- original bytes；
- patched bytes；
- 必要时的 alternate-before bytes。

只有一个 profile 的 5 个位置全部处于已知状态时才会继续。未知布局会安全停止。

## downloader 架构

替代 downloader 是 C# / .NET 托管程序。

源码仓库保存 gzip + Base64 形式的完整 C# 源：

```text
src/downloadIPC_Win7_v1.2.cs.gz.b64
```

`scripts/current/Prepare_Source_v1.2.ps1` 会在源码 checkout 中还原：

```text
scripts/current/downloadIPC_Win7_v1.2.cs
```

随后使用目标 Win7 系统已有的 `csc.exe` 编译为 x64 managed EXE。

## 下载流程

当前稳定路径大致为：

```text
FeverGames task
  -> Manifest
  -> Index HTTP
  -> Index decrypt
  -> Index Zstd decode
  -> parse Chunk metadata
  -> Chunk HTTP
  -> Chunk decrypt
  -> Chunk Zstd decode
  -> SumBuf / file reconstruction
  -> MD5
  -> final file
```

## v1.3.5：进程内 libzstd

v1.3.4 及更早版本的稳定 downloader 使用外部 `7z.exe` / `zstd.exe` 完成 Zstandard 解压。

v1.3.5 改为：

```text
managed downloadIPC.exe
  -> P/Invoke
  -> libzstd.dll 1.5.6
  -> ZSTD_createDStream
  -> ZSTD_initDStream
  -> ZSTD_decompressStream
```

使用到的主要导出包括：

- `ZSTD_versionString`
- `ZSTD_createDStream`
- `ZSTD_freeDStream`
- `ZSTD_initDStream`
- `ZSTD_decompressStream`
- `ZSTD_DStreamInSize`
- `ZSTD_DStreamOutSize`
- `ZSTD_isError`
- `ZSTD_getErrorName`

Windows 7 SP1 x64 + CLR 2.0 的独立流式解压测试已经通过，随后在实际 FeverGames 下载中验证完成。

## 为什么正式版没有采用 Test2 / Test3 / Test4 的并发参数？

性能测试发现，大量小文件时，主要等待可以来自串行的 Index HTTP + Chunk HTTP 往返；文件级并行能显著改善特定游戏。

大文件内部 Chunk 并行也能改善部分大文件，但不同游戏会有不同的：

- 文件数量；
- 文件大小分布；
- Chunk 数量与大小；
- Chunk 共享关系；
- CDN / 下载节点；
- 磁盘性能。

因此把某一个游戏上效果较好的固定 `4 / 6 worker` 参数直接作为全局策略并不稳妥。

v1.3.6 正式版继续保持已验证的串行下载调度；Test2 / Test3 / Test4 的固定并发参数仍未纳入正式版。

## v1.3.6：FeverGames 1.18.44.2-A

v1.3.6 新增 `1.18.44.2 / layout A` exact-byte profile。原版 `FeverGamesInstaller.exe`：

```text
SHA-256: 99b71ce13933694f7eaba85a8e9890d4a3f93fe09c73ab4a3c42da33b1b04aaf
Gate A   : 0xABD2B0
Gate B   : 0x70F0AD
NetLabel : 0xA605DC
NetMinor : 0xA60652
Getter   : 0xA61CA0
```

Gate B 的直接控制流已确认是 `CALL GateA -> TEST AL,AL -> JNE +0xD6`；NetLabel 的 RIP-relative 目标从实际字符串 `windows 7` 调整到 `windows 8.1`。

Windows 7 SP1 x64 实机验证结果：5/5 补丁成功、3133/3133 文件完整下载、游戏成功启动并进入世界。

官方 1.18.44.2 `downloadIPC.exe` 内部出现 QueueDownloader、client pool、smart IP pool 等新调度符号，但实机结果表明 FeverGames 与 downloader 之间现有外部任务接口仍可由本项目 managed downloader 正常处理。

## 状态检查

状态检查要求：

1. 5 个前端位置全部为 PATCHED；
2. `downloadIPC.exe` 是 managed Win7 replacement；
3. rollback backup 完整；
4. 当前 FeverGames 版本目录中存在 `libzstd.dll`。

正常结果：

```text
Frontend patch count: 5/5
downloadIPC.exe = managed Win7 replacement
decoder = libzstd.dll ... (in-process)
rollback backup = COMPLETE
RESULT=READY_FOR_WIN7_FEVERGAMES_DOWNLOAD
```

## 回滚

安装前会保存官方：

```text
FeverGamesInstaller.exe.original
downloadIPC.exe.original
```

如果安装器从工具包复制了 `libzstd.dll`，会额外记录：

```text
copied_libzstd.sha256
```

恢复时只有当前 DLL SHA-256 与记录一致才会删除该 DLL；用户后来替换过的 DLL 会被保留。

## 诊断

v1.3.5 诊断结果新增：

```text
decoder_info.txt
```

其中记录目标版本目录中的 `libzstd.dll` 路径、版本和 SHA-256。

v1.3.6 修复 Win7 / CLR 2.0 下 `SHA256Managed.Dispose()` 不可用导致的诊断收集错误，改用旧 CLR 兼容的 `Clear()`。

诊断不会主动收集 PRIVATE Manifest response、AES key、deviceId、uid、sig、secKey 等敏感鉴权数据。

## 第三方组件

正式 Release ZIP 包含 Zstandard 1.5.6 的 `libzstd.dll`，按 BSD License 条款再分发。

见：[第三方组件说明](THIRD_PARTY_NOTICES.md)。
