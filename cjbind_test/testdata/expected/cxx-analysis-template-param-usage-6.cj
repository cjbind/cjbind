package cjbind_ffi

public type DoesNotUseTemplateParameter_ButAliasDoesUseIt<T> = T

@C
public struct DoesNotUseTemplateParameter {
    public let x: Int32
    public init(x: Int32) {
        this.x = x
    }
}
