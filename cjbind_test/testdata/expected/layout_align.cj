@C
func __cjbind_bitfield_read(ptr: CPointer<UInt8>, bitOffset: Int64, bitWidth: Int64): UInt64 {
    let startByte = bitOffset / 8
    let bitShift = bitOffset % 8
    let bytesNeeded = (bitWidth + bitShift + 7) / 8
    var val: UInt64 = 0
    var i: Int64 = 0
    while (i < bytesNeeded) {
        val = val | (UInt64(unsafe { ptr.read(startByte + i) }) << UInt64(i * 8))
        i++
    }
    val = val >> UInt64(bitShift)
    if (bitWidth < 64) {
        val = val & ((UInt64(1) << UInt64(bitWidth)) - 1)
    }
    return val
}

@C
func __cjbind_bitfield_write(ptr: CPointer<UInt8>, bitOffset: Int64, bitWidth: Int64, val: UInt64): Unit {
    let startByte = bitOffset / 8
    let bitShift = bitOffset % 8
    let bytesNeeded = (bitWidth + bitShift + 7) / 8
    var maskVal = val
    if (bitWidth < 64) {
        maskVal = maskVal & ((UInt64(1) << UInt64(bitWidth)) - 1)
    }
    maskVal = maskVal << UInt64(bitShift)
    var fieldMask: UInt64 = if (bitWidth < 64) {
        ((UInt64(1) << UInt64(bitWidth)) - 1) << UInt64(bitShift)
    } else {
        !UInt64(0)
    }
    var i: Int64 = 0
    while (i < bytesNeeded) {
        let byteVal = UInt8((maskVal >> UInt64(i * 8)) & 0xFF)
        let byteMask = UInt8((fieldMask >> UInt64(i * 8)) & 0xFF)
        let old = unsafe { ptr.read(startByte + i) }
        unsafe { ptr.write(startByte + i, (old & !byteMask) | (byteVal & byteMask)) }
        i++
    }
}

@C
func __cjbind_bitfield_read_signed(ptr: CPointer<UInt8>, bitOffset: Int64, bitWidth: Int64): Int64 {
    let raw = __cjbind_bitfield_read(ptr, bitOffset, bitWidth)
    if (bitWidth > 0 && bitWidth < 64 && (raw & (UInt64(1) << UInt64(bitWidth - 1))) != 0) {
        return Int64(raw | !((UInt64(1) << UInt64(bitWidth)) - 1))
    }
    return Int64(raw)
}

package cjbind_ffi

@C
public struct rte_kni_fifo_rte_kni_fifo {
//< Next position to be written*
public let write : UInt32
//< Next position to be read *
public let read : UInt32
//< Circular buffer length *
public let len : UInt32
//< Pointer size - for 32/64 bit OS *
public let elem_size : UInt32
//< The buffer contains mbuf pointers *
public let buffer : CPointer<CPointer<Unit>>
public init(write : UInt32, read : UInt32, len : UInt32, elem_size : UInt32, buffer : CPointer<CPointer<Unit>>) {
    this.write = write
this.read = read
this.len = len
this.elem_size = elem_size
this.buffer = buffer
}
}

@When[debug]
let _ = {
=>
    let size = sizeOf<rte_kni_fifo_rte_kni_fifo>()
    if (size != 16) {
        throw Exception("Size of rte_kni_fifo_rte_kni_fifo is not 16 but ${size} bytes")
    }
    let align = alignOf<rte_kni_fifo_rte_kni_fifo>()
    if (align != 8) {
        throw Exception("Alignment of rte_kni_fifo_rte_kni_fifo is not 8 but ${align} bytes")
    }
}

@C
public struct rte_eth_link_rte_eth_link {
//< ETH_SPEED_NUM_ *
public var link_speed : UInt32 = unsafe { zeroValue<UInt32>() }
var _bitfield_1 : VArray<UInt8, $1> = VArray<UInt8, $1>(repeat: 0)
public func link_duplex(): UInt16 {
    var s = this._bitfield_1
    return UInt16(unsafe { __cjbind_bitfield_read(inout s, 0, 1) })
}
public mut func link_duplex(val!: UInt16): Unit {
    unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 0, 1, UInt64(val)) }
}
public func link_autoneg(): UInt16 {
    var s = this._bitfield_1
    return UInt16(unsafe { __cjbind_bitfield_read(inout s, 1, 1) })
}
public mut func link_autoneg(val!: UInt16): Unit {
    unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 1, 1, UInt64(val)) }
}
public func link_status(): UInt16 {
    var s = this._bitfield_1
    return UInt16(unsafe { __cjbind_bitfield_read(inout s, 2, 1) })
}
public mut func link_status(val!: UInt16): Unit {
    unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 2, 1, UInt64(val)) }
}
public init() {}
}

@When[debug]
let _ = {
=>
    let size = sizeOf<rte_eth_link_rte_eth_link>()
    if (size != 8) {
        throw Exception("Size of rte_eth_link_rte_eth_link is not 8 but ${size} bytes")
    }
    let align = alignOf<rte_eth_link_rte_eth_link>()
    if (align != 8) {
        throw Exception("Alignment of rte_eth_link_rte_eth_link is not 8 but ${align} bytes")
    }
}