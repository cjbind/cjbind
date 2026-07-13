package cjbind.ir

import std.collection.{ArrayList, HashSet, collectArrayList}
import cjbind.clang
import cjbind.options.FieldInfo
import cjbind.result.Result

public enum CompKind {
    CompKindStruct
    | CompKindUnion
}

public enum MethodKind {
    Constructor
    | Destructor
    | VirtualDestructor(Bool)
    | Static
    | Normal
    | Virtual(Bool)

    public func isDestructor(): Bool {
        return match (this) {
            case Destructor | VirtualDestructor(_) => true
            case _ => false
        }
    }

    public func isVirtual(): Bool {
        return match (this) {
            case Virtual(_) | VirtualDestructor(_) => true
            case _ => false
        }
    }

    public func isPureVirtual(): Bool {
        return match (this) {
            case Virtual(pure) => pure
            case VirtualDestructor(pure) => pure
            case _ => false
        }
    }
}

public class Method {
    public let kind: MethodKind
    public let signature: ItemId
    public let isConst: Bool

    public init(kind: MethodKind, signature: ItemId, isConst: Bool) {
        this.kind = kind
        this.signature = signature
        this.isConst = isConst
    }

    public func isStatic(): Bool {
        return match (this.kind) {
            case MethodKind.Static => true
            case _ => false
        }
    }
}

public enum BaseKind {
    Normal
    | Virtual
}

public class Base {
    public let ty: TypeId
    public let kind: BaseKind
    public let fieldName: String
    public let isPublic: Bool

    public init(ty: TypeId, kind: BaseKind, fieldName: String, isPublic: Bool) {
        this.ty = ty
        this.kind = kind
        this.fieldName = fieldName
        this.isPublic = isPublic
    }

    public func isVirtual(): Bool {
        return match (this.kind) {
            case BaseKind.Virtual => true
            case BaseKind.Normal => false
        }
    }

    public func requiresStorage(ctx: CjbindContext): Bool {
        if (this.isVirtual()) {
            return false
        }

        let baseItem = this.ty.intoResolver().throughTypeRefs().throughTypeAliases().resolve(ctx)
        if (let Some(baseType) <- baseItem.kind.asType()) {
            if (let Some(baseComp) <- baseType.asComp()) {
                if (baseComp.isEmptyBase(ctx, HashSet<ItemId>())) {
                    return false
                }
            }
        }
        return true
    }
}

func baseHasVtable(base: Base, ctx: CjbindContext, visiting: HashSet<ItemId>): Bool {
    let baseItem = base.ty.intoResolver().throughTypeRefs().throughTypeAliases().resolve(ctx)
    if (visiting.contains(baseItem.id)) {
        return false
    }
    visiting.add(baseItem.id)

    if (let Some(baseType) <- baseItem.kind.asType()) {
        if (let Some(baseComp) <- baseType.asComp()) {
            return baseComp.hasVtableInner(ctx, visiting)
        }
    }
    return false
}

public class CompInfo <: IsOpaque<Option<Layout>> & Trace<Tracer, Item> {
    public let kind: CompKind
    public let isCxxRecord: Bool
    public var fields: CompFields = CompFieldsBefore(ArrayList())
    public let innerTypes: ArrayList<TypeId> = ArrayList()
    public let templateParams: ArrayList<TypeId> = ArrayList()
    public let innerVars: ArrayList<ItemId> = ArrayList()
    public let methods: ArrayList<Method> = ArrayList()
    public let constructors: ArrayList<ItemId> = ArrayList()
    public var destructor: ?(MethodKind, ItemId) = None
    public let baseMembers: ArrayList<Base> = ArrayList()

    public var isForwardDeclaration: Bool = false
    public var packedAttr: Bool = false
    public var hasUnevaluableBitFieldWidth: Bool = false
    public var foundUnknownAttr: Bool = false
    public var hasOwnVirtualMethod: Bool = false
    public var hasDestructor: Bool = false
    public var hasNonTypeTemplateParams: Bool = false
    public var hasTemplateTypeParams: Bool = false
    public var hasUnrepresentedVirtualMethod: Bool = false

    public init(kind: CompKind, isCxxRecord!: Bool = false) {
        this.kind = kind
        this.isCxxRecord = isCxxRecord
    }

    public func isUnion(): Bool {
        match (kind) {
            case CompKindUnion => true
            case _ => false
        }
    }

