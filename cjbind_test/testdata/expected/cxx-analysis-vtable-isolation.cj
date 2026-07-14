package cjbind_ffi

foreign func _ZNK15VirtualArgument5valueEv(this_: CPointer<Unit>): Int32

public unsafe func VirtualArgument_value(this_: CPointer<Unit>): Int32 {
    return _ZNK15VirtualArgument5valueEv(this_)
}

@C
public struct VirtualArgument_VirtualArgument__cjbind_vtable {
    public let VirtualArgument_value: CFunc<(this_: CPointer<Unit>) -> Int32>
    public init(VirtualArgument_value: CFunc<(this_: CPointer<Unit>) -> Int32>) {
        this.VirtualArgument_value = VirtualArgument_value
    }
}

@C
public struct VirtualArgument_VirtualArgument {
    public let vtable_: CPointer<VirtualArgument_VirtualArgument__cjbind_vtable>
    public init(vtable_: CPointer<VirtualArgument_VirtualArgument__cjbind_vtable>) {
        this.vtable_ = vtable_
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<VirtualArgument_VirtualArgument>()
        if (size != 8) {
            throw Exception("Size of VirtualArgument_VirtualArgument is not 8 but ${size} bytes")
        }
        let align = alignOf<VirtualArgument_VirtualArgument>()
        if (align != 8) {
            throw Exception("Alignment of VirtualArgument_VirtualArgument is not 8 but ${align} bytes")
        }
}

@C
public struct PlainTemplate_PlainTemplate {
    public let marker: Int32
    public init(marker: Int32) {
        this.marker = marker
    }
}

@C
public struct TemplateArgumentMustNotAddVtable_TemplateArgumentMustNotAddVtable {
    public let _base: PlainTemplate_PlainTemplate
    public let payload: Int32
    public init(_base: PlainTemplate_PlainTemplate, payload: Int32) {
        this._base = _base
        this.payload = payload
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<TemplateArgumentMustNotAddVtable_TemplateArgumentMustNotAddVtable>()
        if (size != 8) {
            throw Exception(
                "Size of TemplateArgumentMustNotAddVtable_TemplateArgumentMustNotAddVtable is not 8 but ${size} bytes")
        }
        let align = alignOf<TemplateArgumentMustNotAddVtable_TemplateArgumentMustNotAddVtable>()
        if (align != 4) {
            throw Exception(
                "Alignment of TemplateArgumentMustNotAddVtable_TemplateArgumentMustNotAddVtable is not 4 but ${align} bytes")
        }
}

@C
public struct FieldMustNotAddVtable_FieldMustNotAddVtable {
    public let member: VirtualArgument_VirtualArgument
    public let payload: Int32
    public init(member: VirtualArgument_VirtualArgument, payload: Int32) {
        this.member = member
        this.payload = payload
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<FieldMustNotAddVtable_FieldMustNotAddVtable>()
        if (size != 16) {
            throw Exception("Size of FieldMustNotAddVtable_FieldMustNotAddVtable is not 16 but ${size} bytes")
        }
        let align = alignOf<FieldMustNotAddVtable_FieldMustNotAddVtable>()
        if (align != 8) {
            throw Exception("Alignment of FieldMustNotAddVtable_FieldMustNotAddVtable is not 8 but ${align} bytes")
        }
}

foreign func _ZN27OuterMustNotUseNestedVtable13NestedVirtual3runEv(this_: CPointer<Unit>): Unit

public unsafe func OuterMustNotUseNestedVtable_NestedVirtual_run(this_: CPointer<Unit>): Unit {
    return _ZN27OuterMustNotUseNestedVtable13NestedVirtual3runEv(this_)
}

@C
public struct OuterMustNotUseNestedVtable_NestedVirtual_NestedVirtual__cjbind_vtable {
    public let OuterMustNotUseNestedVtable_NestedVirtual_run: CFunc<(this_: CPointer<Unit>) -> Unit>
    public init(OuterMustNotUseNestedVtable_NestedVirtual_run: CFunc<(this_: CPointer<Unit>) -> Unit>) {
        this.OuterMustNotUseNestedVtable_NestedVirtual_run = OuterMustNotUseNestedVtable_NestedVirtual_run
    }
}

@C
public struct OuterMustNotUseNestedVtable_NestedVirtual_NestedVirtual {
    public let vtable_: CPointer<OuterMustNotUseNestedVtable_NestedVirtual_NestedVirtual__cjbind_vtable>
    public init(vtable_: CPointer<OuterMustNotUseNestedVtable_NestedVirtual_NestedVirtual__cjbind_vtable>) {
        this.vtable_ = vtable_
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<OuterMustNotUseNestedVtable_NestedVirtual_NestedVirtual>()
        if (size != 8) {
            throw Exception(
                "Size of OuterMustNotUseNestedVtable_NestedVirtual_NestedVirtual is not 8 but ${size} bytes")
        }
        let align = alignOf<OuterMustNotUseNestedVtable_NestedVirtual_NestedVirtual>()
        if (align != 8) {
            throw Exception(
                "Alignment of OuterMustNotUseNestedVtable_NestedVirtual_NestedVirtual is not 8 but ${align} bytes")
        }
}

@C
public struct OuterMustNotUseNestedVtable_OuterMustNotUseNestedVtable {
    public let payload: Int32
    public init(payload: Int32) {
        this.payload = payload
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<OuterMustNotUseNestedVtable_OuterMustNotUseNestedVtable>()
        if (size != 4) {
            throw Exception(
                "Size of OuterMustNotUseNestedVtable_OuterMustNotUseNestedVtable is not 4 but ${size} bytes")
        }
        let align = alignOf<OuterMustNotUseNestedVtable_OuterMustNotUseNestedVtable>()
        if (align != 4) {
            throw Exception(
                "Alignment of OuterMustNotUseNestedVtable_OuterMustNotUseNestedVtable is not 4 but ${align} bytes")
        }
}

@C
public struct AnalysisVtableIsolationHolder_AnalysisVtableIsolationHolder {
    public let templateArgument: TemplateArgumentMustNotAddVtable_TemplateArgumentMustNotAddVtable
    public let field: FieldMustNotAddVtable_FieldMustNotAddVtable
    public let nested: OuterMustNotUseNestedVtable_OuterMustNotUseNestedVtable
    public init(templateArgument: TemplateArgumentMustNotAddVtable_TemplateArgumentMustNotAddVtable,
        field: FieldMustNotAddVtable_FieldMustNotAddVtable,
        nested: OuterMustNotUseNestedVtable_OuterMustNotUseNestedVtable) {
        this.templateArgument = templateArgument
        this.field = field
        this.nested = nested
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<AnalysisVtableIsolationHolder_AnalysisVtableIsolationHolder>()
        if (size != 32) {
            throw Exception(
                "Size of AnalysisVtableIsolationHolder_AnalysisVtableIsolationHolder is not 32 but ${size} bytes")
        }
        let align = alignOf<AnalysisVtableIsolationHolder_AnalysisVtableIsolationHolder>()
        if (align != 8) {
            throw Exception(
                "Alignment of AnalysisVtableIsolationHolder_AnalysisVtableIsolationHolder is not 8 but ${align} bytes")
        }
}
