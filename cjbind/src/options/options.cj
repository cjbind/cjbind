package cjbind.options

import std.collection.*
import std.regex.{Regex, RegexException}

public class NamePatternSet {
    let patterns: ArrayList<String> = ArrayList()
    let matchedPatterns: HashSet<String> = HashSet()
    var valid: Bool = true

    public init() {}

    public func add(pattern: String): Unit {
        this.patterns.add(pattern)
        if (!this.valid) {
            return
        }
        try {
            let _ = Regex(this.fullMatchPattern(pattern))
        } catch (_: RegexException) {
            this.valid = false
            eprintln("Warning: invalid regular expression '${pattern}'; this pattern set will not match any item")
        }
    }

    public func add(all: Collection<String>): Unit {
        for (pattern in all) {
            this.add(pattern)
        }
    }

    public func matches(name: String): Bool {
        if (!this.valid) {
            return false
        }
        var found = false
        for (pattern in this.patterns) {
            if (Regex(this.fullMatchPattern(pattern)).matches(name)) {
                this.matchedPatterns.add(pattern)
                found = true
            }
        }
        return found
    }

    func fullMatchPattern(pattern: String): String {
        return "^(${pattern})$"
    }

    public prop size: Int64 {
        get() { this.patterns.size }
    }

    public prop isEmpty: Bool {
        get() { this.patterns.isEmpty() }
    }

    public func toArray(): Array<String> {
        return this.patterns.toArray()
    }

    public func unmatchedPatterns(): Array<String> {
        let unmatched = ArrayList<String>()
        for (pattern in this.patterns) {
            if (!this.matchedPatterns.contains(pattern)) {
                unmatched.add(pattern)
            }
        }
        return unmatched.toArray()
    }
}

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

/// Controls how C/C++ typedefs and type aliases are represented in Cangjie.
public enum DefaultAliasStyle <: Equatable<DefaultAliasStyle> {
    /// Preserve the source alias as a Cangjie `type` alias.
    | TypeAlias
    /// Generate a distinct, single-field `@C struct`.
    | NewType
    /// Generate a newtype plus explicit `wrap` and `unwrap` helpers.
    | NewTypeDeref

    public operator func ==(rhs: DefaultAliasStyle): Bool {
        match ((this, rhs)) {
            case (TypeAlias, TypeAlias) | (NewType, NewType) |
                (NewTypeDeref, NewTypeDeref) => true
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
    /// Generate externally visible C/C++ bridge functions for functions with
    /// internal linkage (`static` and `static inline`).
    public var wrapStaticFns: Bool = false
    /// Suffix appended to the exported bridge symbol.
    public var wrapStaticFnsSuffix: String = "__extern"
    /// Base output path for the bridge source. cjbind replaces any extension
    /// with `.c` or `.cpp` according to the parsed language.
    public var wrapStaticFnsPath: ?String = None
    public var autoCString: Bool = false
    public var arrayPointersInArgs: Bool = false
    public var makeCjString: Bool = false
    public var objc: Bool = false
    public var objcCodegenMode: ObjcCodegenMode = ObjcCodegenMode.Runtime
    public var objcGenerateDefinitions: Bool = false
    public var defaultEnumStyle: DefaultEnumStyle = DefaultEnumStyle.Consts
    public var defaultAliasStyle: DefaultAliasStyle = DefaultAliasStyle.TypeAlias
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
    public var generateInlineFunctions: Bool = false
    public var generateDeletedFunctions: Bool = false
    public var generatePureVirtualFunctions: Bool = false
    public var generatePrivateFunctions: Bool = false
    public var vtableGeneration: Bool = false
    public var allowlistRecursively: Bool = true
    public var recordMatches: Bool = true
    public var untaggedUnion: Bool = true
    public var sizeTIsUsize: Bool = true
    public let blocklistedTypes: NamePatternSet = NamePatternSet()
    public let blocklistedFunctions: NamePatternSet = NamePatternSet()
    public let blocklistedItems: NamePatternSet = NamePatternSet()
    public let blocklistedVars: NamePatternSet = NamePatternSet()
    public let blocklistedFiles: NamePatternSet = NamePatternSet()
    public let opaqueTypes: NamePatternSet = NamePatternSet()
    public let allowlistedTypes: NamePatternSet = NamePatternSet()
    public let allowlistedFunctions: NamePatternSet = NamePatternSet()
    public let allowlistedItems: NamePatternSet = NamePatternSet()
    public let allowlistedVars: NamePatternSet = NamePatternSet()
    public let allowlistedFiles: NamePatternSet = NamePatternSet()
    /// Alias names matching these patterns always use ordinary Cangjie aliases.
    public let typeAliases: NamePatternSet = NamePatternSet()
    /// Alias names matching these patterns are generated as strong newtypes.
    public let newTypeAliases: NamePatternSet = NamePatternSet()
    /// Alias names matching these patterns are generated as newtypes with
    /// explicit wrapping and unwrapping helpers.
    public let newTypeDerefAliases: NamePatternSet = NamePatternSet()
    /// Allows library users to rename named struct, union, and bitfield fields.
    /// Returning `None` keeps the original C field name.
    public var fieldNameCallback: ?((FieldInfo) -> ?String) = None

    public init() {}

    public init(headers: Collection<String>, clang_args: Collection<String>) {
        this.headers.add(all: headers)
        this.clangArgs.add(all: clang_args)
    }

    /// Resolve an alias style using the same first-match precedence as
    /// rust-bindgen: ordinary alias, newtype, newtype-with-accessors, default.
    public func aliasStyle(name: String): DefaultAliasStyle {
        if (this.typeAliases.matches(name)) {
            return DefaultAliasStyle.TypeAlias
        }
        if (this.newTypeAliases.matches(name)) {
            return DefaultAliasStyle.NewType
        }
        if (this.newTypeDerefAliases.matches(name)) {
            return DefaultAliasStyle.NewTypeDeref
        }
        return this.defaultAliasStyle
    }
}
