# 技术说明

## 1. Windows 7 上的原版 downloadIPC 问题

实机与静态分析确认，发烧游戏新下载后端使用 Go 1.23.x `downloadIPC.exe`。在 Windows 7 上，程序会进入 Go runtime 的随机数初始化路径，并动态解析 `bcryptprimitives.dll!ProcessPrng`；该路径在 Windows 7 上不可用，因此项目使用 Windows 7 可运行的 .NET 替代 downloader。

## 2. 两层兼容方案

1. 对 `FeverGamesInstaller.exe` 做严格、精确字节校验后的前端兼容修补；
2. 用 Windows 7 可运行的 .NET downloader 替换原版 Go downloader。

游戏内容版本不写死，仍从发烧游戏启动参数读取动态 `targetVersion`。

## 3. v1.3.2 的 managed EXE 验证修复

v1.3.1 原先使用：

```powershell
[Reflection.AssemblyName]::GetAssemblyName($Path)
```

判断编译出的 `downloadIPC.exe` 是否为托管程序。部分 Windows 7 / PowerShell 2.0 环境中的当前 PowerShell CLR 较旧，而脚本可能选择 .NET Framework 4.0 的 `csc.exe`。此时编译器已经成功生成文件，但旧 CLR 不一定能通过上述方式加载或识别目标程序集，于是会产生验证误判。

v1.3.2 的 `Is-ManagedExe` 不再加载程序集，而是直接读取 PE：

```text
MZ header
  -> PE signature
  -> Optional Header (PE32 / PE32+)
  -> Data Directory #14
  -> CLR / COM Descriptor RVA + Size
```

只有 CLR / COM Descriptor 同时存在有效 RVA 与 Size 才判定为托管 EXE。安装脚本和状态检查脚本共享这一判断思路，因此不依赖当前 PowerShell CLR 能否加载目标程序集，同时仍能在正式覆盖前拒绝明显无效的编译输出。

## 4. 已知前端补丁布局

已知平台 build 使用 5 个修补点：Gate A、Gate B、`download_check` OS label、`download_check` minor、`downloadIPC --sysVer` getter。具体偏移与字节定义见 `FeverGames_PatchProfiles_v1.3.ps1`。

同一个 `1.18.42.14` 文件夹版本可能对应 layout A / layout B；同版本存在多个候选时要求全部 5 个目标位置精确匹配，不能只信目录版本号。

## 5. 替代 downloader 数据链

```text
FeverGames
  -> ZMTP 3.x PUB/SUB
  -> Manifest API
  -> target_manifest.bin
  -> encrypted .index
  -> AES-CTR
  -> Zstd
  -> protobuf SumHead
  -> SumChunk + SumBuf
  -> CDN chunks
  -> file reconstruction
  -> MD5 verification
  -> progress / completion state
```

## 6. 性能边界

当前稳定 downloader 采用已完整验证的串行实现。大文件网络 chunk 下载完成后会进行本地 SumBuf 重组与整文件 MD5；尾部大量极小 chunk / 小文件使用外部 `7z.exe` 时也可能较慢。v1.3.2 不包含未经完整回归验证的 DLL 直解 Zstd、并发或流水线重写。

## 7. 安全边界

本项目不实现账号登录绕过、不绕过内容授权、不要求账号密码、不分发游戏文件，也不在公开诊断中保存 PRIVATE Manifest response、AES key、deviceId、uid、sig、secKey 等敏感数据。
