@C
func __cjbind_read_rte_ipv4_tuple__cjbind_ty_1(ptr: CPointer<UInt8>): rte_ipv4_tuple__cjbind_ty_1 {
    return unsafe { CPointer<rte_ipv4_tuple__cjbind_ty_1>(ptr).read() }
}

@C
func __cjbind_write_rte_ipv4_tuple__cjbind_ty_1(ptr: CPointer<UInt8>, val: rte_ipv4_tuple__cjbind_ty_1): Unit {
    unsafe { CPointer<rte_ipv4_tuple__cjbind_ty_1>(ptr).write(val) }
}

@C
func __cjbind_read_UInt32(ptr: CPointer<UInt8>): UInt32 {
    return unsafe { CPointer<UInt32>(ptr).read() }
}

@C
func __cjbind_write_UInt32(ptr: CPointer<UInt8>, val: UInt32): Unit {
    unsafe { CPointer<UInt32>(ptr).write(val) }
}

@C
func __cjbind_read_rte_ipv6_tuple__cjbind_ty_1(ptr: CPointer<UInt8>): rte_ipv6_tuple__cjbind_ty_1 {
    return unsafe { CPointer<rte_ipv6_tuple__cjbind_ty_1>(ptr).read() }
}

@C
func __cjbind_write_rte_ipv6_tuple__cjbind_ty_1(ptr: CPointer<UInt8>, val: rte_ipv6_tuple__cjbind_ty_1): Unit {
    unsafe { CPointer<rte_ipv6_tuple__cjbind_ty_1>(ptr).write(val) }
}

@C
func __cjbind_read_rte_ipv4_tuple_rte_ipv4_tuple(ptr: CPointer<UInt8>): rte_ipv4_tuple_rte_ipv4_tuple {
    return unsafe { CPointer<rte_ipv4_tuple_rte_ipv4_tuple>(ptr).read() }
}

@C
func __cjbind_write_rte_ipv4_tuple_rte_ipv4_tuple(ptr: CPointer<UInt8>, val: rte_ipv4_tuple_rte_ipv4_tuple): Unit {
    unsafe { CPointer<rte_ipv4_tuple_rte_ipv4_tuple>(ptr).write(val) }
}

@C
func __cjbind_read_rte_ipv6_tuple_rte_ipv6_tuple(ptr: CPointer<UInt8>): rte_ipv6_tuple_rte_ipv6_tuple {
    return unsafe { CPointer<rte_ipv6_tuple_rte_ipv6_tuple>(ptr).read() }
}

@C
func __cjbind_write_rte_ipv6_tuple_rte_ipv6_tuple(ptr: CPointer<UInt8>, val: rte_ipv6_tuple_rte_ipv6_tuple): Unit {
    unsafe { CPointer<rte_ipv6_tuple_rte_ipv6_tuple>(ptr).write(val) }
}

package cjbind_ffi

@C
public struct rte_ipv4_tuple__cjbind_ty_1 {
public let dport : UInt16
public let sport : UInt16
public init(dport : UInt16, sport : UInt16) {
    this.dport = dport
this.sport = sport
}
}

@When[debug]
let _ = {
=>
    let size = sizeOf<rte_ipv4_tuple__cjbind_ty_1>()
    if (size != 4) {
        throw Exception("Size of rte_ipv4_tuple__cjbind_ty_1 is not 4 but ${size} bytes")
    }
    let align = alignOf<rte_ipv4_tuple__cjbind_ty_1>()
    if (align != 2) {
        throw Exception("Alignment of rte_ipv4_tuple__cjbind_ty_1 is not 2 but ${align} bytes")
    }
}

@C
public struct rte_ipv4_tuple__cjbind_ty_1 {
var _storage: UInt32 = unsafe { zeroValue<UInt32>() }
public init() {}
public func __cjbind_anon_1(): rte_ipv4_tuple__cjbind_ty_1 {
    var s = this._storage
    return unsafe { __cjbind_read_rte_ipv4_tuple__cjbind_ty_1(CPointer<UInt8>(inout s)) }
}
public mut func __cjbind_anon_1(val!: rte_ipv4_tuple__cjbind_ty_1): Unit {
    unsafe { __cjbind_write_rte_ipv4_tuple__cjbind_ty_1(CPointer<UInt8>(inout this._storage), val) }
}
public func sctp_tag(): UInt32 {
    var s = this._storage
    return unsafe { __cjbind_read_UInt32(CPointer<UInt8>(inout s)) }
}
public mut func sctp_tag(val!: UInt32): Unit {
    unsafe { __cjbind_write_UInt32(CPointer<UInt8>(inout this._storage), val) }
}
}

@When[debug]
let _ = {
=>
    let size = sizeOf<rte_ipv4_tuple__cjbind_ty_1>()
    if (size != 4) {
        throw Exception("Size of rte_ipv4_tuple__cjbind_ty_1 is not 4 but ${size} bytes")
    }
    let align = alignOf<rte_ipv4_tuple__cjbind_ty_1>()
    if (align != 4) {
        throw Exception("Alignment of rte_ipv4_tuple__cjbind_ty_1 is not 4 but ${align} bytes")
    }
}

