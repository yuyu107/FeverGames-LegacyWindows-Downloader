# 技术说明

## 问题来源

当前 FeverGames 的新下载后端会启动 `downloadIPC.exe`。实机排查确认，当前原版 downloader 使用 Go 1.23.x，并在 Windows 7 上很早期进入 Go runtime 时崩溃。其随机数初始化路径动态解析 `bcryptprimitives.dll!ProcessPrng`，该 API 的最低客户端版本为 Windows 8，因此 Windows 7 会在建立有效下载任务之前失败。

前端还存在独立的系统版本限制，因此完整方案分成两层：

1. 对已验证的 `FeverGamesInstaller.exe 1.18.42.12` 做严格字节校验后修补，使 Win7 能进入下载流程，并把下载检查/下载参数伪装为 Win8.1；
2. 用 Win7 可运行的 .NET downloader 替代原版 Go downloader。

## 替代 downloader 实现

已实机验证的流程为：

```text
FeverGames
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
  -> FeverGames progress / completion state
```

下载器从 FeverGames 原始参数中读取 `contentid`、`targetVersion`、`deviceId`、`appVer`、`isSSD`、`env`、`oversea`、`path` 等值，请求官方 Manifest。PRIVATE API response 只在内存中处理，不作为仓库内容或诊断结果保存。

## ZMQ / ZMTP 会话

通过 Windows 8.1 工作环境透明抓取后确认：

- `--pubport`：downloadIPC 为 PUB，FeverGames 为 SUB；
- `--subport`：downloadIPC 为 SUB，FeverGames 为 PUB；
- downloader -> FeverGames 使用三帧 multipart：`contentId` / `message type` / `payload`；
- FeverGames -> downloader 同样使用 `contentId` / `command type` / `payload`。

已实机确认的命令：

- `1` = 暂停
- `2` = 恢复
- `3` = 取消/停止
- `4` = heartbeat acknowledgement
- `5` = 限速/参数更新相关

已确认的状态/事件包括：`2`、`3`、`4`、`6`、`8`、`10 heartbeat`、`2001`、`2002`、`2005`。

## 安全边界

本项目不实现账号登录，不要求账号密码，不绕过游戏内容授权，也不把游戏文件、PRIVATE Manifest response、AES key、deviceId、uid、sig、secKey 等敏感数据提交到仓库。

## 版本边界

- Minecraft/游戏内容 `targetVersion`：动态适配；
- FeverGamesInstaller.exe：当前前端补丁只验证于 `1.18.42.12`。

脚本对目标字节做精确检查，未知 build 会停止，而不是盲目写入。
