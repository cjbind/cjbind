macro package cjbind_token.macros

import std.ast.*
import std.collection.ArrayList

func countLeading(s: String): Int64 {
    var count: Int64 = 0
    while (count < Int64(s.size) && (s[count] == 32 || s[count] == 9)) {
        count++
    }
    return count
}

func compileTrimIndent(s: String): String {
    let lines = s.split("\n")
    if (lines.size == 0) { return s }

    var minIndent: Int64 = -1
    for (line in lines) {
        if (line.trimAscii().isEmpty()) { continue }
        let indent = countLeading(line)
        if (minIndent < 0 || minIndent > indent) { minIndent = indent }
    }
    if (minIndent < 0) { minIndent = 0 }

    let processed = ArrayList<String>()
    for (line in lines) {
        if (line.trimAscii().isEmpty()) {
            processed.add("")
        } else if (minIndent > 0 && line.size >= minIndent) {
            processed.add(line[minIndent..])
        } else {
            processed.add(line)
        }
    }

    let arr = processed.toArray()
    var start: Int64 = 0
    while (start < arr.size && arr[start].isEmpty()) { start++ }
    var end: Int64 = arr.size
    while (end > start && arr[end - 1].isEmpty()) { end-- }
    if (start >= end) { return "" }

    var joined = arr[start]
    var idx = start + 1
    while (idx < end) { joined += "\n" + arr[idx]; idx++ }
    return joined
}

func repeat(ch: String, n: Int64): String {
    var result = ""
    var i: Int64 = 0
    while (i < n) { result += ch; i++ }
    return result
}

func addGap(parts: ArrayList<String>, curLine: Int64, curCol: Int64, tkLine: Int64, tkCol: Int64) {
    if (curLine < 0) {
        parts.add(repeat(" ", tkCol))
    } else if (tkLine != curLine) {
        let lineGap = tkLine - curLine
        parts.add(repeat("\n", lineGap))
        parts.add(repeat(" ", tkCol))
    } else {
        let gap = tkCol - curCol
        if (gap > 0) {
            parts.add(repeat(" ", gap))
        }
    }
}

func extractExpr(input: Tokens, start: Int64, end: Int64): String {
    var exprParts = ArrayList<String>()
    var k = start
    while (k < end) {
        if (input[k].kind == TokenKind.NL) { k++; continue }
        if (input[k].kind == TokenKind.DOLLAR && k + 1 < end && input[k + 1].kind == TokenKind.LCURL) {
            k += 2
            var eCurCol2 = Int64(input[k].pos.column)
            var braceDepth: Int64 = 1
            while (k < end && braceDepth > 0) {
                if (input[k].kind == TokenKind.LCURL) { braceDepth++ }
                if (input[k].kind == TokenKind.RCURL) {
                    braceDepth--
                    if (braceDepth == 0) { break }
                }
                let eCol2 = Int64(input[k].pos.column)
                let eGap2 = eCol2 - eCurCol2
                if (eGap2 > 0) { exprParts.add(repeat(" ", eGap2)) }
                exprParts.add(input[k].value)
                eCurCol2 = eCol2 + Int64(input[k].value.size)
                k++
            }
            k++
        } else {
            k++
        }
    }
    return String.join(exprParts.toArray(), delimiter: "")
}

func sepForToken(tk: Token): String {
    match (tk.kind) {
        case TokenKind.COMMA => ", "
        case TokenKind.NL => "\\n"
        case _ =>
            if (tk.value == ";") { return "; " }
            tk.value
    }
}

func reconstruct(input: Tokens): String {
    let parts = ArrayList<String>()
    var curLine: Int64 = -1
    var curCol: Int64 = 0
    var i: Int64 = 0

    while (i < input.size) {
        let tk = input[i]
        let tkLine = Int64(tk.pos.line)
        let tkCol = Int64(tk.pos.column)

        if (tk.kind == TokenKind.NL) {
            i++
            continue
        }

        // Handle $(${expr})sep* repetition pattern
        if (tk.kind == TokenKind.DOLLAR && i + 1 < input.size && input[i + 1].kind == TokenKind.LPAREN) {
            addGap(parts, curLine, curCol, tkLine, tkCol)

            i += 2
            let repInnerStart = i
            var parenDepth: Int64 = 1
            while (i < input.size && parenDepth > 0) {
                if (input[i].kind == TokenKind.LPAREN) { parenDepth++ }
                if (input[i].kind == TokenKind.RPAREN) {
                    parenDepth--
                    if (parenDepth == 0) { break }
                }
                i++
            }
            let repInnerEnd = i
            i++

            let exprText = extractExpr(input, repInnerStart, repInnerEnd)

            var sepStr = ""
            if (i < input.size && input[i].kind == TokenKind.MUL) {
                sepStr = ""
                i++
            } else if (i + 1 < input.size && input[i + 1].kind == TokenKind.MUL) {
                sepStr = sepForToken(input[i])
                i += 2
            } else {
                diagReport(DiagReportLevel.ERROR, input[repInnerStart..repInnerEnd],
                    "Expected * after repetition pattern",
                    "Missing *")
            }

            let escapedSep = sepStr.replace("\\", "\\\\").replace("\"", "\\\"")
            parts.add("\${joinStreams(${exprText}, \"${escapedSep}\")}")

            if (i < input.size) {
                curLine = Int64(input[i - 1].pos.line)
                curCol = Int64(input[i - 1].pos.column) + Int64(input[i - 1].value.size)
            }
            continue
        }

        // Handle ${expr} interpolation
        if (tk.kind == TokenKind.DOLLAR && i + 1 < input.size && input[i + 1].kind == TokenKind.LCURL) {
            addGap(parts, curLine, curCol, tkLine, tkCol)

            let lcurlCol = Int64(input[i + 1].pos.column)
            i += 2
            var exprParts = ArrayList<String>()
            var eCurCol = lcurlCol + 1
            var depth: Int64 = 1
            while (i < input.size && depth > 0) {
                if (input[i].kind == TokenKind.LCURL) { depth++ }
                if (input[i].kind == TokenKind.RCURL) {
                    depth--
                    if (depth == 0) { break }
                }
                let eCol = Int64(input[i].pos.column)
                let eGap = eCol - eCurCol
                if (eGap > 0) { exprParts.add(repeat(" ", eGap)) }
                exprParts.add(input[i].value)
                eCurCol = eCol + Int64(input[i].value.size)
                i++
            }
            parts.add("\${${String.join(exprParts.toArray(), delimiter: "")}}")

            if (i < input.size) {
                curLine = Int64(input[i].pos.line)
                curCol = Int64(input[i].pos.column) + 1
                i++
            }
            continue
        }

        addGap(parts, curLine, curCol, tkLine, tkCol)
        parts.add(tk.value)
        curLine = tkLine
        curCol = tkCol + Int64(tk.value.size)
        i++
    }

    return String.join(parts.toArray(), delimiter: "")
}

public macro tmpl(input: Tokens): Tokens {
    let template = reconstruct(input)
    let trimmed = compileTrimIndent(template)

    let result = Tokens()
    result.append(Token(TokenKind.IDENTIFIER, "tokenStreamFromTemplate"))
    result.append(Token(TokenKind.LPAREN))
    result.append(Token(TokenKind.MULTILINE_STRING, trimmed))
    result.append(Token(TokenKind.RPAREN))
    return result
}
