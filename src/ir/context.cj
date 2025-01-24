package cjbind.ir

import std.ast.Tokens
import std.collection.*
import cjbind.result.Result
import cjbind.clang
import cjbind.options.CjbindOptions

public type ItemId = UIntNative

public type TypeId = ItemId

public type ModuleId = ItemId

extend ItemId <: IsOpaque<Unit> & Trace<Tracer, Unit> {
    public func isOpaque(ctx: CjbindContext, _: Unit): Bool {
        return ctx.resolveItem(this).isOpaque(ctx, ())
    }

    // cjlint-ignore -start !G.ITF.04
    public func trace(ctx: CjbindContext, tracer: Tracer, _: Unit): Unit {
        ctx.resolveItem(this).trace(ctx, tracer, ())
    }
    // cjlint-ignore -end
}

public enum TypeKey <: Hashable & Equatable<TypeKey> {
    Usr(String)
    | Declaration(clang.Cursor)

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

public class PartialType <: Equatable<PartialType> {
    public let decl: clang.Cursor
    public let id: ItemId

    init(decl: clang.Cursor, id: ItemId) {
        this.decl = decl
        this.id = id
    }

    public operator func ==(that: PartialType): Bool {
        return decl == that.decl && id == that.id
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

    public var codegenItems: Option<ItemSet> = None

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

    public func addItem(
        item: Item,
        declaration: ?clang.Cursor,
        _: ?clang.Cursor
    ) {
        let id = item.id
        let isType = item.kind.isType()
        let isUnnamed = item.kind.isType() && item.kind.expectType().name.isNone()

        if (item.id != this.rootModule) {
            this.addItemToModule(item)
        }

        if (isType && item.kind.expectType().isComp()) {
            this.needBitfieldAllocation.add(id)
        }

        if (this.items[Int64(id)].isSome()) {
            throw Exception("Item with id ${id} already exists, WTF case")
        }

        this.items[Int64(id)] = item

        if (!isType) {
            return
        }

        if (let Some(decl) <- declaration) {
            let candecl = decl.canonical()
            if (!candecl.isValid()) {
                return
            }

            let key = if (isUnnamed) {
                TypeKey.Declaration(candecl)
            } else if (let Some(usr) <- candecl.usr()) {
                TypeKey.Usr(usr)
            } else {
                TypeKey.Declaration(candecl)
            }

            this.types.add(key, id)
        }
    }

    public func addItemToModule(item: Item) {
        let p = this.items[Int64(item.parentId)]
        if (let Some(pp) <- p) {
            if (let Some(module) <- pp.asModule()) {
                module.children.add(item.id)
                return
            }
        }

        this.items[Int64(this.currentModule)].getOrThrow().asModule().getOrThrow().children.add(item.id)
        return
    }

    public func getResolvedType(decl: clang.CanonicalTypeDeclaration): ?TypeId {
        let ret1 = this.types.get(TypeKey.Declaration(decl.cursor))

        if (let Some(ret) <- ret1) {
            return ret
        }

        let usr = decl.cursor.usr()

        if (let Some(u) <- usr) {
            return this.types.get(TypeKey.Usr(u))
        }

        return None
    }

    public func addBuiltinItem(item: Item) {
        this.addItemToModule(item)
        let id = item.id

        if (items[Int64(id)].isSome()) {
            throw Exception("Inserted type twice?")
        }

        items[Int64(id)] = item
    }

    public func buildWrapper(
        withId: ItemId,
        wrapperId: TypeId,
        parentId: ?ItemId,
        ty: clang.Type,
        isConst: Bool
    ): TypeId {
        let spelling = ty.spelling()
        let layout = ty.fallibleLayout(this).ok()
        let location = ty.declaration().location()
        let typeKind = TypeKind.ResolvedTypeRef(wrapperId)
        let ity = Type(Some(spelling), layout, typeKind, isConst)
        let item = Item(
            withId,
            None,
            parentId.getOrDefault() {=> this.currentModule},
            ItemKind.KindType(ity),
            Some(location)
        )
        this.addBuiltinItem(item)

        return withId
    }

    public func buildTyWrapper(
        withId: ItemId,
        wrapperId: TypeId,
        parentId: ?ItemId,
        ty: clang.Type
    ): TypeId {
        return this.buildWrapper(withId, wrapperId, parentId, ty, ty.isConst())
    }

    // cjlint-ignore -start !G.FUN.01
    public func buildBuiltinTy(ty: clang.Type): ?TypeId {
        let typeKindDef: ?TypeKind = {
            =>
            let k = ty.kind()

            if (k == clang.CXType_NullPtr) {
                return TypeKind.TypeKindNullPtr
            }
            if (k == clang.CXType_Void) {
                return TypeKind.TypeKindVoid
            }
            if (k == clang.CXType_Bool) {
                return TypeKind.TypeKindInt(IntKindBool)
            }
            if (k == clang.CXType_Int) {
                return TypeKind.TypeKindInt(IntKindInt)
            }
            if (k == clang.CXType_UInt) {
                return TypeKind.TypeKindInt(IntKindUInt)
            }
            if (k == clang.CXType_Char_S) {
                return TypeKind.TypeKindInt(IntKindChar(true))
            }
            if (k == clang.CXType_Char_U) {
                return TypeKind.TypeKindInt(IntKindChar(false))
            }
            if (k == clang.CXType_SChar) {
                return TypeKind.TypeKindInt(IntKindSChar)
            }
            if (k == clang.CXType_UChar) {
                return TypeKind.TypeKindInt(IntKindUChar)
            }
            if (k == clang.CXType_Short) {
                return TypeKind.TypeKindInt(IntKindShort)
            }
            if (k == clang.CXType_UShort) {
                return TypeKind.TypeKindInt(IntKindUShort)
            }
            if (k == clang.CXType_WChar) {
                return TypeKind.TypeKindInt(IntKindWChar)
            }
            if (k == clang.CXType_Char16) {
                return TypeKind.TypeKindInt(IntKindU16)
            }
            if (k == clang.CXType_Char32) {
                return TypeKind.TypeKindInt(IntKindU32)
            }
            if (k == clang.CXType_Long) {
                return TypeKind.TypeKindInt(IntKindLong)
            }
            if (k == clang.CXType_ULong) {
                return TypeKind.TypeKindInt(IntKindULong)
            }
            if (k == clang.CXType_LongLong) {
                return TypeKind.TypeKindInt(IntKindLongLong)
            }
            if (k == clang.CXType_ULongLong) {
                return TypeKind.TypeKindInt(IntKindULongLong)
            }
            if (k == clang.CXType_Int128) {
                return TypeKind.TypeKindInt(IntKindI128)
            }
            if (k == clang.CXType_UInt128) {
                return TypeKind.TypeKindInt(IntKindU128)
            }
            if (k == clang.CXType_Float16 || k == clang.CXType_Half) {
                return TypeKind.TypeKindFloat(FloatKindFloat16)
            }
            if (k == clang.CXType_Float) {
                return TypeKind.TypeKindFloat(FloatKindFloat)
            }
            if (k == clang.CXType_Double) {
                return TypeKind.TypeKindFloat(FloatKindDouble)
            }
            if (k == clang.CXType_LongDouble) {
                return TypeKind.TypeKindFloat(FloatKindLongDouble)
            }
            if (k == clang.CXType_Float128) {
                return TypeKind.TypeKindFloat(FloatKindFloat128)
            }
            if (k == clang.CXType_Complex) {
                let ft = ty.elemType().getOrThrow().kind()
                let floatKind = {
                    =>
                    if (ft == clang.CXType_Float16 || ft == clang.CXType_Half) {
                        return FloatKindFloat16
                    }
                    if (ft == clang.CXType_Float) {
                        return FloatKindFloat
                    }
                    if (ft == clang.CXType_Double) {
                        return FloatKindDouble
                    }
                    if (ft == clang.CXType_LongDouble) {
                        return FloatKindLongDouble
                    }
                    if (ft == clang.CXType_Float128) {
                        return FloatKindFloat128
                    }
                    throw Exception("unknown float type ${ft}")
                }()
                return TypeKind.TypeKindComplex(floatKind)
            }
            return None<TypeKind>
        }()
        let typeKind = typeKindDef ?? return None
        let spelling = ty.spelling()
        let isConst = ty.isConst()
        let layout = ty.fallibleLayout(this).ok()
        let location = ty.declaration().location()
        let ity = Type(Some(spelling), layout, typeKind, isConst)

        let nid = this.nextItemId()
        let item = Item(
            nid,
            None,
            this.rootModule,
            ItemKind.KindType(ity),
            Some(location)
        )

        this.addBuiltinItem(item)
        return nid
    }

    // cjlint-ignore -end

    public func builtinOrResolvedTy(
        withId: ItemId,
        parentId: ?ItemId,
        ty: clang.Type,
        location: ?clang.Cursor
    ): ?TypeId {
        if (let Some(decl) <- ty.canonicalDeclaration(location)) {
            if (let Some(tid) <- this.getResolvedType(decl)) {
                return Some(this.buildTyWrapper(withId, tid, parentId, ty))
            }
        }

        return this.buildBuiltinTy(ty)
    }

    public func beginParsing(partialTy: PartialType) {
        this.currentlyParsedTypes.add(partialTy)
    }

    public func finishParsing(): PartialType {
        let ret = this.currentlyParsedTypes.last
        this.currentlyParsedTypes.remove(at: this.currentlyParsedTypes.size - 1)
        match (ret) {
            case Some(v) => return v
            case None => throw Exception("finish parsing without begin")
        }
    }

    public func resolveItemFallible(id: ItemId): ?Item {
        match (this.items.get(Int64(id))) {
            case Some(v) => v
            case None => None
        }
    }

    public func resolveItem(itemId: ItemId): Item {
        this.resolveItemFallible(itemId).getOrThrow()
    }

    public func resolveType(typeId: TypeId): Type {
        this.resolveItem(typeId).kind.expectType()
    }

    public func safeResolveType(typeId: TypeId): ?Type {
        this.resolveItemFallible(typeId).flatMap {
            t => t.kind.expectType()
        }
    }

    public func addSemanticParent(
        def: clang.Cursor,
        parentId: ItemId
    ) {
        this.semanticParents.add(def, parentId)
    }

    public func knownSemanticParent(def: clang.Cursor): ?ItemId {
        return this.semanticParents.get(def)
    }

    public func addDep(dep: String) {
        this.deps.add(dep)
    }

    public func getItems(): Iterator<(ItemId, Item)> {
        this
            .items
            .iterator()
            .enumerate()
            .filterMap {
                v =>
                let idx = v[0]
                let it = v[1]
                let ret: Option<(ItemId, Item)> = match (it) {
                    case Some(v) => (UIntNative(idx), v)
                    case None => None
                }
                ret
            }
    }

    func collectTyperefs(): ArrayList<(ItemId, clang.Type, clang.Cursor, ?ItemId)> {
        if (!this.collectedTyperefs) {
            this.collectedTyperefs = true
        } else {
            throw Exception("already collected")
        }

        let typerefs = ArrayList<(ItemId, clang.Type, clang.Cursor, ?ItemId)>()

        for ((id, item) in this.getItems()) {
            let kind = item.kind
            let ty = match (kind.asType()) {
                case Some(t) => t
                case None => continue
            }

            if (let TypeKind.UnresolvedTypeRef(ty, loc, parentId) <- ty.kind) {
                typerefs.add((id, ty, loc, parentId))
            }
        }

        return typerefs
    }

    func resolveTypeRefs() {
        let typerefs = this.collectTyperefs()

        for ((id, ty, loc, parentId) in typerefs) {
            let resolved = Item
                .fromTy(ty, loc, parentId, this)
                .unwrapOrElse {
                    _ =>
                    eprintln("Could not resolve type reference, falling back to opaque blob")
                    Item.newOpaqueType(this.nextItemId(), ty, this)
                }

            let item = this.items[Int64(id)].getOrThrow()
            item.kind.expectType().kind = TypeKind.ResolvedTypeRef(resolved)
        }
    }

    func withLoanedItem<T>(id: ItemId, f: (CjbindContext, Item) -> T): T {
        let item = this.items[Int64(id)].getOrThrow()
        this.items[Int64(id)] = None

        let result = f(this, item)

        this.items[Int64(id)] = item

        return result
    }

    func computeBitfieldUnits() {
        let tnba = this.needBitfieldAllocation
        this.needBitfieldAllocation = ArrayList()

        for (id in tnba) {
            this.withLoanedItem(id) {
                ctx, item =>
                let ty = item.kind.asType().getOrThrow()
                let layout = ty.getLayout(ctx)
                ty.asComp().getOrThrow().computeBitfieldUnits(ctx, layout)
            }
        }
    }

    func deanonymizeFields() {
        let compItemIds = this
            .getItems()
            .filterMap {
                v =>
                let id = v[0]
                let item = v[1]

                let cond = item.kind.asType()?.isComp()
                let ret: ?ItemId = match (cond) {
                    case Some(v) =>
                        if (v) {
                            return Some(id)
                        } else {
                            return None<ItemId>
                        }
                    case None => None<ItemId>
                }
                return ret
            } |> collectArrayList

        for (id in compItemIds) {
            this.withLoanedItem(id) {
                ctx, item => item.kind.asType().getOrThrow().asComp().getOrThrow().deanonymizeFields(ctx)
            }
        }
    }

    func isStdintType(name: String): Bool {
        match (name) {
            case "int8_t" | "uint8_t" | "int16_t" | "uint16_t" | "int32_t" | "uint32_t" | "int64_t" | "uint64_t" | "uintptr_t" | "intptr_t" | "ptrdiff_t" | "size_t" | "ssize_t" => true
            case _ => false
        }
    }

    func computeCodegenItems() {
        let roots = this.getItems().map {
            it => it[0]
        } |> collectArray
        roots.reverse()

        let found = ItemTraversal(this, roots) |> collectArray
        this.codegenItems = Some(ItemSet(found))
    }

    // cjlint-ignore -start !G.FUN.01
    func computeEnumTypedefCombos() {
        let data = HashSet<ItemId>()

        for (item in this.getItems()) {
            if (let ItemKind.KindModule(module) <- item[1].kind) {
                let namesOfTypedefs = HashSet<String>()

                for (childId in module.children) {
                    if (let Some(ItemKind.KindType(ty)) <- this.items[Int64(childId)].flatMap {it => it.kind}) {
                        if (let (Some(name), TypeKind.TypeKindAlias(typeId)) <- (ty.name, ty.kind)) {
                            if (typeId
                                .intoResolver()
                                .throughTypeRefs()
                                .throughTypeAliases()
                                .resolve(this)
                                .kind
                                .expectType()
                                .isInt()) {
                                namesOfTypedefs.add(name)
                            }
                        }
                    }
                }

                for (childId in module.children) {
                    if (let Some(ItemKind.KindType(ty)) <- this.items[Int64(childId)].flatMap {it => it.kind}) {
                        if (let (Some(name), true) <- (ty.name, ty.isEnum())) {
                            if (namesOfTypedefs.contains(name)) {
                                data.add(childId)
                            }
                        }
                    }
                }
            }
        }

        this.enumTypedefCombos = Some(data)
    }
    // cjlint-ignore -end

    public func gen<E>(cb: (CjbindContext) -> Result<(Tokens, CjbindOptions), E>): Result<(Tokens, CjbindOptions), E> {
        this.inCodegen = true

        this.resolveTypeRefs()
        this.computeBitfieldUnits()
        this.deanonymizeFields()

        this.computeCodegenItems()

        this.computeEnumTypedefCombos()

        return cb(this)
    }
}

public class ItemResolver {
    let idVal: ItemId
    var throughTypeRefsVal: Bool = false
    var throughTypeAliasesVal: Bool = false

    public init(id: ItemId) {
        this.idVal = id
    }

    public func throughTypeRefs(): ItemResolver {
        this.throughTypeRefsVal = true
        return this
    }

    public func throughTypeAliases(): ItemResolver {
        this.throughTypeAliasesVal = true
        return this
    }

    public func resolve(ctx: CjbindContext): Item {
        var id = this.idVal
        var seenIds = HashSet<ItemId>()

        while (true) {
            let item = ctx.resolveItem(id)

            if (!seenIds.add(id)) {
                return item
            }

            let tyKind = item.asType().flatMap {t => t.kind}
            match (tyKind) {
                case Some(TypeKind.ResolvedTypeRef(nextId)) =>
                    if (this.throughTypeRefsVal) {
                        id = nextId
                    }
                case Some(TypeKind.TypeKindAlias(nextId)) =>
                    if (this.throughTypeAliasesVal) {
                        id = nextId
                    }
                case _ => return item
            }
        }

        throw Exception("unreachable")
    }
}

extend ItemId {
    func intoResolver(): ItemResolver {
        return ItemResolver(this)
    }
}
