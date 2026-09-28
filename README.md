# 发烧游戏旧版 Windows 下载器

英文项目名：**FeverGames Legacy Windows Downloader**

这是一个面向 **Windows 7 SP1 x64** 的社区兼容项目，用于恢复发烧游戏平台（FeverGames）的游戏下载、修复与更新链路。v1.4.0 新增的独立下载器主要作为 **FeverGames 前端无法安全修补时的备用方案**：当新版平台布局发生变化、完整补丁无法通过 Exact Profile / Auto Profile 验证时，仍可绕开发烧游戏平台前端，直接完成受支持游戏下载链。

当前正式版：**v1.4.0**

- [下载 v1.4.0](https://github.com/yuyu107/FeverGames-LegacyWindows-Downloader/releases/tag/v1.4.0)
- [查看更新日志](CHANGELOG.md)
- [查看 v1.4.0 Release Notes](docs/releases/v1.4.0.md)

> [!IMPORTANT]
> 本项目解决的是 **FeverGames 下载流程兼容**。它不保证下载后的每个游戏本体都能在 Windows 7 上运行。

## v1.4.0 主要功能

Release ZIP 继续保留 v1.3.x 用户熟悉的中文编号入口：

```text
01_一键安装.cmd
02_检查状态.cmd
03_恢复官方文件.cmd
04_收集诊断.cmd
05_独立下载_检查更新与修复.cmd
06_仅修补downloadIPC.cmd
```

### 01：完整补丁

如果 FeverGames 在 Windows 7 上还没调用下载组件就因为系统版本检测阻止下载，运行 `01_一键安装.cmd`。

完整补丁会对经过验证的 `FeverGamesInstaller.exe` 布局做精确字节修补，并安装当前 Win7 兼容 `downloadIPC.exe`。已知布局优先使用 Built-in Exact Profile；未知布局只有 Auto Profile 5/5 验证通过才会继续，否则安全停止。

### 05：独立下载、检查更新与修复

`05_独立下载_检查更新与修复.cmd` 的设计目的，是在 **FeverGames 平台本身无法安全修补，或新版本前端布局暂未适配** 时提供备用下载路径。它不依赖 `FeverGamesInstaller.exe` 的前端补丁，也不要求先由官方客户端创建下载任务。

因此推荐顺序是：平台能够正常修补时优先使用 `01_一键安装.cmd` 恢复原生 FeverGames 下载体验；如果前端布局变化导致完整补丁拒绝安装，再使用 05 独立下载器作为兜底。

`05_独立下载_检查更新与修复.cmd` 支持：

- 输入 App ID 后匿名获取游戏信息、Content ID 和最新版；
- Manifest / Index / AES-CTR / Zstd / Protobuf / Chunk / Build / MD5；
- 默认安装目录与自定义目录；
- 禁止直接选择磁盘根目录；
- 选择目录后返回上一步重新修改；
- 实时进度条；
- 已安装游戏更新检查；
- 增量更新；
- 校验 / 修复当前安装；
- 下载完成后登记到 FeverGames。

### 06：仅修补 downloadIPC.exe

`06_仅修补downloadIPC.cmd` 不修改 `FeverGamesInstaller.exe`，只替换实际负责新版文件分发任务的 `downloadIPC.exe` 并配置 `libzstd.dll`。

已实测可以恢复 FeverGames 平台内原本失败的“游戏修复”功能。

## Index Tail Recovery

v1.4.0 针对部分环境 Index 下载到约 99% 后停滞 / 重新开始的问题调整为：

```text
普通 Index：
HDD 24 workers
SSD 32 workers

最后 64 个 Index：
最多 4 workers
Keep-Alive = false
Timeout = 10 秒
Retry = 3 次
```

## 已知限制：Aria2 / 经典下载游戏

05 独立下载器当前支持 FeverGames 的新版 Manifest / Index / Chunk 分发链。

部分游戏仍由 FeverGames 使用 **Aria2 / 经典下载方式**。这类游戏不能使用 05 独立下载器，请使用 FeverGames 平台自身的下载功能。

如果当前 FeverGames 前端仍能被安全识别并修补，优先运行 `01_一键安装.cmd`，继续使用平台原生下载。只有在前端新版布局暂时无法通过安全验证、无法修补时，05 才是主要备用方案。

## 已验证前端布局

```text
1.18.42.12 / layout A
1.18.42.14 / layout A
1.18.42.14 / layout B
1.18.43.22 / layout A
1.18.44.2 / layout A
```

## 源码

v1.4.0 的精确 Release 源码快照保存在：

```text
src/v1.4.0/
```

源码快照排除了第三方 `libzstd.dll` 二进制；普通用户请使用 GitHub Release ZIP。

## 安全与回滚

- 修改 FeverGames 程序目录前请完全退出 FeverGames，包括托盘；
- 完整补丁会先建立原版回滚备份；
- `03_恢复官方文件.cmd` 可恢复补丁安装前的官方文件；
- 公开反馈时不要上传 PRIVATE Manifest response、AES key、Token / Cookie、deviceId / uid、sig / secKey 等账号或临时鉴权信息。

## 文档

- [兼容性记录](docs/COMPATIBILITY.md)
- [系统环境要求](docs/ENVIRONMENT.md)
- [技术说明](docs/TECHNICAL.md)
- [更新日志](CHANGELOG.md)
- [v1.4.0 Release Notes](docs/releases/v1.4.0.md)
- [第三方组件说明](docs/THIRD_PARTY_NOTICES.md)

## License

项目自行编写的代码、脚本和文档采用 [MIT License](LICENSE)。Zstandard / libzstd 按其 BSD License 条款使用和再分发，详见第三方组件说明。
