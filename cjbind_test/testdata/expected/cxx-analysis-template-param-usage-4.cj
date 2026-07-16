package cjbind_ffi

@C
public struct UsesTemplateParameter_DoesNotUseTemplateParameters {
    public var x: Int32
    private init(x: Int32) {
        this.x = x
    }
}
