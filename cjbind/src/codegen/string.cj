package cjbind.codegen

// Escape source text without changing its UTF-8 value. In particular, a C
// string containing ${...} must not become a Cangjie interpolation expression.
func escapeStringContents(value: String): String {
    let escaped = StringBuilder()
    let hex = "0123456789abcdef"
    for (ch in value.toRuneArray()) {
        match (ch) {
            case r'\\' => escaped.append("\\\\")
            case r'"' => escaped.append("\\\"")
            case r'$' => escaped.append("\\\$")
            case r'\n' => escaped.append("\\n")
            case r'\r' => escaped.append("\\r")
            case r'\t' => escaped.append("\\t")
            case _ =>
                let code = UInt32(ch)
                if (code < 0x20 || code == 0x7f) {
                    escaped.append("\\u{")
                    escaped.append(Rune(hex[Int64(code / 16)]))
                    escaped.append(Rune(hex[Int64(code % 16)]))
                    escaped.append("}")
                } else {
                    escaped.append(ch)
                }
        }
    }
    return escaped.toString()
}

func stringLiteral(value: String): String {
    return "\"${escapeStringContents(value)}\""
}
