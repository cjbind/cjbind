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

public const MyEnum_ONE : MyEnum_MyEnum = 0

public const MyEnum_TWO : MyEnum_MyEnum = 1

public const MyEnum_THREE : MyEnum_MyEnum = 2

public const MyEnum_FOUR : MyEnum_MyEnum = 3

public type MyEnum_MyEnum = UInt32

@C
public struct TaggedPtr_TaggedPtr {
var _bitfield_1 : VArray<UInt8, $8> = VArray<UInt8, $8>(repeat: 0)
public func tag(): MyEnum_MyEnum {
    var s = this._bitfield_1
    return MyEnum_MyEnum(unsafe { __cjbind_bitfield_read(inout s, 0, 2) })
}
public mut func tag(val!: MyEnum_MyEnum): Unit {
    unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 0, 2, UInt64(val)) }
}
public func ptr(): Int64 {
    var s = this._bitfield_1
    return Int64(unsafe { __cjbind_bitfield_read_signed(inout s, 2, 62) })
}
public mut func ptr(val!: Int64): Unit {
    unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 2, 62, UInt64(val)) }
}
public init() {}
}

@When[debug]
let _ = {
=>
    let size = sizeOf<TaggedPtr_TaggedPtr>()
    if (size != 8) {
        throw Exception("Size of TaggedPtr_TaggedPtr is not 8 but ${size} bytes")
    }
    let align = alignOf<TaggedPtr_TaggedPtr>()
    if (align != 8) {
        throw Exception("Alignment of TaggedPtr_TaggedPtr is not 8 but ${align} bytes")
    }
}