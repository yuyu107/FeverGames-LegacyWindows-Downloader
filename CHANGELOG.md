# 更新日志

## v1.2 - Zero-Start

首个从“官方 / 重装后的干净 FeverGames”直接安装的整合版本，也是首个公开 Release。

### 已验证

- Windows 7 SP1 x64 下 FeverGames 新版下载链端到端成功；
- 《我的世界》基岩互通版完成 3130 / 3130 文件，下载进度达到 100%；
- 《第五人格》已确认可以正常进入下载流程并下载游戏内容；
- 其他 FeverGames 游戏也出现成功下载案例，说明替代下载器并非 Minecraft 专用实现；
- ZMTP / ZMQ 握手、heartbeat、暂停、恢复、取消均已验证；
- Manifest / Index / AES-CTR / Zstd / Chunk / SumBuf / MD5 全流程已验证。

### 相对早期测试包

- 合并前端 v2.0 的 5 处补丁；
- 合并已端到端验证成功的 integrated downloadIPC；
- 不需要 v1.0 ZMQ Emulator 作为前置步骤；
- 不需要手动 Manifest Probe；
- 不需要 `PRIVATE_manifest_response.json`；
- 自动寻找 FeverGames 安装目录；
- 自动申请管理员权限；
- 自动检查 FeverGames 进程是否已退出；
- 自动检查 .NET C# 编译器；
- 自动检查 7-Zip / zstd；
- 所有前端目标字节先在临时副本验证；
- 正式文件修改前创建 clean rollback backup；
- 安装出错时尝试事务式自动回滚；
- 支持从旧测试环境寻找原版 Native downloadIPC 作为备份；
- 新增完整状态检查；
- 新增一键恢复官方文件；
- 新增隐私安全的诊断收集；
- 新增可选缓存清理。

### 当前限制

- FeverGames 前端二进制补丁目前只实机验证于 `1.18.42.12`；
- 其他使用相同下载后端的游戏可能兼容，但只有实际测试过的游戏才列为“已验证”。
