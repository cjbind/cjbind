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
        if (minIndent < 0 || indent < minIndent) { minIndent = indent }
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

    let result = ArrayList<String>()
    var idx = start
    while (idx < end) { result.add(arr[idx]); idx++ }
    return String.join(result.toArray(), delimiter: "\n")
}

func repeat(ch: String, n: Int64): String {
    let parts = ArrayList<String>()
    var i: Int64 = 0
    while (i < n) { parts.add(ch); i++ }
    return String.join(parts.toArray(), delimiter: "")
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

        // Detect ${...} interpolation: DOLLAR LCURL ... RCURL
        if (tk.kind == TokenKind.DOLLAR && i + 1 < input.size && input[i + 1].kind == TokenKind.LCURL) {
            addGap(parts, curLine, curCol, tkLine, tkCol)

            // Reconstruct expression tokens between { and } using positions
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
    result.append(Token(TokenKind.IDENTIFIER, "Tokens"))
    result.append(Token(TokenKind.LPAREN))
    result.append(Token(TokenKind.MULTILINE_STRING, trimmed))
    result.append(Token(TokenKind.RPAREN))
    return result
}
