package cjbind_ffi

foreign func _ZN14OverloadedCtorC1Ei(this_: CPointer<OverloadedCtor_OverloadedCtor>, value: Int32): Unit

public unsafe func OverloadedCtor_OverloadedCtor_constructor(this_: CPointer<OverloadedCtor_OverloadedCtor>,
    value: Int32): Unit {
    return _ZN14OverloadedCtorC1Ei(this_, value)
}

foreign func _ZN14OverloadedCtorC1Ed(this_: CPointer<OverloadedCtor_OverloadedCtor>, value: Float64): Unit

public unsafe func OverloadedCtor_OverloadedCtor_constructor1(this_: CPointer<OverloadedCtor_OverloadedCtor>,
    value: Float64): Unit {
    return _ZN14OverloadedCtorC1Ed(this_, value)
}

foreign func _ZN14OverloadedCtorD1Ev(this_: CPointer<OverloadedCtor_OverloadedCtor>): Unit

public unsafe func OverloadedCtor_OverloadedCtor_destructor(this_: CPointer<OverloadedCtor_OverloadedCtor>): Unit {
    return _ZN14OverloadedCtorD1Ev(this_)
}

foreign func _ZNK14OverloadedCtor5valueEv(this_: CPointer<OverloadedCtor_OverloadedCtor>): Int32

public unsafe func OverloadedCtor_value(this_: CPointer<OverloadedCtor_OverloadedCtor>): Int32 {
    return _ZNK14OverloadedCtor5valueEv(this_)
}

@C
public struct OverloadedCtor_OverloadedCtor {
    private let stored: Int32
    public func toString(): String {
        var output = "OverloadedCtor_OverloadedCtor {"
        output += " stored: "
        output += this.stored.toString()
        output += " }"
        return output
    }
    private init(stored: Int32) {
        this.stored = stored
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<OverloadedCtor_OverloadedCtor>()
        if (size != 4) {
            throw Exception("Size of OverloadedCtor_OverloadedCtor is not 4 but ${size} bytes")
        }
        let align = alignOf<OverloadedCtor_OverloadedCtor>()
        if (align != 4) {
            throw Exception("Alignment of OverloadedCtor_OverloadedCtor is not 4 but ${align} bytes")
        }
}

foreign func _ZN8lifetime9OutOfLineC1Ev(this_: CPointer<lifetime_OutOfLine_OutOfLine>): Unit

public unsafe func lifetime_OutOfLine_OutOfLine_constructor(this_: CPointer<lifetime_OutOfLine_OutOfLine>): Unit {
    return _ZN8lifetime9OutOfLineC1Ev(this_)
}

foreign func _ZN8lifetime9OutOfLineD1Ev(this_: CPointer<lifetime_OutOfLine_OutOfLine>): Unit

public unsafe func lifetime_OutOfLine_OutOfLine_destructor(this_: CPointer<lifetime_OutOfLine_OutOfLine>): Unit {
    return _ZN8lifetime9OutOfLineD1Ev(this_)
}

@C
public struct lifetime_OutOfLine_OutOfLine {
    public let marker: Int32
    public func toString(): String {
        var output = "lifetime_OutOfLine_OutOfLine {"
        output += " marker: "
        output += this.marker.toString()
        output += " }"
        return output
    }
    public init(marker: Int32) {
        this.marker = marker
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<lifetime_OutOfLine_OutOfLine>()
        if (size != 4) {
            throw Exception("Size of lifetime_OutOfLine_OutOfLine is not 4 but ${size} bytes")
        }
        let align = alignOf<lifetime_OutOfLine_OutOfLine>()
        if (align != 4) {
            throw Exception("Alignment of lifetime_OutOfLine_OutOfLine is not 4 but ${align} bytes")
        }
}
