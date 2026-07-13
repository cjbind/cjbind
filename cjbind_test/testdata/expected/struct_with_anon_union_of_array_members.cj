package cjbind_ffi

func __cjbind_read_bpf_array__cjbind_ty_1__cjbind_ty_1__cjbind_ty_1_from_VArray_UInt8__0_(storage: VArray<UInt8, $0>): bpf_array__cjbind_ty_1__cjbind_ty_1__cjbind_ty_1 {
    var s = storage
    return unsafe { CPointer<bpf_array__cjbind_ty_1__cjbind_ty_1__cjbind_ty_1>(CPointer<UInt8>(inout s)).read() }
}

func __cjbind_write_bpf_array__cjbind_ty_1__cjbind_ty_1__cjbind_ty_1_from_VArray_UInt8__0_(storage: VArray<UInt8, $0>,
    val: bpf_array__cjbind_ty_1__cjbind_ty_1__cjbind_ty_1): VArray<UInt8, $0> {
    var s = storage
    unsafe { CPointer<bpf_array__cjbind_ty_1__cjbind_ty_1__cjbind_ty_1>(CPointer<UInt8>(inout s)).write(val) }
    return s
}

func __cjbind_read_bpf_array__cjbind_ty_1__cjbind_ty_2__cjbind_ty_2_from_VArray_UInt8__0_(storage: VArray<UInt8, $0>): bpf_array__cjbind_ty_1__cjbind_ty_2__cjbind_ty_2 {
    var s = storage
    return unsafe { CPointer<bpf_array__cjbind_ty_1__cjbind_ty_2__cjbind_ty_2>(CPointer<UInt8>(inout s)).read() }
}

func __cjbind_write_bpf_array__cjbind_ty_1__cjbind_ty_2__cjbind_ty_2_from_VArray_UInt8__0_(storage: VArray<UInt8, $0>,
    val: bpf_array__cjbind_ty_1__cjbind_ty_2__cjbind_ty_2): VArray<UInt8, $0> {
    var s = storage
    unsafe { CPointer<bpf_array__cjbind_ty_1__cjbind_ty_2__cjbind_ty_2>(CPointer<UInt8>(inout s)).write(val) }
    return s
}

@C
public struct bpf_array__cjbind_ty_1__cjbind_ty_1__cjbind_ty_1__cjbind_ty_1 {}

@When[debug]
let _ = {
    =>
        let size = sizeOf<bpf_array__cjbind_ty_1__cjbind_ty_1__cjbind_ty_1__cjbind_ty_1>()
        if (size != 0) {
            throw Exception(
                "Size of bpf_array__cjbind_ty_1__cjbind_ty_1__cjbind_ty_1__cjbind_ty_1 is not 0 but ${size} bytes")
        }
        let align = alignOf<bpf_array__cjbind_ty_1__cjbind_ty_1__cjbind_ty_1__cjbind_ty_1>()
        if (align != 1) {
            throw Exception(
                "Alignment of bpf_array__cjbind_ty_1__cjbind_ty_1__cjbind_ty_1__cjbind_ty_1 is not 1 but ${align} bytes")
        }
}

