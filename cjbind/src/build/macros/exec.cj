macro package cjbind.build.macros

import std.ast.{Tokens, TokenKind, diagReport, DiagReportLevel, ToTokens}
import std.process.{executeWithOutput, ProcessRedirect}
import std.env

// Arguments are split by single spaces. Quoted arguments or arguments containing spaces are not supported.
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
    // Non-git fallback: in CI environments (CI env var set), fail loudly.
    // Outside CI, return "exec-placeholder" so builds succeed without git.
    var stdout = Array<UInt8>()
    try {
        let (code, out, stderr) = executeWithOutput(args[0], args[1..], stdOut: ProcessRedirect.Pipe, stdErr: ProcessRedirect.Pipe)
        if (code != 0) {
            throw Exception("exec failed: ${token.value}\nstderr: ${String.fromUtf8(stderr)}")
        }
        stdout = out
    } catch (e: Exception) {
        let isCI = env.getVariable("CI").isSome()
        if (isCI) {
            throw e
        } else {
            return quote("exec-placeholder")
        }
    }

    let s = String.fromUtf8(stdout)
    let clean = s.trimAscii()

    return quote($(clean))
}