    public static func kindFromCursor(cursor: clang.Cursor): Result<CompKind, ParseError> {
        let k = cursor.kind()

        if (k == clang.CXCursorKind_CXCursor_UnionDecl) {
            return Result.Ok(CompKind.CompKindUnion)
        }
        if (k == clang.CXCursorKind_CXCursor_StructDecl) {
            return Result.Ok(CompKind.CompKindStruct)
        }
        if (k == clang.CXCursorKind_CXCursor_ClassDecl) {
            return Result.Ok(CompKind.CompKindStruct)
        }
        if (k == clang.CXCursorKind_CXCursor_CXXBaseSpecifier ||
            k == clang.CXCursorKind_CXCursor_ClassTemplate ||
            k == clang.CXCursorKind_CXCursor_ClassTemplatePartialSpecialization) {
            if (cursor.templateKind() == clang.CXCursorKind_CXCursor_UnionDecl) {
                return Result.Ok(CompKind.CompKindUnion)
            }
            return Result.Ok(CompKind.CompKindStruct)
        }

        return Result.Err(ParseError.Continue)
    }

    // cjlint-ignore -start !G.FUN.01
    public static func fromTy(
        potentialId: ItemId,
        ty: clang.Type,
        location: ?clang.Cursor,
        ctx: CjbindContext
    ): Result<CompInfo, ParseError> {
        let cursor = Box(ty.declaration())
        var kindr = CompInfo.kindFromCursor(cursor.value)
        if (kindr.isErr()) {
            if (let Some(loc) <- location) {
                kindr = CompInfo.kindFromCursor(loc)
                cursor.value = loc
            }
        }

        let kind = match (kindr) {
            case Ok(v) => v
            case Err(e) => return Err(e)
        }

        let ci = CompInfo(
            kind,
            isCxxRecord: cursor.value.language() == clang.CXLanguageKind_CXLanguage_CPlusPlus
        )
        ci.isForwardDeclaration = location
            .flatMap {
                cur =>
                let k = cur.kind()
                if (k == clang.CXCursorKind_CXCursor_ParmDecl) {
                    return true
                }
                if (k == clang.CXCursorKind_CXCursor_StructDecl || k == clang.CXCursorKind_CXCursor_UnionDecl ||
                    k == clang.CXCursorKind_CXCursor_ClassDecl) {
                    return !cur.isDefinition()
                }
                return false
            }
            .getOrDefault({=> true})

        let maybeAnonymousStructField: Box<?(TypeId, clang.Type, ?UIntNative)> = Box(None)
        cursor
            .value
            .visit {
                cur =>
                let k = cur.kind()
                if (k != clang.CXCursorKind_CXCursor_FieldDecl) {
                    if (let Some((ty, clangTy, offset)) <- maybeAnonymousStructField.value) {
                        if (k == clang.CXCursorKind_CXCursor_TypedefDecl && cur.typedefType().getOrThrow().canonicalType() ==
                            clangTy) {
                            // Typedefs of anonymous structs appear later in the ast
                            // than the struct itself, that would otherwise be an
                            // anonymous field. Detect that case here, and do nothing.
                            maybeAnonymousStructField.value = None
                        } else {
                            let field = RawField(None, ty, None, None, offset)
                            maybeAnonymousStructField.value = None
                            ci.fields.appendRawField(field)
                        }
                    }
                }

                if (k == clang.CXCursorKind_CXCursor_FieldDecl) {
                    if (let Some((ty, clangTy, offset)) <- maybeAnonymousStructField.value) {
                        let used: Box<Bool> = Box(false)
                        cur.visit {
                            child =>
                            if (child.curType() == clangTy) {
                                used.value = true
                            }
                            return clang.CXChildVisitResult_CXChildVisit_Continue
                        }

                        if (!used.value) {
                            let field = RawField(None, ty, None, None, offset)
                            ci.fields.appendRawField(field)
                        }
                        maybeAnonymousStructField.value = None
                    }

                    let bitWidth: ?UInt32 = if (cur.isBitField()) {
                        let width = cur.bitWidth()

                        if (width.isNone()) {
                            ci.hasUnevaluableBitFieldWidth = true
                            return clang.CXChildVisitResult_CXChildVisit_Break
                        }

                        width
                    } else {
                        None
                    }

                    let fieldType = Item.fromTyOrRef(
                        cur.curType(),
                        cur,
                        potentialId,
                        ctx
                    )

                    let comment = cur.rawComment()
                    let spell = cur.spelling()
                    let offset = cur.offsetOfField().ok()

                    let name: ?String = if (spell.isEmpty()) {
                        None
                    } else {
                        Some(spell)
                    }

                    let field = RawField(
                        name,
                        fieldType,
                        comment,
                        bitWidth,
                        offset,
                        isPublic: cur.isPublic()
                    )
                    ci.fields.appendRawField(field)

                    cur.visit {
                        cur =>
                        if (cur.kind() == clang.CXCursorKind_CXCursor_UnexposedAttr) {
                            ci.foundUnknownAttr = true
                        }
                        return clang.CXChildVisitResult_CXChildVisit_Continue
                    }
                } else if (k == clang.CXCursorKind_CXCursor_UnexposedAttr) {
                    ci.foundUnknownAttr = true
                } else if (k == clang.CXCursorKind_CXCursor_EnumDecl ||
                    k == clang.CXCursorKind_CXCursor_TypedefDecl ||
                    k == clang.CXCursorKind_CXCursor_TypeAliasDecl ||
                    k == clang.CXCursorKind_CXCursor_TypeAliasTemplateDecl ||
                    k == clang.CXCursorKind_CXCursor_StructDecl ||
                    k == clang.CXCursorKind_CXCursor_UnionDecl ||
                    k == clang.CXCursorKind_CXCursor_ClassDecl ||
                    k == clang.CXCursorKind_CXCursor_ClassTemplate) {
                    if (ctx.options.respectCxxAccessSpecs && !cur.isPublic()) {
                        return clang.CXChildVisitResult_CXChildVisit_Continue
                    }
                    let isInnerStruct: Bool = cur.semanticParent() == cursor.value || cur.isDefinition()
                    if (!isInnerStruct) {
                        return clang.CXChildVisitResult_CXChildVisit_Continue
                    }

                    let inner = Item.parse(cur, Some(potentialId), ctx).expect("Inner ClassDecl")

                    if (ctx.resolveItemFallible(inner).isSome()) {
                        ci.innerTypes.add(inner)

                        if (cur.isAnonymous() && cur.kind() != clang.CXCursorKind_CXCursor_EnumDecl) {
                            let ty = cur.curType()
                            let offset = cur.offsetOfField().ok()
                            maybeAnonymousStructField.value = Some((inner, ty, offset))
                        }
                    }
                } else if (k == clang.CXCursorKind_CXCursor_PackedAttr) {
                    ci.packedAttr = true
                } else if (k == clang.CXCursorKind_CXCursor_TemplateTypeParameter) {
                    ci.hasTemplateTypeParams = true
                    if (let Some(param) <- Item.typeParam(None, cur, ctx)) {
                        ci.templateParams.add(param)
                    }
                } else if (k == clang.CXCursorKind_CXCursor_NonTypeTemplateParameter) {
                    ci.hasNonTypeTemplateParams = true
                } else if (k == clang.CXCursorKind_CXCursor_CXXBaseSpecifier) {
                    let isVirtual = cur.isVirtualBase()
                    ci.hasOwnVirtualMethod ||= isVirtual
                    let baseKind = if (isVirtual) { BaseKind.Virtual } else { BaseKind.Normal }
                    let fieldName = if (ci.baseMembers.isEmpty()) {
                        "_base"
                    } else {
                        "_base_${ci.baseMembers.size}"
                    }
                    let baseType = Item.fromTyOrRef(cur.curType(), cur, Some(potentialId), ctx)
                    ci.baseMembers.add(Base(baseType, baseKind, fieldName, cur.isPublic()))
                } else if (k == clang.CXCursorKind_CXCursor_Constructor ||
                    k == clang.CXCursorKind_CXCursor_Destructor ||
                    k == clang.CXCursorKind_CXCursor_CXXMethod) {
                    let isVirtual = cur.methodIsVirtual()
                    let isStatic = cur.methodIsStatic()
                    ci.hasDestructor ||= k == clang.CXCursorKind_CXCursor_Destructor
                    ci.hasOwnVirtualMethod ||= isVirtual

                    if (ci.hasTemplateTypeParams || ci.hasNonTypeTemplateParams) {
                        ci.hasUnrepresentedVirtualMethod ||= isVirtual
                        return clang.CXChildVisitResult_CXChildVisit_Continue
                    }

                    let signature = match (Item.parse(cur, Some(potentialId), ctx)) {
                        case Ok(itemId) =>
                            if (!ctx.resolveItem(itemId).kind.isFunction()) {
                                ci.hasUnrepresentedVirtualMethod ||= isVirtual
                                return clang.CXChildVisitResult_CXChildVisit_Continue
                            }
                            itemId
                        case _ =>
                            ci.hasUnrepresentedVirtualMethod ||= isVirtual
                            return clang.CXChildVisitResult_CXChildVisit_Continue
                    }

                    if (k == clang.CXCursorKind_CXCursor_Constructor) {
                        ci.constructors.add(signature)
                    } else if (k == clang.CXCursorKind_CXCursor_Destructor) {
                        let methodKind = if (isVirtual) {
                            MethodKind.VirtualDestructor(cur.methodIsPureVirtual())
                        } else {
                            MethodKind.Destructor
                        }
                        ci.destructor = Some((methodKind, signature))
                    } else {
                        let methodKind = if (isStatic) {
                            MethodKind.Static
                        } else if (isVirtual) {
                            MethodKind.Virtual(cur.methodIsPureVirtual())
                        } else {
                            MethodKind.Normal
                        }
                        ci.methods.add(Method(methodKind, signature, cur.methodIsConst()))
                    }
                } else if (k == clang.CXCursorKind_CXCursor_VarDecl) {
                    if (cur.visibility() == clang.CXVisibilityKind_CXVisibility_Default &&
                        (!ctx.options.respectCxxAccessSpecs || cur.isPublic())) {
                        if (let Ok(varId) <- Item.parse(cur, Some(potentialId), ctx)) {
                            ci.innerVars.add(varId)
                        }
                    }
                } else {
                    ()
                }

                return clang.CXChildVisitResult_CXChildVisit_Continue
            }

        if (let Some((ty, _, offset)) <- maybeAnonymousStructField.value) {
            let tf = RawField(None, ty, None, None, offset)
            maybeAnonymousStructField.value = None
            ci.fields.appendRawField(tf)
        }

        Result.Ok(ci)
    }
    // cjlint-ignore -end

