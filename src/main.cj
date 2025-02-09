package cjbind

import std.argopt.*
import std.process.Process
import std.fs.File
import cjbind.build
import cjbind.utils.{updateConsole, anySome, anySomeValue, formatString}
import cjbind.options.CjbindOptions

const HELP = """
自动生成 C 库到仓颉的 FFI 绑定代码。

用法：cjbind <OPTIONS> <HEADER> -- <CLANG_ARGS>

参数：
    <HEADER>\tC 头文件路径
    [CLANG_ARGS]...\t会被直接传递给 clang 的参数

选项：
    -o, --output\t<OUTPUT> 把生成的绑定输出到文件
    -p, --package\t<PACKAGE> 指定生成的包名
    -V, --version\t显示版本号并退出
    -h, --help\t显示帮助信息
"""

func help(): Unit {
    print(HELP)
    Process.current.exit(0)
}

func version(): Unit {
    let version = """
cjbind 版本：\t${build.VERSION}

Commit Hash：\t${build.COMMIT_HASH}
Commit 时间：\t${build.COMMIT_DATE}
开发分支：\t${build.BRANCH}
标签：\t${build.TAG}
洁净构建：\t${build.GIT_CLEAN_FILES.isEmpty()}
"""
    print(version)
    Process.current.exit(0)
}

main(): Int64 {
    updateConsole()

    let shortArgs = "o:p:V:h"
    let longArgs = ["output=", "pacakge=", "version", "help"]

    let args = Process.current.arguments
    let ao = ArgOpt(args, shortArgs, longArgs)

    if (anySome(ao.getArg("-h"), ao.getArg("--help"))) {
        help()
    }
    if (anySome(ao.getArg("-V"), ao.getArg("--version"))) {
        version()
    }

    let opt = CjbindOptions()

    let packageName = anySomeValue(ao.getArg("-p"), ao.getArg("--package"))
    if (let Some(v) <- packageName) {
        opt.packageName = v
    }

    let rem = ao.getUnparseArgs()

    var collector = opt.headers
    var collectingClang = false

    for (l in rem) {
        match (l) {
            case "--" =>
                collector = opt.clangArgs
                collectingClang = true
            case _ =>
                if (l.startsWith("-") && !collectingClang) {
                    throw Exception("未知选项: ${l}")
                }

                collector.add(l)
        }
    }

    if (opt.headers.isEmpty()) {
        eprintln("警告：没有指定头文件")
    }

    let binding = formatString(generate(opt))

    let out = anySomeValue(ao.getArg("-o"), ao.getArg("--output"))
    match (out) {
        case Some(v) => File.writeTo(v, binding.toArray())
        case None => println(binding)
    }

    return 0
}
