package cjbind_ffi

@C
public struct Storage_open0_int_close0_Storage_open0_int_close0 {
    public let value: Int32
    public func clone(): Storage_open0_int_close0_Storage_open0_int_close0 {
        return this
    }
    public func toString(): String {
        var output = "Storage_open0_int_close0_Storage_open0_int_close0 {"
        output += " value: "
        output += this.value.toString()
        output += " }"
        return output
    }
    public init(value: Int32) {
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<Storage_open0_int_close0_Storage_open0_int_close0>()
        if (size != 4) {
            throw Exception("Size of Storage_open0_int_close0_Storage_open0_int_close0 is not 4 but ${size} bytes")
        }
        let align = alignOf<Storage_open0_int_close0_Storage_open0_int_close0>()
        if (align != 4) {
            throw Exception(
                "Alignment of Storage_open0_int_close0_Storage_open0_int_close0 is not 4 but ${align} bytes")
        }
}

@C
public struct Storage_open0_int_ptr_close0_Storage_open0_int_ptr_close0 {
    public let first: CPointer<Int32>
    public let second: CPointer<Int32>
    public func clone(): Storage_open0_int_ptr_close0_Storage_open0_int_ptr_close0 {
        return this
    }
    public func toString(): String {
        var output = "Storage_open0_int_ptr_close0_Storage_open0_int_ptr_close0 {"
        output += " first: "
        output += CPointer<Unit>(this.first).toUIntNative().toString()
        output += ", second: "
        output += CPointer<Unit>(this.second).toUIntNative().toString()
        output += " }"
        return output
    }
    public init(first: CPointer<Int32>, second: CPointer<Int32>) {
        this.first = first
        this.second = second
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<Storage_open0_int_ptr_close0_Storage_open0_int_ptr_close0>()
        if (size != 16) {
            throw Exception(
                "Size of Storage_open0_int_ptr_close0_Storage_open0_int_ptr_close0 is not 16 but ${size} bytes")
        }
        let align = alignOf<Storage_open0_int_ptr_close0_Storage_open0_int_ptr_close0>()
        if (align != 8) {
            throw Exception(
                "Alignment of Storage_open0_int_ptr_close0_Storage_open0_int_ptr_close0 is not 8 but ${align} bytes")
        }
}

@C
public struct PartialHolder_PartialHolder {
    public let scalar: Storage_open0_int_close0_Storage_open0_int_close0
    public let pointers: Storage_open0_int_ptr_close0_Storage_open0_int_ptr_close0
    public func clone(): PartialHolder_PartialHolder {
        return this
    }
    public func toString(): String {
        var output = "PartialHolder_PartialHolder {"
        output += " scalar: "
        output += this.scalar.toString()
        output += ", pointers: "
        output += this.pointers.toString()
        output += " }"
        return output
    }
    public init(scalar: Storage_open0_int_close0_Storage_open0_int_close0,
        pointers: Storage_open0_int_ptr_close0_Storage_open0_int_ptr_close0) {
        this.scalar = scalar
        this.pointers = pointers
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<PartialHolder_PartialHolder>()
        if (size != 24) {
            throw Exception("Size of PartialHolder_PartialHolder is not 24 but ${size} bytes")
        }
        let align = alignOf<PartialHolder_PartialHolder>()
        if (align != 8) {
            throw Exception("Alignment of PartialHolder_PartialHolder is not 8 but ${align} bytes")
        }
}
