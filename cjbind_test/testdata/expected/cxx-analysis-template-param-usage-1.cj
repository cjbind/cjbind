package cjbind_ffi

@C
public struct DoesNotUseTemplateParameter {
    public var x: Int32
    private init(x: Int32) {
        this.x = x
    }
}
