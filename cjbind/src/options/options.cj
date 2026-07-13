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

/// Information passed to `fieldNameCallback` when a named struct or union
/// field is about to be emitted.
public class FieldInfo {
    public let typeName: String
    public let fieldName: String
    public let fieldTypeName: ?String

    public init(typeName: String, fieldName: String, fieldTypeName: ?String) {
        this.typeName = typeName
        this.fieldName = fieldName
        this.fieldTypeName = fieldTypeName
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
    public var useUnionAccessorWorkaround: Bool = true
    public var enableCxxNamespaces: Bool = false
    public var conservativeInlineNamespaces: Bool = false
    public var generateFunctions: Bool = true
    public var generateTypes: Bool = true
    public var generateVars: Bool = true
    public var generateMethods: Bool = true
    public var generateConstructors: Bool = true
    public var generateDestructors: Bool = true
    public var representCxxOperators: Bool = false
    public var respectCxxAccessSpecs: Bool = false
    public var useSpecificVirtualFunctionReceiver: Bool = false
    public var useDistinctChar16T: Bool = false
    public var generateInlineFunctions: Bool = false
    public var generateDeletedFunctions: Bool = false
    public var generatePureVirtualFunctions: Bool = false
    public var generatePrivateFunctions: Bool = false
    public var vtableGeneration: Bool = false
    /// Allows library users to rename named struct, union, and bitfield fields.
    /// Returning `None` keeps the original C field name.
    public var fieldNameCallback: ?((FieldInfo) -> ?String) = None

    public init() {}

    public init(headers: Collection<String>, clang_args: Collection<String>) {
        this.headers.add(all: headers)
        this.clangArgs.add(all: clang_args)
    }
}
