package cjbind.ir

import std.collection.ArrayList
import cjbind.clang
import cjbind.result.Result

public class Var <: ClangSubItemParser<Var> {
    public let name: String
    public let ty: TypeId
    public let val: ?VarType
    public let isConst: Bool

    public init(
        name: String,
        ty: TypeId,
        val: ?VarType,
        isConst: Bool
    ) {
        if (name.isEmpty()) {
            throw Exception("Var name can't be empty")
        }

        this.name = name
        this.ty = ty
        this.val = val
        this.isConst = isConst
    }

    // cjlint-ignore -start !G.FUN.01
    public static func parse(cursor: clang.Cursor, ctx: CjbindContext): Result<ParseResult<Var>, ParseError> {
        let k = cursor.kind()
        if (k == clang.CXCursorKind_CXCursor_MacroDefinition) {
            if (cursor.isMacroFunctionLike()) {
                return Err(ParseError.Continue)
            }

            // currently we don't support macro parse, wait a c expr
            // TODO: we can support single literal
            return Err(ParseError.Continue)
        } else if (k == clang.CXCursorKind_CXCursor_VarDecl) {
            let name = cursor.spelling()
            if (name.isEmpty()) {
                return Err(ParseError.Continue)
            }

            let ty = cursor.curType()
            let isConst = ty.isConst() || ([clang.CXTypeKind_CXType_ConstantArray, clang.CXTypeKind_CXType_IncompleteArray].contains(
                ty.kind()) && ty.elemType().flatMap({
                et => et.isConst()
            }).getOrDefault {=> false})

            let tyId = match (Item.fromTy(ty, cursor, None, ctx)) {
                case Ok(v) => v
                case Err(e) => return Err(e)
            }

            let canonicalTy = ctx.safeResolveType(tyId)
                .flatMap {
                    t => t.safeCanonicalType(ctx)
                }

            let isInteger = canonicalTy.flatMap {
                t => t.isInteger()
            }.getOrDefault {=> false}
            let isFloat = canonicalTy.flatMap {
                t => t.isFloat()
            }.getOrDefault {=> false}

            let value: ?VarType = if (isInteger) {
                let kind = match (canonicalTy.getOrThrow().kind) {
                    case TypeKind.TypeKindInt(k) => k
                    case _ => throw Exception("Should be int type")
                }

                let iv = cursor.evalutate().asInt()
                if (iv.isNone() || !kind.signednessMatches(iv.getOrThrow())) {
                    None
                } else {
                    let kv = iv.getOrThrow()
                    match (kind) {
                        case IntKindBool => VarType.VarBool(kv != 0)
                        case _ => VarType.VarInt(kv)
                    }
                }
            } else if (isFloat) {
                cursor.evalutate().asDouble().flatMap {
                    fv => VarType.VarFloat(fv)
                }
            } else {
                cursor.evalutate().asLiteralString().flatMap {
                    sv => VarType.VarString(sv)
                }
            }

            let varr = Var(name, tyId, value, isConst)
            return Ok(ParseResult.New(varr, Some(cursor)))
        } else {
            return Err(ParseError.Continue)
        }
    }
    // cjlint-ignore -end
}

public enum VarType {
    VarBool(Bool)
    | VarInt(Int64)
    | VarFloat(Float64)
    | VarChar(UInt8)
    | VarString(CString)
}