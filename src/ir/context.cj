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

    public let root_module: ModuleId
    public var current_module: ModuleId

    public let semantic_parents: HashMap<clang.Cursor, ItemId> = HashMap()

    public let currently_parsed_types: ArrayList<PartialType> = ArrayList()

    public let includes: HashMap<String, (String, UIntNative)> = HashMap()
    public let deps: HashSet<String>

    public var collected_typerefs: Bool = false
    public var in_codegen: Bool = false

    public let translation_unit: clang.TranslationUnit
    public let target_info: clang.TargetInfo

    public let codegen_items: Option<ItemSet> = None

    public var need_bitfield_allocation: ArrayList<ItemId> = ArrayList()

    public var enum_typedef_combos: ?HashSet<ItemId> = None

    public init(options: CjbindOptions) {
        let index = clang.Index(false, true)

        let parse_options = clang.CXTranslationUnit_DetailedPreprocessingRecord

        let translation_unit = clang.TranslationUnit(
            index,
            "",
            options.clang_args.toArray().toArray(),
            parse_options
        )

        let target_info = clang.TargetInfo(translation_unit)
        let root_module = Item(
            0,
            None,
            0,
            KindModule(Module("root")),
            None
        )

        this.items = ArrayList<?Item>([root_module])
        this.deps = HashSet(options.headers)
        this.root_module = 0
        this.current_module = 0
        this.translation_unit = translation_unit
        this.target_info = target_info
    }

    public func with_module(module_id: ModuleId, cb: (CjbindContext) -> Unit): Unit {
        let prev_module = this.current_module
        this.current_module = module_id

        cb(this)

        this.current_module = prev_module
    }
}