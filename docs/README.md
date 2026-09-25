# 文档索引

当前正式版：**v1.3.6**

- [兼容性记录](COMPATIBILITY.md)
- [系统环境要求](ENVIRONMENT.md)
- [技术说明](TECHNICAL.md)
- [源码包使用说明](使用说明.txt)
- [第三方组件说明](THIRD_PARTY_NOTICES.md)
- [v1.3.6 Release Notes](releases/v1.3.6.md)
- [版本发布记录](releases/)
- [校验值](releases/checksums/)

v1.3.6 新增 **FeverGames 1.18.44.2-A** 精确支持，并修复旧 CLR 下 `decoder_info.txt` 的 SHA-256 收集；下载核心继续沿用 v1.3.5 已验证的 **libzstd.dll 1.5.6** 进程内解压方案，Release ZIP 已内置 DLL。

`releases/` 保存各版本 Release Notes 与校验值，仓库根目录不堆放历史发布文件。

v1.3.2 Release 已删除，其修复内容已由后续版本继承；普通用户请直接下载 v1.3.6。

如果 Windows 7 是深度精简版，请先查看 [系统环境要求](ENVIRONMENT.md)。缺少 `powershell.exe` 或 .NET C# 编译器 `csc.exe` 时，安装器无法正常运行。
