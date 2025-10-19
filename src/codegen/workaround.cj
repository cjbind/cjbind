package cjbind.codegen

import std.ast.{Tokens, Token, TokenKind}

foreign func CJ_AST_Float64ToCPointer(num: Float64): CString

// workaround 仓颉标准库中有 bug 的 Float64 to Tokens 转换函数
public func float64toTokens(val: Float64): Tokens {
    let strPtr = unsafe { CJ_AST_Float64ToCPointer(val) }
    var floatStr = String()
    if (!strPtr.isNull()) {
        floatStr = strPtr.toString()
        unsafe { LibC.free(strPtr) }
    }
    floatStr = floatStr.replace("+", "")

    if (val < 0.0) {
        return Tokens().append(Token(TokenKind.SUB)).append(Token(TokenKind.FLOAT_LITERAL, floatStr[1..]))
    }
    let tok: Token = Token(TokenKind.FLOAT_LITERAL, floatStr)
    return tok.toTokens()
}