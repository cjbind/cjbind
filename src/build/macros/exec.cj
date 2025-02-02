macro package cjbind.build.macros

import std.ast.{Tokens, TokenKind, diagReport, DiagReportLevel, ToTokens}
import std.process.{Process, ProcessRedirect}

public macro exec(input: Tokens): Tokens {
    if (input.size != 1) {
        diagReport(
            DiagReportLevel.ERROR,
            input,
            "exec macro only accept one argument",
            "$(input.size) arguments are given"
        )
        return Tokens()
    }

    let token = input[0]
    if (token.kind != TokenKind.STRING_LITERAL) {
        diagReport(
            DiagReportLevel.ERROR,
            input,
            "exec macro only accept string literal",
            "a ${token.kind} token is given"
        )
        return Tokens()
    }

    let args = token.value.split(" ", removeEmpty: true)
    let (code, stdout, _) = Process.runOutput(args[0], args[1..], stdOut: ProcessRedirect.Pipe)
    if (code != 0) {
        throw Exception("exec failed: ${token.value}")
    }

    let s = String.fromUtf8(stdout)

    return quote($(s))
}