    public func hasFields(): Bool {
        match (this.fields) {
            case CompFields.CompFieldsError => false
            case CompFields.CompFieldsAfter(v) => !v.fields.isEmpty()
            case CompFields.CompFieldsBefore(v) => !v.isEmpty()
        }
    }

    public func hasVtable(ctx: CjbindContext): Bool {
        return this.hasVtableInner(ctx, HashSet<ItemId>())
    }

    public func hasVtablePointer(ctx: CjbindContext): Bool {
        if (!this.hasOwnVirtualMethod) {
            return false
        }
        for (base in this.baseMembers) {
            if (baseHasVtable(base, ctx, HashSet<ItemId>())) {
                return false
            }
        }
        return true
    }

    func hasVtableInner(ctx: CjbindContext, visiting: HashSet<ItemId>): Bool {
        if (this.hasOwnVirtualMethod) {
            return true
        }
        for (base in this.baseMembers) {
            if (baseHasVtable(base, ctx, visiting)) {
                return true
            }
        }
        return false
    }

    func isEmptyBase(ctx: CjbindContext, visiting: HashSet<ItemId>): Bool {
        if (this.hasFields() || this.hasVtableInner(ctx, visiting)) {
            return false
        }
        for (base in this.baseMembers) {
            if (base.requiresStorage(ctx)) {
                return false
            }
        }
        return true
    }

