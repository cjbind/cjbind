package cjbind

import cjbind.options.CjbindOptions

main(): Int64 {
    let opt = CjbindOptions()
    opt.headers.add("testdata/test.h")

    print(generate(opt))

    return 0
}