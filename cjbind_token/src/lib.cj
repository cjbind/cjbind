package cjbind_token

import std.collection.ArrayList

public enum Spacing <: Equatable<Spacing> {
    | Joint
    | Alone

    public operator func ==(rhs: Spacing): Bool {
        match ((this, rhs)) {
            case (Joint, Joint) | (Alone, Alone) => true
            case _ => false
        }
    }

    public operator func !=(rhs: Spacing): Bool {
        !(this == rhs)
    }
}

public enum Delimiter <: Equatable<Delimiter> {
    | Paren
    | Brace
    | Bracket
    | Angle
    | Invisible

    public operator func ==(rhs: Delimiter): Bool {
        match ((this, rhs)) {
            case (Paren, Paren) | (Brace, Brace) | (Bracket, Bracket) | (Angle, Angle) | (Invisible, Invisible) => true
            case _ => false
        }
    }

    public operator func !=(rhs: Delimiter): Bool {
        !(this == rhs)
    }
}

public enum TokenTree {
    | Ident(String)
    | Literal(String)
    | Punct(Rune, Spacing)
    | Group(Delimiter, TokenStream)
}

public class TokenStream <: ToString & Iterable<TokenTree> {
    let inner = ArrayList<TokenTree>()

    public init() {}

    public func append(tt: TokenTree): Unit {
        inner.add(tt)
    }

    public func `extend`(other: TokenStream): Unit {
        inner.add(all: other.inner)
    }

    public func isEmpty(): Bool {
        return inner.isEmpty()
    }

    public func iterator(): Iterator<TokenTree> {
        return inner.iterator()
    }

    public func appendLiteral(s: String): Unit {
        if (!s.isEmpty()) {
            inner.add(TokenTree.Literal(s))
        }
    }

    public func toString(): String {
        return formatTokens(inner)
    }
}

func formatTokens(tokens: ArrayList<TokenTree>): String {
    let parts = ArrayList<String>()
    var prevJoint = false
    var prevLiteralEndsWhitespace = false
    var first = true

    for (tt in tokens) {
        let skipSpace = first || prevJoint || prevLiteralEndsWhitespace
        match (tt) {
            case Ident(s) =>
                if (!skipSpace) { parts.add(" ") }
                parts.add(s)
                prevJoint = false
                prevLiteralEndsWhitespace = false
            case Literal(s) =>
                let literalStartsWhitespace = !s.isEmpty() && (s.startsWith(" ") || s.startsWith("\n") || s.startsWith("\t"))
                if (!skipSpace && !literalStartsWhitespace) { parts.add(" ") }
                parts.add(s)
                prevJoint = false
                prevLiteralEndsWhitespace = !s.isEmpty() && (s.endsWith(" ") || s.endsWith("\n") || s.endsWith("\t"))
            case Punct(ch, spacing) =>
                if (!skipSpace) { parts.add(" ") }
                parts.add("${ch}")
                prevJoint = (spacing == Spacing.Joint)
                prevLiteralEndsWhitespace = false
            case Group(delim, stream) =>
                if (!skipSpace) { parts.add(" ") }
                match (delim) {
                    case Delimiter.Invisible =>
                        let col = currentColumn(parts)
                        let content = formatTokens(stream.inner)
                        let lines = content.split("\n")
                        var i = 0
                        for (line in lines) {
                            if (i > 0) {
                                parts.add("\n")
                                parts.add(makeSpaces(col))
                            }
                            parts.add(line)
                            i++
                        }
                    case Delimiter.Brace =>
                        let hasContent = !stream.isEmpty()
                        if (hasContent) {
                            parts.add("{ ")
                            parts.add(formatTokens(stream.inner))
                            parts.add(" }")
                        } else {
                            parts.add("{}")
                        }
                    case Delimiter.Paren =>
                        parts.add("(")
                        parts.add(formatTokens(stream.inner))
                        parts.add(")")
                    case Delimiter.Bracket =>
                        parts.add("[")
                        parts.add(formatTokens(stream.inner))
                        parts.add("]")
                    case Delimiter.Angle =>
                        parts.add("<")
                        parts.add(formatTokens(stream.inner))
                        parts.add(">")
                }
                prevJoint = false
                prevLiteralEndsWhitespace = false
        }
        first = false
    }
    return String.join(parts.toArray(), delimiter: "")
}