@C
public struct rte_ipv4_tuple_rte_ipv4_tuple {
public let src_addr : UInt32
public let dst_addr : UInt32
public let __cjbind_anon_1 : rte_ipv4_tuple__cjbind_ty_1
public init(src_addr : UInt32, dst_addr : UInt32, __cjbind_anon_1 : rte_ipv4_tuple__cjbind_ty_1) {
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
public struct rte_ipv6_tuple__cjbind_ty_1 {
public let dport : UInt16
public let sport : UInt16
public init(dport : UInt16, sport : UInt16) {
    this.dport = dport
this.sport = sport
}
}

@When[debug]
let _ = {
=>
    let size = sizeOf<rte_ipv6_tuple__cjbind_ty_1>()
    if (size != 4) {
        throw Exception("Size of rte_ipv6_tuple__cjbind_ty_1 is not 4 but ${size} bytes")
    }
    let align = alignOf<rte_ipv6_tuple__cjbind_ty_1>()
    if (align != 2) {
        throw Exception("Alignment of rte_ipv6_tuple__cjbind_ty_1 is not 2 but ${align} bytes")
    }
}

@C
public struct rte_ipv6_tuple__cjbind_ty_1 {
var _storage: UInt32 = unsafe { zeroValue<UInt32>() }
public init() {}
public func __cjbind_anon_1(): rte_ipv6_tuple__cjbind_ty_1 {
    var s = this._storage
    return unsafe { __cjbind_read_rte_ipv6_tuple__cjbind_ty_1(CPointer<UInt8>(inout s)) }
}
public mut func __cjbind_anon_1(val!: rte_ipv6_tuple__cjbind_ty_1): Unit {
    unsafe { __cjbind_write_rte_ipv6_tuple__cjbind_ty_1(CPointer<UInt8>(inout this._storage), val) }
}
public func sctp_tag(): UInt32 {
    var s = this._storage
    return unsafe { __cjbind_read_UInt32(CPointer<UInt8>(inout s)) }
}
public mut func sctp_tag(val!: UInt32): Unit {
    unsafe { __cjbind_write_UInt32(CPointer<UInt8>(inout this._storage), val) }
}
}

@When[debug]
let _ = {
=>
    let size = sizeOf<rte_ipv6_tuple__cjbind_ty_1>()
    if (size != 4) {
        throw Exception("Size of rte_ipv6_tuple__cjbind_ty_1 is not 4 but ${size} bytes")
    }
    let align = alignOf<rte_ipv6_tuple__cjbind_ty_1>()
    if (align != 4) {
        throw Exception("Alignment of rte_ipv6_tuple__cjbind_ty_1 is not 4 but ${align} bytes")
    }
}

@C
public struct rte_ipv6_tuple_rte_ipv6_tuple {
public let src_addr : VArray<UInt8, $16>
public let dst_addr : VArray<UInt8, $16>
public let __cjbind_anon_1 : rte_ipv6_tuple__cjbind_ty_1
public init(src_addr : VArray<UInt8, $16>, dst_addr : VArray<UInt8, $16>, __cjbind_anon_1 : rte_ipv6_tuple__cjbind_ty_1) {
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
var _storage: VArray<UInt8, $48> = unsafe { zeroValue<VArray<UInt8, $48>>() }
public init() {}
public func v4(): rte_ipv4_tuple_rte_ipv4_tuple {
    var s = this._storage
    return unsafe { __cjbind_read_rte_ipv4_tuple_rte_ipv4_tuple(CPointer<UInt8>(inout s)) }
}
public mut func v4(val!: rte_ipv4_tuple_rte_ipv4_tuple): Unit {
    unsafe { __cjbind_write_rte_ipv4_tuple_rte_ipv4_tuple(CPointer<UInt8>(inout this._storage), val) }
}
public func v6(): rte_ipv6_tuple_rte_ipv6_tuple {
    var s = this._storage
    return unsafe { __cjbind_read_rte_ipv6_tuple_rte_ipv6_tuple(CPointer<UInt8>(inout s)) }
}
public mut func v6(val!: rte_ipv6_tuple_rte_ipv6_tuple): Unit {
    unsafe { __cjbind_write_rte_ipv6_tuple_rte_ipv6_tuple(CPointer<UInt8>(inout this._storage), val) }
}
}

@When[debug]
let _ = {
=>
    let size = sizeOf<rte_thash_tuple_rte_thash_tuple>()
    if (size != 48) {
        throw Exception("Size of rte_thash_tuple_rte_thash_tuple is not 48 but ${size} bytes")
    }
    let align = alignOf<rte_thash_tuple_rte_thash_tuple>()
    if (align != 16) {
        throw Exception("Alignment of rte_thash_tuple_rte_thash_tuple is not 16 but ${align} bytes")
    }
}