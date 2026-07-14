package cjbind_ffi

public type VOID = Unit

public type ALSO_VOID = VOID

foreign func this_api_returns_nothing(): Unit

foreign func this_api_also_returns_nothing(): Unit

foreign func this_other_api_also_returns_nothing(): Unit
