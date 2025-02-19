package cjbind

import std.fs.File
import std.process.Process
import cjbind.arg.{Flag, StringFlag, BoolFlag, ArgsParser}
import cjbind.build
import cjbind.clang.getClangVersion
import cjbind.options.CjbindOptions
import cjbind.utils.sprintAlign

func processArgs(): (CjbindOptions, (String) -> Unit) {
    let noEnumPrefixFlag = BoolFlag(None, "no-enum-prefix", "no-enum-prefix",
        "生成枚举时，不使用枚举名称作为枚举值的前缀",)
    let noDetectIncludePath = BoolFlag(None, "no-detect-include-path", "no-detect-include-path",
        "禁用自动 include 路径检测")
    let noComment = BoolFlag(None, "no-comment", "no-comment", "不尝试生成代码中的注释")
    let noLayoutTests = BoolFlag(None, "no-layout-test", "no-layout-test", "不生成布局测试代码")
    let builtins = BoolFlag(None, "builtins", "builtins", "生成内置定义的 bindings，如 __builtin_va_list")
    let makeFuncWrapperFlag = BoolFlag(None, "make-func-wrapper", "make-func-wrapper", "生成 foreign 函数包装器以允许包外调用")
    let funcWrapperSuffixFlag = StringFlag(None, "func-wrapper-suffix", "func-wrapper-suffix", "生成函数包装器时使用的后缀，默认为 _cjbindwrapper", "SUFFIX", "_cjbindwrapper")
    let autoCString = BoolFlag(None, "auto-cstring", "auto-cstring", "把 char* 转换为 CString 而不是 CPointer<UInt8>")
    let arrayPointersInArgs = BoolFlag(None, "array-pointers-in-args", "array-pointers-in-args", "把数组 T arr[size] 转换为 VArray<T, $size> 而不是 CPointer<T>")
    let makeCjString = BoolFlag(None, "make-cjstring", "make-cjstring", "把 C 字符串转换为仓颉的 String 而不是 VArray<UInt8>，这可能会导致二进制表示不一致")

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
        autoCString,
        arrayPointersInArgs,
        makeCjString,
        outputFlag,
        packageFlag,
        versionFlag,
        helpFlag
    )

    let (headers, clangArgs) = parser.parse(Process.current.arguments)

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
    opt.arrayPointersInArgs = arrayPointersInArgs.value
    opt.makeCjString = makeCjString.value

    let output: ?String = outputFlag.value

    let writer: (String) -> Unit = match (output) {
        case Some(v) => {gen => File.writeTo(v, gen.toArray())}
        case None => {gen => println(gen)}
    }

    return (opt, writer)
}

func printVersion() {
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

    Process.current.exit(0)
}

func printHelp(parser: ArgsParser): Nothing {
    println(parser.getHelp())

    Process.current.exit(0)
}
