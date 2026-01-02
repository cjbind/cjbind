package cjbind.ir

import std.collection.ArrayList
import cjbind.clang
import cjbind.result.Result

public enum EnumVariantValue {
    Boolean(Bool)
    | Signed(Int64)
    | Unsigned(UInt64)
}

public class EnumVariant {
    public let name: String
    public let comment: ?String
    public let val: EnumVariantValue

    public init(
        name: String,
        comment: ?String,
        val: EnumVariantValue
    ) {
        this.name = name
        this.comment = comment
        this.val = val
    }
}

public class Enum {
    public let repr: ?TypeId
    public let variants: Array<EnumVariant>

    public init(
        repr: ?TypeId,
        variants: Array<EnumVariant>
    ) {
        this.repr = repr
        this.variants = variants
    }


    // cjlint-ignore -start !G.FUN.01
    public static func fromTy(
        ty: clang.Type,
        ctx: CjbindContext
    ): Result<Enum, ParseError> {
        if (ty.kind() != clang.CXTypeKind_CXType_Enum) {
            return Err(ParseError.Continue)
        }

        let declaration = ty.declaration().canonical()
        let repr = declaration.enumType().flatMap {
            et => Item.fromTy(et, declaration, None, ctx).ok()
        }
        let variants = ArrayList<EnumVariant>()

        let variantTy = repr.flatMap {
            r => ctx.resolveType(r).safeCanonicalType(ctx)
        }
        let isBool = variantTy.flatMap {
            t => t.isBool()
        }.getOrDefault({=> false})

        let isSigned = variantTy
            .flatMap {
                tty => match (tty.kind) {
                    case TypeKindInt(ik) => ik.isSigned()
                    case _ => throw Exception("enum must be int")
                }
            }
            .getOrDefault {=> true}

        let definition = declaration.definition().getOrDefault{=>declaration}
        definition.visit {
            cursor => 
                if (cursor.kind() == clang.CXCursorKind_CXCursor_EnumConstantDecl) {
                    let value = if (isBool) {
                        cursor.enumValBoolean().flatMap {
                            vv => EnumVariantValue.Boolean(vv)
                        }
                    } else if (isSigned) {
                        cursor.enumValSigned().flatMap {
                            vv => EnumVariantValue.Signed(vv)
                        }
                    } else {
                        cursor.enumValUnsigned().flatMap {
                            vv => EnumVariantValue.Unsigned(vv)
                        }
                    }

                    if (let Some(val) <- value) {
                        let vname = cursor.spelling()
                        let comment = cursor.rawComment()
                        variants.add(EnumVariant(vname, comment, val))
                    }
                }

                return clang.CXChildVisitResult_CXChildVisit_Continue
        }
        return Ok(Enum(repr, variants.toArray()))
    }
    // cjlint-ignore -end
}
