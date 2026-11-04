# cjbind

## 依赖版本

- 仓颉版本：`STS 1.2.0`，由 `cangjie-sdk.toml` 固定
- uv：CI 使用最新版本；Python 版本：`3.14`，用于运行 `scripts` 下的脚本并自动配置依赖

## 更新版本

- 同步更新 `cjbind`、`cjbind_cli`、`cjbind_test` 和 `cjbind_token` 中 `cjpm.toml` 的版本号。
- 推送对应的 `vX.Y.Z` 标签，触发构建、发布和 GitCode 同步。

## 发布与 GitCode 同步

在 GitHub 仓库的 Actions secrets 中配置 `GITCODE_TOKEN`，该令牌需要具有
`Cangjie-TPC/cjbind` 仓库的代码推送及 Release 写入权限。

- `.github/workflows/mirror.yml` 在推送 `master` 或标签时，将 `master` 和全部标签同步到 GitCode；也可以手动运行。同步不会强制覆盖远端分支或标签。
- `.github/workflows/release.yml` 和 `build-libclang.yml` 在 GitHub Release 及其附件发布成功后，自动调用 `sync-releases.yml` 同步对应标签、发布标题、说明和全部附件。通过 GitHub 页面手动发布 Release 时，也会触发同步。
- 如果附件同步失败，可以手动运行 **Sync Releases**，填写版本标签重试；留空或填写 `latest` 会选择 GitHub 最新正式版。指定标签也支持已发布的预发布版本。

附件列表从 GitHub Release 动态读取，各附件分别上传，最多同时处理两个；上传后从 GitCode 公开下载地址重新下载并逐字节比较，确认镜像内容与 GitHub 一致。同步前会先推送发布标签及其提交，确保 GitCode 能找到对应版本。

全部附件校验通过后，会对齐发布标题、说明和发布状态；只有 GitHub 当前最新正式版会被标为 GitCode 最新版，历史版本的补传不会将旧版标为最新。预发布版本保留预发布标记。

## 生成 libclang 绑定

假设 `libclang` 的头文件在 `T:\cjbind-bootstrap\include\clang-c\Index.h`，可以使用以下命令生成 `libclang.cj`：

```
cjbind -o libclang.cj -p cjbind.clang T:\cjbind-bootstrap\include\clang-c\Index.h -- -I T:\cjbind-bootstrap\include\
```

## 拉取最新的 `libclang` 预编译包

此程序依赖于 `libclang`，动态链接时请确保系统中安装了 LLVM 17 或更高版本。

当前 `cjbind` 使用 `qt` 提供的预编译 `libclang`。使用以下命令下载 `libclang`：

```
uv run scripts/download.py
```

## 构建

因为仓颉当前不支持在 `build.cj` 中设置 `link-options`, 因此编译时需要设置环境变量来完成链接。

使用 `scripts/cjpm.py` 来自动设置环境变量。

```
uv run scripts/cjpm.py build -V
```

### 链接模式

通过 `--static` 参数控制是否静态链接：

- 默认：动态链接系统 `libclang`，需要运行时有 LLVM 17 或更高版本的 `libclang` 可用
- `--static`：静态链接 `libclang`，生成的二进制文件不依赖外部 `libclang`，启动时不检查其版本

```
# 动态链接（默认）
uv run scripts/cjpm.py build -V

# 静态链接
uv run scripts/cjpm.py --static build -V
```
