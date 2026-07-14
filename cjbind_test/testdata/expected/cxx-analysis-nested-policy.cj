package cjbind_ffi

@C
public struct api_Outer_Inner_Inner {
    public let value: Int32
    public func clone(): api_Outer_Inner_Inner {
        return this
    }
    public init(value: Int32) {
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<api_Outer_Inner_Inner>()
        if (size != 4) {
            throw Exception("Size of api_Outer_Inner_Inner is not 4 but ${size} bytes")
        }
        let align = alignOf<api_Outer_Inner_Inner>()
        if (align != 4) {
            throw Exception("Alignment of api_Outer_Inner_Inner is not 4 but ${align} bytes")
        }
}

foreign func _ZN3api5Outer1fEv(this_: CPointer<api_Outer_Outer>): Int32

public unsafe func api_Outer_f(this_: CPointer<api_Outer_Outer>): Int32 {
    return _ZN3api5Outer1fEv(this_)
}

@C
public struct api_Outer_Outer {
    let _cjbind_empty: UInt8
    public func clone(): api_Outer_Outer {
        return this
    }
    public func toString(): String {
        var output = "api_Outer_Outer {"
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
        let size = sizeOf<api_Outer_Outer>()
        if (size != 1) {
            throw Exception("Size of api_Outer_Outer is not 1 but ${size} bytes")
        }
        let align = alignOf<api_Outer_Outer>()
        if (align != 1) {
            throw Exception("Alignment of api_Outer_Outer is not 1 but ${align} bytes")
        }
}
