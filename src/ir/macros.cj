package cjbind.ir

public enum MacroEvalResult {
    EvalResultInt(Int64) |
    EvalFloat(Float64) |
    EvalChar(UInt8) |
    EvalStr(CString) |
    EvalInvalid
}