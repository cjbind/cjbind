# cjbind vs rust-bindgen 对比分析 TODO

## 一、实现不一致（需修复）

### C 绑定

- [ ] **Union 处理**：当前将 union 转为 opaque blob (`VArray<UInt8, $size>`)，rust-bindgen 生成正确的 union 类型并支持字段访问。应生成可访问字段的 union 表示。
  - 文件：`codegen/lib.cj` (union codegen)、`ir/comp.cj`

- [ ] **Bitfield 处理**：当前将含 bitfield 的 struct 转为 opaque blob，rust-bindgen 生成 `BitfieldUnit` + getter/setter 访问器。应生成位域访问方法。
  - 文件：`codegen/lib.cj`、`ir/comp.cj`

- [ ] **Packed 结构体**：当前跳过并输出警告，rust-bindgen 用 `#[repr(packed)]` 正确生成。应支持 packed struct 生成。
  - 文件：`codegen/lib.cj`

- [ ] **调用约定丢失**：IR 层 (`function.cj`) 已正确解析 Stdcall/Fastcall/ThisCall/Vectorcall/AAPCS/Win64，但 codegen 阶段全部映射为 CDECL。应将调用约定传播到生成代码中。
  - 文件：`codegen/lib.cj`、`ir/function.cj`

- [ ] **Enum 生成风格单一**：仅支持常量 + 类型别名，rust-bindgen 支持 5 种模式（Rust enum、NewType、Const、ModuleConst、NonExhaustive）。可考虑增加 Cangjie `enum` 生成模式。
  - 文件：`codegen/lib.cj`、`options/options.cj`

- [ ] **Macro 常量类型推断**：固定使用 Int64/UInt64/Float64，rust-bindgen 有 `fit_macro_constants` 自动选择最小适配类型。可优化为最小类型匹配。
  - 文件：`ir/var.cj`、`codegen/lib.cj`

### ObjC 绑定

- [ ] **Category runtime 模式合并到基类**：丢失了 category 边界信息。rust-bindgen 生成独立 trait。compiler 模式已用 `extend` 块处理，但 runtime 模式应保留 category 信息或至少加注释标记。
  - 文件：`codegen/objc.cj`、`lib.cj`

- [ ] **缺少向下转型 (Downcast)**：rust-bindgen 通过 `TryFrom` + 运行时 `isKindOfClass:` 检查实现。cjbind 仅有向上转型 (`asParentName()`)，应补充向下转型方法。
  - 文件：`codegen/objc.cj`

- [ ] **Method selector 转换规则差异**：rust-bindgen 将冒号替换为下划线 (`initWithFrame:` → `initWithFrame_`)，cjbind 去掉尾冒号 (`initWithFrame:` → `initWithFrame`)。cjbind 通过 `@ForeignName` 保留原始 selector，做法更好，但多参数 selector 的转换规则需确认一致性。
  - 文件：`lib.cj` (parseObjCMethod)

- [ ] **Property setter 命名差异**：rust-bindgen 用 `setValue_`（带下划线后缀），cjbind 用 `setPropertyName`（无下划线）。cjbind 使用 Cangjie prop 语法更地道，但需确认与 ObjC 运行时 selector 匹配。
  - 文件：`codegen/objc.cj`

---

## 二、缺少的功能（cjbind 未实现）

### C 相关

- [ ] **Allowlist/Blocklist 过滤**：按名称/正则过滤要生成或排除的类型、函数、变量
- [ ] **手动 Opaque 类型配置**：允许用户指定某些类型强制为 opaque
- [ ] **Function-like macro callback**：通过回调处理函数式宏
- [ ] **Flexible array member (FAM)**：零长度数组的特殊处理
- [ ] **Link name / mangled name**：符号名称重映射
- [ ] **函数属性传播**：`must_use`、`noreturn`/divergent 属性
- [ ] **Typedef 变体模式**：NewType、NewTypeDeref 等包装模式
- [ ] **Field 级别属性**：自定义字段注解模式

### ObjC 相关

- [ ] **ObjC 项过滤**：Allowlist/Blocklist 对 ObjC 类/方法的过滤
- [ ] **导入模式切换**：类似 `--objc-extern-crate` 控制导入方式

---

## 三、cjbind 优于 rust-bindgen 的功能（保持优势）

- [x] **双模式 codegen**：runtime (objc_msgSend) + compiler (@ObjCMirror)
- [x] **ObjC Block 支持**：解析为 CFunc 类型（rust-bindgen 不支持）
- [x] **Protocol 完整方法签名**：完整的 protocol 接口定义（rust-bindgen 仅生成空 marker trait）
- [x] **@ObjCOptional 标注**：标注可选协议方法
- [x] **Nullability 完整传播**：参数/返回值/属性的 nullable 标注均传播到生成代码
- [x] **Selector/Class 缓存**：运行时性能优化
- [x] **autoCString 选项**：自动 `char*` → `CString` 转换
- [x] **makeFuncWrapper 选项**：安全函数包装器生成
