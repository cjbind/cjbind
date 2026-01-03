# cjbind

![构建状态](https://img.shields.io/github/actions/workflow/status/cjbind/cjbind/build.yml?style=flat-square)
![版本](https://img.shields.io/github/v/release/cjbind/cjbind?style=flat-square)
![许可证](https://img.shields.io/badge/license-MIT-blue.svg?style=flat-square)

自动生成仓颉到 C 库的 FFI 绑定代码。

## 文档

完整文档请访问 [cjbind.zxilly.dev](https://cjbind.zxilly.dev)

## 使用方式

### 安装

可以从 [GitHub Releases](https://github.com/cjbind/cjbind/releases) 下载适用于您的平台的二进制文件，或者参照
[构建](./DEVELOPMENT.md) 文档自行构建。

> [!IMPORTANT]
> 由于仓颉当前不支持静态链接，运行程序时需要依赖其 runtime，请确保相关环境变量已正确配置。

你也可以使用以下安装脚本安装：

#### Linux/macOS

```shell
curl -fsSL https://cjbind.zxilly.dev/install.sh | bash
```

可以使用镜像源加速下载：

```shell
curl -fsSL https://cjbind.zxilly.dev/install.sh | bash -s -- --mirror
```

#### Windows

```powershell
irm https://cjbind.zxilly.dev/install.ps1 | iex
```

可以使用镜像源加速下载：

```powershell
& ([scriptblock]::Create((irm https://cjbind.zxilly.dev/install.ps1))) --mirror
```

### 使用

```text
自动生成仓颉到 C 库的 FFI 绑定代码。

用法：cjbind <OPTIONS> <HEADER> -- <CLANG_ARGS>

参数：
    <HEADER>          C 头文件路径
    [CLANG_ARGS]...   会被直接传递给 clang 的参数

选项：
        --no-enum-prefix                 生成枚举时，不使用枚举名称作为枚举值的前缀
        --no-detect-include-path         禁用自动 include 路径检测
        --no-comment                     不尝试生成代码中的注释
        --no-layout-test                 不生成布局测试代码
        --builtins                       生成内置定义的 bindings，如 __builtin_va_list
        --make-func-wrapper              生成 foreign 函数包装器以允许包外调用
        --func-wrapper-suffix <SUFFIX>   生成函数包装器时使用的后缀，默认为 _cjbindwrapper
        --auto-cstring                   把 char* 转换为 CString 而不是 CPointer<UInt8>
        --array-pointers-in-args         把数组 T arr[size] 转换为 VArray<T, $size> 而不是 CPointer<T>
        --make-cjstring                  把 C 字符串转换为仓颉的 String 而不是 VArray<UInt8>，这可能会导致二进制表示不一致
    -o, --output <FILE>                  把生成的绑定输出到文件
    -p, --package <PACKAGE>              生成的绑定中的包名
    -v, --version                        显示版本号并退出
    -h, --help                           显示帮助信息
```

## 开发

查看 [开发文档](./DEVELOPMENT.md) 以获取更多信息。

## 开源协议

本项目在 [MIT](./LICENSE) 协议下开源。

## 鸣谢

此程序在编写时参照了 [bindgen](https://github.com/rust-lang/rust-bindgen) 的实现。