package cjbind_ffi

@C
public struct alpha_Forward_Forward {
    public let value: Int32
    public init(value: Int32) {
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<alpha_Forward_Forward>()
        if (size != 4) {
            throw Exception("Size of alpha_Forward_Forward is not 4 but ${size} bytes")
        }
        let align = alignOf<alpha_Forward_Forward>()
        if (align != 4) {
            throw Exception("Alignment of alpha_Forward_Forward is not 4 but ${align} bytes")
        }
}

foreign func _ZN5alpha6nested8evaluateEPNS_7ForwardE(value: CPointer<alpha_Forward_Forward>): Int32

public unsafe func alpha_nested_evaluate(value: CPointer<alpha_Forward_Forward>): Int32 {
    return _ZN5alpha6nested8evaluateEPNS_7ForwardE(value)
}

foreign func _ZN5alpha6nested8evaluateEd(value: Float64): Float64

public unsafe func alpha_nested_evaluate1(value: Float64): Float64 {
    return _ZN5alpha6nested8evaluateEd(value)
}

@C
public struct beta_Holder_Holder {
    public let pointer: CPointer<alpha_Forward_Forward>
    public init(pointer: CPointer<alpha_Forward_Forward>) {
        this.pointer = pointer
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<beta_Holder_Holder>()
        if (size != 8) {
            throw Exception("Size of beta_Holder_Holder is not 8 but ${size} bytes")
        }
        let align = alignOf<beta_Holder_Holder>()
        if (align != 8) {
            throw Exception("Alignment of beta_Holder_Holder is not 8 but ${align} bytes")
        }
}
