package cjbind.ir

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
    public let linkName: ?String
    public let signature: TypeId
    public let kind: FunctionKind
    public let linkage: FunctionLinkage

    public init(
        name: String,
        linkName: ?String,
        signature: TypeId,
        kind: FunctionKind,
        linkage: FunctionLinkage
    ) {
        this.name = name
        this.linkName = linkName
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

        if (cursor.isInlinedFunction() || cursor.definition().map({
            d => d.isInlinedFunction()
        }).getOrDefault({=> false})) {
            return Result.Err(ParseError.Continue)
        }

        throw Exception("TODO")
    }
}
