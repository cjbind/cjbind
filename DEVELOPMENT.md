# cjbind

## 依赖版本

- 仓颉版本：`0.59.6`：需要为 opt 生成补丁
- uv: `>= 0.6.0` Python 版本：`>= 3.11`：用于运行 `scripts` 下的脚本并自动配置依赖
- Go: `>= 1.24`：用于构建 opt 的补丁

## 修补编译器

确保当前环境中安装了 `Go`，并且环境变量 `CANGJIE_HOME` 指向仓颉的安装目录。
在 `cjbind` 的根目录下运行以下命令：

```
uv run scripts/patch_opt.py
```

这会构建 `scripts/opt.go` 并替换原有的 `opt`，原有的 `opt` 会被重命名为 `opt.old(.exe)`。

这是为了 workaround 编译器中 llvm pass `cangjie-ir-verifier` 在 `cjbing.clang` 上的错误报错。 

## 更新版本

- 更新 `cjpm.toml`

## 生成 libclang 绑定

假设 `libclang` 的头文件在 `T:\cjbind-bootstrap\include\clang-c\Index.h`，可以使用以下命令生成 `libclang.cj`：

```
cjbind -o libclang.cj -p cjbind.clang T:\cjbind-bootstrap\include\clang-c\Index.h -- -I T:\cjbind-bootstrap\include\
```

## 拉取最新的 `libclang` 预编译包

此程序依赖于 `libclang`，请确保你的系统中安装了 `llvm`。

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
