package cjbind_token

import std.collection.ArrayList

public interface ToTokens {
    func toTokens(): Tokens
}

public class Tokens <: ToString {
    let parts = ArrayList<String>()

    public init() {}

    public init(s: String) {
        parts.add(s)
    }

    public func append(s: String): Unit {
        parts.add(s)
    }

    public func append(t: Tokens): Unit {
        let s = t.toString()
        if (!s.isEmpty()) {
            parts.add(s)
        }
    }

    public func isEmpty(): Bool {
        for (p in parts) {
            if (!p.isEmpty()) {
                return false
            }
        }
        return true
    }

    public func toString(): String {
        var result = ""
        for (p in parts) {
            result += p
        }
        return result
    }
}

public func joinTokens(val: Collection<Tokens>, sep: String): Tokens {
    let result = Tokens()
    var first = true
    for (v in val) {
        if (!first) {
            result.append(sep)
        }
        result.append(v)
        first = false
    }
    return result
}

public func removeSuffixNL(val: Tokens): Tokens {
    var s = val.toString()
    while (s.endsWith("\n")) {
        s = s[0..s.size - 1]
    }
    return Tokens(s)
}

public func removePrefixNL(val: Tokens): Tokens {
    var s = val.toString()
    while (s.startsWith("\n")) {
        s = s[1..]
    }
    return Tokens(s)
}

public func float64Repr(val: Float64): String {
    return "${val}".replace("+", "")
}