    public func getFields(): Array<Field> {
        return match (fields) {
            case CompFields.CompFieldsError => Array()
            case CompFields.CompFieldsBefore(_) => throw Exception("getFields called before computed")
            case CompFields.CompFieldsAfter(v) => v.fields
        }
    }

    public func eachKnownFieldLayout(
        ctx: CjbindContext,
        cb: (Layout) -> Unit
    ): Unit {
        match (this.fields) {
            case CompFields.CompFieldsError => ()
            case CompFields.CompFieldsAfter(v) => for (field in v.fields) {
                if (let Some(layout) <- field.getLayout(ctx)) {
                    cb(layout)
                }
            }
            case CompFields.CompFieldsBefore(rawFields) => for (field in rawFields) {
                let fieldTy = ctx.resolveType(field.ty)
                if (let Some(layout) <- fieldTy.getLayout(ctx)) {
                    cb(layout)
                }
            }
        }
    }

    // Struct layout is provided by the Type.layout field populated from libclang, not recomputed here.
    // This returns None intentionally for CompKindStruct.
    public func getLayout(ctx: CjbindContext): ?Layout {
        match (this.kind) {
            case CompKindStruct => return None
            case _ => ()
        }

        if (this.isForwardDeclaration) {
            return None
        }

        if (!this.hasFields()) {
            return None
        }

        let maxSize = Box(Int32(0))
        let maxAlign = Box(Int32(1))

        this.eachKnownFieldLayout(ctx) {
            layout =>
            maxSize.value = max(maxSize.value, layout.size)
            maxAlign.value = max(maxAlign.value, layout.align)
        }

        return Some(Layout(maxSize.value, maxAlign.value))
    }

