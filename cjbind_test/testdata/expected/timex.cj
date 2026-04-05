package cjbind_ffi

@C
public struct timex_timex {
    let _cjbind_opaque_blob: VArray<UInt32, $12>
    public init() {
        this._cjbind_opaque_blob = unsafe { zeroValue<VArray<UInt32, $12>>() }
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<timex_timex>()
        if (size != 48) {
            throw Exception("Size of timex_timex is not 48 but ${size} bytes")
        }
        let align = alignOf<timex_timex>()
        if (align != 4) {
            throw Exception("Alignment of timex_timex is not 4 but ${align} bytes")
        }
}

@C
public struct timex_named_timex_named {
    let _cjbind_opaque_blob: VArray<UInt32, $12>
    public init() {
        this._cjbind_opaque_blob = unsafe { zeroValue<VArray<UInt32, $12>>() }
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<timex_named_timex_named>()
        if (size != 48) {
            throw Exception("Size of timex_named_timex_named is not 48 but ${size} bytes")
        }
        let align = alignOf<timex_named_timex_named>()
        if (align != 4) {
            throw Exception("Alignment of timex_named_timex_named is not 4 but ${align} bytes")
        }
}