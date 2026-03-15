package cjbind.options

import std.collection.*

public enum ObjcCodegenMode <: Equatable<ObjcCodegenMode> {
    | Runtime
    | Compiler

    public operator func ==(rhs: ObjcCodegenMode): Bool {
        match ((this, rhs)) {
            case (Runtime, Runtime) | (Compiler, Compiler) => true
            case _ => false
        }
    }
}

public enum DefaultEnumStyle <: Equatable<DefaultEnumStyle> {
    | Consts
    | NewType

    public operator func ==(rhs: DefaultEnumStyle): Bool {
        match ((this, rhs)) {
            case (Consts, Consts) | (NewType, NewType) => true
            case _ => false
        }
    }
}

public class CjbindOptions {
    public let headers: ArrayList<String> = ArrayList()
    public let clangArgs: ArrayList<String> = ArrayList()
    
    public var packageName: String = "cjbind_ffi"
    public var noEnumPrefix = false 
    public var noDetectIncludePath = false
    public var noLayoutTests = false
    public var builtins = false
    public var noComment = false
    public var makeFuncWrapper = false
    public var funcWrapperSuffix = "_cjbindwrapper"
    public var autoCString = false
    public var arrayPointersInArgs = false
    public var makeCjString = false
    public var objc = false
    public var objcCodegenMode: ObjcCodegenMode = ObjcCodegenMode.Runtime
    public var objcGenerateDefinitions = false
    public var defaultEnumStyle: DefaultEnumStyle = DefaultEnumStyle.Consts
    public var fitMacroConstants = false

    public init() {}

    public init(headers: Collection<String>, clang_args: Collection<String>) {
        this.headers.add(all: headers)
        this.clangArgs.add(all: clang_args)
    }
}