    public func isPacked(
        ctx: CjbindContext,
        layout: ?Layout
    ): Bool {
        if (this.packedAttr) {
            return true
        }

        if (let Some(parentLayout) <- layout) {
            let packed = Box(false)
            this.eachKnownFieldLayout(ctx) {
                layout => packed.value = packed.value || layout.align > parentLayout.align
            }

            if (packed.value) {
                return true
            }
        }

        return false
    }

    public func computeBitfieldUnits(
        ctx: CjbindContext,
        layout: ?Layout
    ): Unit {
        let packed = this.isPacked(ctx, layout)
        this.fields = this.fields.computeBitfieldUnits(ctx, packed)
    }

    public func assignFieldNames(ctx: CjbindContext, canonicalTypeName: String): Unit {
        this.fields.assignFieldNames(ctx, canonicalTypeName)
    }

    public func isOpaque(ctx: CjbindContext, layout: Option<Layout>): Bool {
        if (this.hasUnevaluableBitFieldWidth) {
            return true
        }

        if (let CompFields.CompFieldsError <- this.fields) {
            return true
        }

        let fieldsCond = this
            .getFields()
            .iterator()
            .any {
                f => match (f) {
                    case Field.DataMember(_) => false
                    case Field.Bitfields(unit) => unit
                        .bitfields
                        .iterator()
                        .any {
                            bf =>
                            let maybeLayout = ctx.resolveType(bf.data.ty).getLayout(ctx)
                            if (maybeLayout.isNone()) {
                                return true
                            }
                            let bfLayout = maybeLayout.getOrThrow()
                            return bf.data.bitfieldWidth.getOrThrow() > UInt32(bfLayout.size) * 8
                        }
                }
            }
        if (fieldsCond) {
            return true
        }

        if (this.isPacked(ctx, layout)) {
            return true
        }

        if (this.isCxxRecord && !this.isUnion()) {
            let hasBitfields = this.getFields().iterator().any {
                field => match (field) {
                    case Field.Bitfields(_) => true
                    case _ => false
                }
            }
            let complexLayout = !this.baseMembers.isEmpty() || this.hasVtablePointer(ctx)
            if (hasBitfields && complexLayout) {
                return true
            }
            if (!hasBitfields) {
                if (let Some(expected) <- layout) {
                    if (!this.generatedRecordLayoutMatches(ctx, expected)) {
                        return true
                    }
                }
            }
        }

        return false
    }

    func generatedRecordLayoutMatches(ctx: CjbindContext, expected: Layout): Bool {
        if (let clang.ABIKind.Microsoft <- ctx.targetInfo.abi) {
            if (!this.baseMembers.isEmpty() || this.hasVtableInner(ctx, HashSet<ItemId>())) {
                return false
            }
        }

        for (base in this.baseMembers) {
            if (base.isVirtual()) {
                return false
            }
        }

        var storedBaseCount = 0
        var firstStoredBaseHasVtable = false
        for (base in this.baseMembers) {
            if (!base.requiresStorage(ctx)) {
                continue
            }
            let hasVtable = baseHasVtable(base, ctx, HashSet<ItemId>())
            if (storedBaseCount == 0) {
                firstStoredBaseHasVtable = hasVtable
            } else if (!firstStoredBaseHasVtable && hasVtable) {
                return false
            }
            storedBaseCount += 1
        }

        var size = 0i32
        var alignment = 1i32

        func appendLayout(fieldLayout: Layout): Unit {
            size = alignBytes(size, fieldLayout.align)
            size += fieldLayout.size
            alignment = max(alignment, fieldLayout.align)
        }

        if (this.hasVtablePointer(ctx)) {
            let pointerSize = ctx.pointerWidth()
            appendLayout(Layout(pointerSize, pointerSize))
        }

        for (base in this.baseMembers) {
            if (!base.requiresStorage(ctx)) {
                continue
            }
            let baseLayout = match (ctx.resolveType(base.ty).getLayout(ctx)) {
                case Some(value) => value
                case None => return false
            }
            if (baseLayout.align > ctx.pointerWidth()) {
                return false
            }
            appendLayout(baseLayout)
        }

        for (field in this.getFields()) {
            match (field) {
                case Field.DataMember(data) =>
                    let fieldLayout = match (ctx.resolveType(data.ty).getLayout(ctx)) {
                        case Some(value) => value
                        case None => return false
                    }
                    if (fieldLayout.align > ctx.pointerWidth()) {
                        return false
                    }
                    let fieldOffset = alignBytes(size, fieldLayout.align)
                    if (let Some(actualOffset) <- data.offset) {
                        if (actualOffset != UIntNative(fieldOffset * 8)) {
                            return false
                        }
                    }
                    size = fieldOffset + fieldLayout.size
                    alignment = max(alignment, fieldLayout.align)
                case Field.Bitfields(_) => return false
            }
        }

        if (size == 0 && expected.size > 0) {
            size = 1
        }
        size = alignBytes(size, alignment)
        return size == expected.size && alignment == expected.align
    }

