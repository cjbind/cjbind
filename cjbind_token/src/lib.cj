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
        return String.join(parts.toArray(), delimiter: "")
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

public func float64Repr(val: Float64): String {
    return "${val}".replace("+", "")
}

