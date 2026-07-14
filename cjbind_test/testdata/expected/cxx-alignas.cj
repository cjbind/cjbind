package cjbind_ffi

@C
public struct Wide {
    let _cjbind_opaque_blob: VArray<UInt8, $16>
    private init() {
        this._cjbind_opaque_blob = unsafe { zeroValue<VArray<UInt8, $16>>() }
    }
}

foreign func _Z15passthroughWideP4Wide(value: CPointer<Wide>): CPointer<Wide>

public unsafe func passthroughWide(value: CPointer<Wide>): CPointer<Wide> {
    return _Z15passthroughWideP4Wide(value)
}

@C
public struct Empty {
    let _cjbind_empty: UInt8
    public init(_cjbind_empty: UInt8) {
        this._cjbind_empty = _cjbind_empty
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<Empty>()
        if (size != 1) {
            throw Exception("Size of Empty is not 1 but ${size} bytes")
        }
        let align = alignOf<Empty>()
        if (align != 1) {
            throw Exception("Alignment of Empty is not 1 but ${align} bytes")
        }
}

@C
public struct NoUniqueAddress {
    let _cjbind_opaque_blob: UInt64
    public init() {
        this._cjbind_opaque_blob = unsafe { zeroValue<UInt64>() }
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<NoUniqueAddress>()
        if (size != 8) {
            throw Exception("Size of NoUniqueAddress is not 8 but ${size} bytes")
        }
        let align = alignOf<NoUniqueAddress>()
        if (align != 8) {
            throw Exception("Alignment of NoUniqueAddress is not 8 but ${align} bytes")
        }
}

foreign func _Z26passthroughNoUniqueAddressP15NoUniqueAddress(value: CPointer<NoUniqueAddress>): CPointer<NoUniqueAddress>

public unsafe func passthroughNoUniqueAddress(value: CPointer<NoUniqueAddress>): CPointer<NoUniqueAddress> {
    return _Z26passthroughNoUniqueAddressP15NoUniqueAddress(value)
}

public type NoUniqueAddressCallback = CPointer<Unit>

foreign func _Z30installNoUniqueAddressCallbackPF15NoUniqueAddressS_E(callback: NoUniqueAddressCallback): Unit

public unsafe func installNoUniqueAddressCallback(callback: NoUniqueAddressCallback): Unit {
    return _Z30installNoUniqueAddressCallbackPF15NoUniqueAddressS_E(callback)
}

@C
public struct PackedValue {
    let _cjbind_opaque_blob: VArray<UInt8, $5>
    public init() {
        this._cjbind_opaque_blob = unsafe { zeroValue<VArray<UInt8, $5>>() }
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<PackedValue>()
        if (size != 5) {
            throw Exception("Size of PackedValue is not 5 but ${size} bytes")
        }
        let align = alignOf<PackedValue>()
        if (align != 1) {
            throw Exception("Alignment of PackedValue is not 1 but ${align} bytes")
        }
}

foreign func _Z22passthroughPackedValueP11PackedValue(value: CPointer<PackedValue>): CPointer<PackedValue>

public unsafe func passthroughPackedValue(value: CPointer<PackedValue>): CPointer<PackedValue> {
    return _Z22passthroughPackedValueP11PackedValue(value)
}

@C
public struct PackedContainer {
    public let packed: PackedValue
    public init(packed: PackedValue) {
        this.packed = packed
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<PackedContainer>()
        if (size != 5) {
            throw Exception("Size of PackedContainer is not 5 but ${size} bytes")
        }
        let align = alignOf<PackedContainer>()
        if (align != 1) {
            throw Exception("Alignment of PackedContainer is not 1 but ${align} bytes")
        }
}

foreign func _Z26passthroughPackedContainerP15PackedContainer(value: CPointer<PackedContainer>): CPointer<PackedContainer>

public unsafe func passthroughPackedContainer(value: CPointer<PackedContainer>): CPointer<PackedContainer> {
    return _Z26passthroughPackedContainerP15PackedContainer(value)
}

@C
public struct DeletedMoves {
    public let value: Int32
    public init(value: Int32) {
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<DeletedMoves>()
        if (size != 4) {
            throw Exception("Size of DeletedMoves is not 4 but ${size} bytes")
        }
        let align = alignOf<DeletedMoves>()
        if (align != 4) {
            throw Exception("Alignment of DeletedMoves is not 4 but ${align} bytes")
        }
}

foreign func _Z23passthroughDeletedMovesP12DeletedMoves(value: CPointer<DeletedMoves>): CPointer<DeletedMoves>

public unsafe func passthroughDeletedMoves(value: CPointer<DeletedMoves>): CPointer<DeletedMoves> {
    return _Z23passthroughDeletedMovesP12DeletedMoves(value)
}

@C
public struct DeletedMoveContainer {
    public let value: DeletedMoves
    public init(value: DeletedMoves) {
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<DeletedMoveContainer>()
        if (size != 4) {
            throw Exception("Size of DeletedMoveContainer is not 4 but ${size} bytes")
        }
        let align = alignOf<DeletedMoveContainer>()
        if (align != 4) {
            throw Exception("Alignment of DeletedMoveContainer is not 4 but ${align} bytes")
        }
}

foreign func _Z31passthroughDeletedMoveContainerP20DeletedMoveContainer(value: CPointer<DeletedMoveContainer>): CPointer<DeletedMoveContainer>

public unsafe func passthroughDeletedMoveContainer(value: CPointer<DeletedMoveContainer>): CPointer<DeletedMoveContainer> {
    return _Z31passthroughDeletedMoveContainerP20DeletedMoveContainer(value)
}

@C
public struct PrivateCopy {
    public let value: Int32
    public init(value: Int32) {
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<PrivateCopy>()
        if (size != 4) {
            throw Exception("Size of PrivateCopy is not 4 but ${size} bytes")
        }
        let align = alignOf<PrivateCopy>()
        if (align != 4) {
            throw Exception("Alignment of PrivateCopy is not 4 but ${align} bytes")
        }
}

@C
public struct PrivateCopyContainer {
    public let value: PrivateCopy
    public init(value: PrivateCopy) {
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<PrivateCopyContainer>()
        if (size != 4) {
            throw Exception("Size of PrivateCopyContainer is not 4 but ${size} bytes")
        }
        let align = alignOf<PrivateCopyContainer>()
        if (align != 4) {
            throw Exception("Alignment of PrivateCopyContainer is not 4 but ${align} bytes")
        }
}

foreign func _Z31passthroughPrivateCopyContainerP20PrivateCopyContainer(value: CPointer<PrivateCopyContainer>): CPointer<PrivateCopyContainer>

public unsafe func passthroughPrivateCopyContainer(value: CPointer<PrivateCopyContainer>): CPointer<PrivateCopyContainer> {
    return _Z31passthroughPrivateCopyContainerP20PrivateCopyContainer(value)
}
