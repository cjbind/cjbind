package cjbind.ir

import std.collection.ArrayList
import cjbind.clang
import cjbind.result.Result

public enum FunctionKind {
    KindFunction

    public static func fromCursor(cursor: clang.Cursor): ?FunctionKind {
        if (cursor.kind() == clang.CXCursor_FunctionDecl) {
            return FunctionKind.KindFunction
        }
        return None
    }
}

public enum FunctionLinkage {
    LinkageExternal
    | LinkageInternal
}

public class Function <: ClangSubItemParser<Function> {
    public let name: String
    public let signature: TypeId
    public let kind: FunctionKind
    public let linkage: FunctionLinkage

    public init(
        name: String,
        signature: TypeId,
        kind: FunctionKind,
        linkage: FunctionLinkage
    ) {
        this.name = name
        this.signature = signature
        this.kind = kind
        this.linkage = linkage
    }

    public static func parse(
        cursor: clang.Cursor,
        context: CjbindContext
    ): Result<ParseResult<Function>, ParseError> {
        let _kind = match (FunctionKind.fromCursor(cursor)) {
            case Some(v) => v
            case None => return Result.Err(ParseError.Continue)
        }

        let visibility = cursor.visibility()
        if (visibility != clang.CXVisibility_Default) {
            return Result.Err(ParseError.Continue)
        }

        let linkage_c = cursor.linkage()
        let _linkage = match (linkage_c) {
            // case clang.CXLinkage_External | clang.CXLinkage_External => FunctionLinkage.LinkageExternal
            case 3 | 4 => FunctionLinkage.LinkageExternal
            // case clang.CXLinkage_Internal => FunctionLinkage.LinkageInternal
            case 2 => FunctionLinkage.LinkageInternal
            case _ => return Result.Err(ParseError.Continue)
        }

        if (cursor.isInlinedFunction() || cursor
            .definition()
            .map({
                d => d.isInlinedFunction()
            })
            .getOrDefault({=> false})) {
            return Result.Err(ParseError.Continue)
        }

        let sige = Item.fromTy(cursor.curType(), cursor, None, context)
        let sig = match (sige) {
            case Ok(v) => v
            case Err(e) => return Result.Err(e)
        }

        let nname = cursor.spelling()

        let newFunc = Function(nname, sig, _kind, _linkage)

        Result.Ok(ParseResult.New(newFunc, cursor))
    }
}

public enum Abi {
    C
    | Win64 // STDCALL in cangjie 
}

public enum ClangAbi {
    Known(Abi)
    | Unknown(clang.CXCallingConv)
}

func getAbi(cc: clang.CXCallingConv): ClangAbi {
    if (cc == clang.CXCallingConv_C || cc == clang.CXCallingConv_Default) {
        return Known(Abi.C)
    }
    if (cc == clang.CXCallingConv_X86_64Win64) {
        return Known(Abi.Win64)
    }
    return Unknown(cc)
}

func argsFromTyAndCursor(
    ty: clang.Type,
    cursor: clang.Cursor,
    ctx: CjbindContext
): ArrayList<(?String, TypeId)> {
    let cursorArgs = cursor.args().getOrDefault() {=> return Array<clang.Cursor>()}
    let typeArgs = ty.args().getOrDefault() {=> return Array<clang.Type>()}

    let cursorArgsIt = cursorArgs.iterator()
    let typeArgsIt = typeArgs.iterator()

    let result = ArrayList<(?String, TypeId)>()

    while (true) {
        let argCur = cursorArgsIt.next()
        let argTy = typeArgsIt.next()

        if (argCur.isNone() && argTy.isNone()) {
            break
        }

        let name: ?String = match (argCur) {
            case Some(a) =>
                let spelling = a.spelling()
                if (!spelling.isEmpty()) {
                    Some(spelling)
                } else {
                    None
                }
            case _ => None
        }

        let ncursor = match (argCur) {
            case Some(v) => v
            case None => cursor
        }

        let nty = match (argTy) {
            case Some(v) => v
            case None => cursor.curType()
        }

        result.add((name, Item.fromTyOrRef(nty, ncursor, None, ctx)))
    }

    return result
}

public class FunctionSig {
    public let name: String
    public let returnType: TypeId
    public let argumentTypes: Array<(?String, TypeId)>

    public let isVariadic: Bool

    public let abi: ClangAbi

    public init(
        name: String,
        returnType: TypeId,
        argumentTypes: Array<(?String, TypeId)>,
        isVariadic: Bool,
        abi: ClangAbi
    ) {
        this.name = name
        this.returnType = returnType
        this.argumentTypes = argumentTypes
        this.isVariadic = isVariadic
        this.abi = abi
    }

    // cjlint-ignore -start !G.FUN.01
    public static func fromTy(
        ty: clang.Type,
        cursor: clang.Cursor,
        ctx: CjbindContext
    ): Result<FunctionSig, ParseError> {
        let kind = cursor.kind()
        let spelling = cursor.spelling()

        let ncursor = if (cursor.isValid()) {
            cursor
        } else {
            ty.declaration()
        }

        let args = if (kind == clang.CXCursor_FunctionDecl) {
            argsFromTyAndCursor(ty, cursor, ctx)
        } else {
            let targs: ArrayList<(?String, TypeId)> = ArrayList()
            cursor.visit {
                c =>
                if (c.kind() == clang.CXCursor_ParmDecl) {
                    let tty = Item.fromTyOrRef(
                        c.curType(),
                        c,
                        None,
                        ctx
                    )
                    let _spelling = c.spelling()
                    let _name: ?String = if (!_spelling.isEmpty()) {
                        Some(_spelling)
                    } else {
                        None
                    }
                    targs.add((_name, tty))
                }
                return clang.CXChildVisit_Continue
            }

            if (targs.isEmpty()) {
                argsFromTyAndCursor(ty, ncursor, ctx)
            } else {
                targs
            }
        }

        let tyRetType = match(ty.retType()) {
            case Some(v) => v
            case None => return Err(ParseError.Continue)
        }

        let ret = Item.fromTyOrRef(tyRetType, cursor, None, ctx)

        var callConv = ty.callConv()
        if (let Some(tty) <- cursor.curType().canonicalType().pointeeType()) {
            let cursorCallConv = tty.callConv()
            if (cursorCallConv != clang.CXCallingConv_Invalid) {
                callConv = cursorCallConv
            }
        }

        let curAbi = getAbi(callConv)

        return Result.Ok(FunctionSig(
            spelling,
            ret,
            args.toArray(),
            ty.isVariadic(),
            curAbi
        ))
    }
    // cjlint-ignore -end
}
