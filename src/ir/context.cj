package cjbind.ir

import std.collection.*

import cjbind.clang
import cjbind.options.CjbindOptions

public type ItemId = UIntNative

public type TypeId = ItemId
public type ModuleId = ItemId

public enum TypeKey <: Hashable & Equatable<TypeKey> {
    Usr(String) |
    Declaration(clang.Cursor)

    public func hashCode(): Int64 {
        match (this) {
            case Usr(v) => v.hashCode()
            case Declaration(v) => v.hashCode()
        }
    }

    public operator func ==(that: TypeKey): Bool {
        match ((this, that)) {
            case (Usr(v1), Usr(v2)) => v1 == v2
            case (Declaration(v1), Declaration(v2)) => v1 == v2
            case _ => false
        }
    }
}

public class PartialType {
    public let decl: clang.Cursor
    public let id: ItemId

    init(id: ItemId, decl: clang.Cursor) {
        this.id = id
        this.decl = decl
    }
}

public class CjbindContext {
    public let items: ArrayList<?Item>
    public let types: HashMap<TypeKey, TypeId> = HashMap()
    public let modules: HashMap<clang.Cursor, ModuleId> = HashMap()

    public let rootModule: ModuleId
    public var currentModule: ModuleId

    public let semanticParents: HashMap<clang.Cursor, ItemId> = HashMap()

    public let currentlyParsedTypes: ArrayList<PartialType> = ArrayList()

    public let includes: HashMap<String, (String, UIntNative)> = HashMap()
    public let deps: HashSet<String>

    public var collectedTyperefs: Bool = false
    public var inCodegen: Bool = false

    public let translationUnit: clang.TranslationUnit
    public let targetInfo: clang.TargetInfo

    public let codegenItems: Option<ItemSet> = None

    public var needBitfieldAllocation: ArrayList<ItemId> = ArrayList()

    public var enumTypedefCombos: ?HashSet<ItemId> = None

    public init(options: CjbindOptions) {
        let index = clang.Index(false, true)


        this.translationUnit = clang.TranslationUnit(
            index,
            "",
            options.clangArgs.toArray(),
            clang.CXTranslationUnit_DetailedPreprocessingRecord
        )

        this.targetInfo = clang.TargetInfo(translationUnit)
        let rootModuleItem = Item(
            0,
            None,
            0,
            KindModule(Module("root")),
            None
        )

        this.items = ArrayList<?Item>([rootModuleItem])
        this.deps = HashSet(options.headers)
        this.rootModule = 0
        this.currentModule = 0
    }

    public func withModule(module_id: ModuleId, cb: (CjbindContext) -> Unit): Unit {
        let prev_module = this.currentModule
        this.currentModule = module_id

        cb(this)

        this.currentModule = prev_module
    }

    public func nextItemId(): ItemId {
        let ret = UIntNative(this.items.size)
        this.items.add(None)
        return ret
    }
}