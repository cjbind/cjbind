package cjbind

import std.fs.File
import std.process.Process
import cjbind.arg.{Flag, StringFlag, BoolFlag, ArgsParser}
import cjbind.build
import cjbind.clang.getClangVersion
import cjbind.options.CjbindOptions

func processArgs(): (CjbindOptions, (String) -> Unit) {
    let noEnumPrefixFlag = BoolFlag(None, "no-enum-prefix", "no-enum-prefix",
        "生成枚举时，不使用枚举名称作为枚举值的前缀",)
    let outputFlag = StringFlag(Some("o"), "output", "output", "把生成的绑定输出到文件", "FILE", None)
    let packageFlag = StringFlag(Some("p"), "package", "package", "生成的绑定中的包名", "PACKAGE", "cjbind_ffi")

    // 处理特例
    let versionFlag = BoolFlag(Some("v"), "version", "version", "显示版本号并退出")
    let helpFlag = BoolFlag(Some("h"), "help", "help", "显示帮助信息")

    let parser = ArgsParser(
        noEnumPrefixFlag,
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

    let output: ?String = outputFlag.value

    let writer: (String) -> Unit = match (output) {
        case Some(v) => {gen => File.writeTo(v, gen.toArray())}
        case None => {gen => println(gen)}
    }

    return (opt, writer)
}

func printVersion() {
    let version = """
cjbind 版本：\t${build.VERSION}

Commit Hash：\t${build.COMMIT_HASH}
Commit 时间：\t${build.COMMIT_DATE}
开发分支：\t${build.BRANCH}
标签：\t${build.TAG}
洁净构建：\t${build.GIT_CLEAN_FILES.isEmpty()}

libclang 版本：\t${getClangVersion()}"""
    print(version)

    Process.current.exit(0)
}

func printHelp(parser: ArgsParser): Nothing {
    println(parser.getHelp())

    Process.current.exit(0)
}