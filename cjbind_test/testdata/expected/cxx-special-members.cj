package cjbind_ffi

foreign func _ZN14OverloadedCtorC1Ei(this_: CPointer<OverloadedCtor>, value: Int32): Unit

public unsafe func OverloadedCtor_constructor(this_: CPointer<OverloadedCtor>, value: Int32): Unit {
    return _ZN14OverloadedCtorC1Ei(this_, value)
}

foreign func _ZN14OverloadedCtorC1Ed(this_: CPointer<OverloadedCtor>, value: Float64): Unit

public unsafe func OverloadedCtor_constructor1(this_: CPointer<OverloadedCtor>, value: Float64): Unit {
    return _ZN14OverloadedCtorC1Ed(this_, value)
}

foreign func _ZN14OverloadedCtorD1Ev(this_: CPointer<OverloadedCtor>): Unit

public unsafe func OverloadedCtor_OverloadedCtor_destructor(this_: CPointer<OverloadedCtor>): Unit {
    return _ZN14OverloadedCtorD1Ev(this_)
}

foreign func _ZNK14OverloadedCtor5valueEv(this_: CPointer<OverloadedCtor>): Int32

public unsafe func OverloadedCtor_value(this_: CPointer<OverloadedCtor>): Int32 {
    return _ZNK14OverloadedCtor5valueEv(this_)
}

@C
public struct OverloadedCtor {
    private let stored: Int32
    private init(stored: Int32) {
        this.stored = stored
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<OverloadedCtor>()
        if (size != 4) {
            throw Exception("Size of OverloadedCtor is not 4 but ${size} bytes")
        }
        let align = alignOf<OverloadedCtor>()
        if (align != 4) {
            throw Exception("Alignment of OverloadedCtor is not 4 but ${align} bytes")
        }
}

foreign func _ZN8lifetime9OutOfLineC1Ev(this_: CPointer<lifetime_OutOfLine>): Unit

public unsafe func lifetime_OutOfLine_constructor(this_: CPointer<lifetime_OutOfLine>): Unit {
    return _ZN8lifetime9OutOfLineC1Ev(this_)
}

foreign func _ZN8lifetime9OutOfLineD1Ev(this_: CPointer<lifetime_OutOfLine>): Unit

public unsafe func lifetime_OutOfLine_OutOfLine_destructor(this_: CPointer<lifetime_OutOfLine>): Unit {
    return _ZN8lifetime9OutOfLineD1Ev(this_)
}

@C
public struct lifetime_OutOfLine {
    public let marker: Int32
    public init(marker: Int32) {
        this.marker = marker
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<lifetime_OutOfLine>()
        if (size != 4) {
            throw Exception("Size of lifetime_OutOfLine is not 4 but ${size} bytes")
        }
        let align = alignOf<lifetime_OutOfLine>()
        if (align != 4) {
            throw Exception("Alignment of lifetime_OutOfLine is not 4 but ${align} bytes")
        }
}
