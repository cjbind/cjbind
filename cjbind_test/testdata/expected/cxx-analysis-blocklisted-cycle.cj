package cjbind_ffi

public type Api_Alias = Cycle

@C
public struct Api {
    let _cjbind_empty: UInt8
    public init(_cjbind_empty: UInt8) {
        this._cjbind_empty = _cjbind_empty
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<Api>()
        if (size != 1) {
            throw Exception("Size of Api is not 1 but ${size} bytes")
        }
        let align = alignOf<Api>()
        if (align != 1) {
            throw Exception("Alignment of Api is not 1 but ${align} bytes")
        }
}

@C
public struct Ignores {
    let _cjbind_empty: UInt8
    public init(_cjbind_empty: UInt8) {
        this._cjbind_empty = _cjbind_empty
    }
}

@C
public struct Base {
    public let value: Ignores
    public init(value: Ignores) {
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<Base>()
        if (size != 1) {
            throw Exception("Size of Base is not 1 but ${size} bytes")
        }
        let align = alignOf<Base>()
        if (align != 1) {
            throw Exception("Alignment of Base is not 1 but ${align} bytes")
        }
}

@C
public struct Cycle {
    public let _base: Base
    public init(_base: Base) {
        this._base = _base
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<Cycle>()
        if (size != 1) {
            throw Exception("Size of Cycle is not 1 but ${size} bytes")
        }
        let align = alignOf<Cycle>()
        if (align != 1) {
            throw Exception("Alignment of Cycle is not 1 but ${align} bytes")
        }
}

foreign func _Z5entryv(): Api

public unsafe func entry(): Api {
    return _Z5entryv()
}
