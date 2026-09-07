# v1.3.1 - 同版本多布局、自定义安装路径与一键安装稳定性修复

v1.3.1 是 v1.3.0 的稳定性 / 兼容性更新。

本版本继续沿用已经完成端到端验证的 v1.2 .NET 下载核心，不合入实验性的并发、流水线或 DLL 直解 Zstd 重构。

## 主要变化

- 新增 FeverGames `1.18.42.14 / layout B` 前端精确补丁配置；
- 已确认同一个 `1.18.42.14` 文件夹版本号可能对应不同的 `FeverGamesInstaller.exe` 二进制布局；
- 同版本存在多个布局时，不再只根据版本号选择 profile，而是要求 5 个目标位置全部精确匹配；
- 支持 FeverGames 安装在自定义目录：
  - 记住上一次成功使用的安装根目录；
  - 检查 Windows 卸载信息；
  - 检查桌面 / 开始菜单快捷方式；
  - 检查各磁盘常见目录；
  - 自动查找失败时，可直接拖入 FeverGames 根目录、数字版本目录或 `FeverGamesInstaller.exe`；
- 支持 7-Zip 安装在自定义目录：
  - 默认 Program Files；
  - 7-Zip 官方注册表路径；
  - PATH；
  - 已保存的 decoder 路径；
- 修复一键安装的 UAC 流程：外层脚本会等待管理员安装过程真正完成，再自动运行状态检查；
- 修复 Windows 7 / PowerShell 2.0 下保存 FeverGames 自定义安装根目录失败的问题；
- 修复旧包中残留的 `v1.3.0-rc2` 显示；
- Release ZIP 重新整理，根目录只保留常用入口和一个可直接用记事本打开的 `使用说明.txt`。

## 实机验证

本版本已在 Windows 7 SP1 x64 上验证：

- FeverGames `1.18.42.14 / layout B`
- FeverGames 自定义安装目录：`D:\FeverGames`
- 7-Zip 自定义安装目录：`D:\7-Zip`
- 前端补丁：`5/5`
- `downloadIPC.exe` 替换成功
- rollback backup：完整
- 《我的世界》基岩互通版：完整下载成功
- 游戏启动成功
- 成功进入世界

`1.18.42.14 / layout B` 原版 `FeverGamesInstaller.exe`：

```text
SHA256:
0a2a9568ac788227f0815e3c23761cadc11b51ee4ba9b86336cb2abf61e178e9
```

## 使用

完全退出 FeverGames 后运行：

```text
01_一键安装.cmd
```

安装结束后会自动进行状态检查。正常结果应包含：

```text
Patch profile: 1.18.42.14 / layout B
Frontend patch count: 5/5
downloadIPC.exe = managed Win7 replacement
rollback backup = COMPLETE
RESULT=READY_FOR_WIN7_FEVERGAMES_DOWNLOAD
```

也可以手动运行：

```text
02_检查状态.cmd
03_恢复官方文件.cmd
04_收集诊断.cmd
```

## Release 包结构

```text
01_一键安装.cmd
02_检查状态.cmd
03_恢复官方文件.cmd
04_收集诊断.cmd
使用说明.txt
core\
```

Release ZIP 中不再重复附带多个 Markdown 说明文件；完整 README、兼容性与技术文档继续保留在 GitHub 仓库。

## 已知性能现象

当前稳定版优先保证正确性与兼容性。

大文件下载完成后的本地拼接 / MD5 阶段可能短暂显示 `0 B/s`；尾部大量极小 chunk / 小文件阶段也可能明显变慢。这不一定代表网络卡死。

实验性的 DLL 直解 Zstd、并发与流水线优化暂不合入 v1.3.1。

## 隐私与边界

本项目不实现账号登录绕过，不分发游戏内容，也不需要账号密码。

公开日志 / Issue / 诊断信息中请勿包含：

- PRIVATE Manifest response
- AES key
- Token / Cookie
- deviceId / uid
- sig / secKey
- 其他账号或临时鉴权信息
