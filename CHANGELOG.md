# 更新日志

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
