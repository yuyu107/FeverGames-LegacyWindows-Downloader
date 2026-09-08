# v1.3.2 - 修复 Windows 7 / PowerShell 2.0 下 .NET 下载器验证误判

v1.3.2 是 v1.3.1 的小型兼容性修复版本。

本版本**不修改已经完成端到端验证的下载核心、不修改 5 点前端补丁逻辑，也不引入新的并发 / 流水线 / DLL Zstd 实验代码**。主要修复一类较原生 Windows 7 环境中，安装器对刚编译出的 `downloadIPC.exe` 发生误判并主动中止安装的问题。

## 问题现象

受影响环境中，v1.3.1 可以正常：

- 找到 FeverGames；
- 识别 `1.18.42.14 / layout A` 或其它已知布局；
- 对 5 个前端目标位置完成精确字节修补；
- 找到 .NET 4 `csc.exe` 并生成新的 `downloadIPC.exe`；

但随后会报：

```text
Compiled downloader did not validate as a managed .NET executable.
Installation did not complete successfully. Exit code: 1
```

此时安装器仍处于正式覆盖前的临时工作目录阶段，因此会安全停止，不会把未通过验证的文件写入 FeverGames 正式目录。

## 根因

v1.3.1 使用：

```powershell
[Reflection.AssemblyName]::GetAssemblyName($Path)
```

判断生成的 EXE 是否为托管 .NET 程序。

在部分 Windows 7 / PowerShell 2.0 环境中，当前 PowerShell 运行于旧 CLR，而脚本又可能选择 .NET Framework 4.0 的 `csc.exe` 编译下载器。编译器已经成功生成文件，但旧 CLR 不一定能通过上述方式加载 / 识别目标程序集，于是脚本把“当前 CLR 无法加载”误判成“不是有效的 managed .NET EXE”。

## v1.3.2 修复

- 安装脚本不再依赖当前 PowerShell CLR 加载目标程序集；
- 改为直接读取 PE Optional Header，并检查 CLR / COM Descriptor 数据目录；
- 状态检查脚本同步使用同一套 CLR-independent 判断，避免安装成功后再次误报；
- 编译结果验证仍保留 fail-safe：如果 PE 中不存在有效 CLR Descriptor，仍会在正式覆盖前停止；
- 验证失败时额外输出生成文件大小与 SHA-256，方便继续诊断。

## 实机验证

该修复已由一台此前 v1.3.1 会稳定出现：

```text
Compiled downloader did not validate as a managed .NET executable.
```

的 Windows 7 环境进行复测。

使用 `v1.3.2-test1`（与正式 v1.3.2 使用相同的 CLR-independent 验证逻辑）后，安装可以正常继续并完成，因此本次问题已确认属于 v1.3.1 的验证兼容性误判。

## 保持不变的部分

v1.3.2 继续沿用 v1.3.1 已验证内容：

- FeverGames `1.18.42.12 / layout A`；
- FeverGames `1.18.42.14 / layout A`；
- FeverGames `1.18.42.14 / layout B`；
- 同版本多布局的 5 点精确匹配选择；
- 自定义 FeverGames 安装路径发现 / 手动拖入兜底；
- 自定义 7-Zip 路径发现；
- UAC 等待与自动状态检查；
- 已完成端到端验证的 v1.2 .NET 下载核心；
- rollback backup、状态检查、恢复与诊断流程。

`1.18.42.14 / layout B` 原版 `FeverGamesInstaller.exe` SHA-256 仍为：

```text
0a2a9568ac788227f0815e3c23761cadc11b51ee4ba9b86336cb2abf61e178e9
```

## 使用

完全退出 FeverGames 后运行：

```text
01_一键安装.cmd
```

安装结束后会自动运行状态检查。正常结果应包含：

```text
Frontend patch count: 5/5
downloadIPC.exe = managed Win7 replacement
rollback backup = COMPLETE
RESULT=READY_FOR_WIN7_FEVERGAMES_DOWNLOAD
```

## 隐私与边界

本项目不实现账号登录绕过，不分发游戏内容，也不需要账号密码。

公开日志 / Issue / 诊断信息中请勿包含 PRIVATE Manifest response、AES key、Token、Cookie、deviceId、uid、sig、secKey 或其它账号 / 临时鉴权信息。
