package cjbind_ffi

@C
public struct CrtpIgnoresU {
    public let _base: UInt8
    public let y: Int32
    public init(_base: UInt8, y: Int32) {
        this._base = _base
        this.y = y
    }
}
