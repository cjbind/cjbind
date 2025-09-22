package cjbind.ir

public enum MacroEvalResult {
    EvalResultInt(Ints) |
    EvalFloat(Float64) |
    EvalChar(UInt8) |
    EvalStr(CString) |
    EvalInvalid
}