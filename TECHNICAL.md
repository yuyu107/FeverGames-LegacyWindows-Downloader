# 技术说明

## 1. Windows 7 上的原版 downloadIPC 问题

实机与静态分析确认，发烧游戏（FeverGames）新下载后端使用 Go 1.23.x `downloadIPC.exe`。在 Windows 7 上，程序很早进入 Go runtime 的随机数初始化路径，并动态解析：

```text
bcryptprimitives.dll!ProcessPrng
```

该路径在 Windows 7 上不可用，原版 downloader 会在有效下载任务建立前失败。

发烧游戏 1.18.42.14 的原版 `downloadIPC.exe` 仍能确认包含同一 Go 1.23.8 / `ProcessPrng` 兼容问题，因此 v1.3 继续采用替代 downloader。

## 2. 两层兼容方案

v1.3 分为两层：

1. 对 `FeverGamesInstaller.exe` 做严格、精确字节校验后的前端兼容修补；
2. 用 Windows 7 可运行的 .NET downloader 替换原版 Go downloader。

游戏内容版本不写死，仍从发烧游戏启动参数读取动态 `targetVersion`。

## 3. 已知前端补丁布局

| 项目 | 1.18.42.12 | 1.18.42.14 |
|---|---:|---:|
| Gate A | `0xA64460` | `0xA64C70` |
| Gate B | `0x6EE624` | `0x6EE624` |
| `download_check` OS label | `0xA07B5C` | `0xA0836C` |
| `download_check` minor | `0xA07BD2` | `0xA083E2` |
| `sysVer` getter | `0xA09220` | `0xA09A30` |

每处都在写入前验证原始字节。版本号未知时，只有一个已知配置的所有目标位置都匹配已知原始 / 已补丁状态，才允许复用；否则停止。

具体字节定义见：

```text
FeverGames_PatchProfiles_v1.3.ps1
```

## 4. 替代 downloader 数据链

已验证流程：

```text
发烧游戏（FeverGames）
  -> ZMTP 3.x PUB/SUB
  -> Manifest API
  -> target_manifest.bin
  -> encrypted .index
  -> AES-CTR (zero counter)
  -> Zstd
  -> protobuf SumHead
  -> SumChunk + SumBuf
  -> CDN chunks
  -> file reconstruction
  -> MD5 verification
  -> 发烧游戏 progress / completion state
```

下载器读取发烧游戏已经提供给官方下载任务的参数，并使用官方 Manifest / CDN 流程。PRIVATE API response 只在运行时内存中处理，不应写入公开诊断或仓库。

## 5. ZMQ / ZMTP

已确认：

- `--pubport`：downloadIPC PUB -> 发烧游戏 SUB；
- `--subport`：downloadIPC SUB <- 发烧游戏 PUB；
- 业务消息为三帧 multipart：`contentId` / `type` / `payload`。

已验证命令：

```text
1 = pause
2 = resume
3 = cancel/stop
4 = heartbeat acknowledgement
5 = rate-limit/update related
```

完成状态使用 `StateFlags=8`。

## 6. v1.3.0 的性能边界

当前稳定 downloader 采用已完整验证的串行实现。日志分析确认两类主要性能开销：

- 一个大文件的网络 chunk 下载完成后，会进行本地 SumBuf 重组与整文件 MD5；这个阶段可能没有网络流量，因此界面会短暂显示 0 B/s；
- 尾部存在大量极小 chunk / 小文件，使用外部 `7z.exe` 解压时，进程启动固定开销会占据较大比例，因此最后几个百分点可能较慢。

Windows 8.1 官方 downloader 的完整过程抓取表明其文件创建 / I/O 调度方式与当前串行替代实现明显不同，后续版本可以研究并发下载和构建流水线。

为了避免在正式发布前引入新的数据一致性风险，v1.3.0 不包含未经完整回归验证的并发 / 流水线重写。

## 7. 安全边界

本项目：

- 不实现账号登录绕过；
- 不绕过内容授权；
- 不要求账号密码；
- 不分发游戏文件；
- 不在公开诊断中保存 PRIVATE Manifest response、AES key、deviceId、uid、sig、secKey 等敏感数据。