    public func canGenerateTypedVtable(ctx: CjbindContext): Bool {
        if (!this.baseMembers.isEmpty() || this.hasDestructor || this.hasUnrepresentedVirtualMethod) {
            return false
        }
        for (method in this.methods) {
            if (!method.kind.isVirtual()) {
                continue
            }
            let function = match (ctx.resolveItem(method.signature).kind) {
                case ItemKind.KindFunction(value) => value
                case _ => return false
            }
            let signature = match (ctx.resolveType(function.signature).canonicalType(ctx).kind) {
                case TypeKind.TypeKindFunction(value) => value
                case _ => return false
            }
            if (!signature.abi.isCFuncCompatibleForTarget(ctx.targetInfo)) {
                return false
            }
        }
        return true
    }

    public func hasNonPublicMembers(): Bool {
        for (base in this.baseMembers) {
            if (!base.isPublic) {
                return true
            }
        }
        for (field in this.getFields()) {
            match (field) {
                case Field.DataMember(data) =>
                    if (!data.isPublic) {
                        return true
                    }
                case Field.Bitfields(unit) =>
                    for (bitfield in unit.bitfields) {
                        if (!bitfield.data.isPublic) {
                            return true
                        }
                    }
            }
        }
        return false
    }

    // cjlint-ignore -start !G.ITF.04
    public func trace(context: CjbindContext, tracer: Tracer, item: Item): Unit {
        let opaque = item.isOpaque(context, ())
        if (!opaque) {
            this.fields.trace(context, tracer, ())
            for (base in this.baseMembers) {
                tracer.visitKind(base.ty, EdgeKind.BaseMemberEdge)
            }
        }

        for (inner in this.innerTypes) {
            tracer.visitKind(inner, EdgeKind.InnerTypeEdge)
        }
        if (context.options.generateVars) {
            for (innerVar in this.innerVars) {
                tracer.visitKind(innerVar, EdgeKind.InnerVarEdge)
            }
        }
        if (context.options.generateMethods) {
            for (method in this.methods) {
                tracer.visitKind(method.signature, EdgeKind.MethodEdge)
            }
        } else if (context.options.vtableGeneration && this.canGenerateTypedVtable(context)) {
            for (method in this.methods) {
                if (!method.kind.isVirtual()) {
                    continue
                }
                if (let ItemKind.KindFunction(function) <- context.resolveItem(method.signature).kind) {
                    tracer.visit(function.signature)
                }
            }
        }
        if (context.options.generateConstructors) {
            for (constructor in this.constructors) {
                tracer.visitKind(constructor, EdgeKind.ConstructorEdge)
            }
        }
        if (context.options.generateDestructors) {
            if (let Some((_, destructor)) <- this.destructor) {
                tracer.visitKind(destructor, EdgeKind.DestructorEdge)
            }
        }
    }
    // cjlint-ignore -end
}

public open class FieldData {
    public var name: ?String
    public let ty: TypeId
    public let comment: ?String
    public let bitfieldWidth: ?UInt32
    public let offset: ?UIntNative
    public let isPublic: Bool

    public init(
        name: ?String,
        ty: TypeId,
        comment: ?String,
        bitfieldWidth: ?UInt32,
        offset: ?UIntNative,
        isPublic!: Bool = true
    ) {
        this.name = name
        this.ty = ty
        this.comment = comment
        this.bitfieldWidth = bitfieldWidth
        this.offset = offset
        this.isPublic = isPublic
    }
}

public class RawField <: FieldData {
    public init(
        name: ?String,
        ty: TypeId,
        comment: ?String,
        bitfieldWidth: ?UInt32,
        offset: ?UIntNative,
        isPublic!: Bool = true
    ) {
        super(name, ty, comment, bitfieldWidth, offset, isPublic: isPublic)
    }
}

public class Bitfield {
    public let offsetIntoUnit: UIntNative
    public let data: FieldData
    public let getterName: ?String = None
    public let setterName: ?String = None

    public init(
        offsetIntoUnit: UIntNative,
        data: FieldData
    ) {
        this.offsetIntoUnit = offsetIntoUnit
        this.data = data
    }
}

