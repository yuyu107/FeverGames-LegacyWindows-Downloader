# 第三方组件说明

## Zstandard / libzstd.dll

v1.5.0 的 **05 独立下载器**继续使用从 v1.4.2 正式包原样保留的 Zstandard 1.5.6 x64 `app/libzstd.dll`。平台补丁安装不再将此 DLL 作为自制 downloadIPC 的依赖复制到平台目录。

- 上游项目：[facebook/zstd](https://github.com/facebook/zstd)
- 版权所有：Meta Platforms, Inc. and affiliates，以及相关贡献者
- 再分发选择：BSD License
- 完整许可：[Zstandard_v1.5.6_LICENSE.txt](third_party/Zstandard_v1.5.6_LICENSE.txt)，正式 ZIP 内也包含 `ZSTD_LICENSE.txt`

| 项目 | 值 |
| --- | --- |
| 正式包路径 | app/libzstd.dll |
| 版本 | 1.5.6 |
| 架构 | x86-64 |
| 大小 | 1254833 字节 |
| SHA-256 | `4d540a749823e5b8a6eb56deca5715150442d45f1e8863dd185fc31002b9b5d1` |

## 官方组件

FeverGamesInstaller.exe、官方 Go 版 downloadIPC.exe 及 OrbitSDK.dll 属于官方程序。本项目发布包不包含其完整 EXE；通过本机原始文件生成兼容补丁，修改后的 EXE 原有数字签名会失效。

项目自行编写的代码、脚本与文档采用仓库根目录的 [MIT License](../LICENSE)。第三方组件遵循各自许可证。
