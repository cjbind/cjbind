package cjbind.ir

public enum MacroEvalResult {
    EvalResultInt(Ints) |
    EvalFloat(Float64) |
    EvalStr(CString) |
    EvalInvalid
}