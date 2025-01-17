package cjbind.ir

import std.collection.ArrayList
import cjbind.clang
import cjbind.result.Result

public enum CompKind {
    CompKindStruct
    | CompKindUnion
}

public class CompInfo {
    public let kind: CompKind
    public let fields: CompFields = CompFieldsBefore(ArrayList())
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

        if (k == clang.CXCursor_UnionDecl) {
            return Result.Ok(CompKind.CompKindUnion)
        }
        if (k == clang.CXCursor_StructDecl) {
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
                if (k == clang.CXCursor_ParmDecl) {
                    return true
                }
                if (k == clang.CXCursor_StructDecl || k == clang.CXCursor_UnionDecl) {
                    return !cur.isDefinition()
                }
                return false
            }
            .getOrDefault({=> false})

        let maybeAnonymoudsStructField: Box<?(TypeId, clang.Type, ?UIntNative)> = Box(None)
        cursor
            .value
            .visit {
                cur =>
                if (let Some((ty, clangTy, offset)) <- maybeAnonymoudsStructField.value) {
                    if (cur.kind() == clang.CXCursor_TypedefDecl && cur.typedefType().getOrThrow().canonicalType() ==
                        clangTy) {
                    // do nothing
                    } else {
                        let field = RawField(None, ty, None, None, offset)
                        ci.fields.appendRawField(field)
                    }
                }

                let k = cur.kind()
                if (k == clang.CXCursor_FieldDecl) {
                    if (let Some((ty, clangTy, offset)) <- maybeAnonymoudsStructField.value) {
                        let used: Box<Bool> = Box(false)
                        cur.visit {
                            child =>
                            if (child.curType() == clangTy) {
                                used.value = true
                            }
                            return clang.CXChildVisit_Continue
                        }

                        if (!used.value) {
                            let field = RawField(None, ty, None, None, offset)
                            ci.fields.appendRawField(field)
                        }
                    }

                    let bitWidth: ?UInt32 = if (cur.isBitField()) {
                        let width = cur.bitWidth()

                        if (width.isNone()) {
                            ci.hasUnevaluableBitFieldWidth = true
                            return clang.CXChildVisit_Break
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
                        if (cur.kind() == clang.CXCursor_UnexposedAttr) {
                            ci.foundUnknownAttr = true
                        }
                        return clang.CXChildVisit_Continue
                    }
                } else if (k == clang.CXCursor_UnexposedAttr) {
                    ci.foundUnknownAttr = true
                } else if (k == clang.CXCursor_EnumDecl || k == clang.CXCursor_TypedefDecl || k == clang
                    .CXCursor_StructDecl || k == clang.CXCursor_UnionDecl) {
                    let isInnerStruct: Bool = cur.semanticParent() == cursor.value || cur.isDefinition()
                    if (!isInnerStruct) {
                        return clang.CXChildVisit_Continue
                    }

                    let inner = Item.parse(cur, Some(potentialId), ctx).expect("Inner ClassDecl")

                    if (ctx.resolveItemFallible(inner).isSome()) {
                        ci.innerTypes.add(inner)

                        if (cur.isAnonymous() && cur.kind() != clang.CXCursor_EnumDecl) {
                            let ty = cur.curType()
                            let offset = cur.offsetOfField().ok()
                            maybeAnonymoudsStructField.value = Some((inner, ty, offset))
                        }
                    }
                } else if (k == clang.CXCursor_PackedAttr) {
                    ci.packedAttr = true
                } else {
                    // throw those fucking away
                }

                return clang.CXChildVisit_Continue
            }

        if (let Some((ty, _, offset)) <- maybeAnonymoudsStructField.value) {
            let field = RawField(None, ty, None,None, offset)
            ci.fields.appendRawField(field)
        }

        Result.Ok(ci)
    }
    // cjlint-ignore -end
}

public open class FieldData {
    public let name: ?String
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

public enum Field {
    DataMember(FieldData)
    | Bitfields(BitfieldUnit)
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

public enum CompFields {
    CompFieldsBefore(ArrayList<RawField>)
    | CompFieldsAfter(CompFieldsAfterValue)
    | CompFieldsError

    func appendRawField(raw: RawField) {
        match (this) {
            case CompFieldsBefore(raws) => raws.add(raw)
            case _ => throw Exception("fields computed")
        }
    }
}
