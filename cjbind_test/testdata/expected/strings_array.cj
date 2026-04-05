package cjbind_ffi

// String value: Hello, world!
public const MY_STRING_UTF8_MY_STRING_UTF8: VArray<UInt8, $14> = [72, 101, 108, 108, 111, 44, 32, 119, 111, 114, 108,
    100, 33, 0]

// String value: Hello,
public const MY_STRING_INTERIOR_NULL_MY_STRING_INTERIOR_NULL: VArray<UInt8, $7> = [72, 101, 108, 108, 111, 44, 0]

// String value: <non-UTF-8>
public const MY_STRING_NON_UTF8_MY_STRING_NON_UTF8: VArray<UInt8, $7> = [65, 66, 67, 68, 69, 255, 0]