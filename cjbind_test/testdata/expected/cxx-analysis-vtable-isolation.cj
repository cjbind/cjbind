package cjbind_ffi

foreign func _ZNK15VirtualArgument5valueEv(this_: CPointer<Unit>): Int32

public unsafe func VirtualArgument_value(this_: CPointer<Unit>): Int32 {
    return _ZNK15VirtualArgument5valueEv(this_)
}

@C
public struct VirtualArgument__cjbind_vtable {
    public let VirtualArgument_value: CFunc<(this_: CPointer<Unit>) -> Int32>
    public init(VirtualArgument_value: CFunc<(this_: CPointer<Unit>) -> Int32>) {
        this.VirtualArgument_value = VirtualArgument_value
    }
}

@C
public struct VirtualArgument {
    public let vtable_: CPointer<VirtualArgument__cjbind_vtable>
    public init(vtable_: CPointer<VirtualArgument__cjbind_vtable>) {
        this.vtable_ = vtable_
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<VirtualArgument>()
        if (size != 8) {
            throw Exception("Size of VirtualArgument is not 8 but ${size} bytes")
        }
        let align = alignOf<VirtualArgument>()
        if (align != 8) {
            throw Exception("Alignment of VirtualArgument is not 8 but ${align} bytes")
        }
}

@C
public struct PlainTemplate {
    public let marker: Int32
    public init(marker: Int32) {
        this.marker = marker
    }
}

@C
public struct TemplateArgumentMustNotAddVtable {
    public let _base: PlainTemplate
    public let payload: Int32
    public init(_base: PlainTemplate, payload: Int32) {
        this._base = _base
        this.payload = payload
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<TemplateArgumentMustNotAddVtable>()
        if (size != 8) {
            throw Exception("Size of TemplateArgumentMustNotAddVtable is not 8 but ${size} bytes")
        }
        let align = alignOf<TemplateArgumentMustNotAddVtable>()
        if (align != 4) {
            throw Exception("Alignment of TemplateArgumentMustNotAddVtable is not 4 but ${align} bytes")
        }
}

@C
public struct FieldMustNotAddVtable {
    public let member: VirtualArgument
    public let payload: Int32
    public init(member: VirtualArgument, payload: Int32) {
        this.member = member
        this.payload = payload
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<FieldMustNotAddVtable>()
        if (size != 16) {
            throw Exception("Size of FieldMustNotAddVtable is not 16 but ${size} bytes")
        }
        let align = alignOf<FieldMustNotAddVtable>()
        if (align != 8) {
            throw Exception("Alignment of FieldMustNotAddVtable is not 8 but ${align} bytes")
        }
}

foreign func _ZN27OuterMustNotUseNestedVtable13NestedVirtual3runEv(this_: CPointer<Unit>): Unit

public unsafe func OuterMustNotUseNestedVtable_NestedVirtual_run(this_: CPointer<Unit>): Unit {
    return _ZN27OuterMustNotUseNestedVtable13NestedVirtual3runEv(this_)
}

@C
public struct OuterMustNotUseNestedVtable_NestedVirtual__cjbind_vtable {
    public let OuterMustNotUseNestedVtable_NestedVirtual_run: CFunc<(this_: CPointer<Unit>) -> Unit>
    public init(OuterMustNotUseNestedVtable_NestedVirtual_run: CFunc<(this_: CPointer<Unit>) -> Unit>) {
        this.OuterMustNotUseNestedVtable_NestedVirtual_run = OuterMustNotUseNestedVtable_NestedVirtual_run
    }
}

@C
public struct OuterMustNotUseNestedVtable_NestedVirtual {
    public let vtable_: CPointer<OuterMustNotUseNestedVtable_NestedVirtual__cjbind_vtable>
    public init(vtable_: CPointer<OuterMustNotUseNestedVtable_NestedVirtual__cjbind_vtable>) {
        this.vtable_ = vtable_
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<OuterMustNotUseNestedVtable_NestedVirtual>()
        if (size != 8) {
            throw Exception("Size of OuterMustNotUseNestedVtable_NestedVirtual is not 8 but ${size} bytes")
        }
        let align = alignOf<OuterMustNotUseNestedVtable_NestedVirtual>()
        if (align != 8) {
            throw Exception("Alignment of OuterMustNotUseNestedVtable_NestedVirtual is not 8 but ${align} bytes")
        }
}

@C
public struct OuterMustNotUseNestedVtable {
    public let payload: Int32
    public init(payload: Int32) {
        this.payload = payload
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<OuterMustNotUseNestedVtable>()
        if (size != 4) {
            throw Exception("Size of OuterMustNotUseNestedVtable is not 4 but ${size} bytes")
        }
        let align = alignOf<OuterMustNotUseNestedVtable>()
        if (align != 4) {
            throw Exception("Alignment of OuterMustNotUseNestedVtable is not 4 but ${align} bytes")
        }
}

@C
public struct AnalysisVtableIsolationHolder {
    public let templateArgument: TemplateArgumentMustNotAddVtable
    public let field: FieldMustNotAddVtable
    public let nested: OuterMustNotUseNestedVtable
    public init(templateArgument: TemplateArgumentMustNotAddVtable, field: FieldMustNotAddVtable,
        nested: OuterMustNotUseNestedVtable) {
        this.templateArgument = templateArgument
        this.field = field
        this.nested = nested
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<AnalysisVtableIsolationHolder>()
        if (size != 32) {
            throw Exception("Size of AnalysisVtableIsolationHolder is not 32 but ${size} bytes")
        }
        let align = alignOf<AnalysisVtableIsolationHolder>()
        if (align != 8) {
            throw Exception("Alignment of AnalysisVtableIsolationHolder is not 8 but ${align} bytes")
        }
}
