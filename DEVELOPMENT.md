# cjbind

## 依赖版本

- 仓颉版本：`STS 1.1.3`
- uv：CI 使用最新版本；Python 版本：`3.14`，用于运行 `scripts` 下的脚本并自动配置依赖
- Go：`1.26`，用于构建 opt 补丁

## 修补编译器

仓颉 STS 1.1.3 仍需为 `opt` 生成补丁。原版优化器在编译 `cjbind.clang` 时会由 `CJBarrierOpt` 报出 `Need write barrier` 并终止；CI 也会执行此步骤。

确保当前环境中安装了 `Go`。使用 `cjv` 时，在 `cjbind` 根目录运行以下命令，让补丁脚本获得 STS 1.1.3 的 `CANGJIE_HOME`：

```
cjv run sts-1.1.3 uv run scripts/patch_opt.py
```

CI 中 `setup-cangjie` 已设置 `CANGJIE_HOME`，因此 workflow 直接运行 `uv run scripts/patch_opt.py`。

这会构建 `scripts/opt.go` 并替换原有的 `opt`，原有的 `opt` 会被重命名为 `opt.old(.exe)`。

脚本会根据当前 SDK 原版 `opt` 的 SHA-256 重新生成 pass 缓存，切换 SDK 版本时不会复用旧工具链的 pipeline。

## 更新版本

- 更新 `cjpm.toml`

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
