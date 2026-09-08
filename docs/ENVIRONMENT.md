# 系统环境要求

FeverGames Legacy Windows Downloader 主要面向 **Windows 7 SP1 x64**。

本工具不是纯静态单文件补丁。安装、检查、恢复和诊断过程中需要系统仍保留一些基础组件。如果使用深度精简版 Windows 7，可能会因为系统组件缺失而无法运行安装器；这类问题不等同于 FeverGames 补丁逻辑失败。

## 最低运行要求

建议环境：接近原版的 **Windows 7 SP1 x64**。

安装器运行时需要：

- `cmd.exe`：用于运行 Release 包中的 `.cmd` 入口；
- `powershell.exe`：用于执行安装、状态检查、恢复和诊断脚本；
- .NET Framework 2.0 / 3.5 / 4.x 中至少一个可用的 C# 编译器 `csc.exe`；
- 管理员权限：用于修改 FeverGames 安装目录中的程序文件；
- 7-Zip 或 Windows 7 可用的 `zstd.exe`：用于处理 `.zst` 数据；
- 基本注册表、文件系统和进程查询能力：用于自动寻找 FeverGames、7-Zip、备份和状态检查。

## 精简版 Windows 7 说明

部分精简版系统可能移除或破坏：

- PowerShell；
- .NET Framework / C# 编译器；
- WMI / 注册表查询相关组件；
- 系统 PATH / 环境变量；
- UAC 或管理员提权相关组件。

如果这些组件缺失，安装器可能无法继续。当前版本不保证能在深度精简系统上完整运行。

## 常见环境错误

### 找不到 PowerShell

如果运行 `01_一键安装.cmd` 后看到：

```text
'powershell.exe' 不是内部或外部命令，也不是可运行的程序或批处理文件。
```

说明系统中没有可用的 PowerShell，或者 `powershell.exe` 所在路径不可用。当前安装器无法继续运行。

建议使用接近原版的 Windows 7 SP1 x64，或先恢复 Windows PowerShell 组件。

### 找不到 C# 编译器

如果看到：

```text
No compatible .NET C# compiler was found (2.0/3.5/4.x).
```

说明系统里没有找到可用的 .NET C# 编译器 `csc.exe`。

安装器需要在目标机器上编译 Win7 可运行的替代 `downloadIPC.exe`，因此需要系统中存在 .NET Framework 2.0 / 3.5 / 4.x 的编译器。

### CMD 入口乱码或命令被截断

如果看到：

```text
锘緻echo off
powershell.exe -> hell.exe
echo -> ho
goto -> to
```

这是旧 Release 包 `.cmd` 入口文件编码 / 换行不兼容 Windows 7 `cmd.exe` 的表现。请删除旧解压目录，重新下载 v1.3.3 或更新版本。

v1.3.3 的 Release 包已将入口 `.cmd` 统一为无 BOM + CRLF，并保持纯 ASCII 命令内容。

## 不建议的处理方式

- 不建议使用来源不明的“系统组件修复包”；
- 不建议从随机 DLL 网站下载 PowerShell、.NET 或系统 DLL；
- 不建议手动替换 `System32` 中的系统文件；
- 不建议把其它机器上编译出的 `downloadIPC.exe` 手动复制到不同 FeverGames 环境中。

## 反馈时请提供

如果怀疑是系统环境问题，请反馈：

```text
where powershell
powershell -NoProfile -Command "$PSVersionTable.PSVersion; [Environment]::Version"
dir %WINDIR%\Microsoft.NET\Framework\v*\csc.exe
dir %WINDIR%\Microsoft.NET\Framework64\v*\csc.exe
```

同时提供：

- Windows 版本；
- 是否为精简版 / Ghost 版 / 魔改版；
- FeverGames 安装路径；
- 运行的工具版本；
- 第一条错误信息。

请不要公开 Token、Cookie、PRIVATE Manifest response、AES key、deviceId、uid、sig、secKey 或其它账号 / 临时鉴权信息。
