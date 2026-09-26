# 技术说明

## 项目结构

FeverGames Legacy Windows Downloader 由两部分组成：

1. 对已知 `FeverGamesInstaller.exe` 布局进行 5 点 exact-byte 兼容补丁，并为未知布局提供实验性的 Auto Profile 结构识别备用路径；
2. 用 Windows 7 可运行的托管 `downloadIPC.exe` 替代官方下载后端。

当前正式版：**v1.3.7**。

## 前端补丁

安装器不会只根据版本目录名称直接写入固定偏移。

每个已知 Built-in Exact Profile 都包含 5 个目标位置：

- Gate A
- Gate B
- `download_check` OS label
- `download_check` minor
- `downloadIPC --sysVer` getter

每个目标位置保存 offset、original bytes、patched bytes，并在必要时保存 alternate-before bytes。已知 profile 只有在 5 个位置全部处于可接受状态时才会继续。

### v1.3.7 Auto Profile

如果没有 Built-in Exact Profile 能匹配当前二进制，v1.3.7 可以进入实验性的 Auto Profile 结构识别路径。它的原则是：

- 不根据版本文件夹名称直接复用旧偏移；
- 通过周围结构、控制流和目标字节寻找候选位置；
- 5 个目标必须全部通过验证；
- 任一候选不唯一、不确定或字节状态异常都会安全停止。

当前没有真正更新后的 FeverGames 新版本可供测试，因此 Auto Profile 只能视为备用能力，不能视为已验证的未来版本兼容。新布局实测成功后，应固化为新的 Built-in Exact Profile。

## downloader 架构

替代 downloader 是 C# / .NET 托管程序。源码仓库保存 gzip + Base64 形式的完整 C# 源：

```text
src/downloadIPC_Win7_v1.2.cs.gz.b64
```

`scripts/current/Prepare_Source_v1.2.ps1` 会在源码 checkout 中还原 `scripts/current/downloadIPC_Win7_v1.2.cs`，随后使用目标 Win7 系统已有的 `csc.exe` 编译为 x64 managed EXE。

## 下载流程

v1.3.7 的稳定路径大致为：

```text
FeverGames task
  -> Manifest HTTP
  -> parse Manifest / compute Index total
  -> enter Index state
  -> concurrent Index HTTP
  -> AES-CTR decrypt
  -> in-process libzstd decode
  -> Protobuf / Chunk metadata
  -> balanced Chunk HTTP pipeline
  -> Chunk decrypt / Zstd decode
  -> SumBuf / file reconstruction
  -> MD5
  -> final file
```

## 进程内 libzstd

v1.3.5 起改为：

```text
managed downloadIPC.exe
  -> P/Invoke
  -> libzstd.dll 1.5.6
  -> ZSTD_createDStream
  -> ZSTD_initDStream
  -> ZSTD_decompressStream
```

Windows 7 SP1 x64 + CLR 2.0 的独立流式解压测试已经通过，随后在实际 FeverGames 下载中验证完成。

## v1.3.7：Index 调度

此前测试曾出现两个与 Windows 10 / 11 官方 downloader 行为明显不同的问题：Index 阶段刚出现时总大小为 0，以及按最终文件 StageSize 排序后，大 Index 集中在前面、小 Index 集中在尾段。

v1.3.7 调整为：

- 先完成 Manifest 解析并读取 `pb_size_v2`，再进入 Index 状态；
- Index 阶段使用 Manifest 原始顺序；
- Index 并发：HDD 64 / SSD 96；
- HTTP connection limit 同步提高；
- Index 数据尽量在内存中完成 AES-CTR、libzstd 和 Protobuf 处理；
- AES Key 探测只读取必要头部并缓存成功 Key；
- 正常热路径减少逐 Index 同步日志写入。

这些修改改善了 Index 阶段的响应和尾段行为，但 Windows 7 替代实现仍可能比官方新系统 downloader 慢。

## v1.3.7：平衡型 Chunk / Build 管线

正式版主下载采用经测试后保留的平衡参数：

```text
HDD: large chunk workers = 8, small chunk workers = 6, build workers = 1
SSD: large chunk workers = 12, small chunk workers = 10, build workers = 2
```

Index 完成后，主下载计划仍可按适合 Chunk / Build 的顺序组织，因此 Index 的 Manifest 顺序不会强制改变后续文件构建策略。

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

Windows 7 SP1 x64 实机验证结果：5/5 补丁成功、3133/3133 文件完整下载、游戏成功启动并进入世界。

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

安装前会保存官方 `FeverGamesInstaller.exe.original` 和 `downloadIPC.exe.original`。如果安装器复制了 `libzstd.dll`，会记录 `copied_libzstd.sha256`；恢复时只有当前 DLL SHA-256 与记录一致才会删除该 DLL。

## 诊断

诊断会记录 downloader / decoder 状态、下载阶段以及性能相关信息。v1.3.6 已修复旧 CLR 下 `decoder_info.txt` 的 SHA-256 采集兼容问题。

诊断不会主动收集 PRIVATE Manifest response、AES key、deviceId、uid、sig、secKey 等敏感鉴权数据。

## 第三方组件

正式 Release ZIP 包含 Zstandard 1.5.6 的 `libzstd.dll`，按 BSD License 条款再分发。见：[第三方组件说明](THIRD_PARTY_NOTICES.md)。
