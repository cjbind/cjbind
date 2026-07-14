package cjbind_ffi

@C
public struct BaseIgnoresT {
    public let x: Int32
    public init(x: Int32) {
        this.x = x
    }
}

@C
public struct CrtpIgnoresU {
    public let _base: BaseIgnoresT
    public let y: Int32
    public init(_base: BaseIgnoresT, y: Int32) {
        this._base = _base
        this.y = y
    }
}
