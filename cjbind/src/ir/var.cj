package cjbind.ir

import std.collection.ArrayList
import cjbind.clang
import cjbind.result.Result
import cjbind_token.*

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

            // TODO: add expr eval, only use clang eval as fallback
            let (name, value) = match (parseMacroClangFallback(ctx, cursor)) {
                case Some(v) => v
                case None => return Err(ParseError.Continue)
            }

            if (name.isEmpty()) {
                throw Exception("Macro name can't be empty")
            }

            let previouslyDefined = ctx.parsedMacro(name)
            ctx.noteParsedMacro(name, value)

            if (previouslyDefined) {
                eprintln("Warning: Macro `${name}` is already defined")
                return Err(ParseError.Continue)
            }

            var macroLayout: ?Layout = None
            let (typeKind, val) = match (value) {
                case MacroEvalResult.EvalTypedInt(it, kind, layout) =>
                    macroLayout = Some(layout)
                    let constant = match (kind) {
                        case IntKindBool => VarType.VarBool(!it.isZero())
                        case _ => VarType.VarInt(it)
                    }
                    (TypeKind.TypeKindInt(kind), constant)
                case MacroEvalResult.EvalTypedFloat(it, kind, layout) =>
                    macroLayout = Some(layout)
                    (TypeKind.TypeKindFloat(kind), VarType.VarTypedFloat(it))
                case MacroEvalResult.EvalResultInt(it) => match (it) {
                    case Ints.Int(v) =>
                        let ik = if (ctx.options.fitMacroConstants) {
                            fitSignedIntKind(v)
                        } else {
                            IntKindI64
                        }
                        (TypeKind.TypeKindInt(ik), VarType.VarInt(it))
                    case Ints.UInt(v) =>
                        let ik = if (ctx.options.fitMacroConstants) {
                            fitUnsignedIntKind(v)
                        } else {
                            IntKindU64
                        }
                        (TypeKind.TypeKindInt(ik), VarType.VarInt(it))
                }
                case MacroEvalResult.EvalFloat(it) => (TypeKind.TypeKindFloat(FloatKindDouble), VarType.VarFloat(it))
                case MacroEvalResult.EvalStr(it) =>
                    let charTy = Item.builtinType(
                        TypeKind.TypeKindInt(TypeKindIntKind.IntKindU8),
                        true,
                        ctx
                    )
                    (TypeKind.TypeKindPointer(charTy), VarType.VarString(it))
                // FIXME: didn't consider for now as clang didn't provide these
                case _ => return Err(ParseError.Continue)
            }

            let ty = if (let Some(layout) <- macroLayout) {
                let id = ctx.nextItemId()
                ctx.addItem(
                    Item(id, None, ctx.rootModule, KindType(Type(None, layout, typeKind, true)), None),
                    None,
                    None
                )
                id
            } else {
                Item.builtinType(typeKind, true, ctx)
            }

            return Ok(
                ParseResult.New(
                    Var(name, ty, Some(val), true),
                    Some(cursor)
                )
            )
        } else if (k == clang.CXCursorKind_CXCursor_VarDecl) {
            let name = cursor.spelling()
            if (name.isEmpty()) {
                return Err(ParseError.Continue)
            }

            let ty = cursor.curType()
            let isConst = ty.isConst()

            let tyId = match (Item.fromTy(ty, cursor, None, ctx)) {
                case Ok(v) => v
                case Err(e) => return Err(e)
            }

            let canonicalTy = ctx.safeResolveType(tyId).flatMap {
                t => t.safeCanonicalType(ctx)
            }

            let isInteger = canonicalTy.flatMap {
                t => t.isInteger()
            }.getOrDefault {=> false}
            let isFloat = canonicalTy.flatMap {
                t => t.isFloat()
            }.getOrDefault {=> false}

            var value: ?VarType = None
            try (evaluated = cursor.evalutate()) {
                value = if (isInteger) {
                    let kind = match (canonicalTy.getOrThrow().kind) {
                        case TypeKind.TypeKindInt(k) => k
                        case _ => throw Exception("Should be int type")
                    }

                    let iv = evaluated.asInt()
                    if (iv.isNone() || !kind.signednessMatches(iv.getOrThrow().toInts().isNonNegative())) {
                        None
                    } else {
                        let kv = iv.getOrThrow().toInts()
                        match (kind) {
                            case IntKindBool => VarType.VarBool(!kv.isZero())
                            case _ => VarType.VarInt(kv)
                        }
                    }
                } else if (isFloat) {
                    evaluated.asDouble().flatMap {
                        fv => VarType.VarFloat(fv)
                    }
                } else {
                    evaluated.asLiteralBytes().flatMap {
                        sv => VarType.VarString(sv)
                    }
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

// cjlint-ignore -start !G.FUN.01
func parseMacroClangFallback(
    ctx: CjbindContext,
    cursor: clang.Cursor
): Option<(String, MacroEvalResult)> {
    let ftu = match (ctx.tryEnsureFallbackTranslationUnit()) {
        case Some(ftu) => ftu
        case None => return None
    }

    let contents = "int main() { ${cursor.spelling()}; }"
    match (ftu.reparse(contents)) {
        case Err(_) => return None
        case Ok(_) => ()
    }

    let rootChildren = ftu.tu.cursor().collectChildren()
    let mainFunc = match (rootChildren.last) {
        case Some(m) => m
        case None => return None
    }
    let allStmts = mainFunc.collectChildren()
    let macroStmt = match (allStmts.first) {
        case Some(s) => s
        case None => return None
    }

    let parenExprs = macroStmt.collectChildren()
    let paren = match (parenExprs.first) {
        case Some(p) => p
        case None => return None
    }

    let evalutated = paren.evalutate()
    try {
        let evalutatedKind = evalutated.kind()

        if (evalutatedKind == clang.CXEvalResultKind_CXEval_Int) {
            match (evalutated.asInt()) {
                case Some(v) =>
                    let value = v.toInts()
                    if (ctx.options.macroConstUseCTypes) {
                        let valueType = evalutated.valueType()
                        let layout = valueType.fallibleLayout(ctx).ok()
                        if (let Some(l) <- layout) {
                            if (let Some(ik) <- macroIntegerKind(valueType, value, l)) {
                                return Some((cursor.spelling(), MacroEvalResult.EvalTypedInt(value, ik, l)))
                            }
                        }
                        eprintln(
                            "Warning: skipping macro '${cursor.spelling()}' with unsupported C integer type '${valueType.spelling()}'")
                        return None
                    }
                    return Some((cursor.spelling(), MacroEvalResult.EvalResultInt(value)))
                case None => return None
            }
        } else if (evalutatedKind == clang.CXEvalResultKind_CXEval_Float) {
            match (evalutated.asDouble()) {
                case Some(v) =>
                    if (ctx.options.macroConstUseCTypes) {
                        let valueType = evalutated.valueType()
                        let kind = macroFloatKind(valueType)
                        let layout = valueType.fallibleLayout(ctx).ok()
                        if (let Some(fk) <- kind && let Some(l) <- layout) {
                            return Some((cursor.spelling(), MacroEvalResult.EvalTypedFloat(v, fk, l)))
                        }
                        eprintln(
                            "Warning: skipping macro '${cursor.spelling()}' with unsupported C floating-point type '${valueType.spelling()}'")
                        return None
                    }
                    return Some((cursor.spelling(), MacroEvalResult.EvalFloat(v)))
                case None => return None
            }
        } else if (evalutatedKind == clang.CXEvalResultKind_CXEval_StrLiteral) {
            match (evalutated.asLiteralBytes()) {
                case Some(v) => return Some((cursor.spelling(), MacroEvalResult.EvalStr(v)))
                case None => return None
            }
        }

        return None
    } finally {
        evalutated.close()
    }
}
// cjlint-ignore -end

func macroIntegerKind(ty: clang.Type, value: Ints, layout: Layout): ?TypeKindIntKind {
    let kind = ty.kind()
    if (kind == clang.CXTypeKind_CXType_Bool) {
        return IntKindBool
    }
    if (kind == clang.CXTypeKind_CXType_Char_S || kind == clang.CXTypeKind_CXType_SChar) {
        return IntKindSChar
    }
    if (kind == clang.CXTypeKind_CXType_Char_U || kind == clang.CXTypeKind_CXType_UChar) {
        return IntKindUChar
    }
    if (kind == clang.CXTypeKind_CXType_Char16) {
        return IntKindChar16
    }
    if (kind == clang.CXTypeKind_CXType_Char32) {
        return IntKindU32
    }
    if (kind == clang.CXTypeKind_CXType_WChar) {
        let signed = match (value) {
            case Ints.Int(_) => true
            case Ints.UInt(_) => false
        }
        // The generic wchar carrier uses unsigned storage. Macro constants
        // need the expression's signed value type, including negative wchar_t.
        return match (layout.size) {
            case 2 =>
                if (signed) {
                    IntKindI16
                } else {
                    IntKindU16
                }
            case 4 =>
                if (signed) {
                    IntKindI32
                } else {
                    IntKindU32
                }
            case _ => None
        }
    }
    if (kind == clang.CXTypeKind_CXType_Short) {
        return IntKindShort
    }
    if (kind == clang.CXTypeKind_CXType_UShort) {
        return IntKindUShort
    }
    if (kind == clang.CXTypeKind_CXType_Int) {
        return IntKindInt
    }
    if (kind == clang.CXTypeKind_CXType_UInt) {
        return IntKindUInt
    }
    if (kind == clang.CXTypeKind_CXType_Long) {
        return IntKindLong
    }
    if (kind == clang.CXTypeKind_CXType_ULong) {
        return IntKindULong
    }
    if (kind == clang.CXTypeKind_CXType_LongLong) {
        return IntKindLongLong
    }
    if (kind == clang.CXTypeKind_CXType_ULongLong) {
        return IntKindULongLong
    }
    // Libclang's evaluator only exposes 64 bits, so do not truncate __int128.
    return None
}

func macroFloatKind(ty: clang.Type): ?TypeKindFloatKind {
    let kind = ty.kind()
    if (kind == clang.CXTypeKind_CXType_Float16 || kind == clang.CXTypeKind_CXType_Half) {
        return FloatKindFloat16
    }
    if (kind == clang.CXTypeKind_CXType_Float) {
        return FloatKindFloat
    }
    if (kind == clang.CXTypeKind_CXType_Double) {
        return FloatKindDouble
    }
    if (kind == clang.CXTypeKind_CXType_LongDouble) {
        return FloatKindLongDouble
    }
    if (kind == clang.CXTypeKind_CXType_Float128) {
        return FloatKindFloat128
    }
    // __bf16 has a different format from Cangjie Float16's IEEE half precision.
    return None
}

func fitSignedIntKind(v: Int64): TypeKindIntKind {
    if (v >= -128 && v <= 127) {
        return TypeKindIntKind.IntKindI8
    }
    if (v >= -32768 && v <= 32767) {
        return TypeKindIntKind.IntKindI16
    }
    if (v >= -2147483648 && v <= 2147483647) {
        return TypeKindIntKind.IntKindI32
    }
    return TypeKindIntKind.IntKindI64
}

func fitUnsignedIntKind(v: UInt64): TypeKindIntKind {
    if (v <= 255) {
        return TypeKindIntKind.IntKindU8
    }
    if (v <= 65535) {
        return TypeKindIntKind.IntKindU16
    }
    if (v <= 4294967295) {
        return TypeKindIntKind.IntKindU32
    }
    return TypeKindIntKind.IntKindU64
}

public enum Ints <: ToTokens & ToString {
    Int(Int64)
    | UInt(UInt64)

    public func appendToStream(tokens: TokenStream): Unit {
        tokens.append(TokenTree.Literal(this.toString()))
    }

    public func toString(): String {
        match (this) {
            case Int(v) => "${v}"
            case UInt(v) => "${v}"
        }
    }

    public func isNonNegative(): Bool {
        match (this) {
            case Int(v) => v >= 0
            case UInt(v) => true
        }
    }

    public func isZero(): Bool {
        match (this) {
            case Int(v) => v == 0
            case UInt(v) => v == 0
        }
    }
}

extend clang.EvalResultInt {
    public func toInts(): Ints {
        match (this) {
            case Int(v) => Ints.Int(v)
            case UInt(v) => Ints.UInt(v)
        }
    }
}

public enum VarType {
    VarBool(Bool)
    | VarInt(Ints)
    | VarFloat(Float64)
    | VarTypedFloat(Float64)
    | VarString(Array<UInt8>)
}
