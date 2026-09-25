# 系统环境要求

本项目主要面向 **Windows 7 SP1 x64**。

## 推荐环境

建议使用接近原版的 Windows 7 SP1 64 位系统，并保留常见系统组件。

安装器至少需要：

- `cmd.exe`
- `powershell.exe`
- .NET Framework 2.0 / 3.5 / 4.x 中至少一个可用的 C# 编译器 `csc.exe`
- 管理员权限 / UAC 提权能力
- 正常的文件系统、注册表和进程查询功能

## v1.3.5 起不再要求安装 7-Zip

v1.3.6 Release ZIP 已包含：

```text
core\tools\libzstd.dll
```

版本为 **Zstandard 1.5.6 x64**。

安装器会把 DLL 复制到当前 FeverGames 版本目录，使替代 `downloadIPC.exe` 可以直接通过 P/Invoke 调用 `ZSTD_decompressStream`。

因此普通 Release 用户不需要：

- 安装 7-Zip；
- 配置 7-Zip 安装目录；
- 单独准备 `zstd.exe`。

## 从源码仓库运行

源码仓库不直接提交第三方 `libzstd.dll` 二进制。

如果从源码 checkout 运行根目录的安装入口，需要自行从 Zstandard 官方 **v1.5.6 Windows x64** Release 中取得：

```text
libzstd.dll
```

并放到：

```text
tools\libzstd.dll
```

普通用户应优先使用 GitHub Release ZIP，因为正式包已经包含经过 Win7 实机测试的 DLL。

## .NET / C# 编译器

替代 `downloadIPC.exe` 会在目标机器上使用系统现有的 `csc.exe` 编译。

安装器依次尝试常见 Framework / Framework64 路径，包括 .NET 4.x、3.5 和 2.0。

v1.3.2 起，生成后的 managed EXE 不再通过当前 PowerShell CLR 直接加载验证，而是检查 PE Optional Header 中的 CLR / COM Descriptor，以避免 PowerShell 2.0 / 旧 CLR 对较新程序集的误判。

## PowerShell

需要可运行的 Windows PowerShell。

深度精简版系统如果已经删除 `powershell.exe`，当前一键安装流程无法正常工作。

## 管理员权限

修改 FeverGames 版本目录中的：

- `FeverGamesInstaller.exe`
- `downloadIPC.exe`
- `libzstd.dll`

通常需要管理员权限。

一键入口会请求 UAC 提权，并等待提权后的安装流程结束。

## 深度精简 / Ghost / 魔改系统

以下情况都可能导致安装失败：

- PowerShell 被删除；
- .NET Framework 或 `csc.exe` 被裁剪；
- UAC / RunAs 功能损坏；
- 系统加密 API / SHA-256 支持异常；
- 基础文件系统、进程或注册表组件被裁剪。

这种环境出现问题时，应优先收集诊断，而不是直接绕过检查。

## 网络与磁盘

替代 downloader 仍要完成 Manifest、Index、Chunk 下载、解密、Zstd 解压、文件重组和 MD5 校验。

大量小文件 / 小 Chunk、机械硬盘、慢速存储或 CDN 延迟可能让末尾阶段明显变慢；短暂 `0 B/s` 不一定代表卡死。

v1.3.6 正式版仍没有启用针对某个游戏调出来的实验并发参数。
