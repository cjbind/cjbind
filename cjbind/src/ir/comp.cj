package cjbind.ir

import std.collection.{ArrayList, collectArrayList}
import cjbind.clang
import cjbind.result.Result

public enum CompKind {
    CompKindStruct
    | CompKindUnion
}

public class CompInfo <: IsOpaque<Option<Layout>> & Trace<Tracer, Item> {
    public let kind: CompKind
    public var fields: CompFields = CompFieldsBefore(ArrayList())
    public let innerTypes: ArrayList<TypeId> = ArrayList()

    public var isForwardDeclaration: Bool = false
    public var packedAttr: Bool = false
    public var hasUnevaluableBitFieldWidth: Bool = false
    public var foundUnknownAttr: Bool = false

    public init(kind: CompKind) {
        this.kind = kind
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

        let ci = CompInfo(kind)
        ci.isForwardDeclaration = location
            .flatMap {
                cur =>
                let k = cur.kind()
                if (k == clang.CXCursorKind_CXCursor_ParmDecl) {
                    return true
                }
                if (k == clang.CXCursorKind_CXCursor_StructDecl || k == clang.CXCursorKind_CXCursor_UnionDecl) {
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
                            maybeAnonymousStructField.value = None
                            ci.fields.appendRawField(field)
                        }
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
                        offset
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
                } else if (k == clang.CXCursorKind_CXCursor_EnumDecl || k == clang.CXCursorKind_CXCursor_TypedefDecl || k == clang
                    .CXCursorKind_CXCursor_StructDecl || k == clang.CXCursorKind_CXCursor_UnionDecl) {
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
                } else {
                    // throw those fucking away
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

    public func deanonymizeFields(ctx: CjbindContext): Unit {
        this.fields.deanonymizeFields(ctx)
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
                            let bfLayout = ctx.resolveType(bf.data.ty).getLayout(ctx).getOrThrow()
                            return (bf.data.bitfieldWidth.getOrThrow() / 8) > UInt32(bfLayout.size)
                        }
                }
            }
        if (fieldsCond) {
            return true
        }

        if (this.isPacked(ctx, layout)) {
            if (layout.flatMap {
                l => return l.align > 1
            }.getOrDefault {=> false}) {
                return true
            }
        }

        return false
    }

    // cjlint-ignore -start !G.ITF.04
    public func trace(context: CjbindContext, tracer: Tracer, item: Item): Unit {
        if (item.isOpaque(context, ())) {
            return
        }

        this.fields.trace(context, tracer, ())
    }
    // cjlint-ignore -end
}

public open class FieldData {
    public var name: ?String
    public let ty: TypeId
    public let comment: ?String
    public let bitfieldWidth: ?UInt32
    public let offset: ?UIntNative

    public init(
        name: ?String,
        ty: TypeId,
        comment: ?String,
        bitfieldWidth: ?UInt32,
        offset: ?UIntNative
    ) {
        this.name = name
        this.ty = ty
        this.comment = comment
        this.bitfieldWidth = bitfieldWidth
        this.offset = offset
    }
}

public class RawField <: FieldData {
    public init(
        name: ?String,
        ty: TypeId,
        comment: ?String,
        bitfieldWidth: ?UInt32,
        offset: ?UIntNative
    ) {
        super(name, ty, comment, bitfieldWidth, offset)
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

    func deanonymizeFields(_: CjbindContext) {
        let fields = match (this) {
            case CompFields.CompFieldsAfter(v) => v.fields
            case CompFields.CompFieldsError => return
            case CompFields.CompFieldsBefore(_) => throw Exception("fields not computed")
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
        let align = 1u32
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

    var maxAlign = 0u32
    var unfilledBitsInUnit = 0u32
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
            maxAlign = max(maxAlign, bitfieldAlign)
            unitAlign = max(unitAlign, bitfieldAlign)
        }

        bitfieldsInUnit.add(Bitfield(UIntNative(offset), bitfield))
        unitSizeInBits = offset + bitfieldWidth

        let dataSize = alignTo(unitSizeInBits, bitfieldAlign * 8)
        unfilledBitsInUnit = dataSize - unitSizeInBits
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
