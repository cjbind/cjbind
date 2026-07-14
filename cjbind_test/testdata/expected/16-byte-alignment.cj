package cjbind_ffi

func __cjbind_read_rte_ipv4_tuple__cjbind_ty_1__cjbind_ty_1__cjbind_ty_1_from_UInt32(storage: UInt32): rte_ipv4_tuple__cjbind_ty_1__cjbind_ty_1__cjbind_ty_1 {
    var s = storage
    return unsafe { CPointer<rte_ipv4_tuple__cjbind_ty_1__cjbind_ty_1__cjbind_ty_1>(CPointer<UInt8>(inout s)).read() }
}

func __cjbind_write_rte_ipv4_tuple__cjbind_ty_1__cjbind_ty_1__cjbind_ty_1_from_UInt32(storage: UInt32,
    val: rte_ipv4_tuple__cjbind_ty_1__cjbind_ty_1__cjbind_ty_1): UInt32 {
    var s = storage
    unsafe { CPointer<rte_ipv4_tuple__cjbind_ty_1__cjbind_ty_1__cjbind_ty_1>(CPointer<UInt8>(inout s)).write(val) }
    return s
}

func __cjbind_read_UInt32_from_UInt32(storage: UInt32): UInt32 {
    var s = storage
    return unsafe { CPointer<UInt32>(CPointer<UInt8>(inout s)).read() }
}

func __cjbind_write_UInt32_from_UInt32(storage: UInt32, val: UInt32): UInt32 {
    var s = storage
    unsafe { CPointer<UInt32>(CPointer<UInt8>(inout s)).write(val) }
    return s
}

func __cjbind_read_rte_ipv6_tuple__cjbind_ty_1__cjbind_ty_1__cjbind_ty_1_from_UInt32(storage: UInt32): rte_ipv6_tuple__cjbind_ty_1__cjbind_ty_1__cjbind_ty_1 {
    var s = storage
    return unsafe { CPointer<rte_ipv6_tuple__cjbind_ty_1__cjbind_ty_1__cjbind_ty_1>(CPointer<UInt8>(inout s)).read() }
}

func __cjbind_write_rte_ipv6_tuple__cjbind_ty_1__cjbind_ty_1__cjbind_ty_1_from_UInt32(storage: UInt32,
    val: rte_ipv6_tuple__cjbind_ty_1__cjbind_ty_1__cjbind_ty_1): UInt32 {
    var s = storage
    unsafe { CPointer<rte_ipv6_tuple__cjbind_ty_1__cjbind_ty_1__cjbind_ty_1>(CPointer<UInt8>(inout s)).write(val) }
    return s
}

