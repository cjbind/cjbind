package cjbind_ffi

public type va_list_va_list = __builtin_va_list___builtin_va_list

foreign func vprintf(format: CPointer<UInt8>, vlist: __builtin_va_list___builtin_va_list): Int32

@C
public struct __va_list___va_list {
    public let __stack: CPointer<Unit>
    public let __gr_top: CPointer<Unit>
    public let __vr_top: CPointer<Unit>
    public let __gr_offs: Int32
    public let __vr_offs: Int32
    public func clone(): __va_list___va_list {
        return this
    }
    public func toString(): String {
        var output = "__va_list___va_list {"
        output += " __stack: "
        output += CPointer<Unit>(this.__stack).toUIntNative().toString()
        output += ", __gr_top: "
        output += CPointer<Unit>(this.__gr_top).toUIntNative().toString()
        output += ", __vr_top: "
        output += CPointer<Unit>(this.__vr_top).toUIntNative().toString()
        output += ", __gr_offs: "
        output += this.__gr_offs.toString()
        output += ", __vr_offs: "
        output += this.__vr_offs.toString()
        output += " }"
        return output
    }
    public init(__stack: CPointer<Unit>, __gr_top: CPointer<Unit>, __vr_top: CPointer<Unit>, __gr_offs: Int32,
        __vr_offs: Int32) {
        this.__stack = __stack
        this.__gr_top = __gr_top
        this.__vr_top = __vr_top
        this.__gr_offs = __gr_offs
        this.__vr_offs = __vr_offs
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<__va_list___va_list>()
        if (size != 32) {
            throw Exception("Size of __va_list___va_list is not 32 but ${size} bytes")
        }
        let align = alignOf<__va_list___va_list>()
        if (align != 8) {
            throw Exception("Alignment of __va_list___va_list is not 8 but ${align} bytes")
        }
}

public type __builtin_va_list___builtin_va_list = __va_list___va_list
