# downloadIPC v1.2 source

由于当前发布流程不直接提交生成后的 `downloadIPC.exe` 二进制，Win7 替代 downloader 由安装脚本在目标机器上使用系统自带/已安装的 C# 编译器生成。

仓库中的完整 C# 源码以 gzip + Base64 文本形式保存为：

`downloadIPC_Win7_v1.2.cs.gz.b64`

运行仓库根目录的：

`Prepare_Source_v1.2.ps1`

会在根目录还原出：

`downloadIPC_Win7_v1.2.cs`

`01_Zero_Start_One_Click_Install.cmd` 已经会自动先执行这个还原步骤，因此普通使用者无需手动操作。

这样做只用于保持仓库内容为可审阅的文本并避免提交预编译 downloader；还原后的源码与当前 v1.2 安装器使用的源码一致。
