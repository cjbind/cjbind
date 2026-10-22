package cjbind.ir

public enum MacroEvalResult {
    EvalResultInt(Ints)
    | EvalFloat(Float64)
    | EvalStr(Array<UInt8>)
    | EvalInvalid
}
