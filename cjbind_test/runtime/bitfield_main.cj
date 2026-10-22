package cjbind_ffi

func requireBitfield(condition: Bool, message: String): Unit {
    if (!condition) {
        throw Exception(message)
    }
}

func referenceRead(storage: CPointer<UInt8>, offset: Int64, width: Int64): UInt64 {
    var result = 0u64
    for (bit in 0..width) {
        let sourceBit = offset + bit
        let byte = UInt64(unsafe { storage.read(sourceBit / 8) })
        result = result | (((byte >> UInt64(sourceBit % 8)) & 1) << UInt64(bit))
    }
    return result
}

func referenceWrite(storage: CPointer<UInt8>, offset: Int64, width: Int64, value: UInt64): Unit {
    for (bit in 0..width) {
        let targetBit = offset + bit
        let index = targetBit / 8
        let mask = UInt8(UInt64(1) << UInt64(targetBit % 8))
        let old = unsafe { storage.read(index) }
        let updated = if (((value >> UInt64(bit)) & 1) == 0) { old & !mask } else { old | mask }
        unsafe { storage.write(index, updated) }
    }
}

main(): Int64 {
    let actual = unsafe { LibC.malloc<UInt8>(count: 16) }
    let expected = unsafe { LibC.malloc<UInt8>(count: 16) }
    var checked = 0
    try {
        for (startByte in [0, 3]) {
            for (shift in 0..8) {
                for (width in 0..=64) {
                    let offset = startByte * 8 + shift
                    for (value in [0u64, 1u64, 0x8000000000000000u64, 0xFFFFFFFFFFFFFFFFu64,
                        0x0123456789ABCDEFu64, 0xFEDCBA9876543210u64]) {
                        for (index in 0..16) {
                            let initial = UInt8((index * 37 + 0xA5) & 0xFF)
                            unsafe { actual.write(index, initial) }
                            unsafe { expected.write(index, initial) }
                        }
                        let label = "offset=${offset} width=${width} value=${value}"
                        requireBitfield(unsafe { __cjbind_bitfield_read(actual, offset, width) } ==
                            referenceRead(expected, offset, width), "initial read failed: ${label}")
                        referenceWrite(expected, offset, width, value)
                        unsafe { __cjbind_bitfield_write(actual, offset, width, value) }
                        for (index in 0..16) {
                            requireBitfield(unsafe { actual.read(index) == expected.read(index) },
                                "write changed unexpected bits at byte ${index}: ${label}")
                        }
                        requireBitfield(unsafe { __cjbind_bitfield_read(actual, offset, width) } ==
                            referenceRead(expected, offset, width), "round trip failed: ${label}")
                        if (width > 0 && value == 0xFFFFFFFFFFFFFFFFu64) {
                            requireBitfield(unsafe { __cjbind_bitfield_read_signed(actual, offset, width) } == -1,
                                "signed read failed: ${label}")
                        }
                        checked += 1
                    }
                }
            }
        }
    } finally {
        unsafe { LibC.free(actual) }
        unsafe { LibC.free(expected) }
    }
    println("Validated ${checked} bitfield cases")
    return 0
}
