package cjbind_ffi

@C
public struct Wide_Wide {
    let _cjbind_opaque_blob: VArray<UInt8, $16>
    public func clone(): Wide_Wide {
        return this
    }
    public func toString(): String {
        var output = "Wide_Wide {"
        output += " <opaque>"
        output += " }"
        return output
    }
    private init() {
        this._cjbind_opaque_blob = unsafe { zeroValue<VArray<UInt8, $16>>() }
    }
}

foreign func _Z15passthroughWideP4Wide(value: CPointer<Wide_Wide>): CPointer<Wide_Wide>

public unsafe func passthroughWide(value: CPointer<Wide_Wide>): CPointer<Wide_Wide> {
    return _Z15passthroughWideP4Wide(value)
}

@C
public struct Empty_Empty {
    let _cjbind_empty: UInt8
    public func clone(): Empty_Empty {
        return this
    }
    public func toString(): String {
        var output = "Empty_Empty {"
        output += " }"
        return output
    }
    public init(_cjbind_empty: UInt8) {
        this._cjbind_empty = _cjbind_empty
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<Empty_Empty>()
        if (size != 1) {
            throw Exception("Size of Empty_Empty is not 1 but ${size} bytes")
        }
        let align = alignOf<Empty_Empty>()
        if (align != 1) {
            throw Exception("Alignment of Empty_Empty is not 1 but ${align} bytes")
        }
}

@C
public struct NoUniqueAddress_NoUniqueAddress {
    let _cjbind_opaque_blob: UInt64
    public func clone(): NoUniqueAddress_NoUniqueAddress {
        return this
    }
    public func toString(): String {
        var output = "NoUniqueAddress_NoUniqueAddress {"
        output += " <opaque>"
        output += " }"
        return output
    }
    public init() {
        this._cjbind_opaque_blob = unsafe { zeroValue<UInt64>() }
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<NoUniqueAddress_NoUniqueAddress>()
        if (size != 8) {
            throw Exception("Size of NoUniqueAddress_NoUniqueAddress is not 8 but ${size} bytes")
        }
        let align = alignOf<NoUniqueAddress_NoUniqueAddress>()
        if (align != 8) {
            throw Exception("Alignment of NoUniqueAddress_NoUniqueAddress is not 8 but ${align} bytes")
        }
}

foreign func _Z26passthroughNoUniqueAddressP15NoUniqueAddress(value: CPointer<NoUniqueAddress_NoUniqueAddress>): CPointer<NoUniqueAddress_NoUniqueAddress>

public unsafe func passthroughNoUniqueAddress(value: CPointer<NoUniqueAddress_NoUniqueAddress>): CPointer<NoUniqueAddress_NoUniqueAddress> {
    return _Z26passthroughNoUniqueAddressP15NoUniqueAddress(value)
}

public type NoUniqueAddressCallback_NoUniqueAddressCallback = CPointer<Unit>

foreign func _Z30installNoUniqueAddressCallbackPF15NoUniqueAddressS_E(
    callback: NoUniqueAddressCallback_NoUniqueAddressCallback): Unit

public unsafe func installNoUniqueAddressCallback(callback: NoUniqueAddressCallback_NoUniqueAddressCallback): Unit {
    return _Z30installNoUniqueAddressCallbackPF15NoUniqueAddressS_E(callback)
}

@C
public struct PackedValue_PackedValue {
    let _cjbind_opaque_blob: VArray<UInt8, $5>
    public func clone(): PackedValue_PackedValue {
        return this
    }
    public func toString(): String {
        var output = "PackedValue_PackedValue {"
        output += " <opaque>"
        output += " }"
        return output
    }
    public init() {
        this._cjbind_opaque_blob = unsafe { zeroValue<VArray<UInt8, $5>>() }
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<PackedValue_PackedValue>()
        if (size != 5) {
            throw Exception("Size of PackedValue_PackedValue is not 5 but ${size} bytes")
        }
        let align = alignOf<PackedValue_PackedValue>()
        if (align != 1) {
            throw Exception("Alignment of PackedValue_PackedValue is not 1 but ${align} bytes")
        }
}

foreign func _Z22passthroughPackedValueP11PackedValue(value: CPointer<PackedValue_PackedValue>): CPointer<PackedValue_PackedValue>

public unsafe func passthroughPackedValue(value: CPointer<PackedValue_PackedValue>): CPointer<PackedValue_PackedValue> {
    return _Z22passthroughPackedValueP11PackedValue(value)
}

@C
public struct PackedContainer_PackedContainer {
    public let packed: PackedValue_PackedValue
    public func clone(): PackedContainer_PackedContainer {
        return this
    }
    public func toString(): String {
        var output = "PackedContainer_PackedContainer {"
        output += " packed: "
        output += this.packed.toString()
        output += " }"
        return output
    }
    public init(packed: PackedValue_PackedValue) {
        this.packed = packed
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<PackedContainer_PackedContainer>()
        if (size != 5) {
            throw Exception("Size of PackedContainer_PackedContainer is not 5 but ${size} bytes")
        }
        let align = alignOf<PackedContainer_PackedContainer>()
        if (align != 1) {
            throw Exception("Alignment of PackedContainer_PackedContainer is not 1 but ${align} bytes")
        }
}

foreign func _Z26passthroughPackedContainerP15PackedContainer(value: CPointer<PackedContainer_PackedContainer>): CPointer<PackedContainer_PackedContainer>

public unsafe func passthroughPackedContainer(value: CPointer<PackedContainer_PackedContainer>): CPointer<PackedContainer_PackedContainer> {
    return _Z26passthroughPackedContainerP15PackedContainer(value)
}

@C
public struct DeletedMoves_DeletedMoves {
    public let value: Int32
    public func clone(): DeletedMoves_DeletedMoves {
        return this
    }
    public func toString(): String {
        var output = "DeletedMoves_DeletedMoves {"
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
        let size = sizeOf<DeletedMoves_DeletedMoves>()
        if (size != 4) {
            throw Exception("Size of DeletedMoves_DeletedMoves is not 4 but ${size} bytes")
        }
        let align = alignOf<DeletedMoves_DeletedMoves>()
        if (align != 4) {
            throw Exception("Alignment of DeletedMoves_DeletedMoves is not 4 but ${align} bytes")
        }
}

foreign func _Z23passthroughDeletedMovesP12DeletedMoves(value: CPointer<DeletedMoves_DeletedMoves>): CPointer<DeletedMoves_DeletedMoves>

public unsafe func passthroughDeletedMoves(value: CPointer<DeletedMoves_DeletedMoves>): CPointer<DeletedMoves_DeletedMoves> {
    return _Z23passthroughDeletedMovesP12DeletedMoves(value)
}

@C
public struct DeletedMoveContainer_DeletedMoveContainer {
    public let value: DeletedMoves_DeletedMoves
    public func clone(): DeletedMoveContainer_DeletedMoveContainer {
        return this
    }
    public func toString(): String {
        var output = "DeletedMoveContainer_DeletedMoveContainer {"
        output += " value: "
        output += this.value.toString()
        output += " }"
        return output
    }
    public init(value: DeletedMoves_DeletedMoves) {
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<DeletedMoveContainer_DeletedMoveContainer>()
        if (size != 4) {
            throw Exception("Size of DeletedMoveContainer_DeletedMoveContainer is not 4 but ${size} bytes")
        }
        let align = alignOf<DeletedMoveContainer_DeletedMoveContainer>()
        if (align != 4) {
            throw Exception("Alignment of DeletedMoveContainer_DeletedMoveContainer is not 4 but ${align} bytes")
        }
}

foreign func _Z31passthroughDeletedMoveContainerP20DeletedMoveContainer(
    value: CPointer<DeletedMoveContainer_DeletedMoveContainer>): CPointer<DeletedMoveContainer_DeletedMoveContainer>

public unsafe func passthroughDeletedMoveContainer(value: CPointer<DeletedMoveContainer_DeletedMoveContainer>): CPointer<DeletedMoveContainer_DeletedMoveContainer> {
    return _Z31passthroughDeletedMoveContainerP20DeletedMoveContainer(value)
}

@C
public struct PrivateCopy_PrivateCopy {
    public let value: Int32
    public func clone(): PrivateCopy_PrivateCopy {
        return this
    }
    public func toString(): String {
        var output = "PrivateCopy_PrivateCopy {"
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
        let size = sizeOf<PrivateCopy_PrivateCopy>()
        if (size != 4) {
            throw Exception("Size of PrivateCopy_PrivateCopy is not 4 but ${size} bytes")
        }
        let align = alignOf<PrivateCopy_PrivateCopy>()
        if (align != 4) {
            throw Exception("Alignment of PrivateCopy_PrivateCopy is not 4 but ${align} bytes")
        }
}

@C
public struct PrivateCopyContainer_PrivateCopyContainer {
    public let value: PrivateCopy_PrivateCopy
    public func clone(): PrivateCopyContainer_PrivateCopyContainer {
        return this
    }
    public func toString(): String {
        var output = "PrivateCopyContainer_PrivateCopyContainer {"
        output += " value: "
        output += this.value.toString()
        output += " }"
        return output
    }
    public init(value: PrivateCopy_PrivateCopy) {
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<PrivateCopyContainer_PrivateCopyContainer>()
        if (size != 4) {
            throw Exception("Size of PrivateCopyContainer_PrivateCopyContainer is not 4 but ${size} bytes")
        }
        let align = alignOf<PrivateCopyContainer_PrivateCopyContainer>()
        if (align != 4) {
            throw Exception("Alignment of PrivateCopyContainer_PrivateCopyContainer is not 4 but ${align} bytes")
        }
}

foreign func _Z31passthroughPrivateCopyContainerP20PrivateCopyContainer(
    value: CPointer<PrivateCopyContainer_PrivateCopyContainer>): CPointer<PrivateCopyContainer_PrivateCopyContainer>

public unsafe func passthroughPrivateCopyContainer(value: CPointer<PrivateCopyContainer_PrivateCopyContainer>): CPointer<PrivateCopyContainer_PrivateCopyContainer> {
    return _Z31passthroughPrivateCopyContainerP20PrivateCopyContainer(value)
}
