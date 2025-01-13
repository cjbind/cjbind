package cjbind.options

import std.collection.*

public class CjbindOptions {
    public let headers: ArrayList<String> = ArrayList()
    public let clang_args: ArrayList<String> = ArrayList()

    init() {}

    init(headers: ArrayList<String>, clang_args: ArrayList<String>) {
        this.headers.appendAll(headers)
        this.clang_args.appendAll(clang_args)
    }
}

public class CjbindOptionsBuilder {
    let opts: CjbindOptions

    init() {
        opts = CjbindOptions()
    }

    public func header(str: String): CjbindOptionsBuilder {
        opts.headers.append(str)
        return this
    }

    public func headers(strs: Array<String>): CjbindOptionsBuilder {
        opts.headers.appendAll(strs)
        return this
    }

    public func clangArg(str: String): CjbindOptionsBuilder {
        opts.clang_args.append(str)
        return this
    }

    public func clangArgs(strs: Array<String>): CjbindOptionsBuilder {
        opts.clang_args.appendAll(strs)
        return this
    }

    public func build(): CjbindOptions {
        opts
    }
}