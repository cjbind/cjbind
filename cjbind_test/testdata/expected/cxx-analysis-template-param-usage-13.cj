package cjbind_ffi

@C
public struct BaseIgnoresT {
    public var x: Int32
    private init(x: Int32) {
        this.x = x
    }
}
