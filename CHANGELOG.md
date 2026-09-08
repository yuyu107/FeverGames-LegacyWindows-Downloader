# 更新日志

## v1.3.3

当前建议使用的正式版本。由于 v1.3.2 Release 已删除，v1.3.3 同时包含 v1.3.2 的修复内容和本次新增的 CMD 打包修复。

- 合入 v1.3.2 的 Windows 7 / PowerShell 2.0 / 旧 CLR 托管 EXE 验证修复；
- `Is-ManagedExe` 继续使用 PE Optional Header + CLR / COM Descriptor 判断，不再依赖当前 PowerShell CLR 加载目标程序集；
- 修复 v1.3.2 Release ZIP 中 `.cmd` 入口文件 UTF-8 BOM / LF 换行导致 Windows 7 `cmd.exe` 解析错乱的问题；
- Release ZIP 中所有入口 `.cmd` 改为无 BOM + CRLF，并保持纯 ASCII 命令内容；
- 修复后已确认此前会出现 `锘緻echo`、`hell.exe`、`ho` 等解析错误的环境可以正常运行入口；
- 下载核心、layout A/B、5 点精确字节补丁、自定义 FeverGames / 7-Zip 路径、UAC、备份与恢复逻辑保持不变。

## v1.3.2

历史过渡版本。该 Release 已删除，修复内容已由 v1.3.3 继承。请直接使用 v1.3.3。

- 修复部分较原生 Windows 7 / PowerShell 2.0 环境中，`.NET 4 csc.exe` 已成功生成 `downloadIPC.exe`，但旧 CLR 通过 `AssemblyName.GetAssemblyName()` 验证时发生误判的问题；
- `Is-ManagedExe` 改为直接读取 PE Optional Header，并检查 CLR / COM Descriptor；
- 安装脚本与状态检查脚本统一使用 CLR-independent 判断；
- 如果 PE 中不存在有效 CLR Descriptor，仍会在正式覆盖前安全停止；
- 编译后验证失败时额外输出文件大小和 SHA-256，方便继续诊断；
- 该修复已由一台 v1.3.1 会稳定出现 `Compiled downloader did not validate as a managed .NET executable.` 的 Windows 7 实机复测，修正后的测试包可正常完成安装；
- 其余 layout A/B、5 点精确字节补丁、v1.2 .NET 下载核心、自定义 FeverGames / 7-Zip 路径、UAC、备份与恢复逻辑保持 v1.3.1 行为。

## v1.3.1

v1.3.0 的稳定性 / 兼容性更新。

- 新增 FeverGames `1.18.42.14 / layout B` 前端精确补丁配置；
- 确认同一个 `1.18.42.14` 文件夹版本号可能对应不同 `FeverGamesInstaller.exe` 二进制布局；
- 同版本多布局时不再只根据版本号选择 profile，而是要求 5 个目标位置全部精确匹配；
- 支持 FeverGames 与 7-Zip 自定义安装目录；
- 修复一键安装 UAC 等待、Windows 7 / PowerShell 2.0 路径保存和旧版本显示问题；
- Release ZIP 简化为常用入口、`使用说明.txt` 与 `core\`；
- 继续沿用已完成端到端验证的 v1.2 .NET 下载核心。

### v1.3.1 实机验证

Windows 7 SP1 x64：FeverGames `1.18.42.14 / layout B`、`D:\FeverGames`、`D:\7-Zip`、前端补丁 `5/5`、完整 rollback backup、《我的世界》基岩互通版完整下载、启动并进入世界。

`1.18.42.14 / layout B` 原版 `FeverGamesInstaller.exe` SHA256：

```text
0a2a9568ac788227f0815e3c23761cadc11b51ee4ba9b86336cb2abf61e178e9
```

## v1.3.0

正式稳定版。新增 `1.18.42.14` 精确补丁配置、滚动版本目录、多 build 补丁表、PowerShell 2.0 / .NET 3.5 SHA256 兼容修复，并继续使用 v1.2 .NET 下载核心。

## v1.2 - Zero-Start

首个可以从官方/重装后的干净 FeverGames 直接安装的整合版本：合并前端 5 处补丁、端到端验证的 integrated downloadIPC、自动权限/编译器/解压器检查、clean rollback backup、状态检查、恢复、诊断和可选缓存清理。
