# 文档索引

当前正式版：**v1.4.0**

- [兼容性记录](COMPATIBILITY.md)
- [系统环境要求](ENVIRONMENT.md)
- [技术说明](TECHNICAL.md)
- [源码包使用说明](使用说明.txt)
- [第三方组件说明](THIRD_PARTY_NOTICES.md)
- [v1.4.0 Release Notes](releases/v1.4.0.md)
- [版本发布记录](releases/)
- [校验值](releases/checksums/)

v1.4.0 新增独立下载、更新检查 / 增量更新 / 校验修复，以及只修补 `downloadIPC.exe` 的入口。完整前端补丁、Built-in Exact Profile、Auto Profile 5/5 验证、恢复与诊断功能继续保留。

05 独立下载器只支持新版 Manifest / Index / Chunk 分发链；Aria2 / 经典下载游戏仍使用 FeverGames 平台原生下载。