func currentColumn(parts: ArrayList<String>): Int64 {
    var col: Int64 = 0
    var i = parts.size - 1
    while (i >= 0) {
        let s = parts[i]
        if (let Some(nlIdx) <- s.lastIndexOf("\n")) {
            col += Int64(s.size) - nlIdx - 1
            return col
        }
        col += Int64(s.size)
        i--
    }
    return col
}

func makeSpaces(n: Int64): String {
    if (n <= 0) { return "" }
    let arr = Array<String>(Int64(n), repeat: " ")
    return String.join(arr, delimiter: "")
}

// --- ToTokens interface ---

public interface ToTokens {
    func appendToStream(tokens: TokenStream): Unit

    func toTokenStream(): TokenStream {
        let ts = TokenStream()
        this.appendToStream(ts)
        return ts
    }
}

extend TokenStream <: ToTokens {
    public func appendToStream(tokens: TokenStream): Unit {
        tokens.`extend`(this)
    }
}

extend TokenTree <: ToTokens {
    public func appendToStream(tokens: TokenStream): Unit {
        tokens.append(this)
    }
}

extend Int8 <: ToTokens {
    public func appendToStream(tokens: TokenStream): Unit {
        tokens.append(TokenTree.Literal("${this}"))
    }
}

extend Int16 <: ToTokens {
    public func appendToStream(tokens: TokenStream): Unit {
        tokens.append(TokenTree.Literal("${this}"))
    }
}

extend Int32 <: ToTokens {
    public func appendToStream(tokens: TokenStream): Unit {
        tokens.append(TokenTree.Literal("${this}"))
    }
}

extend Int64 <: ToTokens {
    public func appendToStream(tokens: TokenStream): Unit {
        tokens.append(TokenTree.Literal("${this}"))
    }
}

extend UInt8 <: ToTokens {
    public func appendToStream(tokens: TokenStream): Unit {
        tokens.append(TokenTree.Literal("${this}"))
    }
}

extend UInt16 <: ToTokens {
    public func appendToStream(tokens: TokenStream): Unit {
        tokens.append(TokenTree.Literal("${this}"))
    }
}

extend UInt32 <: ToTokens {
    public func appendToStream(tokens: TokenStream): Unit {
        tokens.append(TokenTree.Literal("${this}"))
    }
}

extend UInt64 <: ToTokens {
    public func appendToStream(tokens: TokenStream): Unit {
        tokens.append(TokenTree.Literal("${this}"))
    }
}

extend Float32 <: ToTokens {
    public func appendToStream(tokens: TokenStream): Unit {
        tokens.append(TokenTree.Literal("${this}".replace("+", "")))
    }
}

extend Float64 <: ToTokens {
    public func appendToStream(tokens: TokenStream): Unit {
        tokens.append(TokenTree.Literal("${this}".replace("+", "")))
    }
}

extend Bool <: ToTokens {
    public func appendToStream(tokens: TokenStream): Unit {
        tokens.append(TokenTree.Ident(if (this) { "true" } else { "false" }))
    }
}

public func optionAppendToStream<T>(opt: ?T, tokens: TokenStream): Unit where T <: ToTokens {
    if (let Some(v) <- opt) {
        v.appendToStream(tokens)
    }
}

// --- TokenStreamExt ---

extend TokenStream {
    public func appendAll(items: Iterable<TokenStream>): Unit {
        for (item in items) {
            item.appendToStream(this)
        }
    }

    public func appendSeparated(items: Iterable<TokenStream>, sep: TokenStream): Unit {
        var first = true
        for (item in items) {
            if (!first) {
                sep.appendToStream(this)
            }
            item.appendToStream(this)
            first = false
        }
    }

    public func appendTerminated(items: Iterable<TokenStream>, term: TokenStream): Unit {
        for (item in items) {
            item.appendToStream(this)
            term.appendToStream(this)
        }
    }
}

// --- Helper functions ---

public func ident(name: String): TokenTree {
    return TokenTree.Ident(name)
}

public func punct(ch: Rune, spacing!: Spacing = Spacing.Alone): TokenTree {
    return TokenTree.Punct(ch, spacing)
}

public func group(delim: Delimiter, content: TokenStream): TokenTree {
    return TokenTree.Group(delim, content)
}

// --- Convenience ---

public func joinStreams(items: Iterable<TokenStream>, sep: String): TokenStream {
    let result = TokenStream()
    result.appendSeparated(items, tokenStreamFromTemplate(sep))
    return result
}

// --- @tmpl macro bridge ---

public func tokenStreamFromTemplate(s: String): TokenStream {
    let ts = TokenStream()
    ts.appendLiteral(s)
    return ts
}
