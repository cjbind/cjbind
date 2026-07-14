package cjbind_ffi

foreign func _ZN6NumberC1Ev(this_: CPointer<Number_Number>): Unit

public unsafe func Number_Number_constructor(this_: CPointer<Number_Number>): Unit {
    return _ZN6NumberC1Ev(this_)
}

foreign func _ZN6NumberC1ERKS_(this_: CPointer<Number_Number>, other: CPointer<Number_Number>): Unit

public unsafe func Number_Number_constructor1(this_: CPointer<Number_Number>, other: CPointer<Number_Number>): Unit {
    return _ZN6NumberC1ERKS_(this_, other)
}

foreign func _ZN6NumberC1EOS_(this_: CPointer<Number_Number>, other: CPointer<Number_Number>): Unit

public unsafe func Number_Number_constructor2(this_: CPointer<Number_Number>, other: CPointer<Number_Number>): Unit {
    return _ZN6NumberC1EOS_(this_, other)
}

foreign func _ZN6NumberaSERKS_(this_: CPointer<Number_Number>, other: CPointer<Number_Number>): CPointer<Number_Number>

public unsafe func Number_operator_equals(this_: CPointer<Number_Number>, other: CPointer<Number_Number>): CPointer<Number_Number> {
    return _ZN6NumberaSERKS_(this_, other)
}

foreign func _ZN6Number5valueEv(this_: CPointer<Number_Number>): CPointer<Int32>

public unsafe func Number_value(this_: CPointer<Number_Number>): CPointer<Int32> {
    return _ZN6Number5valueEv(this_)
}

foreign func _ZNK6Number5valueEv(this_: CPointer<Number_Number>): CPointer<Int32>

public unsafe func Number_value1(this_: CPointer<Number_Number>): CPointer<Int32> {
    return _ZNK6Number5valueEv(this_)
}

@C
public struct Number_Number {
    let _cjbind_empty: UInt8
    public func clone(): Number_Number {
        return this
    }
    public func toString(): String {
        var output = "Number_Number {"
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
        let size = sizeOf<Number_Number>()
        if (size != 1) {
            throw Exception("Size of Number_Number is not 1 but ${size} bytes")
        }
        let align = alignOf<Number_Number>()
        if (align != 1) {
            throw Exception("Alignment of Number_Number is not 1 but ${align} bytes")
        }
}
