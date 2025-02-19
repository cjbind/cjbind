package cjbind.options

import std.collection.*

public class CjbindOptions {
    public let headers: ArrayList<String> = ArrayList()
    public let clangArgs: ArrayList<String> = ArrayList()
    
    public var packageName: String = "cjbind_ffi"
    public var noEnumPrefix = false 
    public var noDetectIncludePath = false
    public var builtins = false
    public var noComment = false
    public var makeFuncWrapper = false
    public var funcWrapperSuffix = "_cjbindwrapper"
    public var autoCString = false
    public var arrayPointersInArgs = false
    public var makeCjString = false

    public init() {}

    public init(headers: Collection<String>, clang_args: Collection<String>) {
        this.headers.add(all: headers)
        this.clangArgs.add(all: clang_args)
    }
}
