package cjbind_ffi

@C
public struct Empty {
    let _cjbind_empty: UInt8
    public init(_cjbind_empty: UInt8) {
        this._cjbind_empty = _cjbind_empty
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<Empty>()
        if (size != 1) {
            throw Exception("Size of Empty is not 1 but ${size} bytes")
        }
        let align = alignOf<Empty>()
        if (align != 1) {
            throw Exception("Alignment of Empty is not 1 but ${align} bytes")
        }
}

@C
public struct EmptyDerived {
    let _cjbind_empty: UInt8
    public init(_cjbind_empty: UInt8) {
        this._cjbind_empty = _cjbind_empty
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<EmptyDerived>()
        if (size != 1) {
            throw Exception("Size of EmptyDerived is not 1 but ${size} bytes")
        }
        let align = alignOf<EmptyDerived>()
        if (align != 1) {
            throw Exception("Alignment of EmptyDerived is not 1 but ${align} bytes")
        }
}

@C
public struct InheritsEmpty {
    public let value: Bool
    public init(value: Bool) {
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<InheritsEmpty>()
        if (size != 1) {
            throw Exception("Size of InheritsEmpty is not 1 but ${size} bytes")
        }
        let align = alignOf<InheritsEmpty>()
        if (align != 1) {
            throw Exception("Alignment of InheritsEmpty is not 1 but ${align} bytes")
        }
}

@C
public struct ContainsEmpty {
    public let empty: Empty
    public let value: Bool
    public init(empty: Empty, value: Bool) {
        this.empty = empty
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<ContainsEmpty>()
        if (size != 2) {
            throw Exception("Size of ContainsEmpty is not 2 but ${size} bytes")
        }
        let align = alignOf<ContainsEmpty>()
        if (align != 1) {
            throw Exception("Alignment of ContainsEmpty is not 1 but ${align} bytes")
        }
}

@C
public struct ContainsEmptyArray {
    public let values: VArray<Empty, $4>
    public init(values: VArray<Empty, $4>) {
        this.values = values
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<ContainsEmptyArray>()
        if (size != 4) {
            throw Exception("Size of ContainsEmptyArray is not 4 but ${size} bytes")
        }
        let align = alignOf<ContainsEmptyArray>()
        if (align != 1) {
            throw Exception("Alignment of ContainsEmptyArray is not 1 but ${align} bytes")
        }
}

@C
public struct EmptyTemplate {
    let _cjbind_empty: UInt8
    public init(_cjbind_empty: UInt8) {
        this._cjbind_empty = _cjbind_empty
    }
}

@C
public struct TemplateEmptyBase {
    public let value: UInt8
    public init(value: UInt8) {
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<TemplateEmptyBase>()
        if (size != 1) {
            throw Exception("Size of TemplateEmptyBase is not 1 but ${size} bytes")
        }
        let align = alignOf<TemplateEmptyBase>()
        if (align != 1) {
            throw Exception("Alignment of TemplateEmptyBase is not 1 but ${align} bytes")
        }
}

@C
public struct TemplateEmptyMember {
    public let empty: EmptyTemplate
    public let value: UInt8
    public init(empty: EmptyTemplate, value: UInt8) {
        this.empty = empty
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<TemplateEmptyMember>()
        if (size != 2) {
            throw Exception("Size of TemplateEmptyMember is not 2 but ${size} bytes")
        }
        let align = alignOf<TemplateEmptyMember>()
        if (align != 1) {
            throw Exception("Alignment of TemplateEmptyMember is not 1 but ${align} bytes")
        }
}

@C
public struct DeepEmptyBase {
    public let value: UInt8
    public init(value: UInt8) {
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<DeepEmptyBase>()
        if (size != 1) {
            throw Exception("Size of DeepEmptyBase is not 1 but ${size} bytes")
        }
        let align = alignOf<DeepEmptyBase>()
        if (align != 1) {
            throw Exception("Alignment of DeepEmptyBase is not 1 but ${align} bytes")
        }
}

@C
public struct DerivedFromVtable {
    public let _base: BaseWithVtable_open0_ptr_char_close0
    public init(_base: BaseWithVtable_open0_ptr_char_close0) {
        this._base = _base
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<DerivedFromVtable>()
        if (size != 16) {
            throw Exception("Size of DerivedFromVtable is not 16 but ${size} bytes")
        }
        let align = alignOf<DerivedFromVtable>()
        if (align != 8) {
            throw Exception("Alignment of DerivedFromVtable is not 8 but ${align} bytes")
        }
}

foreign func _ZN18DerivedAddsVirtual5extraEv(this_: CPointer<Unit>): Int32

public unsafe func DerivedAddsVirtual_extra(this_: CPointer<Unit>): Int32 {
    return _ZN18DerivedAddsVirtual5extraEv(this_)
}

@C
public struct DerivedAddsVirtual {
    public let _base: BaseWithVtable_open0_ptr_char_close0
    public init(_base: BaseWithVtable_open0_ptr_char_close0) {
        this._base = _base
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<DerivedAddsVirtual>()
        if (size != 16) {
            throw Exception("Size of DerivedAddsVirtual is not 16 but ${size} bytes")
        }
        let align = alignOf<DerivedAddsVirtual>()
        if (align != 8) {
            throw Exception("Alignment of DerivedAddsVirtual is not 8 but ${align} bytes")
        }
}

foreign func _ZN23DerivedIntroducesVtable3runEv(this_: CPointer<Unit>): Unit

public unsafe func DerivedIntroducesVtable_run(this_: CPointer<Unit>): Unit {
    return _ZN23DerivedIntroducesVtable3runEv(this_)
}

@C
public struct DerivedIntroducesVtable {
    public let vtable_: CPointer<Unit>
    public let _base: BaseWithoutVtable_open0_int_close0
    public init(vtable_: CPointer<Unit>, _base: BaseWithoutVtable_open0_int_close0) {
        this.vtable_ = vtable_
        this._base = _base
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<DerivedIntroducesVtable>()
        if (size != 16) {
            throw Exception("Size of DerivedIntroducesVtable is not 16 but ${size} bytes")
        }
        let align = alignOf<DerivedIntroducesVtable>()
        if (align != 8) {
            throw Exception("Alignment of DerivedIntroducesVtable is not 8 but ${align} bytes")
        }
}

@C
public struct DerivedWithoutVtable {
    public let _base: BaseWithoutVtable_open0_int_close0
    public init(_base: BaseWithoutVtable_open0_int_close0) {
        this._base = _base
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<DerivedWithoutVtable>()
        if (size != 4) {
            throw Exception("Size of DerivedWithoutVtable is not 4 but ${size} bytes")
        }
        let align = alignOf<DerivedWithoutVtable>()
        if (align != 4) {
            throw Exception("Alignment of DerivedWithoutVtable is not 4 but ${align} bytes")
        }
}

foreign func _ZN11VirtualRoot4rootEv(this_: CPointer<Unit>): CPointer<VirtualRoot>

public unsafe func VirtualRoot_root(this_: CPointer<Unit>): CPointer<VirtualRoot> {
    return _ZN11VirtualRoot4rootEv(this_)
}

@C
public struct VirtualRoot__cjbind_vtable {
    public let VirtualRoot_root: CFunc<(this_: CPointer<Unit>) -> CPointer<VirtualRoot>>
    public init(VirtualRoot_root: CFunc<(this_: CPointer<Unit>) -> CPointer<VirtualRoot>>) {
        this.VirtualRoot_root = VirtualRoot_root
    }
}

@C
public struct VirtualRoot {
    public let vtable_: CPointer<VirtualRoot__cjbind_vtable>
    public init(vtable_: CPointer<VirtualRoot__cjbind_vtable>) {
        this.vtable_ = vtable_
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<VirtualRoot>()
        if (size != 8) {
            throw Exception("Size of VirtualRoot is not 8 but ${size} bytes")
        }
        let align = alignOf<VirtualRoot>()
        if (align != 8) {
            throw Exception("Alignment of VirtualRoot is not 8 but ${align} bytes")
        }
}

@C
public struct VirtualMiddle {
    public let _base: VirtualRoot
    public init(_base: VirtualRoot) {
        this._base = _base
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<VirtualMiddle>()
        if (size != 8) {
            throw Exception("Size of VirtualMiddle is not 8 but ${size} bytes")
        }
        let align = alignOf<VirtualMiddle>()
        if (align != 8) {
            throw Exception("Alignment of VirtualMiddle is not 8 but ${align} bytes")
        }
}

@C
public struct VirtualLeaf {
    public let _base: VirtualMiddle
    public init(_base: VirtualMiddle) {
        this._base = _base
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<VirtualLeaf>()
        if (size != 8) {
            throw Exception("Size of VirtualLeaf is not 8 but ${size} bytes")
        }
        let align = alignOf<VirtualLeaf>()
        if (align != 8) {
            throw Exception("Alignment of VirtualLeaf is not 8 but ${align} bytes")
        }
}

foreign func _ZN13RecursiveBase7derivedEv(this_: CPointer<Unit>): CPointer<RecursiveDerived>

public unsafe func RecursiveBase_derived(this_: CPointer<Unit>): CPointer<RecursiveDerived> {
    return _ZN13RecursiveBase7derivedEv(this_)
}

@C
public struct RecursiveBase__cjbind_vtable {
    public let RecursiveBase_derived: CFunc<(this_: CPointer<Unit>) -> CPointer<RecursiveDerived>>
    public init(RecursiveBase_derived: CFunc<(this_: CPointer<Unit>) -> CPointer<RecursiveDerived>>) {
        this.RecursiveBase_derived = RecursiveBase_derived
    }
}

@C
public struct RecursiveBase {
    public let vtable_: CPointer<RecursiveBase__cjbind_vtable>
    public init(vtable_: CPointer<RecursiveBase__cjbind_vtable>) {
        this.vtable_ = vtable_
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<RecursiveBase>()
        if (size != 8) {
            throw Exception("Size of RecursiveBase is not 8 but ${size} bytes")
        }
        let align = alignOf<RecursiveBase>()
        if (align != 8) {
            throw Exception("Alignment of RecursiveBase is not 8 but ${align} bytes")
        }
}

foreign func _ZN16RecursiveDerived7derivedEv(this_: CPointer<Unit>): CPointer<RecursiveDerived>

public unsafe func RecursiveDerived_derived(this_: CPointer<Unit>): CPointer<RecursiveDerived> {
    return _ZN16RecursiveDerived7derivedEv(this_)
}

@C
public struct RecursiveDerived {
    public let _base: RecursiveBase
    public init(_base: RecursiveBase) {
        this._base = _base
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<RecursiveDerived>()
        if (size != 8) {
            throw Exception("Size of RecursiveDerived is not 8 but ${size} bytes")
        }
        let align = alignOf<RecursiveDerived>()
        if (align != 8) {
            throw Exception("Alignment of RecursiveDerived is not 8 but ${align} bytes")
        }
}

@C
public struct LayoutAnalysisHolder {
    public let empty: Empty
    public let emptyDerived: EmptyDerived
    public let inherits: InheritsEmpty
    public let contains: ContainsEmpty
    public let array: ContainsEmptyArray
    public let templateBase: TemplateEmptyBase
    public let templateMember: TemplateEmptyMember
    public let deepBase: DeepEmptyBase
    public let dependentNonZero: DependentSize_open0_int_close0
    public let inheritedVtable: CPointer<DerivedFromVtable>
    public let introducedVtable: CPointer<DerivedIntroducesVtable>
    public let noVtable: CPointer<DerivedWithoutVtable>
    public let deepVtable: CPointer<VirtualLeaf>
    public let recursiveVtable: CPointer<RecursiveDerived>
    public init(empty: Empty, emptyDerived: EmptyDerived, inherits: InheritsEmpty, contains: ContainsEmpty,
        array: ContainsEmptyArray, templateBase: TemplateEmptyBase, templateMember: TemplateEmptyMember,
        deepBase: DeepEmptyBase, dependentNonZero: DependentSize_open0_int_close0,
        inheritedVtable: CPointer<DerivedFromVtable>, introducedVtable: CPointer<DerivedIntroducesVtable>,
        noVtable: CPointer<DerivedWithoutVtable>, deepVtable: CPointer<VirtualLeaf>,
        recursiveVtable: CPointer<RecursiveDerived>) {
        this.empty = empty
        this.emptyDerived = emptyDerived
        this.inherits = inherits
        this.contains = contains
        this.array = array
        this.templateBase = templateBase
        this.templateMember = templateMember
        this.deepBase = deepBase
        this.dependentNonZero = dependentNonZero
        this.inheritedVtable = inheritedVtable
        this.introducedVtable = introducedVtable
        this.noVtable = noVtable
        this.deepVtable = deepVtable
        this.recursiveVtable = recursiveVtable
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<LayoutAnalysisHolder>()
        if (size != 64) {
            throw Exception("Size of LayoutAnalysisHolder is not 64 but ${size} bytes")
        }
        let align = alignOf<LayoutAnalysisHolder>()
        if (align != 8) {
            throw Exception("Alignment of LayoutAnalysisHolder is not 8 but ${align} bytes")
        }
}

@C
public struct DependentSize_open0_int_close0 {
    public let value: Int32
    public init(value: Int32) {
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<DependentSize_open0_int_close0>()
        if (size != 4) {
            throw Exception("Size of DependentSize_open0_int_close0 is not 4 but ${size} bytes")
        }
        let align = alignOf<DependentSize_open0_int_close0>()
        if (align != 4) {
            throw Exception("Alignment of DependentSize_open0_int_close0 is not 4 but ${align} bytes")
        }
}

@C
public struct BaseWithoutVtable_open0_int_close0 {
    public let value: Int32
    public init(value: Int32) {
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<BaseWithoutVtable_open0_int_close0>()
        if (size != 4) {
            throw Exception("Size of BaseWithoutVtable_open0_int_close0 is not 4 but ${size} bytes")
        }
        let align = alignOf<BaseWithoutVtable_open0_int_close0>()
        if (align != 4) {
            throw Exception("Alignment of BaseWithoutVtable_open0_int_close0 is not 4 but ${align} bytes")
        }
}

@C
public struct BaseWithVtable_open0_ptr_char_close0 {
    let _cjbind_opaque_blob: VArray<UInt64, $2>
    public init() {
        this._cjbind_opaque_blob = unsafe { zeroValue<VArray<UInt64, $2>>() }
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<BaseWithVtable_open0_ptr_char_close0>()
        if (size != 16) {
            throw Exception("Size of BaseWithVtable_open0_ptr_char_close0 is not 16 but ${size} bytes")
        }
        let align = alignOf<BaseWithVtable_open0_ptr_char_close0>()
        if (align != 8) {
            throw Exception("Alignment of BaseWithVtable_open0_ptr_char_close0 is not 8 but ${align} bytes")
        }
}
