package cjbind_ffi

@C
public struct CrtpIgnoresU {
    public let _base: UInt8
    public var y: Int32
    private init(_base: UInt8, y: Int32) {
        this._base = _base
        this.y = y
    }
}
