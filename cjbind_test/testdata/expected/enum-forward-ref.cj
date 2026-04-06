package cjbind_ffi

public const Foo_A: Foo_Foo = 0

public type Foo_Foo = Int32

public const Bar_B: Bar_Bar = 0

public type Bar_Bar = UInt32

foreign func f(): Baz_Baz

public const Baz_C: Baz_Baz = 0

public type Baz_Baz = Int32

public type Qux_Qux = Int32
