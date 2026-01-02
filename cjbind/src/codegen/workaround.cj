package cjbind.codegen

import std.ast.{Tokens, Token, TokenKind, ToTokens, TokenKind}

foreign func CJ_AST_Float64ToCPointer(num: Float64): CString

// workaround 仓颉标准库中有 bug 的 Float64 to Tokens 转换函数
public func float64toTokens(val: Float64): Tokens {
    let oldTokens = val.toTokens()
    let tokens = Tokens()

    for (token in oldTokens) {
        var t = token
        if (token.kind == TokenKind.FLOAT_LITERAL && token.value.contains("+")) {
            t = Token(TokenKind.FLOAT_LITERAL, token.value.replace("+", ""))
        }
        tokens.append(t)
    }

    return tokens
}