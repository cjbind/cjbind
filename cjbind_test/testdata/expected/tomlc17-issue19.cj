package cjbind_ffi

func __cjbind_read_CPointer_UInt8__from_VArray_UInt64__4_(storage: VArray<UInt64, $4>): CPointer<UInt8> {
    var s = storage
    return unsafe { CPointer<CPointer<UInt8>>(CPointer<UInt8>(inout s)).read() }
}

func __cjbind_write_CPointer_UInt8__from_VArray_UInt64__4_(storage: VArray<UInt64, $4>, val: CPointer<UInt8>): VArray<UInt64, $4> {
    var s = storage
    unsafe { CPointer<CPointer<UInt8>>(CPointer<UInt8>(inout s)).write(val) }
    return s
}

@C
public struct toml_datum_t__cjbind_ty_1__cjbind_ty_1 {
    public var ptr: CPointer<UInt8>
    public var len: Int32
    public init(ptr: CPointer<UInt8>, len: Int32) {
        this.ptr = ptr
        this.len = len
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<toml_datum_t__cjbind_ty_1__cjbind_ty_1>()
        if (size != 16) {
            throw Exception("Size of toml_datum_t__cjbind_ty_1__cjbind_ty_1 is not 16 but ${size} bytes")
        }
        let align = alignOf<toml_datum_t__cjbind_ty_1__cjbind_ty_1>()
        if (align != 8) {
            throw Exception("Alignment of toml_datum_t__cjbind_ty_1__cjbind_ty_1 is not 8 but ${align} bytes")
        }
}

@C
public struct toml_datum_t__cjbind_ty_1__cjbind_ty_2 {
    public var size: Int32
    public var elem: CPointer<toml_datum_t>
    public init(size: Int32, elem: CPointer<toml_datum_t>) {
        this.size = size
        this.elem = elem
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<toml_datum_t__cjbind_ty_1__cjbind_ty_2>()
        if (size != 16) {
            throw Exception("Size of toml_datum_t__cjbind_ty_1__cjbind_ty_2 is not 16 but ${size} bytes")
        }
        let align = alignOf<toml_datum_t__cjbind_ty_1__cjbind_ty_2>()
        if (align != 8) {
            throw Exception("Alignment of toml_datum_t__cjbind_ty_1__cjbind_ty_2 is not 8 but ${align} bytes")
        }
}

@C
public struct toml_datum_t__cjbind_ty_1__cjbind_ty_3 {
    public var size: Int32
    public var key: CPointer<CPointer<UInt8>>
    public var len: CPointer<Int32>
    public var value: CPointer<toml_datum_t>
    public init(size: Int32, key: CPointer<CPointer<UInt8>>, len: CPointer<Int32>, value: CPointer<toml_datum_t>) {
        this.size = size
        this.key = key
        this.len = len
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<toml_datum_t__cjbind_ty_1__cjbind_ty_3>()
        if (size != 32) {
            throw Exception("Size of toml_datum_t__cjbind_ty_1__cjbind_ty_3 is not 32 but ${size} bytes")
        }
        let align = alignOf<toml_datum_t__cjbind_ty_1__cjbind_ty_3>()
        if (align != 8) {
            throw Exception("Alignment of toml_datum_t__cjbind_ty_1__cjbind_ty_3 is not 8 but ${align} bytes")
        }
}

@C
public struct toml_datum_t__cjbind_ty_1 {
    var _storage: VArray<UInt64, $4> = unsafe { zeroValue<VArray<UInt64, $4>>() }
    public init() {}
    public mut prop s: CPointer<UInt8> {
        get() {
            return __cjbind_read_CPointer_UInt8__from_VArray_UInt64__4_(this._storage)
        }
        set(value) {
            this._storage = __cjbind_write_CPointer_UInt8__from_VArray_UInt64__4_(this._storage, value)
        }
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<toml_datum_t__cjbind_ty_1>()
        if (size != 32) {
            throw Exception("Size of toml_datum_t__cjbind_ty_1 is not 32 but ${size} bytes")
        }
        let align = alignOf<toml_datum_t__cjbind_ty_1>()
        if (align != 8) {
            throw Exception("Alignment of toml_datum_t__cjbind_ty_1 is not 8 but ${align} bytes")
        }
}

@C
public struct toml_datum_t {
    public var type_: Int32
    public let u: toml_datum_t__cjbind_ty_1
    public init(type_: Int32, u: toml_datum_t__cjbind_ty_1) {
        this.type_ = type_
        this.u = u
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<toml_datum_t>()
        if (size != 40) {
            throw Exception("Size of toml_datum_t is not 40 but ${size} bytes")
        }
        let align = alignOf<toml_datum_t>()
        if (align != 8) {
            throw Exception("Alignment of toml_datum_t is not 8 but ${align} bytes")
        }
}
