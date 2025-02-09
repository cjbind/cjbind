macro package cjbind.build.macros

import std.ast.{Tokens, TokenKind, diagReport, DiagReportLevel, ToTokens}
import std.process.Process

public macro env(input: Tokens): Tokens {
    if (input.size != 1) {
        diagReport(
            DiagReportLevel.ERROR,
            input,
            "env macro only accept one argument",
            "$(input.size) arguments are given"
        )
        return Tokens()
    }

    let token = input[0]
    if (token.kind != TokenKind.STRING_LITERAL) {
        diagReport(
            DiagReportLevel.ERROR,
            input,
            "env macro only accept string literal",
            "a ${token.kind} token is given"
        )
        return Tokens()
    }

    let name = token.value
    let value = match (Process.current.getEnv(name)) {
        case Some(v) => v
        case None => ""
    }

    let clean = value.trimAscii()
    
    return quote($(clean))
}