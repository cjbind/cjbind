package cjbind_ffi

@C
public struct Date_Date {
    let _cjbind_opaque_blob: VArray<UInt8, $3>
    public func clone(): Date_Date {
        return this
    }
    public func toString(): String {
        var output = "Date_Date {"
        output += " <opaque>"
        output += " }"
        return output
    }
    public init() {
        this._cjbind_opaque_blob = unsafe { zeroValue<VArray<UInt8, $3>>() }
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<Date_Date>()
        if (size != 3) {
            throw Exception("Size of Date_Date is not 3 but ${size} bytes")
        }
        let align = alignOf<Date_Date>()
        if (align != 1) {
            throw Exception("Alignment of Date_Date is not 1 but ${align} bytes")
        }
}
