# downloadIPC v1.2 source

由于当前发布流程不直接提交生成后的 `downloadIPC.exe` 二进制，Win7 替代 downloader 会在目标机器上使用系统已有的 C# 编译器生成。

仓库中的完整 C# 源码以 gzip + Base64 文本形式保存为：

```text
src/downloadIPC_Win7_v1.2.cs.gz.b64
```

根目录的：

```text
01_Zero_Start_One_Click_Install.cmd
```

会先自动调用：

```text
scripts/current/Prepare_Source_v1.2.ps1
```

并在当前脚本目录还原出：

```text
scripts/current/downloadIPC_Win7_v1.2.cs
```

随后当前 v1.3.x 安装脚本会直接使用该源码进行编译，因此普通使用者无需手动解包或移动 C# 源码。

这样做只用于保持仓库内容为可审阅的文本并避免提交预编译 downloader；还原后的源码与当前稳定下载核心使用的源码一致。
