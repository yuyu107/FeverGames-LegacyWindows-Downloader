# 兼容性记录

本页只记录在 Windows 7 SP1 x64 上实际测试过的结果。

## 发烧游戏平台版本

| 发烧游戏版本 | 状态 | 说明 |
|---|---|---|
| 1.18.42.12 | ✅ 已验证 | 早期完整端到端验证基准 |
| 1.18.42.14 / layout A | ✅ 已验证 | v1.3.0 已验证布局 |
| 1.18.42.14 / layout B | ✅ 已验证 | v1.3.1 新增精确补丁配置；Win7 实机完成完整下载、启动并进入世界 |
| 未知未来版本 / 未知布局 | ⚠️ 条件兼容 | 只有 5 个目标位置完整匹配某个已知布局时才复用，否则安全停止 |

v1.3.1 已确认：**同一个 `1.18.42.14` 文件夹版本号可能对应不同的 `FeverGamesInstaller.exe` 二进制布局**。因此安装器不会只根据版本号决定补丁，而是对 5 个目标位置进行精确字节匹配。

`1.18.42.14 / layout B` 实测结果包含：

```text
Patch profile: 1.18.42.14 / layout B
Frontend patch count: 5/5
downloadIPC.exe = managed Win7 replacement
rollback backup = COMPLETE
RESULT=READY_FOR_WIN7_FEVERGAMES_DOWNLOAD
```

原版 `FeverGamesInstaller.exe` SHA256：

```text
0a2a9568ac788227f0815e3c23761cadc11b51ee4ba9b86336cb2abf61e178e9
```

## 安装路径

v1.3.1 已在 Windows 7 SP1 x64 上验证：

| 项目 | 实测路径 | 结果 |
|---|---|---|
| FeverGames | `D:\FeverGames` | ✅ 可自动/手动定位并完成安装 |
| 7-Zip | `D:\7-Zip` | ✅ 可通过自定义目录定位并使用 |

FeverGames 自动查找会结合已保存路径、Windows 卸载信息、桌面/开始菜单快捷方式和各磁盘常见目录。自动查找失败时，可以直接拖入 FeverGames 根目录、数字版本目录或 `FeverGamesInstaller.exe`。

## 游戏

| 游戏 | 发烧游戏平台 | 结果 | 备注 |
|---|---|---|---|
| 《我的世界》基岩互通版 | 1.18.42.12 / 1.18.42.14 | ✅ 完整下载成功 | `1.18.42.14 / layout B` 已验证完整下载、启动并进入世界；此前布局也已验证下载链 |
| 《第五人格》 | 1.18.42.12 | ✅ 可以正常下载 | 已确认进入正常下载流程并下载内容 |

另有其他发烧游戏内的游戏在实机测试中可以下载，说明替代 downloader 并未绑定 Minecraft 的固定文件结构；未逐个记录名称的游戏不在此表中标记为“完整验证”。

## 系统

| 系统 | 说明 |
|---|---|
| Windows 7 SP1 x64 | 本项目主要目标，已验证 |
| Windows 8.1 | 发烧游戏官方新版 downloader 可正常工作，通常无需本项目 |
| Windows 10/11 | 不属于本项目目标；应优先使用官方程序 |

## 反馈建议

遇到失败时建议提供 `04_Collect_Diagnostics.cmd` 或 Release 包中的 `04_收集诊断.cmd` 生成结果，并说明游戏名称、Windows 版本、发烧游戏版本、安装目录、状态检查中的 Patch profile、是否显示下载大小 / 百分比、是否能暂停 / 恢复、是否最终完成。

请不要公开 Token、Cookie、账号信息、PRIVATE Manifest response、AES key、deviceId、uid、sig 或 secKey。