public class BitfieldUnit {
    public let nth: UIntNative
    public let layout: Layout
    public let bitfields: Array<Bitfield>

    public init(
        nth: UIntNative,
        layout: Layout,
        bitfields: Array<Bitfield>
    ) {
        this.nth = nth
        this.layout = layout
        this.bitfields = bitfields
    }
}

public enum Field <: Trace<Tracer, Unit> {
    DataMember(FieldData)
    | Bitfields(BitfieldUnit)

    public func getLayout(ctx: CjbindContext): ?Layout {
        match (this) {
            case DataMember(data) => ctx.resolveType(data.ty).getLayout(ctx)
            case Bitfields(u) => Some(u.layout)
        }
    }
    
    // cjlint-ignore -start !G.ITF.04
    public func trace(_: CjbindContext, tracer: Tracer, _: Unit): Unit {
        match (this) {
            case Field.DataMember(data) =>
                tracer.visitKind(data.ty, EdgeKind.FieldEdge)
            case Field.Bitfields(unit) =>
                for (bf in unit.bitfields) {
                    tracer.visitKind(bf.data.ty, EdgeKind.FieldEdge)
                }
        }
    }
    // cjlint-ignore -end
}

public struct CompFieldsAfterValue {
    public let fields: Array<Field>
    public let hasBitfieldUnits: Bool

    public init(
        fields: Array<Field>,
        hasBitfieldUnits: Bool
    ) {
        this.fields = fields
        this.hasBitfieldUnits = hasBitfieldUnits
    }
}

public enum CompFields <: Trace<Tracer, Unit> {
    CompFieldsBefore(ArrayList<RawField>)
    | CompFieldsAfter(CompFieldsAfterValue)
    | CompFieldsError

    func appendRawField(raw: RawField) {
        match (this) {
            case CompFieldsBefore(raws) => raws.add(raw)
            case _ => throw Exception("fields computed")
        }
    }

    func computeBitfieldUnits(ctx: CjbindContext, packed: Bool): CompFields {
        let raws = match (this) {
            case CompFields.CompFieldsBefore(v) => v
            case _ => throw Exception("fields computed")
        }

        let result = rawFieldsToFieldsAndBitfieldUnits(ctx, raws, packed)

        match (result) {
            case Ok((fields, hasBitfieldUnits)) => return CompFields.CompFieldsAfter(
                CompFieldsAfterValue(fields.toArray(), hasBitfieldUnits))
            case Err(err) => return CompFieldsError
        }
    }

    func assignFieldNames(ctx: CjbindContext, canonicalTypeName: String) {
        let fields = match (this) {
            case CompFields.CompFieldsAfter(v) => v.fields
            case CompFields.CompFieldsError => return
            case CompFields.CompFieldsBefore(_) => throw Exception("fields not computed")
        }

        if (let Some(renameField) <- ctx.options.fieldNameCallback) {
            for (field in fields) {
                match (field) {
                    case Field.DataMember(data) =>
                        if (let Some(originalName) <- data.name) {
                            let info = FieldInfo(
                                canonicalTypeName,
                                originalName,
                                ctx.resolveType(data.ty).name
                            )
                            if (let Some(newName) <- renameField(info)) {
                                data.name = Some(newName)
                            }
                        }
                    case Field.Bitfields(unit) =>
                        for (bitfield in unit.bitfields) {
                            if (let Some(originalName) <- bitfield.data.name) {
                                let info = FieldInfo(
                                    canonicalTypeName,
                                    originalName,
                                    ctx.resolveType(bitfield.data.ty).name
                                )
                                if (let Some(newName) <- renameField(info)) {
                                    bitfield.data.name = Some(newName)
                                }
                            }
                        }
                }
            }
        }

        var anonFieldCounter = 0

        for (field in fields) {
            match (field) {
                case Field.DataMember(data) =>
                    if (data.name.isSome()) {
                        continue
                    }

                    anonFieldCounter++
                    data.name = Some("__cjbind_anon_${anonFieldCounter}")
                case _ => ()
            }
        }
    }

    // cjlint-ignore -start !G.ITF.04
    public func trace(context: CjbindContext, tracer: Tracer, _: Unit): Unit {
        match (this) {
            case CompFields.CompFieldsError => return
            case CompFields.CompFieldsBefore(fields) =>
                for (f in fields) {
                    tracer.visitKind(f.ty, EdgeKind.FieldEdge)
                }
            case CompFields.CompFieldsAfter(v) =>
                for (f in v.fields) {
                    f.trace(context, tracer, ())
                }
        }
    }
    // cjlint-ignore -end
}

