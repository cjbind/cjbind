package cjbind_ffi

// Document field with three slashes
public const B_VAR_A: B = 0

// Document field with preceding star *
public const B_VAR_B: B = 1

// Document field with preceding exclamation *
public const B_VAR_C: B = 2

//< Document field with following star *
public const B_VAR_D: B = 3

//< Document field with following exclamation *
public const B_VAR_E: B = 4

// Document field with preceding star, with a loong long multiline
// comment.
//
// Very interesting documentation, definitely.
public const B_VAR_F: B = 5

// Document enum *
public type B = UInt32
