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
        --wrap-static-fns                为 static/static inline 函数生成可编译的 C/C++ 外部桥接函数
        --wrap-static-fns-suffix <SUFFIX>
                                         static 函数桥接符号的后缀，默认为 __extern
        --wrap-static-fns-path <PATH>    static 函数桥接源文件的基础路径（自动使用 .c 或 .cpp 扩展名）
        --auto-cstring                   把 char* 类型映射为 CString 而不是 CPointer<UInt8>
        --array-pointers-in-args         把数组 T arr[size] 转换为 VArray<T, $size> 而不是 CPointer<T>
        --make-cjstring                  把字符串常量生成为 String；非法 UTF-8 保留为 VArray<UInt8>
        --objc                           启用 Objective-C 绑定生成模式
        --objc-codegen-mode <MODE>       ObjC 代码生成模式: runtime (默认) 或 compiler
        --objc-generate-definitions      在 compiler 模式下生成带默认返回值的方法桩体
        --default-enum-style <STYLE>     默认枚举生成风格: consts (默认) 或 newtype
        --default-alias-style <STYLE>    默认别名生成风格: type_alias (默认)、new_type 或 new_type_deref
        --type-alias <REGEX>             把匹配的 typedef 生成为普通 type alias
        --new-type-alias <REGEX>         把匹配的 typedef 生成为强类型包装
        --new-type-alias-deref <REGEX>   把匹配的 typedef 生成为带 wrap/unwrap 的强类型包装
        --fit-macro-constants            根据值范围选择最小适配整数类型
        --macro-const-use-ctypes         使用宏表达式的 C 类型和目标平台宽度，优先于整数收窄
        --no-union-accessor-workaround   禁用 union accessor 的编译器 verifier workaround
    -o, --output <FILE>                  把生成的绑定输出到文件
    -p, --package <PACKAGE>              生成的绑定中的包名
    -v, --version                        显示版本号并退出
    -h, --help                           显示帮助信息
```

### 宏常量类型

默认情况下，整数宏生成 `Int64` 或 `UInt64`，`--fit-macro-constants` 按值范围选择更小的整数类型。
启用 `--macro-const-use-ctypes` 后，cjbind 使用 Clang 求值所得的 C 表达式类型，包括整数提升、
`--target` 指定的平台宽度和 `char` 的符号性。例如，`0UL` 在 LP64 目标上生成 `UInt64`，
在 Windows LLP64 目标上生成 `UInt32`；`0.f` 生成 `Float32`。库调用可设置
`CjbindOptions.macroConstUseCTypes = true`。同时启用两个选项时，C 类型优先。

此选项通过十六进制浮点字面量保留有限 `float`、`double` 的值和正负零，半精度常量使用
`__CjbindFloat16` 存储类型。对于 Clang 求值接口或当前仓颉表示无法完整保留的类型和值，
包括枚举类型的表达式、128 位整数、宽于 `double` 的 `long double`、128 位浮点数及非有限浮点值，
cjbind 会报告警告并跳过对应宏。

### 库调用：重命名字段

通过 `CjbindOptions.fieldNameCallback` 可以在生成前重命名具名的 struct、union 和 bitfield 字段；返回 `None` 会保留原 C 字段名：

```cangjie
import cjbind.options.{CjbindOptions, FieldInfo}

let options = CjbindOptions(["input.h"], [])
options.fieldNameCallback = {
    info: FieldInfo =>
    match (info.fieldName) {
        case "type" => Some("type_")
        case _ => None
    }
}
```

## 开发

查看 [开发文档](./DEVELOPMENT.md) 以获取更多信息。

## 开源协议

本项目在 [MIT](./LICENSE) 协议下开源。

## 鸣谢

此程序在编写时参照了 [bindgen](https://github.com/rust-lang/rust-bindgen) 的实现。
