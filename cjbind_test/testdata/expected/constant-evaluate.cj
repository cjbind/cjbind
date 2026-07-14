package cjbind_ffi

public const foo: _cjbind_ty_1 = 4
public const bar: _cjbind_ty_1 = 8

public type _cjbind_ty_1 = UInt32

public type EasyToOverflow = UInt64

public const k: EasyToOverflow = 2147483648
public const k_expr: EasyToOverflow = 1152921504606846976
public const wow: EasyToOverflow = 2147483648
public const BAZ: Int64 = 24
public const fuzz: Float64 = 51.000000
public const BAZZ: UInt8 = 53
public const WAT: UInt8 = 0

// String value: Foo
public const bytestring: VArray<UInt8, $4> = [70, 111, 111, 0]

// String value: <non-UTF-8>
public const NOT_UTF8: VArray<UInt8, $5> = [240, 40, 140, 40, 0]
public const max_ull: UInt64 = 18446744073709551615
