package cjbind_cli

import std.fs.File
import std.env
import cjbind_cli.arg.{StringFlag, StringListFlag, BoolFlag, ArgsParser}
import cjbind.build
import cjbind.clang.getClangVersion
import cjbind.options.{CjbindOptions, ObjcCodegenMode, DefaultEnumStyle, DefaultAliasStyle}
import cjbind.utils.sprintAlign

public func processArgs(): (CjbindOptions, (String) -> Unit) {
    let noEnumPrefixFlag = BoolFlag(None, "no-enum-prefix", "no-enum-prefix",
        "生成枚举时，不使用枚举名称作为枚举值的前缀",)
    let noDetectIncludePath = BoolFlag(None, "no-detect-include-path", "no-detect-include-path",
        "禁用自动 include 路径检测")
    let noComment = BoolFlag(None, "no-comment", "no-comment", "不尝试生成代码中的注释")
    let noLayoutTests = BoolFlag(None, "no-layout-test", "no-layout-test", "不生成布局测试代码")
    let builtins = BoolFlag(None, "builtins", "builtins", "生成内置定义的 bindings，如 __builtin_va_list")
    let makeFuncWrapperFlag = BoolFlag(None, "make-func-wrapper", "make-func-wrapper", "生成 foreign 函数包装器以允许包外调用")
    let funcWrapperSuffixFlag = StringFlag(None, "func-wrapper-suffix", "func-wrapper-suffix", "生成函数包装器时使用的后缀，默认为 _cjbindwrapper", "SUFFIX", "_cjbindwrapper")
    let wrapStaticFnsFlag = BoolFlag(None, "wrap-static-fns", "wrap-static-fns",
        "为 static/static inline 函数生成可编译的 C/C++ 外部桥接函数")
    let wrapStaticFnsSuffixFlag = StringFlag(None, "wrap-static-fns-suffix", "wrap-static-fns-suffix",
        "static 函数桥接符号的后缀，默认为 __extern", "SUFFIX", "__extern")
    let wrapStaticFnsPathFlag = StringFlag(None, "wrap-static-fns-path", "wrap-static-fns-path",
        "static 函数桥接源文件的基础路径（自动使用 .c 或 .cpp 扩展名）", "PATH", None)
    let autoCString = BoolFlag(None, "auto-cstring", "auto-cstring", "把 char* 转换为 CString 而不是 CPointer<UInt8>")
    let arrayPointersInArgs = BoolFlag(None, "array-pointers-in-args", "array-pointers-in-args", "把数组 T arr[size] 转换为 VArray<T, $size> 而不是 CPointer<T>")
    let makeCjString = BoolFlag(None, "make-cjstring", "make-cjstring", "把 C 字符串转换为仓颉的 String 而不是 VArray<UInt8>，这可能会导致二进制表示不一致")
    let objcFlag = BoolFlag(None, "objc", "objc", "启用 Objective-C 绑定生成模式")
    let objcCodegenModeFlag = StringFlag(None, "objc-codegen-mode", "objc-codegen-mode", "ObjC 代码生成模式: runtime (默认) 或 compiler", "MODE", "runtime")
    let objcGenerateDefinitions = BoolFlag(None, "objc-generate-definitions", "objc-generate-definitions", "在 compiler 模式下生成带默认返回值的方法桩体")
    let defaultEnumStyleFlag = StringFlag(None, "default-enum-style", "default-enum-style",
        "默认枚举生成风格: consts (默认) 或 newtype", "STYLE", "consts")
    let defaultAliasStyleFlag = StringFlag(None, "default-alias-style", "default-alias-style",
        "默认别名生成风格: type_alias (默认)、new_type 或 new_type_deref", "STYLE", "type_alias")
    let typeAliasFlag = StringListFlag(None, "type-alias", "type-alias",
        "把名称匹配正则表达式的 typedef 生成为普通 type alias", "REGEX")
    let newTypeAliasFlag = StringListFlag(None, "new-type-alias", "new-type-alias",
        "把名称匹配正则表达式的 typedef 生成为强类型包装", "REGEX")
    let newTypeAliasDerefFlag = StringListFlag(None, "new-type-alias-deref", "new-type-alias-deref",
        "把名称匹配正则表达式的 typedef 生成为带 wrap/unwrap 的强类型包装", "REGEX")
    let fitMacroConstantsFlag = BoolFlag(None, "fit-macro-constants", "fit-macro-constants",
        "根据值范围选择最小适配整数类型")
    let noUnionAccessorWorkaroundFlag = BoolFlag(None, "no-union-accessor-workaround",
        "no-union-accessor-workaround", "禁用 union accessor 的编译器 verifier workaround")
    let enableCxxNamespacesFlag = BoolFlag(None, "enable-cxx-namespaces", "enable-cxx-namespaces",
        "启用 C++ namespace 命名规则（默认折叠内联 namespace）")
    let conservativeInlineNamespacesFlag = BoolFlag(None, "conservative-inline-namespaces",
        "conservative-inline-namespaces", "保守处理 C++ inline namespace")
    let ignoreMethodsFlag = BoolFlag(None, "ignore-methods", "ignore-methods", "不生成 C++ 方法绑定")
    let generateFlag = StringFlag(None, "generate", "generate",
        "选择生成项，可用值为 functions、types、vars、methods、constructors、destructors", "ITEMS", None)
    let representCxxOperatorsFlag = BoolFlag(None, "represent-cxx-operators", "represent-cxx-operators",
        "生成受支持的 C++ 运算符绑定")
    let respectCxxAccessSpecsFlag = BoolFlag(None, "respect-cxx-access-specs", "respect-cxx-access-specs",
        "按 C++ 访问说明符设置生成项的可见性")
    let useSpecificVirtualFunctionReceiverFlag = BoolFlag(None, "use-specific-virtual-function-receiver",
        "use-specific-virtual-function-receiver", "虚函数使用具体类指针作为接收者")
    let generateInlineFunctionsFlag = BoolFlag(None, "generate-inline-functions", "generate-inline-functions",
        "生成 C++ inline 函数绑定")
    let generateDeletedFunctionsFlag = BoolFlag(None, "generate-deleted-functions", "generate-deleted-functions",
        "保留标记为 deleted 的 C++ 函数")
    let generatePureVirtualFunctionsFlag = BoolFlag(None, "generate-pure-virtual-functions",
        "generate-pure-virtual-functions", "保留纯虚函数绑定")
    let generatePrivateFunctionsFlag = BoolFlag(None, "generate-private-functions", "generate-private-functions",
        "保留私有 C++ 函数绑定")
    let vtableGenerationFlag = BoolFlag(None, "vtable-generation", "vtable-generation",
        "生成 C++ 虚函数表定义")
    let blocklistTypeFlag = StringListFlag(None, "blocklist-type", "blocklist-type",
        "不生成名称匹配正则表达式的类型", "REGEX")
    let blocklistFunctionFlag = StringListFlag(None, "blocklist-function", "blocklist-function",
        "不生成名称匹配正则表达式的函数", "REGEX")
    let blocklistItemFlag = StringListFlag(None, "blocklist-item", "blocklist-item",
        "不生成名称匹配正则表达式的任意项目", "REGEX")
    let blocklistVarFlag = StringListFlag(None, "blocklist-var", "blocklist-var",
        "不生成名称匹配正则表达式的变量", "REGEX")
    let blocklistFileFlag = StringListFlag(None, "blocklist-file", "blocklist-file",
        "不生成完整路径匹配正则表达式的文件内容", "REGEX")
    let opaqueTypeFlag = StringListFlag(None, "opaque-type", "opaque-type",
        "把名称匹配正则表达式的类型生成为不透明布局", "REGEX")
    let allowlistTypeFlag = StringListFlag(None, "allowlist-type", "allowlist-type",
        "只选择名称匹配正则表达式的类型及其依赖", "REGEX")
    let allowlistFunctionFlag = StringListFlag(None, "allowlist-function", "allowlist-function",
        "只选择名称匹配正则表达式的函数及其依赖", "REGEX")
    let allowlistItemFlag = StringListFlag(None, "allowlist-item", "allowlist-item",
        "只选择名称匹配正则表达式的任意项目及其依赖", "REGEX")
    let allowlistVarFlag = StringListFlag(None, "allowlist-var", "allowlist-var",
        "只选择名称匹配正则表达式的变量及其依赖", "REGEX")
    let allowlistFileFlag = StringListFlag(None, "allowlist-file", "allowlist-file",
        "只选择完整路径匹配正则表达式的文件内容及其依赖", "REGEX")
    let noRecursiveAllowlistFlag = BoolFlag(None, "no-recursive-allowlist", "no-recursive-allowlist",
        "不递归选择显式 allowlist 项目的依赖")
    let noRecordMatchesFlag = BoolFlag(None, "no-record-matches", "no-record-matches",
        "不记录或报告未匹配的正则表达式")
    let disableUntaggedUnionFlag = BoolFlag(None, "disable-untagged-union", "disable-untagged-union",
        "禁用无标签 union 的原生分析规则")
    let noSizeTIsUsizeFlag = BoolFlag(None, "no-size_t-is-usize", "no-size_t-is-usize",
        "不把 size_t 自动映射为目标平台无符号整数")
    let outputFlag = StringFlag(Some("o"), "output", "output", "把生成的绑定输出到文件", "FILE", None)
    let packageFlag = StringFlag(Some("p"), "package", "package", "生成的绑定中的包名", "PACKAGE", "cjbind_ffi")

    // 处理特例
    let versionFlag = BoolFlag(Some("v"), "version", "version", "显示版本号并退出")
    let helpFlag = BoolFlag(Some("h"), "help", "help", "显示帮助信息")

    let parser = ArgsParser(
        noEnumPrefixFlag,
        noDetectIncludePath,
        noComment,
        noLayoutTests,
        builtins,
        makeFuncWrapperFlag,
        funcWrapperSuffixFlag,
        wrapStaticFnsFlag,
        wrapStaticFnsSuffixFlag,
        wrapStaticFnsPathFlag,
        autoCString,
        arrayPointersInArgs,
        makeCjString,
        objcFlag,
        objcCodegenModeFlag,
        objcGenerateDefinitions,
        defaultEnumStyleFlag,
        defaultAliasStyleFlag,
        typeAliasFlag,
        newTypeAliasFlag,
        newTypeAliasDerefFlag,
        fitMacroConstantsFlag,
        noUnionAccessorWorkaroundFlag,
        enableCxxNamespacesFlag,
        conservativeInlineNamespacesFlag,
        ignoreMethodsFlag,
        generateFlag,
        representCxxOperatorsFlag,
        respectCxxAccessSpecsFlag,
        useSpecificVirtualFunctionReceiverFlag,
        generateInlineFunctionsFlag,
        generateDeletedFunctionsFlag,
        generatePureVirtualFunctionsFlag,
        generatePrivateFunctionsFlag,
        vtableGenerationFlag,
        blocklistTypeFlag,
        blocklistFunctionFlag,
        blocklistItemFlag,
        blocklistVarFlag,
        blocklistFileFlag,
        opaqueTypeFlag,
        allowlistTypeFlag,
        allowlistFunctionFlag,
        allowlistItemFlag,
        allowlistVarFlag,
        allowlistFileFlag,
        noRecursiveAllowlistFlag,
        noRecordMatchesFlag,
        disableUntaggedUnionFlag,
        noSizeTIsUsizeFlag,
        outputFlag,
        packageFlag,
        versionFlag,
        helpFlag
    )

    let (headers, clangArgs) = parser.parse(env.getCommandLine())

    if (versionFlag.value) {
        printVersion()
    }

    if (helpFlag.value) {
        printHelp(parser)
    }

    let opt = CjbindOptions(headers, clangArgs)
    opt.packageName = packageFlag.value.getOrThrow()
    opt.noEnumPrefix = noEnumPrefixFlag.value
    opt.noDetectIncludePath = noDetectIncludePath.value
    opt.noLayoutTests = noLayoutTests.value
    opt.builtins = builtins.value
    opt.noComment = noComment.value
    opt.autoCString = autoCString.value
    opt.makeFuncWrapper = makeFuncWrapperFlag.value
    opt.funcWrapperSuffix = funcWrapperSuffixFlag.value.getOrThrow()
    opt.wrapStaticFns = wrapStaticFnsFlag.value
    opt.wrapStaticFnsSuffix = wrapStaticFnsSuffixFlag.value.getOrThrow()
    opt.wrapStaticFnsPath = wrapStaticFnsPathFlag.value
    opt.arrayPointersInArgs = arrayPointersInArgs.value
    opt.makeCjString = makeCjString.value
    opt.objc = objcFlag.value
    opt.objcCodegenMode = match (objcCodegenModeFlag.value.getOrThrow()) {
        case "runtime" => ObjcCodegenMode.Runtime
        case "compiler" => ObjcCodegenMode.Compiler
        case v =>
            eprintln("Error: --objc-codegen-mode must be 'runtime' or 'compiler', got: ${v}")
            env.exit(1)
    }
    opt.objcGenerateDefinitions = objcGenerateDefinitions.value
    opt.defaultEnumStyle = match (defaultEnumStyleFlag.value.getOrThrow()) {
        case "consts" => DefaultEnumStyle.Consts
        case "newtype" => DefaultEnumStyle.NewType
        case v =>
            eprintln("Error: --default-enum-style must be 'consts' or 'newtype', got: ${v}")
            env.exit(1)
    }
    opt.defaultAliasStyle = match (defaultAliasStyleFlag.value.getOrThrow()) {
        case "type_alias" => DefaultAliasStyle.TypeAlias
        case "new_type" => DefaultAliasStyle.NewType
        case "new_type_deref" => DefaultAliasStyle.NewTypeDeref
        case v =>
            eprintln(
                "Error: --default-alias-style must be 'type_alias', 'new_type', or 'new_type_deref', got: ${v}"
            )
            env.exit(1)
    }
    opt.typeAliases.add(typeAliasFlag.values)
    opt.newTypeAliases.add(newTypeAliasFlag.values)
    opt.newTypeDerefAliases.add(newTypeAliasDerefFlag.values)
    opt.fitMacroConstants = fitMacroConstantsFlag.value
    opt.useUnionAccessorWorkaround = !noUnionAccessorWorkaroundFlag.value
    opt.enableCxxNamespaces = enableCxxNamespacesFlag.value
    opt.conservativeInlineNamespaces = conservativeInlineNamespacesFlag.value
    opt.representCxxOperators = representCxxOperatorsFlag.value
    opt.respectCxxAccessSpecs = respectCxxAccessSpecsFlag.value
    opt.useSpecificVirtualFunctionReceiver = useSpecificVirtualFunctionReceiverFlag.value
    opt.generateInlineFunctions = generateInlineFunctionsFlag.value
    opt.generateDeletedFunctions = generateDeletedFunctionsFlag.value
    opt.generatePureVirtualFunctions = generatePureVirtualFunctionsFlag.value
    opt.generatePrivateFunctions = generatePrivateFunctionsFlag.value
    opt.vtableGeneration = vtableGenerationFlag.value
    opt.blocklistedTypes.add(blocklistTypeFlag.values)
    opt.blocklistedFunctions.add(blocklistFunctionFlag.values)
    opt.blocklistedItems.add(blocklistItemFlag.values)
    opt.blocklistedVars.add(blocklistVarFlag.values)
    opt.blocklistedFiles.add(blocklistFileFlag.values)
    opt.opaqueTypes.add(opaqueTypeFlag.values)
    opt.allowlistedTypes.add(allowlistTypeFlag.values)
    opt.allowlistedFunctions.add(allowlistFunctionFlag.values)
    opt.allowlistedItems.add(allowlistItemFlag.values)
    opt.allowlistedVars.add(allowlistVarFlag.values)
    opt.allowlistedFiles.add(allowlistFileFlag.values)
    opt.allowlistRecursively = !noRecursiveAllowlistFlag.value
    opt.recordMatches = !noRecordMatchesFlag.value
    opt.untaggedUnion = !disableUntaggedUnionFlag.value
    opt.sizeTIsUsize = !noSizeTIsUsizeFlag.value
    if (let Some(items) <- generateFlag.value) {
        opt.generateFunctions = false
        opt.generateTypes = false
        opt.generateVars = false
        opt.generateMethods = false
        opt.generateConstructors = false
        opt.generateDestructors = false
        for (item in items.split(",")) {
            match (item.trimAscii()) {
                case "methods" => opt.generateMethods = true
                case "constructors" => opt.generateConstructors = true
                case "destructors" => opt.generateDestructors = true
                case "functions" => opt.generateFunctions = true
                case "types" => opt.generateTypes = true
                case "vars" => opt.generateVars = true
                case value =>
                    eprintln("Error: --generate contains an unknown item: ${value}")
                    env.exit(1)
            }
        }
    }
    if (ignoreMethodsFlag.value) {
        opt.generateMethods = false
    }

    let output: ?String = outputFlag.value

    let writer: (String) -> Unit = match (output) {
        case Some(v) => {gen => File.writeTo(v, gen.toArray())}
        case None => {gen => println(gen)}
    }

    return (opt, writer)
}

func printVersion(): Nothing {
    let pre = [
        "Commit Hash：",
        "Commit 时间：",
        "标签：",
        "洁净构建："
    ]
    let post = [
        build.COMMIT_HASH,
        build.COMMIT_DATE,
        build.TAG,
        build.GIT_CLEAN_FILES.isEmpty().toString()
    ]

    let versionInfo = sprintAlign(pre, post, insert: "")

    let version = """
cjbind 版本：\t${build.VERSION}
libclang 版本：\t${getClangVersion()}

${versionInfo}"""
    println(version)

    env.exit(0)
}

func printHelp(parser: ArgsParser): Nothing {
    println(parser.getHelp())

    env.exit(0)
}
