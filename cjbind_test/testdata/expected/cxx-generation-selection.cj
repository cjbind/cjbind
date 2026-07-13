package cjbind_ffi

foreign func _ZNK9Selection3getEv(this_: CPointer<Selection_Selection>): Int32

public unsafe func Selection_get(this_: CPointer<Selection_Selection>): Int32 {
    return _ZNK9Selection3getEv(this_)
}

foreign func _ZN9Selection5scaleEi(value: Int32): Int32

public unsafe func Selection_scale(value: Int32): Int32 {
    return _ZN9Selection5scaleEi(value)
}

@C
public struct Selection_Selection {
    public let stored: Int32
    public init(stored: Int32) {
        this.stored = stored
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<Selection_Selection>()
        if (size != 4) {
            throw Exception("Size of Selection_Selection is not 4 but ${size} bytes")
        }
        let align = alignOf<Selection_Selection>()
        if (align != 4) {
            throw Exception("Alignment of Selection_Selection is not 4 but ${align} bytes")
        }
}
