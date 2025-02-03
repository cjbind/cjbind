# cjbind

自动生成仓颉到 C 库的 FFI 绑定代码。

## 使用方式

```shell
自动生成仓颉到 C 库的 FFI 绑定代码。

用法：cjbind <OPTIONS> <HEADER> -- <CLANG_ARGS>

参数：
    <HEADER>            C 头文件路径
    [CLANG_ARGS]...     会被直接传递给 clang 的参数

选项：
    -o, --output        <OUTPUT> 把生成的绑定输出到文件
    -p, --package       <PACKAGE> 指定生成的包名
    -V, --version       显示版本号并退出
    -h, --help          显示帮助信息
```

## 开源协议

本项目在 [MIT](./LICENSE) 协议下开源。

## 鸣谢

此程序在编写时参照了 [bindgen](https://github.com/rust-lang/rust-bindgen) 的实现。