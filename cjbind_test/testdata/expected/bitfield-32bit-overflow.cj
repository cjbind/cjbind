package cjbind_ffi

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
    var fieldMask: UInt64 = if (bitWidth + bitShift < 64) {
        ((UInt64(1) << UInt64(bitWidth)) - 1) << UInt64(bitShift)
    } else {
        !UInt64(0) << UInt64(bitShift)
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
    let raw = unsafe { __cjbind_bitfield_read(ptr, bitOffset, bitWidth) }
    if (bitWidth > 0 && bitWidth < 64 && (raw & (UInt64(1) << UInt64(bitWidth - 1))) != 0) {
        return Int64(raw | !((UInt64(1) << UInt64(bitWidth)) - 1))
    }
    return Int64(raw)
}

@C
public struct MuchBitfield_MuchBitfield {
    var _bitfield_1: VArray<UInt8, $5> = VArray<UInt8, $5>(repeat: 0)
    public func m0(): UInt8 {
        var s = this._bitfield_1
        return UInt8(unsafe { __cjbind_bitfield_read_signed(inout s, 0, 1) })
    }
    public mut func m0(val!: UInt8): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 0, 1, UInt64(val)) }
    }
    public func m1(): UInt8 {
        var s = this._bitfield_1
        return UInt8(unsafe { __cjbind_bitfield_read_signed(inout s, 1, 1) })
    }
    public mut func m1(val!: UInt8): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 1, 1, UInt64(val)) }
    }
    public func m2(): UInt8 {
        var s = this._bitfield_1
        return UInt8(unsafe { __cjbind_bitfield_read_signed(inout s, 2, 1) })
    }
    public mut func m2(val!: UInt8): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 2, 1, UInt64(val)) }
    }
    public func m3(): UInt8 {
        var s = this._bitfield_1
        return UInt8(unsafe { __cjbind_bitfield_read_signed(inout s, 3, 1) })
    }
    public mut func m3(val!: UInt8): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 3, 1, UInt64(val)) }
    }
    public func m4(): UInt8 {
        var s = this._bitfield_1
        return UInt8(unsafe { __cjbind_bitfield_read_signed(inout s, 4, 1) })
    }
    public mut func m4(val!: UInt8): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 4, 1, UInt64(val)) }
    }
    public func m5(): UInt8 {
        var s = this._bitfield_1
        return UInt8(unsafe { __cjbind_bitfield_read_signed(inout s, 5, 1) })
    }
    public mut func m5(val!: UInt8): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 5, 1, UInt64(val)) }
    }
    public func m6(): UInt8 {
        var s = this._bitfield_1
        return UInt8(unsafe { __cjbind_bitfield_read_signed(inout s, 6, 1) })
    }
    public mut func m6(val!: UInt8): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 6, 1, UInt64(val)) }
    }
    public func m7(): UInt8 {
        var s = this._bitfield_1
        return UInt8(unsafe { __cjbind_bitfield_read_signed(inout s, 7, 1) })
    }
    public mut func m7(val!: UInt8): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 7, 1, UInt64(val)) }
    }
    public func m8(): UInt8 {
        var s = this._bitfield_1
        return UInt8(unsafe { __cjbind_bitfield_read_signed(inout s, 8, 1) })
    }
    public mut func m8(val!: UInt8): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 8, 1, UInt64(val)) }
    }
    public func m9(): UInt8 {
        var s = this._bitfield_1
        return UInt8(unsafe { __cjbind_bitfield_read_signed(inout s, 9, 1) })
    }
    public mut func m9(val!: UInt8): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 9, 1, UInt64(val)) }
    }
    public func m10(): UInt8 {
        var s = this._bitfield_1
        return UInt8(unsafe { __cjbind_bitfield_read_signed(inout s, 10, 1) })
    }
    public mut func m10(val!: UInt8): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 10, 1, UInt64(val)) }
    }
    public func m11(): UInt8 {
        var s = this._bitfield_1
        return UInt8(unsafe { __cjbind_bitfield_read_signed(inout s, 11, 1) })
    }
    public mut func m11(val!: UInt8): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 11, 1, UInt64(val)) }
    }
    public func m12(): UInt8 {
        var s = this._bitfield_1
        return UInt8(unsafe { __cjbind_bitfield_read_signed(inout s, 12, 1) })
    }
    public mut func m12(val!: UInt8): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 12, 1, UInt64(val)) }
    }
    public func m13(): UInt8 {
        var s = this._bitfield_1
        return UInt8(unsafe { __cjbind_bitfield_read_signed(inout s, 13, 1) })
    }
    public mut func m13(val!: UInt8): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 13, 1, UInt64(val)) }
    }
    public func m14(): UInt8 {
        var s = this._bitfield_1
        return UInt8(unsafe { __cjbind_bitfield_read_signed(inout s, 14, 1) })
    }
    public mut func m14(val!: UInt8): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 14, 1, UInt64(val)) }
    }
    public func m15(): UInt8 {
        var s = this._bitfield_1
        return UInt8(unsafe { __cjbind_bitfield_read_signed(inout s, 15, 1) })
    }
    public mut func m15(val!: UInt8): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 15, 1, UInt64(val)) }
    }
    public func m16(): UInt8 {
        var s = this._bitfield_1
        return UInt8(unsafe { __cjbind_bitfield_read_signed(inout s, 16, 1) })
    }
    public mut func m16(val!: UInt8): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 16, 1, UInt64(val)) }
    }
    public func m17(): UInt8 {
        var s = this._bitfield_1
        return UInt8(unsafe { __cjbind_bitfield_read_signed(inout s, 17, 1) })
    }
    public mut func m17(val!: UInt8): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 17, 1, UInt64(val)) }
    }
    public func m18(): UInt8 {
        var s = this._bitfield_1
        return UInt8(unsafe { __cjbind_bitfield_read_signed(inout s, 18, 1) })
    }
    public mut func m18(val!: UInt8): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 18, 1, UInt64(val)) }
    }
    public func m19(): UInt8 {
        var s = this._bitfield_1
        return UInt8(unsafe { __cjbind_bitfield_read_signed(inout s, 19, 1) })
    }
    public mut func m19(val!: UInt8): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 19, 1, UInt64(val)) }
    }
    public func m20(): UInt8 {
        var s = this._bitfield_1
        return UInt8(unsafe { __cjbind_bitfield_read_signed(inout s, 20, 1) })
    }
    public mut func m20(val!: UInt8): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 20, 1, UInt64(val)) }
    }
    public func m21(): UInt8 {
        var s = this._bitfield_1
        return UInt8(unsafe { __cjbind_bitfield_read_signed(inout s, 21, 1) })
    }
    public mut func m21(val!: UInt8): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 21, 1, UInt64(val)) }
    }
    public func m22(): UInt8 {
        var s = this._bitfield_1
        return UInt8(unsafe { __cjbind_bitfield_read_signed(inout s, 22, 1) })
    }
    public mut func m22(val!: UInt8): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 22, 1, UInt64(val)) }
    }
    public func m23(): UInt8 {
        var s = this._bitfield_1
        return UInt8(unsafe { __cjbind_bitfield_read_signed(inout s, 23, 1) })
    }
    public mut func m23(val!: UInt8): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 23, 1, UInt64(val)) }
    }
    public func m24(): UInt8 {
        var s = this._bitfield_1
        return UInt8(unsafe { __cjbind_bitfield_read_signed(inout s, 24, 1) })
    }
    public mut func m24(val!: UInt8): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 24, 1, UInt64(val)) }
    }
    public func m25(): UInt8 {
        var s = this._bitfield_1
        return UInt8(unsafe { __cjbind_bitfield_read_signed(inout s, 25, 1) })
    }
    public mut func m25(val!: UInt8): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 25, 1, UInt64(val)) }
    }
    public func m26(): UInt8 {
        var s = this._bitfield_1
        return UInt8(unsafe { __cjbind_bitfield_read_signed(inout s, 26, 1) })
    }
    public mut func m26(val!: UInt8): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 26, 1, UInt64(val)) }
    }
    public func m27(): UInt8 {
        var s = this._bitfield_1
        return UInt8(unsafe { __cjbind_bitfield_read_signed(inout s, 27, 1) })
    }
    public mut func m27(val!: UInt8): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 27, 1, UInt64(val)) }
    }
    public func m28(): UInt8 {
        var s = this._bitfield_1
        return UInt8(unsafe { __cjbind_bitfield_read_signed(inout s, 28, 1) })
    }
    public mut func m28(val!: UInt8): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 28, 1, UInt64(val)) }
    }
    public func m29(): UInt8 {
        var s = this._bitfield_1
        return UInt8(unsafe { __cjbind_bitfield_read_signed(inout s, 29, 1) })
    }
    public mut func m29(val!: UInt8): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 29, 1, UInt64(val)) }
    }
    public func m30(): UInt8 {
        var s = this._bitfield_1
        return UInt8(unsafe { __cjbind_bitfield_read_signed(inout s, 30, 1) })
    }
    public mut func m30(val!: UInt8): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 30, 1, UInt64(val)) }
    }
    public func m31(): UInt8 {
        var s = this._bitfield_1
        return UInt8(unsafe { __cjbind_bitfield_read_signed(inout s, 31, 1) })
    }
    public mut func m31(val!: UInt8): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 31, 1, UInt64(val)) }
    }
    public func m32(): UInt8 {
        var s = this._bitfield_1
        return UInt8(unsafe { __cjbind_bitfield_read_signed(inout s, 32, 1) })
    }
    public mut func m32(val!: UInt8): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 32, 1, UInt64(val)) }
    }
    public init() {}
    public func clone(): MuchBitfield_MuchBitfield {
        return this
    }
    public func toString(): String {
        var output = "MuchBitfield_MuchBitfield {"
        output += " m0: "
        output += this.m0().toString()
        output += ", m1: "
        output += this.m1().toString()
        output += ", m2: "
        output += this.m2().toString()
        output += ", m3: "
        output += this.m3().toString()
        output += ", m4: "
        output += this.m4().toString()
        output += ", m5: "
        output += this.m5().toString()
        output += ", m6: "
        output += this.m6().toString()
        output += ", m7: "
        output += this.m7().toString()
        output += ", m8: "
        output += this.m8().toString()
        output += ", m9: "
        output += this.m9().toString()
        output += ", m10: "
        output += this.m10().toString()
        output += ", m11: "
        output += this.m11().toString()
        output += ", m12: "
        output += this.m12().toString()
        output += ", m13: "
        output += this.m13().toString()
        output += ", m14: "
        output += this.m14().toString()
        output += ", m15: "
        output += this.m15().toString()
        output += ", m16: "
        output += this.m16().toString()
        output += ", m17: "
        output += this.m17().toString()
        output += ", m18: "
        output += this.m18().toString()
        output += ", m19: "
        output += this.m19().toString()
        output += ", m20: "
        output += this.m20().toString()
        output += ", m21: "
        output += this.m21().toString()
        output += ", m22: "
        output += this.m22().toString()
        output += ", m23: "
        output += this.m23().toString()
        output += ", m24: "
        output += this.m24().toString()
        output += ", m25: "
        output += this.m25().toString()
        output += ", m26: "
        output += this.m26().toString()
        output += ", m27: "
        output += this.m27().toString()
        output += ", m28: "
        output += this.m28().toString()
        output += ", m29: "
        output += this.m29().toString()
        output += ", m30: "
        output += this.m30().toString()
        output += ", m31: "
        output += this.m31().toString()
        output += ", m32: "
        output += this.m32().toString()
        output += " }"
        return output
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<MuchBitfield_MuchBitfield>()
        if (size != 5) {
            throw Exception("Size of MuchBitfield_MuchBitfield is not 5 but ${size} bytes")
        }
        let align = alignOf<MuchBitfield_MuchBitfield>()
        if (align != 1) {
            throw Exception("Alignment of MuchBitfield_MuchBitfield is not 1 but ${align} bytes")
        }
}

