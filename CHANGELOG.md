# 更新日志

## v1.3.1

v1.3.0 的稳定性 / 兼容性更新。

- 新增 FeverGames `1.18.42.14 / layout B` 前端精确补丁配置；
- 确认同一个 `1.18.42.14` 文件夹版本号可能对应不同 `FeverGamesInstaller.exe` 二进制布局；
- 同版本多布局时不再只根据版本号选择 profile，而是要求 5 个目标位置全部精确匹配；
- 支持 FeverGames 安装在自定义目录：记住上次成功路径、检查卸载信息、快捷方式、各磁盘常见目录，并提供拖入根目录 / 数字版本目录 / `FeverGamesInstaller.exe` 的手动兜底；
- 支持 7-Zip 安装在自定义目录：检查 Program Files、官方注册表路径、PATH 和已保存 decoder 路径；
- 修复一键安装 UAC 流程，外层脚本会等待管理员安装过程完成后再运行状态检查；
- 修复 Windows 7 / PowerShell 2.0 下保存 FeverGames 自定义安装根目录失败的问题；
- 修复旧包中残留的 `v1.3.0-rc2` 显示；
- Release ZIP 重新整理，根目录仅保留常用入口、`使用说明.txt` 与 `core\`；
- 继续沿用已完成端到端验证的 v1.2 .NET 下载核心，不合入实验性 DLL 直解 Zstd、并发或流水线重构。

### v1.3.1 实机验证

Windows 7 SP1 x64：

- FeverGames `1.18.42.14 / layout B`；
- FeverGames 自定义目录 `D:\FeverGames`；
- 7-Zip 自定义目录 `D:\7-Zip`；
- 前端补丁 `5/5`；
- `downloadIPC.exe` 替换成功；
- rollback backup 完整；
- 《我的世界》基岩互通版完整下载成功；
- 游戏启动成功并进入世界。

`1.18.42.14 / layout B` 原版 `FeverGamesInstaller.exe` SHA256：

```text
0a2a9568ac788227f0815e3c23761cadc11b51ee4ba9b86336cb2abf61e178e9
```

## v1.3.0

正式稳定版。

相对 v1.2：

- 新增 FeverGames `1.18.42.14` 前端精确补丁配置；
- 保留 `1.18.42.12` 支持；
- `1.18.42.14` 已在 Windows 7 SP1 x64 完成实机完整下载验证；
- 自动扫描数字版本目录，并选择最新完整 FeverGames 版本；
- 使用多 build 补丁表；
- 所有前端补丁继续使用精确字节校验；
- 未知版本只有完整匹配某个已知布局时才允许复用，否则安全停止；
- 修复 PowerShell 2.0 / .NET 3.5 下 SHA256 `Dispose()` 兼容问题；
- 状态输出统一为 `READY_FOR_WIN7_FEVERGAMES_DOWNLOAD`；
- 新备份目录使用 `Win7_Downloader_Fix_Backup_v1.3`；
- 恢复流程兼容旧 `Win7_Bedrock_Fix_Backup_v1.2`；
- 状态检查、恢复与诊断流程适配滚动版本目录；
- 整理 Release 包文档、兼容性说明、技术说明与英文快速说明；
- 保留已经完整验证的 v1.2 .NET 下载核心，正式版不合入实验性并发重构。

### 已知性能特征

当前稳定下载核心优先保证正确性与兼容性。相比 Windows 8.1 上的官方下载器，大文件本地重组 / MD5 阶段可能短暂显示 0 B/s；尾部大量极小 chunk / 小文件阶段可能较慢。后续版本将基于 Win8.1 官方下载过程抓取结果继续优化。

## v1.2 - Zero-Start

首个可以从官方/重装后的干净 FeverGames 直接安装的整合版本：

- 合并前端 5 处补丁；
- 合并已端到端验证成功的 integrated downloadIPC；
- 不需要 ZMQ Emulator / Manifest Probe 等研究阶段前置步骤；
- 自动申请管理员权限、检查编译器和解压器；
- 正式修改前创建 clean rollback backup；
- 安装失败时尝试自动回滚；
- 提供状态检查、恢复、诊断和可选缓存清理。
