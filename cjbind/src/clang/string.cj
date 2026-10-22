package cjbind.clang

import std.collection.ArrayList

// Follow only wrappers that preserve the evaluated expression. Searching all
// descendants would select the wrong string in offsets or conditional branches.
func evaluatedStringLiteral(cursor: Cursor): ?Cursor {
    var expression = cursor
    if (expression.kind() == CXCursorKind_CXCursor_VarDecl) {
        expression = unsafe { Cursor(clang_Cursor_getVarDeclInitializer(expression.x)) }
    }
    while (true) {
        let kind = expression.kind()
        if (kind == CXCursorKind_CXCursor_StringLiteral) {
            return Some(expression)
        }
        if (kind != CXCursorKind_CXCursor_ParenExpr && kind != CXCursorKind_CXCursor_UnexposedExpr) {
            return None
        }
        let children = expression.collectChildren()
        if (children.size != 1) {
            return None
        }
        expression = children[0]
    }
    return None
}

// clang_getCursorSpelling(StringLiteral) uses StringLiteral::outputString:
// ASCII text, standard escapes, and exactly three octal digits for other bytes.
// Decode that canonical form, rather than trying to parse C source spellings.
func decodeClangStringLiteral(spelling: String): ?Array<UInt8> {
    let runes = spelling.toRuneArray()
    var index = if (spelling.startsWith("u8\"")) { 2 } else { 0 }
    if (runes.size < index + 2 || runes[index] != r'"' || runes[runes.size - 1] != r'"') {
        return None
    }
    index += 1
    let end = runes.size - 1
    let bytes = ArrayList<UInt8>()
    while (index < end) {
        let ch = runes[index]
        index += 1
        if (ch != r'\\') {
            let value = UInt32(ch)
            if (value < 0x20 || value > 0x7e || ch == r'"') {
                return None
            }
            bytes.add(UInt8(value))
            continue
        }
        if (index >= end) {
            return None
        }
        let escaped = runes[index]
        index += 1
        match (escaped) {
            case r'a' => bytes.add(7u8)
            case r'b' => bytes.add(8u8)
            case r't' => bytes.add(9u8)
            case r'n' => bytes.add(10u8)
            case r'v' => bytes.add(11u8)
            case r'f' => bytes.add(12u8)
            case r'r' => bytes.add(13u8)
            case r'\\' | r'"' | r'\'' | r'?' => bytes.add(UInt8(UInt32(escaped)))
            case _ =>
                if (escaped < r'0' || escaped > r'3' || index + 2 > end) {
                    return None
                }
                var value = UInt32(escaped) - UInt32(r'0')
                for (_ in 0..2) {
                    let digit = runes[index]
                    index += 1
                    if (digit < r'0' || digit > r'7') {
                        return None
                    }
                    value = value * 8 + UInt32(digit) - UInt32(r'0')
                }
                bytes.add(UInt8(value))
        }
    }
    return Some(bytes.toArray())
}
