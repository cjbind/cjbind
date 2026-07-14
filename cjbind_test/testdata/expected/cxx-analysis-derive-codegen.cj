package cjbind_ffi

func __cjbind_read_UInt64_from_UInt64(storage: UInt64): UInt64 {
    var s = storage
    return unsafe { CPointer<UInt64>(CPointer<UInt8>(inout s)).read() }
}

func __cjbind_write_UInt64_from_UInt64(storage: UInt64, val: UInt64): UInt64 {
    var s = storage
    unsafe { CPointer<UInt64>(CPointer<UInt8>(inout s)).write(val) }
    return s
}

func __cjbind_read_Float64_from_UInt64(storage: UInt64): Float64 {
    var s = storage
    return unsafe { CPointer<Float64>(CPointer<UInt8>(inout s)).read() }
}

func __cjbind_write_Float64_from_UInt64(storage: UInt64, val: Float64): UInt64 {
    var s = storage
    unsafe { CPointer<Float64>(CPointer<UInt8>(inout s)).write(val) }
    return s
}

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
public struct OrderPair_OrderPair {
    public let first: Int32
    public let second: Int32
    public func clone(): OrderPair_OrderPair {
        return this
    }
    public func toString(): String {
        var output = "OrderPair_OrderPair {"
        output += " first: "
        output += this.first.toString()
        output += ", second: "
        output += this.second.toString()
        output += " }"
        return output
    }
    public operator func ==(right: OrderPair_OrderPair): Bool {
        if (this.first != right.first) {
            return false
        }
        if (this.second != right.second) {
            return false
        }
        return true
    }
    public operator func !=(right: OrderPair_OrderPair): Bool {
        return !(this == right)
    }
    public static func default(): OrderPair_OrderPair {
        return unsafe { zeroValue<OrderPair_OrderPair>() }
    }
    public func hashCode(): Int64 {
        var hash = 1469598103934665603i64
        hash = ((hash << 5) | (hash >> 59)) ^ this.first.hashCode()
        hash = ((hash << 5) | (hash >> 59)) ^ this.second.hashCode()
        return hash
    }
    public func __cjbindPartialCompare(right: OrderPair_OrderPair): ?Ordering {
        if (this.first < right.first) {
            return Some(Ordering.LT)
        }
        if (this.first > right.first) {
            return Some(Ordering.GT)
        }
        if (this.first != right.first) {
            return None
        }
        if (this.second < right.second) {
            return Some(Ordering.LT)
        }
        if (this.second > right.second) {
            return Some(Ordering.GT)
        }
        if (this.second != right.second) {
            return None
        }
        return Some(Ordering.EQ)
    }
    public operator func <(right: OrderPair_OrderPair): Bool {
        return match (this.__cjbindPartialCompare(right)) {
            case Some(Ordering.LT) => true
            case _ => false
        }
    }
    public operator func <=(right: OrderPair_OrderPair): Bool {
        return match (this.__cjbindPartialCompare(right)) {
            case Some(Ordering.LT) | Some(Ordering.EQ) => true
            case _ => false
        }
    }
    public operator func >(right: OrderPair_OrderPair): Bool {
        return match (this.__cjbindPartialCompare(right)) {
            case Some(Ordering.GT) => true
            case _ => false
        }
    }
    public operator func >=(right: OrderPair_OrderPair): Bool {
        return match (this.__cjbindPartialCompare(right)) {
            case Some(Ordering.GT) | Some(Ordering.EQ) => true
            case _ => false
        }
    }
    public func compare(right: OrderPair_OrderPair): Ordering {
        return match (this.__cjbindPartialCompare(right)) {
            case Some(value) => value
            case None => throw Exception("ordered comparison produced an unordered value")
        }
    }
    public init(first: Int32, second: Int32) {
        this.first = first
        this.second = second
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<OrderPair_OrderPair>()
        if (size != 8) {
            throw Exception("Size of OrderPair_OrderPair is not 8 but ${size} bytes")
        }
        let align = alignOf<OrderPair_OrderPair>()
        if (align != 4) {
            throw Exception("Alignment of OrderPair_OrderPair is not 4 but ${align} bytes")
        }
}

@C
public struct FloatRecord_FloatRecord {
    public let value: Float32
    public func clone(): FloatRecord_FloatRecord {
        return this
    }
    public func toString(): String {
        var output = "FloatRecord_FloatRecord {"
        output += " value: "
        output += this.value.toString()
        output += " }"
        return output
    }
    public operator func ==(right: FloatRecord_FloatRecord): Bool {
        if (this.value != right.value) {
            return false
        }
        return true
    }
    public operator func !=(right: FloatRecord_FloatRecord): Bool {
        return !(this == right)
    }
    public static func default(): FloatRecord_FloatRecord {
        return unsafe { zeroValue<FloatRecord_FloatRecord>() }
    }
    public func __cjbindPartialCompare(right: FloatRecord_FloatRecord): ?Ordering {
        if (this.value < right.value) {
            return Some(Ordering.LT)
        }
        if (this.value > right.value) {
            return Some(Ordering.GT)
        }
        if (this.value != right.value) {
            return None
        }
        return Some(Ordering.EQ)
    }
    public operator func <(right: FloatRecord_FloatRecord): Bool {
        return match (this.__cjbindPartialCompare(right)) {
            case Some(Ordering.LT) => true
            case _ => false
        }
    }
    public operator func <=(right: FloatRecord_FloatRecord): Bool {
        return match (this.__cjbindPartialCompare(right)) {
            case Some(Ordering.LT) | Some(Ordering.EQ) => true
            case _ => false
        }
    }
    public operator func >(right: FloatRecord_FloatRecord): Bool {
        return match (this.__cjbindPartialCompare(right)) {
            case Some(Ordering.GT) => true
            case _ => false
        }
    }
    public operator func >=(right: FloatRecord_FloatRecord): Bool {
        return match (this.__cjbindPartialCompare(right)) {
            case Some(Ordering.GT) | Some(Ordering.EQ) => true
            case _ => false
        }
    }
    public init(value: Float32) {
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<FloatRecord_FloatRecord>()
        if (size != 4) {
            throw Exception("Size of FloatRecord_FloatRecord is not 4 but ${size} bytes")
        }
        let align = alignOf<FloatRecord_FloatRecord>()
        if (align != 4) {
            throw Exception("Alignment of FloatRecord_FloatRecord is not 4 but ${align} bytes")
        }
}

@C
public struct LargeArray_LargeArray {
    public let values: VArray<Int32, $40>
    public func clone(): LargeArray_LargeArray {
        return this
    }
    public func toString(): String {
        var output = "LargeArray_LargeArray {"
        output += " values: "
        output += "["
        for (__cjbindDebugIndex0 in 0..40) {
            if (__cjbindDebugIndex0 != 0) {
                output += ", "
            }
            output += this.values[__cjbindDebugIndex0].toString()
        }
        output += "]"
        output += " }"
        return output
    }
    public operator func ==(right: LargeArray_LargeArray): Bool {
        for (__cjbindEqIndex0 in 0..40) {
            if (this.values[__cjbindEqIndex0] != right.values[__cjbindEqIndex0]) {
                return false
            }
        }
        return true
    }
    public operator func !=(right: LargeArray_LargeArray): Bool {
        return !(this == right)
    }
    public func hashCode(): Int64 {
        var hash = 1469598103934665603i64
        for (__cjbindHashIndex0 in 0..40) {
            hash = ((hash << 5) | (hash >> 59)) ^ this.values[__cjbindHashIndex0].hashCode()
        }
        return hash
    }
    public func __cjbindPartialCompare(right: LargeArray_LargeArray): ?Ordering {
        for (__cjbindOrdIndex0 in 0..40) {
            if (this.values[__cjbindOrdIndex0] < right.values[__cjbindOrdIndex0]) {
                return Some(Ordering.LT)
            }
            if (this.values[__cjbindOrdIndex0] > right.values[__cjbindOrdIndex0]) {
                return Some(Ordering.GT)
            }
            if (this.values[__cjbindOrdIndex0] != right.values[__cjbindOrdIndex0]) {
                return None
            }
        }
        return Some(Ordering.EQ)
    }
    public operator func <(right: LargeArray_LargeArray): Bool {
        return match (this.__cjbindPartialCompare(right)) {
            case Some(Ordering.LT) => true
            case _ => false
        }
    }
    public operator func <=(right: LargeArray_LargeArray): Bool {
        return match (this.__cjbindPartialCompare(right)) {
            case Some(Ordering.LT) | Some(Ordering.EQ) => true
            case _ => false
        }
    }
    public operator func >(right: LargeArray_LargeArray): Bool {
        return match (this.__cjbindPartialCompare(right)) {
            case Some(Ordering.GT) => true
            case _ => false
        }
    }
    public operator func >=(right: LargeArray_LargeArray): Bool {
        return match (this.__cjbindPartialCompare(right)) {
            case Some(Ordering.GT) | Some(Ordering.EQ) => true
            case _ => false
        }
    }
    public func compare(right: LargeArray_LargeArray): Ordering {
        return match (this.__cjbindPartialCompare(right)) {
            case Some(value) => value
            case None => throw Exception("ordered comparison produced an unordered value")
        }
    }
    public init(values: VArray<Int32, $40>) {
        this.values = values
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<LargeArray_LargeArray>()
        if (size != 160) {
            throw Exception("Size of LargeArray_LargeArray is not 160 but ${size} bytes")
        }
        let align = alignOf<LargeArray_LargeArray>()
        if (align != 4) {
            throw Exception("Alignment of LargeArray_LargeArray is not 4 but ${align} bytes")
        }
}

@C
public struct PointerDefault_PointerDefault {
    public let value: CPointer<Int32>
    public func clone(): PointerDefault_PointerDefault {
        return this
    }
    public func toString(): String {
        var output = "PointerDefault_PointerDefault {"
        output += " value: "
        output += CPointer<Unit>(this.value).toUIntNative().toString()
        output += " }"
        return output
    }
    public operator func ==(right: PointerDefault_PointerDefault): Bool {
        if (CPointer<Unit>(this.value).toUIntNative() != CPointer<Unit>(right.value).toUIntNative()) {
            return false
        }
        return true
    }
    public operator func !=(right: PointerDefault_PointerDefault): Bool {
        return !(this == right)
    }
    public func hashCode(): Int64 {
        var hash = 1469598103934665603i64
        hash = ((hash << 5) | (hash >> 59)) ^ CPointer<Unit>(this.value).toUIntNative().hashCode()
        return hash
    }
    public func __cjbindPartialCompare(right: PointerDefault_PointerDefault): ?Ordering {
        if (CPointer<Unit>(this.value).toUIntNative() < CPointer<Unit>(right.value).toUIntNative()) {
            return Some(Ordering.LT)
        }
        if (CPointer<Unit>(this.value).toUIntNative() > CPointer<Unit>(right.value).toUIntNative()) {
            return Some(Ordering.GT)
        }
        if (CPointer<Unit>(this.value).toUIntNative() != CPointer<Unit>(right.value).toUIntNative()) {
            return None
        }
        return Some(Ordering.EQ)
    }
    public operator func <(right: PointerDefault_PointerDefault): Bool {
        return match (this.__cjbindPartialCompare(right)) {
            case Some(Ordering.LT) => true
            case _ => false
        }
    }
    public operator func <=(right: PointerDefault_PointerDefault): Bool {
        return match (this.__cjbindPartialCompare(right)) {
            case Some(Ordering.LT) | Some(Ordering.EQ) => true
            case _ => false
        }
    }
    public operator func >(right: PointerDefault_PointerDefault): Bool {
        return match (this.__cjbindPartialCompare(right)) {
            case Some(Ordering.GT) => true
            case _ => false
        }
    }
    public operator func >=(right: PointerDefault_PointerDefault): Bool {
        return match (this.__cjbindPartialCompare(right)) {
            case Some(Ordering.GT) | Some(Ordering.EQ) => true
            case _ => false
        }
    }
    public func compare(right: PointerDefault_PointerDefault): Ordering {
        return match (this.__cjbindPartialCompare(right)) {
            case Some(value) => value
            case None => throw Exception("ordered comparison produced an unordered value")
        }
    }
    public init(value: CPointer<Int32>) {
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<PointerDefault_PointerDefault>()
        if (size != 8) {
            throw Exception("Size of PointerDefault_PointerDefault is not 8 but ${size} bytes")
        }
        let align = alignOf<PointerDefault_PointerDefault>()
        if (align != 8) {
            throw Exception("Alignment of PointerDefault_PointerDefault is not 8 but ${align} bytes")
        }
}

foreign func _ZN13VtableDefault4callEv(this_: CPointer<Unit>): Unit

public unsafe func VtableDefault_call(this_: CPointer<Unit>): Unit {
    return _ZN13VtableDefault4callEv(this_)
}

@C
public struct VtableDefault_VtableDefault {
    public let vtable_: CPointer<Unit>
    public func clone(): VtableDefault_VtableDefault {
        return this
    }
    public func toString(): String {
        var output = "VtableDefault_VtableDefault {"
        output += " vtable_: "
        output += CPointer<Unit>(this.vtable_).toUIntNative().toString()
        output += " }"
        return output
    }
    public operator func ==(right: VtableDefault_VtableDefault): Bool {
        if (CPointer<Unit>(this.vtable_).toUIntNative() != CPointer<Unit>(right.vtable_).toUIntNative()) {
            return false
        }
        return true
    }
    public operator func !=(right: VtableDefault_VtableDefault): Bool {
        return !(this == right)
    }
    public func hashCode(): Int64 {
        var hash = 1469598103934665603i64
        hash = ((hash << 5) | (hash >> 59)) ^ CPointer<Unit>(this.vtable_).toUIntNative().hashCode()
        return hash
    }
    public func __cjbindPartialCompare(right: VtableDefault_VtableDefault): ?Ordering {
        if (CPointer<Unit>(this.vtable_).toUIntNative() < CPointer<Unit>(right.vtable_).toUIntNative()) {
            return Some(Ordering.LT)
        }
        if (CPointer<Unit>(this.vtable_).toUIntNative() > CPointer<Unit>(right.vtable_).toUIntNative()) {
            return Some(Ordering.GT)
        }
        if (CPointer<Unit>(this.vtable_).toUIntNative() != CPointer<Unit>(right.vtable_).toUIntNative()) {
            return None
        }
        return Some(Ordering.EQ)
    }
    public operator func <(right: VtableDefault_VtableDefault): Bool {
        return match (this.__cjbindPartialCompare(right)) {
            case Some(Ordering.LT) => true
            case _ => false
        }
    }
    public operator func <=(right: VtableDefault_VtableDefault): Bool {
        return match (this.__cjbindPartialCompare(right)) {
            case Some(Ordering.LT) | Some(Ordering.EQ) => true
            case _ => false
        }
    }
    public operator func >(right: VtableDefault_VtableDefault): Bool {
        return match (this.__cjbindPartialCompare(right)) {
            case Some(Ordering.GT) => true
            case _ => false
        }
    }
    public operator func >=(right: VtableDefault_VtableDefault): Bool {
        return match (this.__cjbindPartialCompare(right)) {
            case Some(Ordering.GT) | Some(Ordering.EQ) => true
            case _ => false
        }
    }
    public func compare(right: VtableDefault_VtableDefault): Ordering {
        return match (this.__cjbindPartialCompare(right)) {
            case Some(value) => value
            case None => throw Exception("ordered comparison produced an unordered value")
        }
    }
    public init(vtable_: CPointer<Unit>) {
        this.vtable_ = vtable_
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<VtableDefault_VtableDefault>()
        if (size != 8) {
            throw Exception("Size of VtableDefault_VtableDefault is not 8 but ${size} bytes")
        }
        let align = alignOf<VtableDefault_VtableDefault>()
        if (align != 8) {
            throw Exception("Alignment of VtableDefault_VtableDefault is not 8 but ${align} bytes")
        }
}

@C
public struct OpaqueWord_OpaqueWord {
    let _cjbind_opaque_blob: UInt64
    public func clone(): OpaqueWord_OpaqueWord {
        return this
    }
    public func toString(): String {
        var output = "OpaqueWord_OpaqueWord {"
        output += " <opaque>"
        output += " }"
        return output
    }
    public operator func ==(right: OpaqueWord_OpaqueWord): Bool {
        if (this._cjbind_opaque_blob != right._cjbind_opaque_blob) {
            return false
        }
        return true
    }
    public operator func !=(right: OpaqueWord_OpaqueWord): Bool {
        return !(this == right)
    }
    public static func default(): OpaqueWord_OpaqueWord {
        return unsafe { zeroValue<OpaqueWord_OpaqueWord>() }
    }
    public func hashCode(): Int64 {
        var hash = 1469598103934665603i64
        hash = ((hash << 5) | (hash >> 59)) ^ this._cjbind_opaque_blob.hashCode()
        return hash
    }
    public func __cjbindPartialCompare(right: OpaqueWord_OpaqueWord): ?Ordering {
        if (this._cjbind_opaque_blob < right._cjbind_opaque_blob) {
            return Some(Ordering.LT)
        }
        if (this._cjbind_opaque_blob > right._cjbind_opaque_blob) {
            return Some(Ordering.GT)
        }
        if (this._cjbind_opaque_blob != right._cjbind_opaque_blob) {
            return None
        }
        return Some(Ordering.EQ)
    }
    public operator func <(right: OpaqueWord_OpaqueWord): Bool {
        return match (this.__cjbindPartialCompare(right)) {
            case Some(Ordering.LT) => true
            case _ => false
        }
    }
    public operator func <=(right: OpaqueWord_OpaqueWord): Bool {
        return match (this.__cjbindPartialCompare(right)) {
            case Some(Ordering.LT) | Some(Ordering.EQ) => true
            case _ => false
        }
    }
    public operator func >(right: OpaqueWord_OpaqueWord): Bool {
        return match (this.__cjbindPartialCompare(right)) {
            case Some(Ordering.GT) => true
            case _ => false
        }
    }
    public operator func >=(right: OpaqueWord_OpaqueWord): Bool {
        return match (this.__cjbindPartialCompare(right)) {
            case Some(Ordering.GT) | Some(Ordering.EQ) => true
            case _ => false
        }
    }
    public func compare(right: OpaqueWord_OpaqueWord): Ordering {
        return match (this.__cjbindPartialCompare(right)) {
            case Some(value) => value
            case None => throw Exception("ordered comparison produced an unordered value")
        }
    }
    public init() {
        this._cjbind_opaque_blob = unsafe { zeroValue<UInt64>() }
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<OpaqueWord_OpaqueWord>()
        if (size != 8) {
            throw Exception("Size of OpaqueWord_OpaqueWord is not 8 but ${size} bytes")
        }
        let align = alignOf<OpaqueWord_OpaqueWord>()
        if (align != 8) {
            throw Exception("Alignment of OpaqueWord_OpaqueWord is not 8 but ${align} bytes")
        }
}

@C
public struct ScalarUnion_ScalarUnion {
    var _storage: UInt64 = unsafe { zeroValue<UInt64>() }
    public init() {}
    public func bits(): UInt64 {
        return __cjbind_read_UInt64_from_UInt64(this._storage)
    }
    public mut func bits(val!: UInt64): Unit {
        this._storage = __cjbind_write_UInt64_from_UInt64(this._storage, val)
    }
    public func number(): Float64 {
        return __cjbind_read_Float64_from_UInt64(this._storage)
    }
    public mut func number(val!: Float64): Unit {
        this._storage = __cjbind_write_Float64_from_UInt64(this._storage, val)
    }
    public func clone(): ScalarUnion_ScalarUnion {
        return this
    }
    public func toString(): String {
        var output = "ScalarUnion_ScalarUnion {"
        output += " <union>"
        output += " }"
        return output
    }
    public operator func ==(right: ScalarUnion_ScalarUnion): Bool {
        if (this._storage != right._storage) {
            return false
        }
        return true
    }
    public operator func !=(right: ScalarUnion_ScalarUnion): Bool {
        return !(this == right)
    }
    public static func default(): ScalarUnion_ScalarUnion {
        return unsafe { zeroValue<ScalarUnion_ScalarUnion>() }
    }
    public func hashCode(): Int64 {
        var hash = 1469598103934665603i64
        hash = ((hash << 5) | (hash >> 59)) ^ this._storage.hashCode()
        return hash
    }
    public func __cjbindPartialCompare(right: ScalarUnion_ScalarUnion): ?Ordering {
        if (this._storage < right._storage) {
            return Some(Ordering.LT)
        }
        if (this._storage > right._storage) {
            return Some(Ordering.GT)
        }
        if (this._storage != right._storage) {
            return None
        }
        return Some(Ordering.EQ)
    }
    public operator func <(right: ScalarUnion_ScalarUnion): Bool {
        return match (this.__cjbindPartialCompare(right)) {
            case Some(Ordering.LT) => true
            case _ => false
        }
    }
    public operator func <=(right: ScalarUnion_ScalarUnion): Bool {
        return match (this.__cjbindPartialCompare(right)) {
            case Some(Ordering.LT) | Some(Ordering.EQ) => true
            case _ => false
        }
    }
    public operator func >(right: ScalarUnion_ScalarUnion): Bool {
        return match (this.__cjbindPartialCompare(right)) {
            case Some(Ordering.GT) => true
            case _ => false
        }
    }
    public operator func >=(right: ScalarUnion_ScalarUnion): Bool {
        return match (this.__cjbindPartialCompare(right)) {
            case Some(Ordering.GT) | Some(Ordering.EQ) => true
            case _ => false
        }
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<ScalarUnion_ScalarUnion>()
        if (size != 8) {
            throw Exception("Size of ScalarUnion_ScalarUnion is not 8 but ${size} bytes")
        }
        let align = alignOf<ScalarUnion_ScalarUnion>()
        if (align != 8) {
            throw Exception("Alignment of ScalarUnion_ScalarUnion is not 8 but ${align} bytes")
        }
}

@C
public struct ManualDebug_ManualDebug {
    public let blocked: Blocked_Blocked
    public let visible: Int32
    public func toString(): String {
        var output = "ManualDebug_ManualDebug {"
        output += " visible: "
        output += this.visible.toString()
        output += " }"
        return output
    }
    public operator func ==(right: ManualDebug_ManualDebug): Bool {
        if (this.blocked != right.blocked) {
            return false
        }
        if (this.visible != right.visible) {
            return false
        }
        return true
    }
    public operator func !=(right: ManualDebug_ManualDebug): Bool {
        return !(this == right)
    }
    public init(blocked: Blocked_Blocked, visible: Int32) {
        this.blocked = blocked
        this.visible = visible
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<ManualDebug_ManualDebug>()
        if (size != 8) {
            throw Exception("Size of ManualDebug_ManualDebug is not 8 but ${size} bytes")
        }
        let align = alignOf<ManualDebug_ManualDebug>()
        if (align != 4) {
            throw Exception("Alignment of ManualDebug_ManualDebug is not 4 but ${align} bytes")
        }
}

@C
public struct NoHash_NoHash {
    public let value: Int32
    public func clone(): NoHash_NoHash {
        return this
    }
    public func toString(): String {
        var output = "NoHash_NoHash {"
        output += " value: "
        output += this.value.toString()
        output += " }"
        return output
    }
    public operator func ==(right: NoHash_NoHash): Bool {
        if (this.value != right.value) {
            return false
        }
        return true
    }
    public operator func !=(right: NoHash_NoHash): Bool {
        return !(this == right)
    }
    public static func default(): NoHash_NoHash {
        return unsafe { zeroValue<NoHash_NoHash>() }
    }
    public func __cjbindPartialCompare(right: NoHash_NoHash): ?Ordering {
        if (this.value < right.value) {
            return Some(Ordering.LT)
        }
        if (this.value > right.value) {
            return Some(Ordering.GT)
        }
        if (this.value != right.value) {
            return None
        }
        return Some(Ordering.EQ)
    }
    public operator func <(right: NoHash_NoHash): Bool {
        return match (this.__cjbindPartialCompare(right)) {
            case Some(Ordering.LT) => true
            case _ => false
        }
    }
    public operator func <=(right: NoHash_NoHash): Bool {
        return match (this.__cjbindPartialCompare(right)) {
            case Some(Ordering.LT) | Some(Ordering.EQ) => true
            case _ => false
        }
    }
    public operator func >(right: NoHash_NoHash): Bool {
        return match (this.__cjbindPartialCompare(right)) {
            case Some(Ordering.GT) => true
            case _ => false
        }
    }
    public operator func >=(right: NoHash_NoHash): Bool {
        return match (this.__cjbindPartialCompare(right)) {
            case Some(Ordering.GT) | Some(Ordering.EQ) => true
            case _ => false
        }
    }
    public func compare(right: NoHash_NoHash): Ordering {
        return match (this.__cjbindPartialCompare(right)) {
            case Some(value) => value
            case None => throw Exception("ordered comparison produced an unordered value")
        }
    }
    public init(value: Int32) {
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<NoHash_NoHash>()
        if (size != 4) {
            throw Exception("Size of NoHash_NoHash is not 4 but ${size} bytes")
        }
        let align = alignOf<NoHash_NoHash>()
        if (align != 4) {
            throw Exception("Alignment of NoHash_NoHash is not 4 but ${align} bytes")
        }
}

@C
public struct NoPartialEq_NoPartialEq {
    public let value: Int32
    public func clone(): NoPartialEq_NoPartialEq {
        return this
    }
    public func toString(): String {
        var output = "NoPartialEq_NoPartialEq {"
        output += " value: "
        output += this.value.toString()
        output += " }"
        return output
    }
    public static func default(): NoPartialEq_NoPartialEq {
        return unsafe { zeroValue<NoPartialEq_NoPartialEq>() }
    }
    public func hashCode(): Int64 {
        var hash = 1469598103934665603i64
        hash = ((hash << 5) | (hash >> 59)) ^ this.value.hashCode()
        return hash
    }
    public init(value: Int32) {
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<NoPartialEq_NoPartialEq>()
        if (size != 4) {
            throw Exception("Size of NoPartialEq_NoPartialEq is not 4 but ${size} bytes")
        }
        let align = alignOf<NoPartialEq_NoPartialEq>()
        if (align != 4) {
            throw Exception("Alignment of NoPartialEq_NoPartialEq is not 4 but ${align} bytes")
        }
}

@C
public struct NameConflicts_NameConflicts {
    var _bitfield_1: VArray<UInt8, $1> = VArray<UInt8, $1>(repeat: 0)
    public func clone(): UInt32 {
        var s = this._bitfield_1
        return UInt32(unsafe { __cjbind_bitfield_read(inout s, 0, 1) })
    }
    public mut func clone(val!: UInt32): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 0, 1, UInt64(val)) }
    }
    public func toString(): UInt32 {
        var s = this._bitfield_1
        return UInt32(unsafe { __cjbind_bitfield_read(inout s, 1, 1) })
    }
    public mut func toString(val!: UInt32): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 1, 1, UInt64(val)) }
    }
    public func hashCode(): UInt32 {
        var s = this._bitfield_1
        return UInt32(unsafe { __cjbind_bitfield_read(inout s, 2, 1) })
    }
    public mut func hashCode(val!: UInt32): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 2, 1, UInt64(val)) }
    }
    public func compare(): UInt32 {
        var s = this._bitfield_1
        return UInt32(unsafe { __cjbind_bitfield_read(inout s, 3, 1) })
    }
    public mut func compare(val!: UInt32): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 3, 1, UInt64(val)) }
    }
    public func __cjbindPartialCompare(): UInt32 {
        var s = this._bitfield_1
        return UInt32(unsafe { __cjbind_bitfield_read(inout s, 4, 1) })
    }
    public mut func __cjbindPartialCompare(val!: UInt32): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 4, 1, UInt64(val)) }
    }
    public init() {}
    public operator func ==(right: NameConflicts_NameConflicts): Bool {
        if (this.clone() != right.clone()) {
            return false
        }
        if (this.toString() != right.toString()) {
            return false
        }
        if (this.hashCode() != right.hashCode()) {
            return false
        }
        if (this.compare() != right.compare()) {
            return false
        }
        if (this.__cjbindPartialCompare() != right.__cjbindPartialCompare()) {
            return false
        }
        return true
    }
    public operator func !=(right: NameConflicts_NameConflicts): Bool {
        return !(this == right)
    }
    public static func default(): NameConflicts_NameConflicts {
        return unsafe { zeroValue<NameConflicts_NameConflicts>() }
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<NameConflicts_NameConflicts>()
        if (size != 4) {
            throw Exception("Size of NameConflicts_NameConflicts is not 4 but ${size} bytes")
        }
        let align = alignOf<NameConflicts_NameConflicts>()
        if (align != 4) {
            throw Exception("Alignment of NameConflicts_NameConflicts is not 4 but ${align} bytes")
        }
}

@C
public struct ContainsNameConflicts_ContainsNameConflicts {
    public let value: NameConflicts_NameConflicts
    public func clone(): ContainsNameConflicts_ContainsNameConflicts {
        return this
    }
    public operator func ==(right: ContainsNameConflicts_ContainsNameConflicts): Bool {
        if (this.value != right.value) {
            return false
        }
        return true
    }
    public operator func !=(right: ContainsNameConflicts_ContainsNameConflicts): Bool {
        return !(this == right)
    }
    public static func default(): ContainsNameConflicts_ContainsNameConflicts {
        return unsafe { zeroValue<ContainsNameConflicts_ContainsNameConflicts>() }
    }
    public init(value: NameConflicts_NameConflicts) {
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<ContainsNameConflicts_ContainsNameConflicts>()
        if (size != 4) {
            throw Exception("Size of ContainsNameConflicts_ContainsNameConflicts is not 4 but ${size} bytes")
        }
        let align = alignOf<ContainsNameConflicts_ContainsNameConflicts>()
        if (align != 4) {
            throw Exception("Alignment of ContainsNameConflicts_ContainsNameConflicts is not 4 but ${align} bytes")
        }
}
