package cjbind_ffi

@C
public struct DoesNotUseTemplateParameter {
    public let x: Int32
    public init(x: Int32) {
        this.x = x
    }
}
