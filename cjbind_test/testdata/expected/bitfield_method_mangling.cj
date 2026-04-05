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
public struct mach_msg_type_descriptor_t_mach_msg_type_descriptor_t {
var _bitfield_1 : VArray<UInt8, $4> = VArray<UInt8, $4>(repeat: 0)
public func pad3(): UInt32 {
    var s = this._bitfield_1
    return UInt32(unsafe { __cjbind_bitfield_read(inout s, 0, 24) })
}
public mut func pad3(val!: UInt32): Unit {
    unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 0, 24, UInt64(val)) }
}
public func type_(): UInt32 {
    var s = this._bitfield_1
    return UInt32(unsafe { __cjbind_bitfield_read(inout s, 24, 8) })
}
public mut func type_(val!: UInt32): Unit {
    unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 24, 8, UInt64(val)) }
}
public init() {}
}

@When[debug]
let _ = {
=>
    let size = sizeOf<mach_msg_type_descriptor_t_mach_msg_type_descriptor_t>()
    if (size != 4) {
        throw Exception("Size of mach_msg_type_descriptor_t_mach_msg_type_descriptor_t is not 4 but ${size} bytes")
    }
    let align = alignOf<mach_msg_type_descriptor_t_mach_msg_type_descriptor_t>()
    if (align != 4) {
        throw Exception("Alignment of mach_msg_type_descriptor_t_mach_msg_type_descriptor_t is not 4 but ${align} bytes")
    }
}