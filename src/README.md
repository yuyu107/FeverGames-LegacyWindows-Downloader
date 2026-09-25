# downloadIPC v1.2 source

当前稳定 Release 仍在目标 Windows 7 机器上使用系统已有的 C# 编译器生成托管 `downloadIPC.exe`，仓库不直接提交预编译 downloader 二进制。

完整 C# 源码以 gzip + Base64 文本形式保存：

```text
src/downloadIPC_Win7_v1.2.cs.gz.b64
```

根目录的：

```text
01_Zero_Start_One_Click_Install.cmd
```

会先调用：

```text
scripts/current/Prepare_Source_v1.2.ps1
```

并在：

```text
scripts/current/downloadIPC_Win7_v1.2.cs
```

还原出完整源码，然后由当前 v1.3.x 安装脚本编译。

## v1.3.5+ Zstandard 后端

v1.3.6 继续沿用 v1.3.5 已验证的托管 downloader 核心；本次正式版主要新增 1.18.44.2-A 前端 profile 和诊断兼容修复，下载调度仍保持串行路径。Zstandard 解压通过 P/Invoke 调用：

```text
libzstd.dll 1.5.6
```

主要使用 `ZSTD_decompressStream` 流式接口，不再把 7-Zip 作为正式运行时依赖。

## 从源码 checkout 运行

GitHub 源码仓库不提交第三方 `libzstd.dll` 二进制。

如果直接从源码运行，请从 Zstandard 官方 v1.5.6 Windows x64 Release 获取 `libzstd.dll`，放到：

```text
tools\libzstd.dll
```

然后再运行根目录的一键安装入口。

普通用户应优先使用 GitHub Release ZIP；正式 v1.3.6 Release 已经内置经过 Windows 7 实机验证的 `libzstd.dll`。
