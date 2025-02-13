# cjbind

自动生成仓颉到 C 库的 FFI 绑定代码。

## 使用方式


### 安装

可以从 [GitHub Releases](https://github.com/cjbind/cjbind/releases) 下载适用于您的平台的二进制文件，或者参照
[构建](./DEVELOPMENT.md) 文档自行构建。

> [!IMPORTANT]  
> 因为仓颉当前不支持静态链接，因此执行时需要依赖仓颉的 runtime，请确保环境变量配置正确。

你也可以使用以下安装脚本安装：

#### Linux/macOS

```shell
curl -fsSL https://example.com/install.sh | bash
```

#### Windows

```powershell
irm https://example.com/install.ps1 | iex
```

### 使用

```shell
自动生成仓颉到 C 库的 FFI 绑定代码。

用法：cjbind <OPTIONS> <HEADER> -- <CLANG_ARGS>

参数：
    <HEADER>          C 头文件路径
    [CLANG_ARGS]...   会被直接传递给 clang 的参数

选项：
        --no-enum-prefix           生成枚举时，不使用枚举名称作为枚举值的前缀
        --no-detect-include-path   禁用自动 include 路径检测
    -o, --output <FILE>            把生成的绑定输出到文件
    -p, --package <PACKAGE>        生成的绑定中的包名
    -v, --version                  显示版本号并退出
    -h, --help                     显示帮助信息
```

## 开源协议

本项目在 [MIT](./LICENSE) 协议下开源。

## 鸣谢

此程序在编写时参照了 [bindgen](https://github.com/rust-lang/rust-bindgen) 的实现。