@C
public struct bpf_array__cjbind_ty_1__cjbind_ty_1__cjbind_ty_1 {
    public let __empty_value1: bpf_array__cjbind_ty_1__cjbind_ty_1__cjbind_ty_1__cjbind_ty_1
    public let value1: CPointer<UInt8>
    public init(__empty_value1: bpf_array__cjbind_ty_1__cjbind_ty_1__cjbind_ty_1__cjbind_ty_1, value1: CPointer<UInt8>) {
        this.__empty_value1 = __empty_value1
        this.value1 = value1
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<bpf_array__cjbind_ty_1__cjbind_ty_1__cjbind_ty_1>()
        if (size != 0) {
            throw Exception("Size of bpf_array__cjbind_ty_1__cjbind_ty_1__cjbind_ty_1 is not 0 but ${size} bytes")
        }
        let align = alignOf<bpf_array__cjbind_ty_1__cjbind_ty_1__cjbind_ty_1>()
        if (align != 1) {
            throw Exception("Alignment of bpf_array__cjbind_ty_1__cjbind_ty_1__cjbind_ty_1 is not 1 but ${align} bytes")
        }
}

@C
public struct bpf_array__cjbind_ty_1__cjbind_ty_2__cjbind_ty_1__cjbind_ty_1 {}

@When[debug]
let _ = {
    =>
        let size = sizeOf<bpf_array__cjbind_ty_1__cjbind_ty_2__cjbind_ty_1__cjbind_ty_1>()
        if (size != 0) {
            throw Exception(
                "Size of bpf_array__cjbind_ty_1__cjbind_ty_2__cjbind_ty_1__cjbind_ty_1 is not 0 but ${size} bytes")
        }
        let align = alignOf<bpf_array__cjbind_ty_1__cjbind_ty_2__cjbind_ty_1__cjbind_ty_1>()
        if (align != 1) {
            throw Exception(
                "Alignment of bpf_array__cjbind_ty_1__cjbind_ty_2__cjbind_ty_1__cjbind_ty_1 is not 1 but ${align} bytes")
        }
}

@C
public struct bpf_array__cjbind_ty_1__cjbind_ty_2__cjbind_ty_2 {
    public let __empty_value2: bpf_array__cjbind_ty_1__cjbind_ty_2__cjbind_ty_1__cjbind_ty_1
    public let value2: CPointer<UInt8>
    public init(__empty_value2: bpf_array__cjbind_ty_1__cjbind_ty_2__cjbind_ty_1__cjbind_ty_1, value2: CPointer<UInt8>) {
        this.__empty_value2 = __empty_value2
        this.value2 = value2
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<bpf_array__cjbind_ty_1__cjbind_ty_2__cjbind_ty_2>()
        if (size != 0) {
            throw Exception("Size of bpf_array__cjbind_ty_1__cjbind_ty_2__cjbind_ty_2 is not 0 but ${size} bytes")
        }
        let align = alignOf<bpf_array__cjbind_ty_1__cjbind_ty_2__cjbind_ty_2>()
        if (align != 1) {
            throw Exception("Alignment of bpf_array__cjbind_ty_1__cjbind_ty_2__cjbind_ty_2 is not 1 but ${align} bytes")
        }
}

@C
public struct bpf_array__cjbind_ty_1__cjbind_ty_1 {
    var _storage: VArray<UInt8, $0> = unsafe { zeroValue<VArray<UInt8, $0>>() }
    public init() {}
    public func __cjbind_anon_1(): bpf_array__cjbind_ty_1__cjbind_ty_1__cjbind_ty_1 {
        return __cjbind_read_bpf_array__cjbind_ty_1__cjbind_ty_1__cjbind_ty_1_from_VArray_UInt8__0_(this._storage)
    }
    public mut func __cjbind_anon_1(val!: bpf_array__cjbind_ty_1__cjbind_ty_1__cjbind_ty_1): Unit {
        this._storage = __cjbind_write_bpf_array__cjbind_ty_1__cjbind_ty_1__cjbind_ty_1_from_VArray_UInt8__0_(
            this._storage, val)
    }
    public func __cjbind_anon_2(): bpf_array__cjbind_ty_1__cjbind_ty_2__cjbind_ty_2 {
        return __cjbind_read_bpf_array__cjbind_ty_1__cjbind_ty_2__cjbind_ty_2_from_VArray_UInt8__0_(this._storage)
    }
    public mut func __cjbind_anon_2(val!: bpf_array__cjbind_ty_1__cjbind_ty_2__cjbind_ty_2): Unit {
        this._storage = __cjbind_write_bpf_array__cjbind_ty_1__cjbind_ty_2__cjbind_ty_2_from_VArray_UInt8__0_(
            this._storage, val)
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<bpf_array__cjbind_ty_1__cjbind_ty_1>()
        if (size != 0) {
            throw Exception("Size of bpf_array__cjbind_ty_1__cjbind_ty_1 is not 0 but ${size} bytes")
        }
        let align = alignOf<bpf_array__cjbind_ty_1__cjbind_ty_1>()
        if (align != 1) {
            throw Exception("Alignment of bpf_array__cjbind_ty_1__cjbind_ty_1 is not 1 but ${align} bytes")
        }
}

@C
public struct bpf_array_bpf_array {
    public let __cjbind_anon_1: bpf_array__cjbind_ty_1__cjbind_ty_1
    public init(__cjbind_anon_1: bpf_array__cjbind_ty_1__cjbind_ty_1) {
        this.__cjbind_anon_1 = __cjbind_anon_1
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<bpf_array_bpf_array>()
        if (size != 0) {
            throw Exception("Size of bpf_array_bpf_array is not 0 but ${size} bytes")
        }
        let align = alignOf<bpf_array_bpf_array>()
        if (align != 1) {
            throw Exception("Alignment of bpf_array_bpf_array is not 1 but ${align} bytes")
        }
}
