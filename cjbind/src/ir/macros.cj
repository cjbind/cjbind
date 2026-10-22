package cjbind.ir

public enum MacroEvalResult {
    EvalResultInt(Ints)
    | EvalFloat(Float64)
    | EvalTypedInt(Ints, TypeKindIntKind, Layout)
    | EvalTypedFloat(Float64, TypeKindFloatKind, Layout)
    | EvalStr(Array<UInt8>)
    | EvalInvalid
}
