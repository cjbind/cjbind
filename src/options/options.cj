package cjbind.options

import std.collection.*

public class CjbindOptions {
    public let headers: ArrayList<String> = ArrayList()
    public let clangArgs: ArrayList<String> = ArrayList()
    public var packageName: String = "cjbind_ffi"

    public init() {}

    public init(headers: ArrayList<String>, clang_args: ArrayList<String>) {
        this.headers.add(all: headers)
        this.clangArgs.add(all: clang_args)
    }
}

public class CjbindOptionsBuilder {
    let opts: CjbindOptions

    init() {
        opts = CjbindOptions()
    }

    public func header(str: String): This {
        opts.headers.add(str)
        return this
    }

    public func headers(strs: Array<String>): This {
        opts.headers.add(all: strs)
        return this
    }

    public func clangArg(str: String): This {
        opts.clangArgs.add(str)
        return this
    }

    public func clangArgs(strs: Array<String>): This {
        opts.clangArgs.add(all: strs)
        return this
    }

    public func packageName(str: String): This {
        opts.packageName = str
        return this
    }

    public func build(): CjbindOptions {
        opts
    }
}
