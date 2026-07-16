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
        --auto-cstring                   把 char* 转换为 CString 而不是 CPointer<UInt8>
        --array-pointers-in-args         把数组 T arr[size] 转换为 VArray<T, $size> 而不是 CPointer<T>
        --make-cjstring                  把 C 字符串转换为仓颉的 String 而不是 VArray<UInt8>，这可能会导致二进制表示不一致
        --objc                           启用 Objective-C 绑定生成模式
        --objc-codegen-mode <MODE>       ObjC 代码生成模式: runtime (默认) 或 compiler
        --objc-generate-definitions      在 compiler 模式下生成带默认返回值的方法桩体
        --default-enum-style <STYLE>     默认枚举生成风格: consts (默认) 或 newtype
        --default-alias-style <STYLE>    默认别名生成风格: type_alias (默认)、new_type 或 new_type_deref
        --type-alias <REGEX>             把匹配的 typedef 生成为普通 type alias
        --new-type-alias <REGEX>         把匹配的 typedef 生成为强类型包装
        --new-type-alias-deref <REGEX>   把匹配的 typedef 生成为带 wrap/unwrap 的强类型包装
        --fit-macro-constants            根据值范围选择最小适配整数类型
        --no-union-accessor-workaround   禁用 union accessor 的编译器 verifier workaround
    -o, --output <FILE>                  把生成的绑定输出到文件
    -p, --package <PACKAGE>              生成的绑定中的包名
    -v, --version                        显示版本号并退出
    -h, --help                           显示帮助信息
```

### 包装 `static` / `static inline` 函数

头文件中的 internal-linkage 函数没有可供仓颉链接的外部符号。使用
`--wrap-static-fns` 后，cjbind 会额外生成一个包含外部桥接函数的 C 或 C++ 源文件，
仓颉绑定会引用桥接符号并保留原函数名的公开调用入口：

```shell
cjbind input.h -o bindings.cj \
  --wrap-static-fns \
  --wrap-static-fns-path generated/static_wrappers

# C 头文件生成 generated/static_wrappers.c；C++ 头文件生成 .cpp。
cc -c generated/static_wrappers.c -o static_wrappers.o
```

桥接源必须和最终仓颉程序一起编译、链接。未指定 `--wrap-static-fns-path` 时，
默认写入系统临时目录下的 `cjbind/extern.c` 或 `cjbind/extern.cpp`；
`--wrap-static-fns-suffix` 可修改桥接符号后缀。变参 static 函数目前会被跳过并输出诊断。

### `typedef` / alias 生成策略

`--default-alias-style` 设置默认策略；`--type-alias`、`--new-type-alias` 和
`--new-type-alias-deref` 可用正则表达式逐项覆盖。`new_type` 生成单字段 `@C struct`，
`new_type_deref` 另外生成映射到 `rawValue` 的可读写 `value` 属性，并保留显式的
`wrap` / `unwrap` 方法。泛型、opaque、`void` 和数组
alias、裸函数类型以及对齐无法由仓颉 `@C` 类型表达的目标，会输出警告并回退为普通
type alias。C++ record alias 也保持普通 alias，避免 newtype 的逐字段构造/复制接口
伪装 C++ special member 与对象生命周期。

### 仓颉友好访问

- 可证明具有整体值赋值语义的非 `const` 标量、枚举、向量和指针字段生成 `var`；
  源码中的 `const` 字段，以及 C/C++ 数组、引用和未证明可赋值的 C++ record 子对象
  仍生成只读 `let`，避免绕过数组/引用规则或 C++ special member。C++ record 的仓颉
  逐字段 `init` 保持私有；对象应来自 C++ wrapper/指针，不能把逐字段赋值冒充 C++ 构造。
- 具有标量值语义的 union 成员和 bitfield 生成为 `mut prop`，可使用 `value.field` 与
  `value.field = next`；`const` 成员只生成 getter。数组、引用和未证明可按值复制的
  record union 成员不伪造属性访问。属性只封装已有存储读写 helper，不增加字段，
  也不改变 record 的 size/alignment。
- `_Float16` 位载体提供 `value: Float16` 属性，complex 载体提供 `real` / `imaginary`
  属性。这些是仓颉侧的本地值视图，不会放宽下面列出的 foreign ABI 限制。

### ABI 支持边界

- C 零长度数组用 `VArray<T, $0>` 保留布局。C 柔性数组没有仓颉原生
  DST/slice 映射；对可写数组，cjbind 保留按 Clang 字段偏移计算的 `*_ptr` 指针访问器，
  并生成可跨 package 调用的显式 `unsafe Record_field_view(value, count:)`。可写视图提供 `pointer`、
  `size`、`isEmpty` 属性和有界的 `unsafe` 下标读写。对 `const` 元素，生成的只读视图
  不公开 `CPointer`、不提供下标 setter，也不生成可写 `*_ptr`。长度、指针有效性和生命
  周期仍是调用方契约；可写视图还要求底层存储可写。cjbind 不会猜测邻近的 count 字段，
  也不会把裸指针访问伪装成安全 prop/slice。
- 变参函数指针会保留为 `CPointer<Unit>`。生成类型上的泛型参数只记录源签名，
  该值只能存储、传递或交回 C，不能在仓颉中直接调用。
- C complex 按底层浮点宽度生成有类型的对象内存载体；目前验证覆盖 Float32/Float64
  的内存布局和指针传递。complex 参数、返回值以及包含 complex 字段的 record 按值
  调用不会生成。`_Float16` 使用 `UInt16` 位载体，因为仓颉 `Float16` 不是 `CType`；
  `value` 属性只通过 `Float16.fromBits` / `toBits` 解释本地存储，不能据此生成
  `CPointer<Float16>` 或按值 foreign 调用。
- C++ 模板只物化具备完整具体实参且布局可由 Clang 证明的 class 实例。
  无法完整表示的非类型模板实参或不透明实例会退化为按 Clang 布局生成的 opaque
  存储，不承诺构造、析构、方法或模板求值语义。若实例对齐超过当前仓颉 `@C` blob
  能可靠表达的范围，生成的占位类型只用于形成/传递指针：不能内嵌、按值传递、
  自行分配或解引用；相关按值函数会被跳过。
- `new_type_deref` 的 `value` prop 与显式 `wrap` / `unwrap` 都是整体值转换，不是透明
  解引用或嵌套字段引用，也不假设单字段
  `@C struct` 与底层标量具有相同的按值调用 ABI。签名直接按值使用该 newtype 的
  非变参 foreign 函数会生成显式的底层 ABI 声明和包装入口；变参函数只保留底层
  ABI 声明。`--default-enum-style newtype` 采用相同规则：对象内存和指针保留 enum
  carrier，函数/callback 的直接值边界使用底层整数表示。无法插入包装层的泛型
  callback alias 若不能证明安全，会退化为 `CPointer<Unit>`。over-aligned alias
  回退为普通 alias 后仍只适合引用 C 已分配对象的指针，不能在仓颉侧自行分配。

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
