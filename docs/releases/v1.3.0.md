# GitHub Release 文案：v1.3.0

建议 Release 标题：

```text
v1.3.0 - FeverGames 1.18.42.14 支持与自动版本选择
```

建议 Tag：

```text
v1.3.0
```

## 正文

FeverGames Legacy Windows Downloader v1.3.0 正式版。

这个版本主要完善 Windows 7 上 FeverGames 新版下载后端的兼容，并新增对 **FeverGames 1.18.42.14** 的支持。

### 主要更新

- ✅ FeverGames `1.18.42.14` 已完成 Win7 实机完整下载验证
- ✅ 保留 `1.18.42.12` 支持
- ✅ 自动选择最新完整 FeverGames 数字版本目录
- ✅ 多 build 前端补丁配置
- ✅ 每一处写入继续进行精确字节校验
- ✅ 未知未来版本布局变化时安全停止
- ✅ 修复 Windows 7 PowerShell 2.0 / .NET 3.5 SHA256 兼容问题
- ✅ 新版状态检查 / 恢复 / 诊断流程
- ✅ 通用结果字符串 `READY_FOR_WIN7_FEVERGAMES_DOWNLOAD`

1.18.42.14 的 Windows 7 测试已确认：

```text
Frontend patch count: 5/5
FILE 3130/3130
mainPercent=1.000000
RESULT=SUCCESS_FULL_DOWNLOAD_VIA_FEVERGAMES
```

### 使用

完整解压 Release ZIP，准备支持 `.zst` 的 7-Zip，或把可在 Win7 使用的 `zstd.exe` 放到 `tools\zstd.exe`，然后完全退出 FeverGames 并运行：

```text
01_Zero_Start_One_Click_Install.cmd
```

安装后可运行：

```text
02_Check_Status.cmd
```

恢复官方文件：

```text
03_Restore_Official_Original.cmd
```

### 已知性能特征

当前稳定版优先保证正确性与兼容性。替代 downloader 在大文件本地重组 / MD5 阶段可能暂时显示 `0 B/s`，最后大量小文件阶段也可能比 Windows 8.1 的官方下载器更慢。

我们已经抓取 Win8.1 官方完整下载过程用于后续性能优化；为了避免在正式版发布前引入新的数据一致性问题，本次 v1.3.0 不合入实验性并发 / 流水线重写。

### 说明

本项目是社区兼容项目，与网易及相关游戏开发商无官方关联。项目不分发游戏内容，不要求账号密码，也不要在 Issue / 日志中公开 PRIVATE Manifest response、AES key、Token、Cookie、deviceId、uid、sig 或 secKey。
