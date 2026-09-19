# 第三方组件说明

## Zstandard / libzstd.dll

- 项目：Zstandard
- v1.3.5 使用版本：**1.5.6**
- 上游仓库：https://github.com/facebook/zstd
- 版权所有：Meta Platforms, Inc. and affiliates，以及相关贡献者

Zstandard 官方仓库采用 **BSD OR GPLv2** 双许可证。FeverGames Legacy Windows Downloader 的 v1.3.5 Release 对 `libzstd.dll` 选择 **BSD License** 条款进行再分发。

完整 BSD License 文本见：

[`docs/third_party/Zstandard_v1.5.6_LICENSE.txt`](third_party/Zstandard_v1.5.6_LICENSE.txt)

v1.3.5 正式 Release ZIP 中的二进制：

```text
File: core\tools\libzstd.dll
Version: 1.5.6
Architecture: x86-64
Size: 1254833 bytes
SHA-256: 4d540a749823e5b8a6eb56deca5715150442d45f1e8863dd185fc31002b9b5d1
```

该 DLL 来自 Zstandard v1.5.6 Windows x64 发布包。

本项目自身代码、脚本与文档仍按仓库根目录的 MIT License 发布；第三方组件遵循各自许可证。
