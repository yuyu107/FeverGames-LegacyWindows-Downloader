# 更新日志

## v1.2 - Zero-Start

当前首个从“官方/重装后的干净 FeverGames”直接安装的整合版本。

相对之前分散的测试包：

- 合并前端 v2.0 的 5 处补丁
- 合并已端到端验证成功的 integrated downloadIPC
- 不需要 v1.0 ZMQ Emulator 作为前置步骤
- 不需要手动 Manifest Probe
- 不需要 PRIVATE_manifest_response.json
- 自动寻找 FeverGames 安装目录
- 自动申请管理员权限
- 自动检查 FeverGames 进程是否已退出
- 自动检查 .NET C# 编译器
- 自动检查 7-Zip / zstd
- 所有前端目标字节先在临时副本验证
- 正式文件修改前创建 clean rollback backup
- 安装出错时尝试事务式自动回滚
- 支持从旧测试环境寻找原版 Native downloadIPC 作为备份
- 新增完整状态检查
- 新增一键恢复官方文件
- 新增隐私安全的诊断收集
- 新增可选缓存清理
