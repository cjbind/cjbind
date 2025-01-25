package cjbind.codegen

import std.ast.*
import std.collection.collectArray

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