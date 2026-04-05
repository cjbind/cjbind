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
    public var noEnumPrefix: Bool = false
    public var noDetectIncludePath: Bool = false
    public var noLayoutTests: Bool = false
    public var builtins: Bool = false
    public var noComment: Bool = false
    public var makeFuncWrapper: Bool = false
    public var funcWrapperSuffix: String = "_cjbindwrapper"
    public var autoCString: Bool = false
    public var arrayPointersInArgs: Bool = false
    public var makeCjString: Bool = false
    public var objc: Bool = false
    public var objcCodegenMode: ObjcCodegenMode = ObjcCodegenMode.Runtime
    public var objcGenerateDefinitions: Bool = false
    public var defaultEnumStyle: DefaultEnumStyle = DefaultEnumStyle.Consts
    public var fitMacroConstants: Bool = false

    public init() {}

    public init(headers: Collection<String>, clang_args: Collection<String>) {
        this.headers.add(all: headers)
        this.clangArgs.add(all: clang_args)
    }
}
