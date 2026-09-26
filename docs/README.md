# 文档索引

当前正式版：**v1.3.7**

- [兼容性记录](COMPATIBILITY.md)
- [系统环境要求](ENVIRONMENT.md)
- [技术说明](TECHNICAL.md)
- [源码包使用说明](使用说明.txt)
- [第三方组件说明](THIRD_PARTY_NOTICES.md)
- [v1.3.7 Release Notes](releases/v1.3.7.md)
- [版本发布记录](releases/)
- [校验值](releases/checksums/)

v1.3.7 将实机测试中验证可用的 **Index 下载优化与平衡型 Chunk / Build 管线**整理进正式版，并加入实验性的 **Auto Profile** 未知布局识别备用路径。

已知布局继续使用 Built-in Exact Profile；Auto Profile 仅在未知布局时尝试，而且必须全部目标通过结构与字节验证。由于当前没有真正更新后的 FeverGames 版本可供测试，Auto Profile 暂不视为未来版本兼容保证。

`releases/` 保存各版本 Release Notes 与校验值，仓库根目录不堆放历史发布文件。

v1.3.2 Release 已删除，其修复内容已由后续版本继承；普通用户请直接下载 v1.3.7。

如果 Windows 7 是深度精简版，请先查看 [系统环境要求](ENVIRONMENT.md)。缺少 `powershell.exe` 或 .NET C# 编译器 `csc.exe` 时，安装器无法正常运行。