@C
public struct capabilities_capabilities {
    var _bitfield_1: VArray<UInt8, $16> = VArray<UInt8, $16>(repeat: 0)
    public func bit_1(): UInt32 {
        var s = this._bitfield_1
        return UInt32(unsafe { __cjbind_bitfield_read(inout s, 0, 1) })
    }
    public mut func bit_1(val!: UInt32): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 0, 1, UInt64(val)) }
    }
    public func bit_2(): UInt32 {
        var s = this._bitfield_1
        return UInt32(unsafe { __cjbind_bitfield_read(inout s, 1, 1) })
    }
    public mut func bit_2(val!: UInt32): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 1, 1, UInt64(val)) }
    }
    public func bit_3(): UInt32 {
        var s = this._bitfield_1
        return UInt32(unsafe { __cjbind_bitfield_read(inout s, 2, 1) })
    }
    public mut func bit_3(val!: UInt32): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 2, 1, UInt64(val)) }
    }
    public func bit_4(): UInt32 {
        var s = this._bitfield_1
        return UInt32(unsafe { __cjbind_bitfield_read(inout s, 3, 1) })
    }
    public mut func bit_4(val!: UInt32): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 3, 1, UInt64(val)) }
    }
    public func bit_5(): UInt32 {
        var s = this._bitfield_1
        return UInt32(unsafe { __cjbind_bitfield_read(inout s, 4, 1) })
    }
    public mut func bit_5(val!: UInt32): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 4, 1, UInt64(val)) }
    }
    public func bit_6(): UInt32 {
        var s = this._bitfield_1
        return UInt32(unsafe { __cjbind_bitfield_read(inout s, 5, 1) })
    }
    public mut func bit_6(val!: UInt32): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 5, 1, UInt64(val)) }
    }
    public func bit_7(): UInt32 {
        var s = this._bitfield_1
        return UInt32(unsafe { __cjbind_bitfield_read(inout s, 6, 1) })
    }
    public mut func bit_7(val!: UInt32): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 6, 1, UInt64(val)) }
    }
    public func bit_8(): UInt32 {
        var s = this._bitfield_1
        return UInt32(unsafe { __cjbind_bitfield_read(inout s, 7, 1) })
    }
    public mut func bit_8(val!: UInt32): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 7, 1, UInt64(val)) }
    }
    public func bit_9(): UInt32 {
        var s = this._bitfield_1
        return UInt32(unsafe { __cjbind_bitfield_read(inout s, 8, 1) })
    }
    public mut func bit_9(val!: UInt32): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 8, 1, UInt64(val)) }
    }
    public func bit_10(): UInt32 {
        var s = this._bitfield_1
        return UInt32(unsafe { __cjbind_bitfield_read(inout s, 9, 1) })
    }
    public mut func bit_10(val!: UInt32): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 9, 1, UInt64(val)) }
    }
    public func bit_11(): UInt32 {
        var s = this._bitfield_1
        return UInt32(unsafe { __cjbind_bitfield_read(inout s, 10, 1) })
    }
    public mut func bit_11(val!: UInt32): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 10, 1, UInt64(val)) }
    }
    public func bit_12(): UInt32 {
        var s = this._bitfield_1
        return UInt32(unsafe { __cjbind_bitfield_read(inout s, 11, 1) })
    }
    public mut func bit_12(val!: UInt32): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 11, 1, UInt64(val)) }
    }
    public func bit_13(): UInt32 {
        var s = this._bitfield_1
        return UInt32(unsafe { __cjbind_bitfield_read(inout s, 12, 1) })
    }
    public mut func bit_13(val!: UInt32): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 12, 1, UInt64(val)) }
    }
    public func bit_14(): UInt32 {
        var s = this._bitfield_1
        return UInt32(unsafe { __cjbind_bitfield_read(inout s, 13, 1) })
    }
    public mut func bit_14(val!: UInt32): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 13, 1, UInt64(val)) }
    }
    public func bit_15(): UInt32 {
        var s = this._bitfield_1
        return UInt32(unsafe { __cjbind_bitfield_read(inout s, 14, 1) })
    }
    public mut func bit_15(val!: UInt32): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 14, 1, UInt64(val)) }
    }
    public func bit_16(): UInt32 {
        var s = this._bitfield_1
        return UInt32(unsafe { __cjbind_bitfield_read(inout s, 15, 1) })
    }
    public mut func bit_16(val!: UInt32): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 15, 1, UInt64(val)) }
    }
    public func bit_17(): UInt32 {
        var s = this._bitfield_1
        return UInt32(unsafe { __cjbind_bitfield_read(inout s, 16, 1) })
    }
    public mut func bit_17(val!: UInt32): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 16, 1, UInt64(val)) }
    }
    public func bit_18(): UInt32 {
        var s = this._bitfield_1
        return UInt32(unsafe { __cjbind_bitfield_read(inout s, 17, 1) })
    }
    public mut func bit_18(val!: UInt32): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 17, 1, UInt64(val)) }
    }
    public func bit_19(): UInt32 {
        var s = this._bitfield_1
        return UInt32(unsafe { __cjbind_bitfield_read(inout s, 18, 1) })
    }
    public mut func bit_19(val!: UInt32): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 18, 1, UInt64(val)) }
    }
    public func bit_20(): UInt32 {
        var s = this._bitfield_1
        return UInt32(unsafe { __cjbind_bitfield_read(inout s, 19, 1) })
    }
    public mut func bit_20(val!: UInt32): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 19, 1, UInt64(val)) }
    }
    public func bit_21(): UInt32 {
        var s = this._bitfield_1
        return UInt32(unsafe { __cjbind_bitfield_read(inout s, 20, 1) })
    }
    public mut func bit_21(val!: UInt32): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 20, 1, UInt64(val)) }
    }
    public func bit_22(): UInt32 {
        var s = this._bitfield_1
        return UInt32(unsafe { __cjbind_bitfield_read(inout s, 21, 1) })
    }
    public mut func bit_22(val!: UInt32): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 21, 1, UInt64(val)) }
    }
    public func bit_23(): UInt32 {
        var s = this._bitfield_1
        return UInt32(unsafe { __cjbind_bitfield_read(inout s, 22, 1) })
    }
    public mut func bit_23(val!: UInt32): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 22, 1, UInt64(val)) }
    }
    public func bit_24(): UInt32 {
        var s = this._bitfield_1
        return UInt32(unsafe { __cjbind_bitfield_read(inout s, 23, 1) })
    }
    public mut func bit_24(val!: UInt32): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 23, 1, UInt64(val)) }
    }
    public func bit_25(): UInt32 {
        var s = this._bitfield_1
        return UInt32(unsafe { __cjbind_bitfield_read(inout s, 24, 1) })
    }
    public mut func bit_25(val!: UInt32): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 24, 1, UInt64(val)) }
    }
    public func bit_26(): UInt32 {
        var s = this._bitfield_1
        return UInt32(unsafe { __cjbind_bitfield_read(inout s, 25, 1) })
    }
    public mut func bit_26(val!: UInt32): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 25, 1, UInt64(val)) }
    }
    public func bit_27(): UInt32 {
        var s = this._bitfield_1
        return UInt32(unsafe { __cjbind_bitfield_read(inout s, 26, 1) })
    }
    public mut func bit_27(val!: UInt32): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 26, 1, UInt64(val)) }
    }
    public func bit_28(): UInt32 {
        var s = this._bitfield_1
        return UInt32(unsafe { __cjbind_bitfield_read(inout s, 27, 1) })
    }
    public mut func bit_28(val!: UInt32): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 27, 1, UInt64(val)) }
    }
    public func bit_29(): UInt32 {
        var s = this._bitfield_1
        return UInt32(unsafe { __cjbind_bitfield_read(inout s, 28, 1) })
    }
    public mut func bit_29(val!: UInt32): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 28, 1, UInt64(val)) }
    }
    public func bit_30(): UInt32 {
        var s = this._bitfield_1
        return UInt32(unsafe { __cjbind_bitfield_read(inout s, 29, 1) })
    }
    public mut func bit_30(val!: UInt32): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 29, 1, UInt64(val)) }
    }
    public func bit_31(): UInt32 {
        var s = this._bitfield_1
        return UInt32(unsafe { __cjbind_bitfield_read(inout s, 30, 1) })
    }
    public mut func bit_31(val!: UInt32): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 30, 1, UInt64(val)) }
    }
    public func bit_32(): UInt32 {
        var s = this._bitfield_1
        return UInt32(unsafe { __cjbind_bitfield_read(inout s, 31, 1) })
    }
    public mut func bit_32(val!: UInt32): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 31, 1, UInt64(val)) }
    }
    public func bit_33(): UInt32 {
        var s = this._bitfield_1
        return UInt32(unsafe { __cjbind_bitfield_read(inout s, 32, 1) })
    }
    public mut func bit_33(val!: UInt32): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 32, 1, UInt64(val)) }
    }
    public func bit_34(): UInt32 {
        var s = this._bitfield_1
        return UInt32(unsafe { __cjbind_bitfield_read(inout s, 33, 1) })
    }
    public mut func bit_34(val!: UInt32): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 33, 1, UInt64(val)) }
    }
    public func bit_35(): UInt32 {
        var s = this._bitfield_1
        return UInt32(unsafe { __cjbind_bitfield_read(inout s, 34, 1) })
    }
    public mut func bit_35(val!: UInt32): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 34, 1, UInt64(val)) }
    }
    public func bit_36(): UInt32 {
        var s = this._bitfield_1
        return UInt32(unsafe { __cjbind_bitfield_read(inout s, 35, 1) })
    }
    public mut func bit_36(val!: UInt32): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 35, 1, UInt64(val)) }
    }
    public func bit_37(): UInt32 {
        var s = this._bitfield_1
        return UInt32(unsafe { __cjbind_bitfield_read(inout s, 36, 1) })
    }
    public mut func bit_37(val!: UInt32): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 36, 1, UInt64(val)) }
    }
    public func bit_38(): UInt32 {
        var s = this._bitfield_1
        return UInt32(unsafe { __cjbind_bitfield_read(inout s, 37, 1) })
    }
    public mut func bit_38(val!: UInt32): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 37, 1, UInt64(val)) }
    }
    public func bit_39(): UInt32 {
        var s = this._bitfield_1
        return UInt32(unsafe { __cjbind_bitfield_read(inout s, 38, 1) })
    }
    public mut func bit_39(val!: UInt32): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 38, 1, UInt64(val)) }
    }
    public func bit_40(): UInt32 {
        var s = this._bitfield_1
        return UInt32(unsafe { __cjbind_bitfield_read(inout s, 39, 1) })
    }
    public mut func bit_40(val!: UInt32): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 39, 1, UInt64(val)) }
    }
    public func bit_41(): UInt32 {
        var s = this._bitfield_1
        return UInt32(unsafe { __cjbind_bitfield_read(inout s, 40, 1) })
    }
    public mut func bit_41(val!: UInt32): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 40, 1, UInt64(val)) }
    }
    public init() {}
    public func clone(): capabilities_capabilities {
        return this
    }
    public func toString(): String {
        var output = "capabilities_capabilities {"
        output += " bit_1: "
        output += this.bit_1().toString()
        output += ", bit_2: "
        output += this.bit_2().toString()
        output += ", bit_3: "
        output += this.bit_3().toString()
        output += ", bit_4: "
        output += this.bit_4().toString()
        output += ", bit_5: "
        output += this.bit_5().toString()
        output += ", bit_6: "
        output += this.bit_6().toString()
        output += ", bit_7: "
        output += this.bit_7().toString()
        output += ", bit_8: "
        output += this.bit_8().toString()
        output += ", bit_9: "
        output += this.bit_9().toString()
        output += ", bit_10: "
        output += this.bit_10().toString()
        output += ", bit_11: "
        output += this.bit_11().toString()
        output += ", bit_12: "
        output += this.bit_12().toString()
        output += ", bit_13: "
        output += this.bit_13().toString()
        output += ", bit_14: "
        output += this.bit_14().toString()
        output += ", bit_15: "
        output += this.bit_15().toString()
        output += ", bit_16: "
        output += this.bit_16().toString()
        output += ", bit_17: "
        output += this.bit_17().toString()
        output += ", bit_18: "
        output += this.bit_18().toString()
        output += ", bit_19: "
        output += this.bit_19().toString()
        output += ", bit_20: "
        output += this.bit_20().toString()
        output += ", bit_21: "
        output += this.bit_21().toString()
        output += ", bit_22: "
        output += this.bit_22().toString()
        output += ", bit_23: "
        output += this.bit_23().toString()
        output += ", bit_24: "
        output += this.bit_24().toString()
        output += ", bit_25: "
        output += this.bit_25().toString()
        output += ", bit_26: "
        output += this.bit_26().toString()
        output += ", bit_27: "
        output += this.bit_27().toString()
        output += ", bit_28: "
        output += this.bit_28().toString()
        output += ", bit_29: "
        output += this.bit_29().toString()
        output += ", bit_30: "
        output += this.bit_30().toString()
        output += ", bit_31: "
        output += this.bit_31().toString()
        output += ", bit_32: "
        output += this.bit_32().toString()
        output += ", bit_33: "
        output += this.bit_33().toString()
        output += ", bit_34: "
        output += this.bit_34().toString()
        output += ", bit_35: "
        output += this.bit_35().toString()
        output += ", bit_36: "
        output += this.bit_36().toString()
        output += ", bit_37: "
        output += this.bit_37().toString()
        output += ", bit_38: "
        output += this.bit_38().toString()
        output += ", bit_39: "
        output += this.bit_39().toString()
        output += ", bit_40: "
        output += this.bit_40().toString()
        output += ", bit_41: "
        output += this.bit_41().toString()
        output += " }"
        return output
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<capabilities_capabilities>()
        if (size != 16) {
            throw Exception("Size of capabilities_capabilities is not 16 but ${size} bytes")
        }
        let align = alignOf<capabilities_capabilities>()
        if (align != 4) {
            throw Exception("Alignment of capabilities_capabilities is not 4 but ${align} bytes")
        }
}
