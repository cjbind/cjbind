# cjbind vs rust-bindgen 对比分析 TODO

## 一、实现不一致（需修复）

### C 绑定

- [x] **Union 处理**：生成 @C struct + blob 存储 + getter/setter 访问器（通过 CPointer 类型转换实现内存重解释）
  - 文件：`codegen/lib.cj`、`codegen/helper.cj`

- [x] **Bitfield 处理**：保留正常字段 + `_bitfield_N` 存储单元 + 位级 getter/setter（含有符号扩展）
  - 文件：`codegen/lib.cj`、`codegen/helper.cj`

- [x] ~~**Packed 结构体**：仓颉语言限制，暂不支持~~

- [x] ~~**调用约定丢失**：仓颉语言限制，暂不支持~~

- [x] **Enum 生成风格**：新增 `--default-enum-style newtype` 选项，生成 @C struct 包装 + static let 常量 + == != 操作符
  - 文件：`codegen/lib.cj`、`options/options.cj`、`cli.cj`

- [x] **Macro 常量类型推断**：新增 `--fit-macro-constants` 选项，根据值范围选择最小适配整数类型
  - 文件：`ir/var.cj`、`options/options.cj`、`cli.cj`

### ObjC 绑定

- [ ] **Category runtime 模式合并到基类**：解析时 category 方法直接合并到基类，完全丢失 category 边界信息。compiler 模式已用 `extend` 块处理，但 runtime 模式应至少加注释标记。
  - 文件：`codegen/objc.cj`、`lib.cj:242-244`

- [ ] **缺少向下转型 (Downcast)**：仅有向上转型 `asParentName()`，无 `isKindOfClass:` 运行时检查和向下转型方法。
  - 文件：`codegen/objc.cj`

- [x] **Method selector 转换规则**：已确认一致。`dataWithBytes:length:` → `dataWithBytes_length`（去尾下划线），通过 `@ForeignName` 保留原始 selector，正确性有保证。
  - 文件：`lib.cj:284-285`

- [x] **Property setter 命名**：已确认正确。使用 Cangjie `mut prop` 语法，通过 `@ForeignSetterName` 注解保留实际 ObjC selector `setPropertyName:`，既符合仓颉惯例又保证 ObjC 运行时正确性。
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
