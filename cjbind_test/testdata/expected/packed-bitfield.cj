package cjbind_ffi

@C
public struct Date {
    let _cjbind_opaque_blob: VArray<UInt8, $3>
    public init() {
        this._cjbind_opaque_blob = unsafe { zeroValue<VArray<UInt8, $3>>() }
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<Date>()
        if (size != 3) {
            throw Exception("Size of Date is not 3 but ${size} bytes")
        }
        let align = alignOf<Date>()
        if (align != 1) {
            throw Exception("Alignment of Date is not 1 but ${align} bytes")
        }
}
