package cjbind

import std.argopt.*
import std.process.Process

import cjbind.build
import cjbind.options.CjbindOptions

const HELP = """
自动生成仓颉到 C 库的 FFI 绑定代码。

用法：cjbind <OPTIONS> <HEADER> -- <CLANG_ARGS>

参数：
    <HEADER>\tC 头文件路径
    [CLANG_ARGS]...\t会被直接传递给 clang 的参数

选项：
    -o, --output\t<OUTPUT> 把生成的绑定输出到文件。
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
    let shortArgs = "o:V:h"
    let longArgs = ["output=", "version", "help"]

    let args = Process.current.arguments
    let ao = ArgOpt(args, shortArgs, longArgs)

    if (ao.getArg("-h").isSome() || ao.getArg("--help").isSome()) {
        help()
    }
    if (ao.getArg("-V").isSome() || ao.getArg("--version").isSome()) {
        version()
    }

    let opt = CjbindOptions()
    opt.headers.add("testdata/test.h")

    print(generate(opt))

    return 0
}