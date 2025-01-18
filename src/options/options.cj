package cjbind.options

import std.collection.*

public class CjbindOptions {
    public let headers: ArrayList<String> = ArrayList()
    public let clangArgs: ArrayList<String> = ArrayList()

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

    public func header(str: String): CjbindOptionsBuilder {
        opts.headers.add(str)
        return this
    }

    public func headers(strs: Array<String>): CjbindOptionsBuilder {
        opts.headers.add(all: strs)
        return this
    }

    public func clangArg(str: String): CjbindOptionsBuilder {
        opts.clangArgs.add(str)
        return this
    }

    public func clangArgs(strs: Array<String>): CjbindOptionsBuilder {
        opts.clangArgs.add(all: strs)
        return this
    }

    public func build(): CjbindOptions {
        opts
    }
}
