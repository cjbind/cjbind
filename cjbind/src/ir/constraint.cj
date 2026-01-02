package cjbind.ir

import cjbind.clang
import cjbind.result.Result

public enum ParseError {
    Recurse
    | Continue
}

public enum ParseResult<T> {
    AlreadyResolved(ItemId)
    | New(T, ?clang.Cursor)
}

public interface ClangSubItemParser<T> {
    static func parse(
        cursor: clang.Cursor,
        context: CjbindContext
    ): Result<ParseResult<T>, ParseError>
}