func rawFieldsToFieldsAndBitfieldUnits(
    ctx: CjbindContext,
    rawFields: ArrayList<RawField>,
    packed: Bool
): Result<(ArrayList<Field>, Bool), Unit> {
    let fields = ArrayList<Field>()
    let bitfieldUnitCount = Box(0)

    var idx = 0

    func takeFields(bt: Bool): ArrayList<RawField> {
        let ret = ArrayList<RawField>()

        while (idx < rawFields.size) {
            let cur = rawFields[idx]
            if ((bt && cur.bitfieldWidth.isSome()) || (!bt && cur.bitfieldWidth.isNone())) {
                ret.add(cur)
                idx += 1
            } else {
                break
            }
        }

        return ret
    }

    while (true) {
        let nonBitfields = takeFields(false)
        let mappedNonBitfields = nonBitfields.iterator().map {
            it => Field.DataMember(it)
        } |> collectArrayList
        fields.add(all: mappedNonBitfields)

        if (idx == rawFields.size) {
            break
        }

        let bitfields = takeFields(true)
        if (bitfields.isEmpty()) {
            break
        }

        bitfieldsToAllocationUnits(
            ctx,
            bitfieldUnitCount,
            fields,
            bitfields,
            packed
        )
    }

    if (idx != rawFields.size) {
        throw Exception("some items not resolved in rawFields")
    }

    return Result.Ok((fields, bitfieldUnitCount.value != 0))
}

func bytesFromBitsPow2(n: UInt32): UInt32 {
    if (n == 0) {
        return 0
    }

    if (n <= 8) {
        return 1
    }

    var v = 16u32
    while (v < n) {
        v *= 2
    }
    return v / 8
}

func alignTo(size: UInt32, align: UInt32): UInt32 {
    if (align == 0) {
        return size
    }

    let rem = size % align
    if (rem == 0) {
        return size
    }

    return size + align - rem
}

func alignBytes(size: Int32, align: Int32): Int32 {
    if (align <= 1) {
        return size
    }
    let remainder = size % align
    if (remainder == 0) {
        return size
    }
    return size + align - remainder
}

// cjlint-ignore -start !G.FUN.01
func bitfieldsToAllocationUnits(
    ctx: CjbindContext,
    bitfieldUnitCount: Box<Int64>,
    fields: ArrayList<Field>,
    rawBitFields: ArrayList<RawField>,
    packed: Bool
): Result<Unit, Unit> {
    func fillAllocationUnit(
        fields2: ArrayList<Field>,
        bitfieldUnitCount: Box<Int64>,
        unitSizeInBits: UInt32,
        unitAlignInBits: UInt32,
        bitfields: ArrayList<Bitfield>
    ) {
        bitfieldUnitCount.value += 1
        let align = alignTo(unitAlignInBits, 8) / 8
        let size = alignTo(unitSizeInBits, 8) / 8
        let layout = Layout(Int32(size), Int32(align))
        let tf = Field.Bitfields(
            BitfieldUnit(
                UIntNative(bitfieldUnitCount.value),
                layout,
                bitfields.toArray()
            )
        )
        fields2.add(tf)
    }

    var unitSizeInBits = 0u32
    var unitAlign = 0u32
    let bitfieldsInUnit = ArrayList<Bitfield>()

    for (bitfield in rawBitFields) {
        let bitfieldWidth = bitfield.bitfieldWidth.getOrThrow()
        let bitfieldLayout = match (ctx.resolveType(bitfield.ty).getLayout(ctx)) {
            case Some(v) => v
            case None => return Result.Err(())
        }
        let bitfieldSize = UInt32(bitfieldLayout.size)
        let bitfieldAlign = UInt32(bitfieldLayout.align)

        var offset = unitSizeInBits
        if (!packed) {
            let cond = (offset != 0) && ((bitfieldWidth == 0) || (((offset % (bitfieldAlign * 8)) + bitfieldWidth) > (bitfieldSize *
                8)))
            if (cond) {
                offset = alignTo(offset, bitfieldAlign * 8)
            }
        }

        if (bitfield.name.isSome()) {
            unitAlign = max(unitAlign, bitfieldAlign)
        }

        bitfieldsInUnit.add(Bitfield(UIntNative(offset), bitfield))
        unitSizeInBits = offset + bitfieldWidth

    }

    if (unitSizeInBits != 0) {
        fillAllocationUnit(
            fields,
            bitfieldUnitCount,
            unitSizeInBits,
            unitAlign,
            bitfieldsInUnit
        )
    }

    return Result.Ok(())
}
// cjlint-ignore -end
