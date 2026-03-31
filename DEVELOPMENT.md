# cjbind

## 依赖版本

- 仓颉版本：`1.1.0`
- uv: `>= 0.6.0` Python 版本：`>= 3.11`：用于运行 `scripts` 下的脚本并自动配置依赖

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

### 链接模式

通过 `--static` 参数控制是否静态链接：

- 默认：动态链接系统 `libclang`，需要运行时有 `libclang` 可用
- `--static`：静态链接 `libclang`，生成的二进制文件不依赖外部 `libclang`

```
# 动态链接（默认）
uv run scripts/cjpm.py build -V

# 静态链接
uv run scripts/cjpm.py --static build -V
```
