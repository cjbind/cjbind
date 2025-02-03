# cjbind

## 更新版本

- 更新 `cjpm.toml`
- 更新 `build/const.cj`

## 生成 libclang 绑定

假设 `libclang` 的头文件在 `T:\cjbind-bootstrap\include\clang-c\Index.h`，可以使用以下命令生成 `libclang.cj`：

```
cjbind -o libclang.cj -p cjbind.clang T:\cjbind-bootstrap\include\clang-c\Index.h -- -I T:\cjbind-bootstrap\include\
```

## 拉取最新的 `libclang` 预编译包

## 构建

此程序依赖于 `libclang`，请确保你的系统中安装了 `llvm`。

你可以从 [libclang-static](https://github.com/cjbind/libclang-static) 下载预编译的 `libclang`。下载后将其解压到 `lib` 目录下。

```
python scripts/download.py
```