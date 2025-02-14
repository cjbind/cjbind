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
    let autoCString = BoolFlag(None, "auto-cstring", "auto-cstring", "把 char* 转换为 CString 而不是 CPointer<UInt8>")
    let outputFlag = StringFlag(Some("o"), "output", "output", "把生成的绑定输出到文件", "FILE", None)
    let packageFlag = StringFlag(Some("p"), "package", "package", "生成的绑定中的包名", "PACKAGE", "cjbind_ffi")

    // 处理特例
    let versionFlag = BoolFlag(Some("v"), "version", "version", "显示版本号并退出")
    let helpFlag = BoolFlag(Some("h"), "help", "help", "显示帮助信息")

    let parser = ArgsParser(
        noEnumPrefixFlag,
        noDetectIncludePath,
        autoCString,
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
    opt.autoCString = autoCString.value

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
