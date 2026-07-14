package cjbind_ffi

public type Api_Alias_Alias = Cycle_Cycle

@C
public struct Api_Api {
    let _cjbind_empty: UInt8
    public func clone(): Api_Api {
        return this
    }
    public func toString(): String {
        var output = "Api_Api {"
        output += " }"
        return output
    }
    public init(_cjbind_empty: UInt8) {
        this._cjbind_empty = _cjbind_empty
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<Api_Api>()
        if (size != 1) {
            throw Exception("Size of Api_Api is not 1 but ${size} bytes")
        }
        let align = alignOf<Api_Api>()
        if (align != 1) {
            throw Exception("Alignment of Api_Api is not 1 but ${align} bytes")
        }
}

@C
public struct UsesExternal_UsesExternal {
    public let value: ExternalPtr_ExternalPtr
    public init(value: ExternalPtr_ExternalPtr) {
        this.value = value
    }
}

@C
public struct Ignores_Ignores {
    let _cjbind_empty: UInt8
    public func clone(): Ignores_Ignores {
        return this
    }
    public func toString(): String {
        var output = "Ignores_Ignores {"
        output += " }"
        return output
    }
    public init(_cjbind_empty: UInt8) {
        this._cjbind_empty = _cjbind_empty
    }
}

@C
public struct Base_Base {
    public let value: Ignores_Ignores
    public func clone(): Base_Base {
        return this
    }
    public func toString(): String {
        var output = "Base_Base {"
        output += " value: "
        output += this.value.toString()
        output += " }"
        return output
    }
    public init(value: Ignores_Ignores) {
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<Base_Base>()
        if (size != 1) {
            throw Exception("Size of Base_Base is not 1 but ${size} bytes")
        }
        let align = alignOf<Base_Base>()
        if (align != 1) {
            throw Exception("Alignment of Base_Base is not 1 but ${align} bytes")
        }
}

@C
public struct Cycle_Cycle {
    public let _base: Base_Base
    public func clone(): Cycle_Cycle {
        return this
    }
    public func toString(): String {
        var output = "Cycle_Cycle {"
        output += " _base: "
        output += this._base.toString()
        output += " }"
        return output
    }
    public init(_base: Base_Base) {
        this._base = _base
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<Cycle_Cycle>()
        if (size != 1) {
            throw Exception("Size of Cycle_Cycle is not 1 but ${size} bytes")
        }
        let align = alignOf<Cycle_Cycle>()
        if (align != 1) {
            throw Exception("Alignment of Cycle_Cycle is not 1 but ${align} bytes")
        }
}

foreign func _Z5entryv(): Api_Api

public unsafe func entry(): Api_Api {
    return _Z5entryv()
}
