package cjbind_cli

import cjbind.{generate}
import cjbind.utils.{updateConsole, formatString}
import cjbind.options.CjbindOptions

main(): Int64 {
    updateConsole()

    let (opt, writer) = processArgs()

    if (opt.headers.isEmpty()) {
        throw Exception("没有指定头文件")
    }

    let binding = formatString(generate(opt))

    writer(binding)

    return 0
}
