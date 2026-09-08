# Scripts

仓库根目录只保留普通用户需要运行的 CMD 入口；PowerShell 实现收在这里。

- `current/`：当前 v1.3.x 正式版使用的脚本。根目录的 `01_...cmd` ～ `05_...cmd` 会调用这里的文件。
- `legacy-v1.2/`：历史 v1.2 脚本，仅用于代码追溯、旧安装恢复或回归参考，不是当前推荐入口。

普通用户应优先从 GitHub Releases 下载正式 ZIP，不需要直接进入本目录运行 PowerShell 文件。
