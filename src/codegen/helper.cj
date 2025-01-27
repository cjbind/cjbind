package cjbind.codegen

import std.ast.*
import std.collection.collectArray

import cjbind.ir.{CjbindContext, Layout}

public class Attributes {
    public static func doc(comment: String): Tokens {
        let lines = comment.lines() |> collectArray

        let ret = Tokens()

        for ((idx, line) in lines.iterator().enumerate()) {
            let val = "//" + line
            ret.append(Token(TokenKind.COMMENT, val))
            if (idx != lines.size - 1) {
                ret.append(Token(TokenKind.NL))
            }
        }

        return ret
    }
}

public class Helpers {
    public static func blob(
        ctx: CjbindContext,
        layout: Layout
    ): Tokens {
        let opaque = layout.opaque()

        let ty = opaque.knownCjTypeForArray().getOrDefault {
            => 
            eprintln("Found unknown alignment on codegen")
            return quote(UInt8)
        }

        let dataLen = opaque.arraySize().getOrDefault {=> layout.size}

        if (dataLen == 1) {
            return ty.toTokens()
        } else {
            return quote(VArray<$(ty), $(dataLen)>)
        }
    }
}