@C
public struct rte_ipv4_tuple__cjbind_ty_1__cjbind_ty_1__cjbind_ty_1 {
    public let dport: UInt16
    public let sport: UInt16
    public func clone(): rte_ipv4_tuple__cjbind_ty_1__cjbind_ty_1__cjbind_ty_1 {
        return this
    }
    public func toString(): String {
        var output = "rte_ipv4_tuple__cjbind_ty_1__cjbind_ty_1__cjbind_ty_1 {"
        output += " dport: "
        output += this.dport.toString()
        output += ", sport: "
        output += this.sport.toString()
        output += " }"
        return output
    }
    public init(dport: UInt16, sport: UInt16) {
        this.dport = dport
        this.sport = sport
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<rte_ipv4_tuple__cjbind_ty_1__cjbind_ty_1__cjbind_ty_1>()
        if (size != 4) {
            throw Exception("Size of rte_ipv4_tuple__cjbind_ty_1__cjbind_ty_1__cjbind_ty_1 is not 4 but ${size} bytes")
        }
        let align = alignOf<rte_ipv4_tuple__cjbind_ty_1__cjbind_ty_1__cjbind_ty_1>()
        if (align != 2) {
            throw Exception(
                "Alignment of rte_ipv4_tuple__cjbind_ty_1__cjbind_ty_1__cjbind_ty_1 is not 2 but ${align} bytes")
        }
}

@C
public struct rte_ipv4_tuple__cjbind_ty_1__cjbind_ty_1 {
    var _storage: UInt32 = unsafe { zeroValue<UInt32>() }
    public init() {}
    public func __cjbind_anon_1(): rte_ipv4_tuple__cjbind_ty_1__cjbind_ty_1__cjbind_ty_1 {
        return __cjbind_read_rte_ipv4_tuple__cjbind_ty_1__cjbind_ty_1__cjbind_ty_1_from_UInt32(this._storage)
    }
    public mut func __cjbind_anon_1(val!: rte_ipv4_tuple__cjbind_ty_1__cjbind_ty_1__cjbind_ty_1): Unit {
        this._storage = __cjbind_write_rte_ipv4_tuple__cjbind_ty_1__cjbind_ty_1__cjbind_ty_1_from_UInt32(this._storage,
            val)
    }
    public func sctp_tag(): UInt32 {
        return __cjbind_read_UInt32_from_UInt32(this._storage)
    }
    public mut func sctp_tag(val!: UInt32): Unit {
        this._storage = __cjbind_write_UInt32_from_UInt32(this._storage, val)
    }
    public func clone(): rte_ipv4_tuple__cjbind_ty_1__cjbind_ty_1 {
        return this
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<rte_ipv4_tuple__cjbind_ty_1__cjbind_ty_1>()
        if (size != 4) {
            throw Exception("Size of rte_ipv4_tuple__cjbind_ty_1__cjbind_ty_1 is not 4 but ${size} bytes")
        }
        let align = alignOf<rte_ipv4_tuple__cjbind_ty_1__cjbind_ty_1>()
        if (align != 4) {
            throw Exception("Alignment of rte_ipv4_tuple__cjbind_ty_1__cjbind_ty_1 is not 4 but ${align} bytes")
        }
}

@C
public struct rte_ipv4_tuple_rte_ipv4_tuple {
    public let src_addr: UInt32
    public let dst_addr: UInt32
    public let __cjbind_anon_1: rte_ipv4_tuple__cjbind_ty_1__cjbind_ty_1
    public func clone(): rte_ipv4_tuple_rte_ipv4_tuple {
        return this
    }
    public init(src_addr: UInt32, dst_addr: UInt32, __cjbind_anon_1: rte_ipv4_tuple__cjbind_ty_1__cjbind_ty_1) {
        this.src_addr = src_addr
        this.dst_addr = dst_addr
        this.__cjbind_anon_1 = __cjbind_anon_1
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<rte_ipv4_tuple_rte_ipv4_tuple>()
        if (size != 12) {
            throw Exception("Size of rte_ipv4_tuple_rte_ipv4_tuple is not 12 but ${size} bytes")
        }
        let align = alignOf<rte_ipv4_tuple_rte_ipv4_tuple>()
        if (align != 4) {
            throw Exception("Alignment of rte_ipv4_tuple_rte_ipv4_tuple is not 4 but ${align} bytes")
        }
}

@C
public struct rte_ipv6_tuple__cjbind_ty_1__cjbind_ty_1__cjbind_ty_1 {
    public let dport: UInt16
    public let sport: UInt16
    public func clone(): rte_ipv6_tuple__cjbind_ty_1__cjbind_ty_1__cjbind_ty_1 {
        return this
    }
    public func toString(): String {
        var output = "rte_ipv6_tuple__cjbind_ty_1__cjbind_ty_1__cjbind_ty_1 {"
        output += " dport: "
        output += this.dport.toString()
        output += ", sport: "
        output += this.sport.toString()
        output += " }"
        return output
    }
    public init(dport: UInt16, sport: UInt16) {
        this.dport = dport
        this.sport = sport
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<rte_ipv6_tuple__cjbind_ty_1__cjbind_ty_1__cjbind_ty_1>()
        if (size != 4) {
            throw Exception("Size of rte_ipv6_tuple__cjbind_ty_1__cjbind_ty_1__cjbind_ty_1 is not 4 but ${size} bytes")
        }
        let align = alignOf<rte_ipv6_tuple__cjbind_ty_1__cjbind_ty_1__cjbind_ty_1>()
        if (align != 2) {
            throw Exception(
                "Alignment of rte_ipv6_tuple__cjbind_ty_1__cjbind_ty_1__cjbind_ty_1 is not 2 but ${align} bytes")
        }
}

@C
public struct rte_ipv6_tuple__cjbind_ty_1__cjbind_ty_1 {
    var _storage: UInt32 = unsafe { zeroValue<UInt32>() }
    public init() {}
    public func __cjbind_anon_1(): rte_ipv6_tuple__cjbind_ty_1__cjbind_ty_1__cjbind_ty_1 {
        return __cjbind_read_rte_ipv6_tuple__cjbind_ty_1__cjbind_ty_1__cjbind_ty_1_from_UInt32(this._storage)
    }
    public mut func __cjbind_anon_1(val!: rte_ipv6_tuple__cjbind_ty_1__cjbind_ty_1__cjbind_ty_1): Unit {
        this._storage = __cjbind_write_rte_ipv6_tuple__cjbind_ty_1__cjbind_ty_1__cjbind_ty_1_from_UInt32(this._storage,
            val)
    }
    public func sctp_tag(): UInt32 {
        return __cjbind_read_UInt32_from_UInt32(this._storage)
    }
    public mut func sctp_tag(val!: UInt32): Unit {
        this._storage = __cjbind_write_UInt32_from_UInt32(this._storage, val)
    }
    public func clone(): rte_ipv6_tuple__cjbind_ty_1__cjbind_ty_1 {
        return this
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<rte_ipv6_tuple__cjbind_ty_1__cjbind_ty_1>()
        if (size != 4) {
            throw Exception("Size of rte_ipv6_tuple__cjbind_ty_1__cjbind_ty_1 is not 4 but ${size} bytes")
        }
        let align = alignOf<rte_ipv6_tuple__cjbind_ty_1__cjbind_ty_1>()
        if (align != 4) {
            throw Exception("Alignment of rte_ipv6_tuple__cjbind_ty_1__cjbind_ty_1 is not 4 but ${align} bytes")
        }
}

@C
public struct rte_ipv6_tuple_rte_ipv6_tuple {
    public let src_addr: VArray<UInt8, $16>
    public let dst_addr: VArray<UInt8, $16>
    public let __cjbind_anon_1: rte_ipv6_tuple__cjbind_ty_1__cjbind_ty_1
    public func clone(): rte_ipv6_tuple_rte_ipv6_tuple {
        return this
    }
    public init(src_addr: VArray<UInt8, $16>, dst_addr: VArray<UInt8, $16>,
        __cjbind_anon_1: rte_ipv6_tuple__cjbind_ty_1__cjbind_ty_1) {
        this.src_addr = src_addr
        this.dst_addr = dst_addr
        this.__cjbind_anon_1 = __cjbind_anon_1
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<rte_ipv6_tuple_rte_ipv6_tuple>()
        if (size != 36) {
            throw Exception("Size of rte_ipv6_tuple_rte_ipv6_tuple is not 36 but ${size} bytes")
        }
        let align = alignOf<rte_ipv6_tuple_rte_ipv6_tuple>()
        if (align != 4) {
            throw Exception("Alignment of rte_ipv6_tuple_rte_ipv6_tuple is not 4 but ${align} bytes")
        }
}

@C
public struct rte_thash_tuple_rte_thash_tuple {
    let _cjbind_opaque_blob: VArray<UInt8, $48>
    public func clone(): rte_thash_tuple_rte_thash_tuple {
        return this
    }
    private init() {
        this._cjbind_opaque_blob = unsafe { zeroValue<VArray<UInt8, $48>>() }
    }
}
