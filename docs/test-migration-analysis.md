# rust-bindgen 测试迁移分析

源：`T:\rust-bindgen\bindgen-tests\tests\headers\`（607 个测试文件）
目标：`cjbind_test/testdata/headers/`

## 迁移原则

1. **cjbind 不支持 C++**：所有 `.hpp` 文件和使用 C++ 特性的测试一律不迁移
2. **无 blocklist/allowlist 机制**：相关测试不迁移
3. **无 Rust 特有输出**：derive traits、newtype、visibility、CStr 等相关测试不迁移
4. **无 dynamic loading**：相关测试不迁移
5. **无 rustbindgen HTML 注解**：相关测试不迁移
6. **ObjC**：cjbind 有自己的 ObjC 测试体系，不从 rust-bindgen 迁移
7. **PARTIAL 处理**：纯 C `.h` 文件如仅带 Rust 特有 flags（如 `--with-derive-hash`），迁移时去掉这些 flags

## 迁移决策标记

- **YES** — 迁移（纯 C 解析测试）
- **NO-CPP** — 不迁移（C++ 文件或 C++ 特性）
- **NO-RUST** — 不迁移（Rust 特有输出/功能）
- **NO-FILTER** — 不迁移（blocklist/allowlist 过滤机制）
- **NO-OBJC** — 不迁移（ObjC，cjbind 有自己的测试）
- **NO-DYN** — 不迁移（dynamic loading）
- **NO-ANNOT** — 不迁移（rustbindgen HTML 注解）
- **NO-OTHER** — 不迁移（其他原因）
- **PARTIAL** — 迁移头文件内容，去掉 Rust 特有 flags

---

## 完整文件列表

### 数字开头

| 文件 | 决策 | 理由 |
|------|------|------|
| `16-byte-alignment.h` | PARTIAL | struct 对齐+匿名 union，去掉 `--with-derive-hash --with-derive-partialeq` |

### 3

| 文件 | 决策 | 理由 |
|------|------|------|
| `381-decltype-alias.hpp` | NO-CPP | C++ decltype |

### A

| 文件 | 决策 | 理由 |
|------|------|------|
| `abi_variadic_function.hpp` | NO-CPP | C++ ms_abi 可变参 |
| `abi-override.h` | NO-RUST | `--override-abi` 是 Rust ABI 名称映射 |
| `accessors.hpp` | NO-CPP | C++ + rustbindgen accessor 注解 |
| `alias_comments.h` | YES | typedef 别名文档注释 |
| `allowlist_basic.hpp` | NO-CPP | C++ + allowlist |
| `allowlist_fix.hpp` | NO-CPP | C++ + allowlist/blocklist |
| `allowlist_item.h` | NO-FILTER | allowlist 过滤 |
| `allowlist_vars.h` | YES | 宏变量解析（无特殊 flags） |
| `allowlist_warnings.h` | NO-FILTER | allowlist 警告 |
| `allowlisted_item_references_no_copy.hpp` | NO-CPP | C++ + allowlist + no-copy |
| `allowlisted-item-references-no-hash.hpp` | NO-CPP | C++ + derive Hash |
| `allowlisted-item-references-no-partialeq.hpp` | NO-CPP | C++ + derive PartialEq |
| `allowlist-file.hpp` | NO-CPP | C++ + allowlist-file |
| `allowlist-namespaces.hpp` | NO-CPP | C++ 命名空间 + allowlist |
| `allowlist-namespaces-basic.hpp` | NO-CPP | C++ 命名空间 + allowlist |
| `annotation_hide.hpp` | NO-CPP | C++ + rustbindgen 注解 |
| `anon_enum.hpp` | NO-CPP | C++ 匿名枚举 |
| `anon_enum_allowlist.h` | NO-FILTER | allowlist + rustified-enum |
| `anon_enum_allowlist_item.h` | NO-FILTER | allowlist-item |
| `anon_enum_blocklist.h` | NO-FILTER | blocklist-type |
| `anon_enum_trait.hpp` | NO-CPP | C++ 模板+匿名枚举 |
| `anon_struct_in_union.h` | PARTIAL | union 中匿名 struct，去掉 derive flags |
| `anon_union.hpp` | NO-CPP | C++ 模板+匿名 union |
| `anon-fields-prefix.h` | YES | 匿名字段命名（`--anon-fields-prefix` 可忽略） |
| `anonymous-template-types.hpp` | NO-CPP | C++14 模板 |
| `arg_keyword.hpp` | NO-CPP | C++ 函数参数 |
| `array-of-zero-sized-types.hpp` | NO-CPP | C++ 零大小类型 |
| `atomic-constant.h` | YES | C11 `_Atomic(int)` |
| `attribute_warn_unused_result.hpp` | NO-CPP | C++ 属性检测 |
| `attribute_warn_unused_result_no_attribute_detection.hpp` | NO-CPP | C++ |
| `attribute-custom.h` | NO-RUST | Rust 自定义 derive 属性 |
| `attribute-custom-cli.h` | NO-RUST | Rust 自定义属性 CLI |
| `auto.hpp` | NO-CPP | C++14 auto |

### B

| 文件 | 决策 | 理由 |
|------|------|------|
| `bad-namespace-parenthood-inheritance.hpp` | NO-CPP | C++ 命名空间继承 |
| `base-to-derived.hpp` | NO-CPP | C++11 模板 |
| `bindgen-union-inside-namespace.hpp` | NO-CPP | C++ 命名空间 |
| `bitfield_align.h` | YES | bitfield 对齐规则 |
| `bitfield_align_2.h` | PARTIAL | enum bitfield 对齐，去掉 `--rustified-enum` |
| `bitfield_large_overflow.hpp` | NO-CPP | C++ 大 bitfield |
| `bitfield_method_mangling.h` | YES | packed C struct bitfield |
| `bitfield_pack_offset.h` | YES | 复杂 bitfield 布局 |
| `bitfield_pragma_packed.h` | YES | pragma pack bitfield |
| `bitfield-32bit-overflow.h` | YES | 32 位溢出 bitfield |
| `bitfield-enum-basic.hpp` | NO-CPP | C++ bitfield-enum |
| `bitfield-enum-repr-c.hpp` | NO-CPP | C++ bitfield-enum repr |
| `bitfield-enum-repr-transparent.hpp` | NO-CPP | C++ bitfield-enum |
| `bitfield-large.hpp` | NO-CPP | C++ 128-bit bitfield |
| `bitfield-linux-32.hpp` | NO-CPP | C++ 32 位 bitfield |
| `bitfield-method-same-name.hpp` | NO-CPP | C++ bitfield/方法同名 |
| `bitfield-template.hpp` | NO-CPP | C++ 模板 bitfield |
| `block_return_type.h` | NO-RUST | Apple blocks + extern-crate |
| `blocklist_bitfield_unit.h` | NO-FILTER | blocklist __BindgenBitfieldUnit |
| `blocklist-and-impl-debug.hpp` | NO-CPP | C++ blocklist + impl Debug |
| `blocklist-file.hpp` | NO-CPP | C++ blocklist-file |
| `blocklist-function.hpp` | NO-CPP | C++ blocklist-function |
| `blocklist-item.hpp` | NO-CPP | C++ blocklist-item |
| `blocklist-methods.hpp` | NO-CPP | C++ blocklist-methods |
| `blocklist-var.hpp` | NO-CPP | C++ blocklist-var |
| `blocks.hpp` | NO-CPP | C++ Apple blocks |
| `blocks-signature.hpp` | NO-CPP | C++ Apple blocks |
| `bug-1529681.hpp` | NO-CPP | C++14 auto |
| `builtin-template.hpp` | NO-CPP | C++ builtin 模板 |

### C

| 文件 | 决策 | 理由 |
|------|------|------|
| `c_naming.h` | NO-RUST | `--c-naming` Rust 命名控制 |
| `call-conv-field.h` | YES | __stdcall 函数指针字段 |
| `call-conv-typedef.h` | YES | __stdcall typedef 链 |
| `canonical_path_without_namespacing.hpp` | NO-CPP | C++ 命名空间 |
| `canonical-types.hpp` | NO-CPP | C++14 模板 |
| `c-empty-layout.h` | YES | 空 C struct |
| `char.h` | PARTIAL | char 类型处理，去掉 derive flags |
| `char16_t.hpp` | NO-CPP | C++ char16_t |
| `class.hpp` | NO-CPP | C++ class |
| `class_nested.hpp` | NO-CPP | C++ 嵌套 class |
| `class_no_members.hpp` | NO-CPP | C++ 空 class |
| `class_static.hpp` | NO-CPP | C++ 静态成员 |
| `class_static_const.hpp` | NO-CPP | C++ static const |
| `class_use_as.hpp` | NO-CPP | C++ + rustbindgen replaces |
| `class_with_dtor.hpp` | NO-CPP | C++ 析构函数 |
| `class_with_enum.hpp` | NO-CPP | C++ class 含 enum |
| `class_with_inner_struct.hpp` | NO-CPP | C++ class 含内部 struct |
| `class_with_typedef.hpp` | NO-CPP | C++ class typedef |
| `comment-indent.hpp` | NO-CPP | C++ 文档注释缩进 |
| `complex.h` | PARTIAL | C99 _Complex，去掉 derive flags |
| `complex_global.h` | PARTIAL | 全局 _Complex，去掉 derive flags |
| `const_array.h` | YES | const/non-const extern 数组 |
| `const_array_fn_arg.h` | YES | const 数组函数参数 |
| `const_array_typedef.h` | YES | 数组 typedef + const |
| `const_bool.hpp` | NO-CPP | C++ const bool |
| `const_enum_unnamed.hpp` | NO-CPP | C++ 匿名 enum 常量 |
| `const_multidim_array_fn_arg.h` | YES | 多维 const 数组参数 |
| `const_ptr.hpp` | NO-CPP | C++ const void* |
| `const_resolved_ty.h` | YES | typedef resolved const 类型 |
| `const_tparam.hpp` | NO-CPP | C++ 模板 const |
| `constant-evaluate.h` | PARTIAL | 常量表达式求值，去掉 `--rustified-enum` |
| `constant-non-specialized-tp.hpp` | NO-CPP | C++11 模板 |
| `const-const-mut-ptr.h` | YES | 深层 const 指针 |
| `constified-enum-module-overflow.hpp` | NO-CPP | C++ enum 模块溢出 |
| `constify-all-enums.h` | NO-RUST | Rust enum 常量化 |
| `constify-enum.h` | NO-RUST | Rust enum 常量化 |
| `constify-module-enums-basic.h` | NO-RUST | Rust constified-enum-module |
| `constify-module-enums-namespace.hpp` | NO-CPP | C++ 命名空间 |
| `constify-module-enums-shadow-name.h` | NO-RUST | Rust constified-enum-module |
| `constify-module-enums-simple-alias.hpp` | NO-CPP | C++ |
| `constify-module-enums-simple-nonamespace.hpp` | NO-CPP | C++ |
| `constify-module-enums-types.hpp` | NO-CPP | C++ |
| `constructors.hpp` | NO-CPP | C++ 构造函数 |
| `constructors_1_33.hpp` | NO-CPP | C++ 构造函数 |
| `constructor-tp.hpp` | NO-CPP | C++ 模板构造函数 |
| `contains-vs-inherits-zero-sized.hpp` | NO-CPP | C++ 继承 ZST |
| `convert-cpp-comment-to-rust.hpp` | NO-CPP | C++ 注释转换 |
| `convert-floats.h` | NO-RUST | `--no-convert-floats` Rust float 命名 |
| `core_ffi_c.h` | NO-RUST | Rust core::ffi 类型 |
| `cpp-empty-layout.hpp` | NO-CPP | C++ 空 class |
| `crtp.hpp` | NO-CPP | C++ CRTP |
| `ctypes-prefix-path.h` | NO-RUST | Rust ctypes 路径 |
| `c-unwind-abi-override.h` | NO-RUST | Rust C-unwind ABI |

### D

| 文件 | 决策 | 理由 |
|------|------|------|
| `dash_language.h` | NO-CPP | 使用 `-x c++ --std=c++11` |
| `decl_extern_int_twice.h` | YES | 重复 extern int 声明 |
| `decl_ptr_to_array.h` | YES | 指向数组的指针 |
| `default_visibility_crate.h` | NO-RUST | Rust visibility crate |
| `default_visibility_private.h` | NO-RUST | Rust visibility private |
| `default_visibility_private_respects_cxx_access_spec.h` | NO-RUST | Rust visibility + C++ access |
| `default-enum-style-constified-module.h` | NO-RUST | Rust enum style |
| `default-macro-constant-type.h` | NO-RUST | Rust 宏常量类型 |
| `default-macro-constant-type-signed.h` | NO-RUST | Rust 宏常量类型 |
| `default-macro-constant-type-unsigned.h` | NO-RUST | Rust 宏常量类型 |
| `default-template-parameter.hpp` | NO-CPP | C++ 模板默认参数 |
| `deleted-function.hpp` | NO-CPP | C++11 = delete |
| `derive-bitfield-method-same-name.hpp` | NO-CPP | C++ derive |
| `derive-clone.h` | NO-RUST | Rust derive Clone |
| `derive-custom.h` | NO-RUST | Rust 自定义 derive |
| `derive-custom-cli.h` | NO-RUST | Rust 自定义 derive CLI |
| `derive-debug-bitfield.hpp` | NO-CPP | C++ impl Debug |
| `derive-debug-bitfield-1-51.hpp` | NO-CPP | C++ impl Debug |
| `derive-debug-bitfield-core.hpp` | NO-CPP | C++ impl Debug + core |
| `derive-debug-function-pointer.hpp` | NO-CPP | C++ impl Debug |
| `derive-debug-generic.hpp` | NO-CPP | C++ impl Debug |
| `derive-debug-mangle-name.h` | NO-RUST | Rust impl Debug |
| `derive-debug-opaque.hpp` | NO-CPP | C++ opaque + Debug |
| `derive-debug-opaque-template-instantiation.hpp` | NO-CPP | C++ 模板 + Debug |
| `derive-default-and-blocklist.hpp` | NO-CPP | C++ derive Default + blocklist |
| `derive-fn-ptr.h` | NO-RUST | Rust derive Hash/PartialEq for fn ptr |
| `derive-hash-and-blocklist.hpp` | NO-CPP | C++ derive Hash + blocklist |
| `derive-hash-blocklisting.hpp` | NO-CPP | C++ derive Hash |
| `derive-hash-struct-with-anon-struct-float.h` | NO-RUST | Rust derive Hash |
| `derive-hash-struct-with-float-array.h` | NO-RUST | Rust derive Hash |
| `derive-hash-struct-with-incomplete-array.h` | NO-RUST | Rust derive Hash |
| `derive-hash-struct-with-pointer.h` | NO-RUST | Rust derive Hash |
| `derive-hash-template-def-float.hpp` | NO-CPP | C++ 模板 derive Hash |
| `derive-hash-template-inst-float.hpp` | NO-CPP | C++ 模板 derive Hash |
| `derive-partialeq-and-blocklist.hpp` | NO-CPP | C++ derive PartialEq + blocklist |
| `derive-partialeq-anonfield.h` | NO-RUST | Rust derive PartialEq |
| `derive-partialeq-base.hpp` | NO-CPP | C++ derive PartialEq |
| `derive-partialeq-bitfield.hpp` | NO-CPP | C++ derive PartialEq |
| `derive-partialeq-core.h` | NO-RUST | Rust derive PartialEq + core |
| `derive-partialeq-pointer.hpp` | NO-CPP | C++ derive PartialEq |
| `derive-partialeq-union.hpp` | NO-CPP | C++ derive PartialEq |
| `disable-namespacing.hpp` | NO-CPP | C++ 命名空间 |
| `disable-nested-struct-naming.h` | YES | 嵌套 struct 命名 |
| `disable-untagged-union.hpp` | NO-CPP | C++ Rust untagged union |
| `divide-by-zero-in-struct-layout.h` | YES | bitfield + pragma pack 边界 |
| `doggo-or-null.hpp` | NO-CPP | C++ opaque union |
| `do-not-derive-copy.hpp` | NO-CPP | C++ no-derive-copy |
| `dupe-enum-variant-in-namespace.h` | NO-CPP | 使用 `-std=c++11` scoped enum |
| `duplicated_constants_in_ns.hpp` | NO-CPP | C++ 命名空间 |
| `duplicated-definition-count.hpp` | NO-CPP | C++ 方法重载 |
| `duplicated-namespaces.hpp` | NO-CPP | C++ 命名空间 |
| `duplicated-namespaces-definitions.hpp` | NO-CPP | C++ 命名空间 |
| `dynamic_loading_attributes.h` | NO-DYN | dynamic loading |
| `dynamic_loading_required.h` | NO-DYN | dynamic loading |
| `dynamic_loading_simple.h` | NO-DYN | dynamic loading |
| `dynamic_loading_template.hpp` | NO-CPP | C++ dynamic loading |
| `dynamic_loading_variable_required.h` | NO-DYN | dynamic loading |
| `dynamic_loading_variable_simple.h` | NO-DYN | dynamic loading |
| `dynamic_loading_variable_with_allowlist.hpp` | NO-CPP | C++ dynamic loading |
| `dynamic_loading_with_allowlist.hpp` | NO-CPP | C++ dynamic loading |
| `dynamic_loading_with_blocklist.hpp` | NO-CPP | C++ dynamic loading |
| `dynamic_loading_with_class.hpp` | NO-CPP | C++ dynamic loading |

### E

| 文件 | 决策 | 理由 |
|------|------|------|
| `elaborated.hpp` | NO-CPP | C++ elaborated type |
| `empty_template_param_name.hpp` | NO-CPP | C++ 模板 |
| `empty-enum.h` | NO-RUST | Rust enum styles (rustified/constified/module) |
| `enum.h` | YES | 基本枚举（正/负值、匿名） |
| `enum_alias.hpp` | NO-CPP | C++11 enum alias |
| `enum_and_vtable_mangling.hpp` | NO-CPP | C++ vtable |
| `enum_dupe.h` | PARTIAL | 重复 enum 值，去掉 `--rustified-enum` |
| `enum_explicit_type.hpp` | NO-CPP | C++11 enum 底层类型 |
| `enum_explicit_type_constants.hpp` | NO-CPP | C++11 |
| `enum_in_template.hpp` | NO-CPP | C++ 模板 |
| `enum_in_template_with_typedef.hpp` | NO-CPP | C++ 模板 |
| `enum_negative.h` | PARTIAL | 负值 enum，去掉 `--rustified-enum` |
| `enum_packed.h` | PARTIAL | packed enum，去掉 `--rustified-enum` |
| `enum-default-bitfield.h` | NO-RUST | Rust enum style bitfield |
| `enum-default-consts.h` | NO-RUST | Rust enum style consts |
| `enum-default-module.h` | NO-RUST | Rust enum style module |
| `enum-default-rust.h` | NO-RUST | Rust enum style rust |
| `enum-doc.h` | YES | enum 文档注释 |
| `enum-doc-bitfield.h` | NO-RUST | Rust bitfield-enum 文档 |
| `enum-doc-mod.h` | NO-RUST | Rust constified-enum-module 文档 |
| `enum-doc-rusty.h` | NO-RUST | Rust rustified-enum 文档 |
| `enum-doc-rusty-non-exhaustive.h` | NO-RUST | Rust non-exhaustive enum |
| `enum-forward-ref.h` | PARTIAL | 前向声明 enum，去掉 `--default-enum-style=consts` |
| `enum-no-debug-rust.h` | NO-RUST | Rust no-derive-debug enum |
| `enum-translate-type.hpp` | NO-CPP | C++11 enum 类型翻译 |
| `enum-typedef.h` | YES | typedef enum（C 惯用法） |
| `enum-undefault.h` | NO-RUST | Rust enum style override |
| `enum-variant-replaces.h` | NO-ANNOT | rustbindgen replaces 注解 |
| `error-E0600-cannot-apply-unary-negation-to-u32.h` | NO-RUST | Rust 编译错误 E0600 |
| `eval-value-dependent.hpp` | NO-CPP | C++11 alignof |
| `eval-variadic-template-parameter.hpp` | NO-CPP | C++11 sizeof... |
| `explicit-padding.h` | YES | 显式 padding 结构 |
| `extern.hpp` | NO-CPP | C++ extern "C" |
| `extern_blocks_post_1_82.h` | NO-RUST | Rust 1.82 extern block |
| `extern_blocks_pre_1_82.h` | NO-RUST | Rust extern block |
| `extern-const-struct.h` | YES | extern const struct |
| `extern-fn-block-attrs.h` | NO-RUST | Rust extern fn 属性 |
| `extern-fn-block-attrs-many.h` | NO-RUST | Rust extern fn 属性 |
| `extern-fn-block-attrs-wasm.h` | NO-RUST | Rust WASM 属性 |

### F

| 文件 | 决策 | 理由 |
|------|------|------|
| `field_attr_annotation.h` | NO-ANNOT | rustbindgen 字段注解 |
| `field_attr_cli.h` | NO-RUST | Rust 字段属性 CLI |
| `field-visibility.h` | NO-RUST | Rust 可见性 |
| `field-visibility-callback.h` | NO-RUST | Rust 可见性回调 |
| `fit-macro-constant-types.h` | NO-RUST | Rust 宏常量整数类型 |
| `fit-macro-constant-types-signed.h` | NO-RUST | Rust 宏常量类型 |
| `flexarray.hpp` | NO-CPP | C++ + nightly Rust DST |
| `float128.hpp` | NO-CPP | C++ __float128 |
| `float16.h` | PARTIAL | __fp16 类型，去掉 derive flags |
| `forward_declared_complex_types.hpp` | NO-CPP | C++ 前向声明 |
| `forward_declared_opaque.h` | NO-RUST | `--opaque-type ".*"` |
| `forward_declared_struct.h` | YES | 前向声明 struct |
| `forward-declaration-autoptr.hpp` | NO-CPP | C++ 前向声明+模板 |
| `forward-enum-decl.hpp` | NO-CPP | C++11 scoped enum |
| `forward-inherit-struct.hpp` | NO-CPP | C++ 模板继承 |
| `forward-inherit-struct-with-fields.hpp` | NO-CPP | C++ 模板继承 |
| `func_proto.h` | YES | 函数原型 typedef |
| `func_ptr.h` | PARTIAL | 全局函数指针，去掉 derive flags |
| `func_ptr_in_struct.h` | PARTIAL | struct 中函数指针，去掉 derive flags |
| `func_ptr_return_type.h` | YES | 返回函数指针的函数 |
| `func_return_must_use.h` | NO-RUST | Rust must_use 属性 |
| `func_with_array_arg.h` | YES | 数组参数函数 |
| `func_with_func_ptr_arg.h` | YES | 函数指针参数 |
| `function-typedef-stdcall.h` | YES | __stdcall 函数 typedef |

### G

| 文件 | 决策 | 理由 |
|------|------|------|
| `gen-constructors.hpp` | NO-CPP | C++ 构造函数生成 |
| `gen-constructors-neg.hpp` | NO-CPP | C++ |
| `gen-destructors.hpp` | NO-CPP | C++ 析构函数生成 |
| `gen-destructors-neg.hpp` | NO-CPP | C++ |
| `generate-inline.hpp` | NO-CPP | C++ inline 函数 |

### I

| 文件 | 决策 | 理由 |
|------|------|------|
| `i128.h` | YES | __int128 类型 |
| `in_class_typedef.hpp` | NO-CPP | C++ class typedef |
| `incomplete-array-padding.h` | YES | bitfield + 不完整数组 |
| `infinite-macro.hpp` | NO-CPP | C++ infinity/NaN 宏 |
| `inherit_multiple_interfaces.hpp` | NO-CPP | C++ 多重继承 |
| `inherit_named.hpp` | NO-CPP | C++ 模板继承 |
| `inherit_typedef.hpp` | NO-CPP | C++ typedef 继承 |
| `inherit-from-template-instantiation-with-vtable.hpp` | NO-CPP | C++ vtable 继承 |
| `inherit-namespaced.hpp` | NO-CPP | C++ 命名空间继承 |
| `inline_namespace.hpp` | NO-CPP | C++11 inline 命名空间 |
| `inline_namespace_allowlist.hpp` | NO-CPP | C++ inline 命名空间 |
| `inline_namespace_conservative.hpp` | NO-CPP | C++ inline 命名空间 |
| `inline_namespace_macro.hpp` | NO-CPP | C++ inline 命名空间 |
| `inline_namespace_nested.hpp` | NO-CPP | C++20 嵌套 inline 命名空间 |
| `inline_namespace_no_ns_enabled.hpp` | NO-CPP | C++11 |
| `inline-function.h` | YES | inline static 函数 |
| `inner_const.hpp` | NO-CPP | C++ 内部 static const |
| `inner_template_self.hpp` | NO-CPP | C++ 自引用模板 |
| `inner-typedef-gh422.hpp` | NO-CPP | C++ 内部 typedef |
| `int128_t.h` | YES | __int128 对齐/大小 |

### Issue 系列

| 文件 | 决策 | 理由 |
|------|------|------|
| `issue_311.hpp` | NO-CPP | C++ 命名空间 |
| `issue_315.hpp` | NO-CPP | C++ rustbindgen replaces |
| `issue-1025-unknown-enum-repr.hpp` | NO-CPP | C++ 模板 enum |
| `issue-1034.h` | YES | 无名无大小 bitfield |
| `issue-1040.h` | YES | 大 unsigned long long 常量 |
| `issue-1076-unnamed-bitfield-alignment.h` | YES | 无名 bitfield 对齐 |
| `issue-1113-template-references.hpp` | NO-CPP | C++ 模板 |
| `issue-1118-using-forward-decl.hpp` | NO-CPP | C++ using 前向声明 |
| `issue-1197-pure-virtual-stuff.hpp` | NO-CPP | C++ 纯虚函数 |
| `issue-1198-alias-rust-bitfield-enum.h` | NO-RUST | Rust bitfield-enum |
| `issue-1198-alias-rust-const-mod-bitfield-enum.h` | NO-RUST | Rust enum 样式 |
| `issue-1198-alias-rust-const-mod-enum.h` | NO-RUST | Rust enum 样式 |
| `issue-1198-alias-rust-enum.h` | NO-RUST | Rust enum 样式 |
| `issue-1216-variadic-member.h` | YES | 可变参函数指针 in struct |
| `issue-1238-fwd-no-copy.h` | YES | typedef 前向声明 |
| `issue-1281.h` | YES | struct 内外同名冲突 |
| `issue-1285.h` | NO-FILTER | no-recursive-allowlist |
| `issue-1291.hpp` | NO-CPP | C++ aligned(16) struct |
| `issue-1350-attribute-overloadable.h` | YES | __attribute__((overloadable)) |
| `issue-1375-prefixed-functions.h` | NO-RUST | parse callback 前缀 |
| `issue-1382-rust-primitive-types.h` | NO-RUST | Rust 原语名冲突 |
| `issue-1435.hpp` | NO-CPP | C++ using 别名 |
| `issue-1443.hpp` | NO-CPP | C++ 引用成员 |
| `issue-1454.h` | NO-FILTER | allowlist + parse callback |
| `issue-1464.hpp` | NO-CPP | C++ 模板 |
| `issue-1488-enum-new-type.h` | NO-RUST | Rust newtype alias |
| `issue-1488-options.h` | NO-RUST | Rust newtype |
| `issue-1488-template-alias-new-type.hpp` | NO-CPP | C++ 模板 + newtype |
| `issue-1498.h` | YES | packed struct + union + __int128 |
| `issue-1514.hpp` | NO-CPP | C++ 模板 |
| `issue-1554.h` | NO-RUST | Rust non-exhaustive enum |
| `issue-1599-opaque-typedef-to-enum.h` | NO-RUST | opaque-type |
| `issue-1676-macro-namespace-prefix.hpp` | NO-CPP | C++ 宏命名空间 |
| `issue-1947.h` | YES | 复杂 bitfield struct 布局 |
| `issue-1977-larger-arrays.hpp` | NO-CPP | C++ 大数组 |
| `issue-1995.h` | YES | 全局 const 文档注释 |
| `issue-2019.hpp` | NO-CPP | C++ nested struct |
| `issue-2239-template-dependent-bit-width.hpp` | NO-CPP | C++ 模板 bitfield |
| `issue-2556.h` | NO-CPP | 使用 `-x c++` 多头文件 include |
| `issue-2566.h` | YES | 嵌入 null 的字符串字面量 |
| `issue-2566-cstr.h` | NO-RUST | Rust CStr |
| `issue-2618.h` | PARTIAL | 大 unsigned 常量，去掉 allowlist |
| `issue-2695.h` | YES | pragma pack(2) + padding |
| `issue-2966.h` | NO-RUST | Rust type visibility |
| `issue-3027.hpp` | NO-CPP | C++ 模板命名空间 |
| `issue-358.hpp` | NO-CPP | C++ 自引用模板 |
| `issue-372.hpp` | NO-CPP | C++ 模板+enum+继承 |
| `issue-410.hpp` | NO-CPP | C++ 命名空间 |
| `issue-446.hpp` | NO-CPP | C++14 递归模板 |
| `issue-447.hpp` | NO-CPP | C++ 复杂模板/命名空间 |
| `issue-493.hpp` | NO-CPP | C++ basic_string 模板 |
| `issue-511.h` | YES | char*/const char* 各种组合 |
| `issue-537.h` | YES | packed+aligned 属性 |
| `issue-537-repr-packed-n.h` | NO-RUST | Rust repr(packed(N)) |
| `issue-544-stylo-creduce.hpp` | NO-CPP | C++14 模板 |
| `issue-544-stylo-creduce-2.hpp` | NO-CPP | C++14 |
| `issue-569-non-type-template-params-causing-layout-test-failures.hpp` | NO-CPP | C++14 模板 |
| `issue-573-layout-test-failures.hpp` | NO-CPP | C++ 静态成员 |
| `issue-574-assertion-failure-in-codegen.hpp` | NO-CPP | C++14 |
| `issue-584-stylo-template-analysis-panic.hpp` | NO-CPP | C++14 模板 |
| `issue-638-stylo-cannot-find-T-in-this-scope.hpp` | NO-CPP | C++14 |
| `issue-639-typedef-anon-field.hpp` | NO-CPP | C++ typedef 匿名 struct |
| `issue-643-inner-struct.h` | YES | DPDK 内部命名 struct |
| `issue-645-cannot-find-type-T-in-this-scope.hpp` | NO-CPP | C++14 |
| `issue-648-derive-debug-with-padding.h` | NO-RUST | Rust derive Debug + padding |
| `issue-654-struct-fn-collision.h` | YES | struct/函数同名 |
| `issue-662-cannot-find-T-in-this-scope.hpp` | NO-CPP | C++14 |
| `issue-662-part-2.hpp` | NO-CPP | C++14 |
| `issue-674-1.hpp` | NO-CPP | C++14 模板 |
| `issue-674-2.hpp` | NO-CPP | C++14 |
| `issue-674-3.hpp` | NO-CPP | C++14 |
| `issue-677-nested-ns-specifier.hpp` | NO-CPP | C++14 命名空间 |
| `issue-691-template-parameter-virtual.hpp` | NO-CPP | C++ 模板+虚函数 |
| `issue-710-must-use-type.h` | NO-RUST | Rust must_use |
| `issue-739-pointer-wide-bitfield.h` | YES | 指针宽度 bitfield |
| `issue-743.h` | YES | void*/_Bool/无名 bitfield |
| `issue-753.h` | YES | UINT32_C() 宏常量 |
| `issue-769-bad-instantiation-test.hpp` | NO-CPP | C++ 模板 |
| `issue-801-opaque-sloppiness.hpp` | NO-CPP | C++ opaque |
| `issue-807-opaque-types-methods-being-generated.hpp` | NO-CPP | C++ opaque |
| `issue-816.h` | YES | 大量 1-bit bitfield |
| `issue-820-unused-template-param-in-alias.hpp` | NO-CPP | C++ 模板 |
| `issue-826-generating-methods-when-asked-not-to.hpp` | NO-CPP | C++ ignore-methods |
| `issue-833.hpp` | NO-CPP | C++ 模板 |
| `issue-833-1.hpp` | NO-CPP | C++ |
| `issue-833-2.hpp` | NO-CPP | C++ |
| `issue-834.hpp` | NO-CPP | C++ |
| `issue-848-replacement-system-include.hpp` | NO-CPP | C++ |
| `issue-888-enum-var-decl-jump.hpp` | NO-CPP | C++ 命名空间 |
| `issue-944-derive-copy-and-blocklisting.hpp` | NO-CPP | C++ derive + blocklist |
| `issue-946.h` | YES | 循环 typedef |

### J

| 文件 | 决策 | 理由 |
|------|------|------|
| `jsval_layout_opaque.hpp` | NO-CPP | C++ SpiderMonkey union |

### K

| 文件 | 决策 | 理由 |
|------|------|------|
| `keywords.h` | NO-RUST | Rust 关键字转义 |

### L

| 文件 | 决策 | 理由 |
|------|------|------|
| `layout.h` | NO-OTHER | 空/禁用测试（#if 0） |
| `layout_align.h` | YES | struct 对齐布局 |
| `layout_arp.h` | YES | ARP/Ethernet packed 结构 |
| `layout_array.h` | PARTIAL | DPDK 大 struct，去掉 derive flags |
| `layout_array_too_long.h` | PARTIAL | DPDK IP 分片 struct，去掉 derive flags |
| `layout_cmdline_token.h` | PARTIAL | 命令行 token struct，去掉 `--rustified-enum` |
| `layout_eth_conf.h` | PARTIAL | DPDK Ethernet 配置，去掉 derive flags |
| `layout_kni_mbuf.h` | YES | DPDK KNI mbuf |
| `layout_large_align_field.h` | PARTIAL | 大对齐字段，去掉 `--rustified-enum` |
| `layout_mbuf.h` | PARTIAL | DPDK mbuf，去掉 derive flags |
| `long_double.h` | YES | long double 类型 |

### M

| 文件 | 决策 | 理由 |
|------|------|------|
| `macro_const.h` | YES | 宏常量（字符串/char/float/long） |
| `macro-expr-basic.h` | YES | 宏表达式（位移/OR/加法） |
| `macro-expr-uncommon-token.h` | YES | 含属性 token 的宏 |
| `macro-redef.h` | YES | 宏重定义 |
| `maddness-is-avoidable.hpp` | NO-CPP | C++ 模板 + blocklist |
| `mangling-ios.h` | NO-OTHER | iOS target 特定符号 mangling |
| `mangling-linux32.hpp` | NO-CPP | C++ 符号 mangling |
| `mangling-linux64.hpp` | NO-CPP | C++ 符号 mangling |
| `mangling-macos.hpp` | NO-CPP | C++ 符号 mangling |
| `mangling-win32.hpp` | NO-CPP | C++ Windows mangling |
| `mangling-win64.hpp` | NO-CPP | C++ Windows mangling |
| `merge_extern_blocks_post_1_82.hpp` | NO-CPP | C++ Rust extern block |
| `merge_extern_blocks_pre_1_82.hpp` | NO-CPP | C++ Rust extern block |
| `method-mangling.hpp` | NO-CPP | C++ 方法 mangling |
| `module-allowlisted.hpp` | NO-CPP | C++ allowlist |
| `msvc-no-usr.hpp` | NO-CPP | C++ MSVC class |
| `multiple-inherit-empty-correct-layout.hpp` | NO-CPP | C++ 多重继承 |
| `mutable.hpp` | NO-CPP | C++ mutable |

### N

| 文件 | 决策 | 理由 |
|------|------|------|
| `namespace.hpp` | NO-CPP | C++ 命名空间 |
| `nested.hpp` | NO-CPP | C++ 嵌套 class |
| `nested_flexarray.hpp` | NO-CPP | C++ + nightly DST |
| `nested_vtable.hpp` | NO-CPP | C++ vtable |
| `nested_within_namespace.hpp` | NO-CPP | C++ 命名空间 |
| `nested-class-field.hpp` | NO-CPP | C++ 嵌套 class |
| `nested-template-typedef.hpp` | NO-CPP | C++ 模板 typedef |
| `new-type-alias.h` | NO-RUST | Rust newtype alias |
| `newtype-enum.hpp` | NO-CPP | C++ Rust newtype enum |
| `newtype-global-enum.hpp` | NO-CPP | C++ Rust newtype enum |
| `no_copy.hpp` | NO-CPP | C++ no-copy 注解 |
| `no_copy_allowlisted.hpp` | NO-CPP | C++ |
| `no_copy_opaque.hpp` | NO-CPP | C++ |
| `no_debug.hpp` | NO-CPP | C++ |
| `no_debug_allowlisted.hpp` | NO-CPP | C++ |
| `no_debug_bypass_impl_debug.hpp` | NO-CPP | C++ |
| `no_debug_opaque.hpp` | NO-CPP | C++ |
| `no_default.hpp` | NO-CPP | C++ |
| `no_default_allowlisted.hpp` | NO-CPP | C++ |
| `no_default_bypass_derive_default.hpp` | NO-CPP | C++ |
| `no_default_opaque.hpp` | NO-CPP | C++ |
| `no_size_t_is_usize.h` | NO-RUST | Rust usize 映射 |
| `no-comments.h` | NO-RUST | Rust doc 注释控制 |
| `no-derive-debug.h` | NO-RUST | Rust no-derive-debug |
| `no-derive-default.h` | NO-RUST | Rust no-derive-default |
| `no-hash-allowlisted.hpp` | NO-CPP | C++ |
| `no-hash-opaque.hpp` | NO-CPP | C++ |
| `non-type-params.hpp` | NO-CPP | C++14 非类型模板参数 |
| `no-partialeq-allowlisted.hpp` | NO-CPP | C++ |
| `no-partialeq-opaque.hpp` | NO-CPP | C++ |
| `no-recursive-allowlisting.h` | NO-FILTER | recursive-allowlist |
| `noreturn.hpp` | NO-CPP | C++ noreturn |
| `no-std.h` | NO-RUST | Rust no_std |
| `nsBaseHashtable.hpp` | NO-CPP | C++14 复杂模板 |
| `nsStyleAutoArray.hpp` | NO-CPP | C++ 模板 |

### O

| 文件 | 决策 | 理由 |
|------|------|------|
| `objc_allowlist.h` | NO-OBJC | ObjC + allowlist |
| `objc_blocklist.h` | NO-OBJC | ObjC + blocklist |
| `objc_category.h` | NO-OBJC | ObjC category |
| `objc_class.h` | NO-OBJC | ObjC class |
| `objc_class_method.h` | NO-OBJC | ObjC class method |
| `objc_escape.h` | NO-OBJC | ObjC + Rust keyword |
| `objc_inheritance.h` | NO-OBJC | ObjC 继承 |
| `objc_interface.h` | NO-OBJC | ObjC interface |
| `objc_interface_type.h` | NO-OBJC | ObjC interface 类型 |
| `objc_method.h` | NO-OBJC | ObjC method |
| `objc_method_clash.h` | NO-OBJC | ObjC method 冲突 |
| `objc_pointer_return_types.h` | NO-OBJC | ObjC 指针返回 |
| `objc_property_fnptr.h` | NO-OBJC | ObjC property |
| `objc_protocol.h` | NO-OBJC | ObjC protocol |
| `objc_protocol_inheritance.h` | NO-OBJC | ObjC protocol 继承 |
| `objc_sel_and_id.h` | NO-OBJC | ObjC SEL/id |
| `objc_template.h` | NO-OBJC | ObjC 泛型 |
| `only_bitfields.hpp` | NO-CPP | C++ bitfield class |
| `opaque_in_struct.hpp` | NO-CPP | C++ opaque |
| `opaque_pointer.hpp` | NO-CPP | C++ opaque |
| `opaque_typedef.hpp` | NO-CPP | C++ opaque |
| `opaque-template-instantiation.hpp` | NO-CPP | C++ |
| `opaque-template-instantiation-namespaced.hpp` | NO-CPP | C++ |
| `opaque-template-inst-member.hpp` | NO-CPP | C++ |
| `opaque-template-inst-member-2.hpp` | NO-CPP | C++ |
| `opaque-tracing.hpp` | NO-CPP | C++ opaque 追踪 |
| `opencl_vector.h` | YES | OpenCL/GCC 向量扩展类型 |
| `operator.hpp` | NO-CPP | C++ 运算符重载 |
| `operator_equals.hpp` | NO-CPP | C++ operator= |
| `ord-enum.h` | NO-RUST | Rust derive Ord |
| `overflowed_enum.hpp` | NO-CPP | C++ enum 溢出 |
| `overloading.hpp` | NO-CPP | C++ 函数重载 |

### P

| 文件 | 决策 | 理由 |
|------|------|------|
| `packed_flexarray.hpp` | NO-CPP | C++ nightly DST |
| `packed-bitfield.h` | YES | packed bitfield struct |
| `packed-n-with-padding.h` | YES | pragma pack(N) 带 padding |
| `packed-vtable.h` | NO-RUST | packed struct + vtable + Rust raw-line |
| `parm-union.hpp` | NO-CPP | C++ union 参数 |
| `parsecb-anonymous-enum-variant-rename.h` | NO-RUST | parse callback |
| `partial-specialization-and-inheritance.hpp` | NO-CPP | C++ 偏特化 |
| `pointer-attr.h` | YES | BTF type tag 属性 |
| `prefix-link-name-c.h` | NO-RUST | Rust link_name 前缀 |
| `prefix-link-name-cpp.hpp` | NO-CPP | C++ |
| `prepend_enum_name.hpp` | NO-CPP | C++ enum 名称前缀 |
| `prepend-enum-constified-variant.h` | NO-RUST | Rust enum 命名 |
| `private.hpp` | NO-CPP | C++ private 注解 |
| `private_fields.hpp` | NO-CPP | C++ access specifier |
| `ptr32-has-different-size.h` | YES | MSVC __ptr32 扩展 |
| `public-dtor.hpp` | NO-CPP | C++ 析构函数 |

### Q

| 文件 | 决策 | 理由 |
|------|------|------|
| `qualified-dependent-types.hpp` | NO-CPP | C++ 偏特化 |

### R

| 文件 | 决策 | 理由 |
|------|------|------|
| `redeclaration.hpp` | NO-CPP | C++ extern "C" 重复声明 |
| `redundant-packed-and-align.h` | YES | packed + aligned 同时存在 |
| `ref_argument_array.hpp` | NO-CPP | C++ 引用参数 |
| `references.hpp` | NO-CPP | C++ 引用 |
| `reparented_replacement.hpp` | NO-CPP | C++ rustbindgen replaces |
| `replace_template_alias.hpp` | NO-CPP | C++ rustbindgen replaces |
| `replace_use.hpp` | NO-CPP | C++ rustbindgen replaces |
| `replaces_double.hpp` | NO-CPP | C++ rustbindgen replaces |
| `repr-align.hpp` | NO-CPP | C++11 alignas |
| `resolved_type_def_function.h` | YES | typedef 函数类型 extern |

### S

| 文件 | 决策 | 理由 |
|------|------|------|
| `same_struct_name_in_different_namespaces.hpp` | NO-CPP | C++ 命名空间 |
| `sentry-defined-multiple-times.hpp` | NO-CPP | C++ 命名空间 |
| `short-enums.hpp` | NO-CPP | C++ -fshort-enums |
| `size_t_template.hpp` | NO-CPP | C++ 模板 |
| `sorted_items.hpp` | NO-CPP | C++ sort-semantically |
| `special-members.hpp` | NO-CPP | C++ 特殊成员函数 |
| `specific_receiver.hpp` | NO-CPP | C++ 虚函数 |
| `stdint_typedef.h` | NO-FILTER | allowlist |
| `strings_array.h` | YES | const char* 字符串常量 |
| `strings_cstr.h` | NO-RUST | Rust CStr |
| `strings_cstr2.h` | NO-RUST | Rust CStr |
| `strings_cstr2_2018.h` | NO-RUST | Rust CStr + edition |
| `struct_containing_forward_declared_struct.h` | PARTIAL | 包含前向声明 struct，去掉 derive flags |
| `struct_typedef.h` | PARTIAL | 匿名 struct/enum typedef，去掉 derive + rustified-enum |
| `struct_typedef_ns.hpp` | NO-CPP | C++ 命名空间 |
| `struct_with_anon_struct.h` | PARTIAL | 含匿名 struct，去掉 derive flags |
| `struct_with_anon_struct_array.h` | PARTIAL | 匿名 struct 数组，去掉 derive flags |
| `struct_with_anon_struct_pointer.h` | PARTIAL | 匿名 struct 指针，去掉 derive flags |
| `struct_with_anon_union.h` | PARTIAL | 含匿名 union，去掉 derive flags |
| `struct_with_anon_unnamed_struct.h` | PARTIAL | 无名匿名 struct，去掉 derive flags |
| `struct_with_anon_unnamed_union.h` | PARTIAL | 无名匿名 union，去掉 derive flags |
| `struct_with_bitfields.h` | PARTIAL | 各种 bitfield，去掉 derive flags |
| `struct_with_derive_debug.h` | NO-RUST | Rust derive Debug 数组限制 |
| `struct_with_large_array.hpp` | NO-CPP | C++ 大数组 derive 限制 |
| `struct_with_nesting.h` | PARTIAL | 嵌套 struct/union，去掉 derive flags |
| `struct_with_packing.h` | PARTIAL | packed struct，去掉 derive flags |
| `struct_with_struct.h` | PARTIAL | struct 内含 struct，去掉 derive flags |
| `struct_with_typedef_template_arg.hpp` | NO-CPP | C++ 模板 |

### T

| 文件 | 决策 | 理由 |
|------|------|------|
| `template.hpp` | NO-CPP | C++ 模板 |
| `template_alias.hpp` | NO-CPP | C++ 模板别名 |
| `template_alias_basic.hpp` | NO-CPP | C++ |
| `template_alias_namespace.hpp` | NO-CPP | C++ |
| `template_fun.hpp` | NO-CPP | C++ 模板函数 |
| `template_instantiation_with_fn_local_type.hpp` | NO-CPP | C++ |
| `template_partial_specification.hpp` | NO-CPP | C++ 偏特化 |
| `template_typedef_transitive_param.hpp` | NO-CPP | C++ |
| `template_typedefs.hpp` | NO-CPP | C++ |
| `template-fun-ty.hpp` | NO-CPP | C++ |
| `template-param-usage-0.hpp` | NO-CPP | C++ |
| `template-param-usage-1.hpp` | NO-CPP | C++ |
| `template-param-usage-2.hpp` | NO-CPP | C++ |
| `template-param-usage-3.hpp` | NO-CPP | C++ |
| `template-param-usage-4.hpp` | NO-CPP | C++ |
| `template-param-usage-5.hpp` | NO-CPP | C++ |
| `template-param-usage-6.hpp` | NO-CPP | C++ |
| `template-param-usage-7.hpp` | NO-CPP | C++ |
| `template-param-usage-8.hpp` | NO-CPP | C++ |
| `template-param-usage-9.hpp` | NO-CPP | C++ |
| `template-param-usage-10.hpp` | NO-CPP | C++ |
| `template-param-usage-11.hpp` | NO-CPP | C++ |
| `template-param-usage-12.hpp` | NO-CPP | C++ |
| `template-param-usage-13.hpp` | NO-CPP | C++ |
| `template-param-usage-14.hpp` | NO-CPP | C++ |
| `template-param-usage-15.hpp` | NO-CPP | C++ |
| `templateref_opaque.hpp` | NO-CPP | C++ |
| `template-with-var.hpp` | NO-CPP | C++ |
| `templatized-bitfield.hpp` | NO-CPP | C++ |
| `timex.h` | YES | 匿名 bitfield padding |
| `transform-op.hpp` | NO-CPP | C++ 模板 union |
| `type_alias_empty.hpp` | NO-CPP | C++ 模板别名 |
| `type_alias_partial_template_especialization.hpp` | NO-CPP | C++ |
| `type_alias_template_specialized.hpp` | NO-CPP | C++ |
| `typedefd-array-as-function-arg.h` | YES | typedef 数组函数参数 |
| `typedef-pointer-overlap.h` | YES | typedef 指针重名 |
| `typeref.hpp` | NO-CPP | C++ 模板 union |
| `type-referenced-by-allowlisted-function.h` | NO-FILTER | allowlist 函数 |

### U

| 文件 | 决策 | 理由 |
|------|------|------|
| `uncallable_functions.hpp` | NO-CPP | C++ deleted/private/virtual |
| `underscore.hpp` | NO-CPP | C++ class |
| `union_bitfield.h` | PARTIAL | union bitfield，去掉 derive + impl-partialeq |
| `union_dtor.hpp` | NO-CPP | C++ union 析构函数 |
| `union_fields.hpp` | NO-CPP | C++ union |
| `union_template.hpp` | NO-CPP | C++ 模板 union |
| `union_with_anon_struct.h` | PARTIAL | union 含匿名 struct，去掉 derive flags |
| `union_with_anon_struct_bitfield.h` | PARTIAL | union 含匿名 struct bitfield，去掉 derive flags |
| `union_with_anon_union.h` | PARTIAL | union 含匿名 union，去掉 derive flags |
| `union_with_anon_unnamed_struct.h` | PARTIAL | union 含无名 struct，去掉 derive flags |
| `union_with_anon_unnamed_union.h` | PARTIAL | union 含无名 union，去掉 derive flags |
| `union_with_big_member.h` | NO-RUST | Rust derive 数组限制 |
| `union_with_nesting.h` | PARTIAL | 深层嵌套 union，去掉 derive flags |
| `union_with_non_copy_member.h` | NO-RUST | Rust union wrapper/ManuallyDrop |
| `union_with_zero_sized_array.h` | YES | 零长数组 union |
| `union-align.h` | YES | 对齐属性 union |
| `union-in-ns.hpp` | NO-CPP | C++ 命名空间 |
| `unknown_attr.h` | YES | max_align_t 非标准对齐 |
| `unsorted-items.h` | YES | 混合声明顺序 |
| `use-core.h` | NO-RUST | Rust use-core / no_std |
| `using.hpp` | NO-CPP | C++ using 别名 |

### V

| 文件 | 决策 | 理由 |
|------|------|------|
| `va_list_aarch64_linux.h` | YES | va_list（AArch64 target） |
| `variadic_template_function.hpp` | NO-CPP | C++ 可变模板 |
| `variadic-method.hpp` | NO-CPP | C++ 可变方法 |
| `variadic-union.hpp` | NO-CPP | C++ 可变 union |
| `var-tracing.hpp` | NO-CPP | C++ allowlist 追踪 |
| `vector.hpp` | NO-CPP | C++ GCC 向量 |
| `virtual_dtor.hpp` | NO-CPP | C++ 虚析构 |
| `virtual_inheritance.hpp` | NO-CPP | C++ 虚继承 |
| `virtual_interface.hpp` | NO-CPP | C++ 纯虚接口 |
| `virtual_overloaded.hpp` | NO-CPP | C++ 虚函数重载 |
| `void_typedef.h` | YES | void typedef 链 |
| `vtable_recursive_sig.hpp` | NO-CPP | C++ vtable |

### W

| 文件 | 决策 | 理由 |
|------|------|------|
| `wasm-constructor-returns.hpp` | NO-CPP | C++ WASM |
| `wasm-import-module.h` | NO-RUST | Rust WASM import module |
| `weird_bitfields.hpp` | NO-CPP | C++ 复杂 bitfield |
| `what_is_going_on.hpp` | NO-CPP | C++ 模板 |
| `win32-dtors.hpp` | NO-CPP | C++ MSVC |
| `win32-thiscall.hpp` | NO-CPP | C++ thiscall |
| `win32-thiscall_1_73.hpp` | NO-CPP | C++ thiscall |
| `win32-thiscall_nightly.hpp` | NO-CPP | C++ nightly |
| `win32-vectorcall.h` | YES | __vectorcall 调用约定 |
| `win32-vectorcall-nightly.h` | NO-RUST | Rust nightly abi_vectorcall |
| `with_array_pointers_arguments.h` | YES | 数组指针参数 |
| `without_array_pointers_arguments.h` | YES | 默认数组衰减 |
| `wrap_unsafe_ops_anon_union.hpp` | NO-CPP | C++ wrap-unsafe-ops |
| `wrap_unsafe_ops_class.hpp` | NO-CPP | C++ wrap-unsafe-ops |
| `wrap_unsafe_ops_dynamic_loading_simple.h` | NO-RUST | Rust wrap-unsafe-ops |
| `wrap_unsafe_ops_objc_class.h` | NO-OBJC | ObjC wrap-unsafe-ops |
| `wrap-static-fns.h` | NO-RUST | Rust static fn wrapper |

### Z

| 文件 | 决策 | 理由 |
|------|------|------|
| `zero-size-array-align.h` | YES | 零长数组对齐 |
| `zero-sized-array.hpp` | NO-CPP | C++ 零长数组 |

---

## 统计汇总

| 决策 | 数量 |
|------|------|
| YES（直接迁移） | ~70 |
| PARTIAL（迁移，去掉 Rust flags） | ~35 |
| NO-CPP | ~300 |
| NO-RUST | ~90 |
| NO-FILTER | ~10 |
| NO-OBJC | ~17 |
| NO-DYN | ~5 |
| NO-ANNOT | ~2 |
| NO-OTHER | ~2 |

**总计需迁移：~105 个测试（YES + PARTIAL）**
