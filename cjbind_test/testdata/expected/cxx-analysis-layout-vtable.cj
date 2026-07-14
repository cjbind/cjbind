package cjbind_ffi

@C
public struct Empty_Empty {
    let _cjbind_empty: UInt8
    public func clone(): Empty_Empty {
        return this
    }
    public func toString(): String {
        var output = "Empty_Empty {"
        output += " }"
        return output
    }
    public init(_cjbind_empty: UInt8) {
        this._cjbind_empty = _cjbind_empty
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<Empty_Empty>()
        if (size != 1) {
            throw Exception("Size of Empty_Empty is not 1 but ${size} bytes")
        }
        let align = alignOf<Empty_Empty>()
        if (align != 1) {
            throw Exception("Alignment of Empty_Empty is not 1 but ${align} bytes")
        }
}

@C
public struct EmptyDerived_EmptyDerived {
    let _cjbind_empty: UInt8
    public func clone(): EmptyDerived_EmptyDerived {
        return this
    }
    public func toString(): String {
        var output = "EmptyDerived_EmptyDerived {"
        output += " }"
        return output
    }
    public init(_cjbind_empty: UInt8) {
        this._cjbind_empty = _cjbind_empty
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<EmptyDerived_EmptyDerived>()
        if (size != 1) {
            throw Exception("Size of EmptyDerived_EmptyDerived is not 1 but ${size} bytes")
        }
        let align = alignOf<EmptyDerived_EmptyDerived>()
        if (align != 1) {
            throw Exception("Alignment of EmptyDerived_EmptyDerived is not 1 but ${align} bytes")
        }
}

@C
public struct InheritsEmpty_InheritsEmpty {
    public let value: Bool
    public func clone(): InheritsEmpty_InheritsEmpty {
        return this
    }
    public func toString(): String {
        var output = "InheritsEmpty_InheritsEmpty {"
        output += " value: "
        output += this.value.toString()
        output += " }"
        return output
    }
    public init(value: Bool) {
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<InheritsEmpty_InheritsEmpty>()
        if (size != 1) {
            throw Exception("Size of InheritsEmpty_InheritsEmpty is not 1 but ${size} bytes")
        }
        let align = alignOf<InheritsEmpty_InheritsEmpty>()
        if (align != 1) {
            throw Exception("Alignment of InheritsEmpty_InheritsEmpty is not 1 but ${align} bytes")
        }
}

@C
public struct ContainsEmpty_ContainsEmpty {
    public let empty: Empty_Empty
    public let value: Bool
    public func clone(): ContainsEmpty_ContainsEmpty {
        return this
    }
    public func toString(): String {
        var output = "ContainsEmpty_ContainsEmpty {"
        output += " empty: "
        output += this.empty.toString()
        output += ", value: "
        output += this.value.toString()
        output += " }"
        return output
    }
    public init(empty: Empty_Empty, value: Bool) {
        this.empty = empty
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<ContainsEmpty_ContainsEmpty>()
        if (size != 2) {
            throw Exception("Size of ContainsEmpty_ContainsEmpty is not 2 but ${size} bytes")
        }
        let align = alignOf<ContainsEmpty_ContainsEmpty>()
        if (align != 1) {
            throw Exception("Alignment of ContainsEmpty_ContainsEmpty is not 1 but ${align} bytes")
        }
}

@C
public struct ContainsEmptyArray_ContainsEmptyArray {
    public let values: VArray<Empty_Empty, $4>
    public func clone(): ContainsEmptyArray_ContainsEmptyArray {
        return this
    }
    public func toString(): String {
        var output = "ContainsEmptyArray_ContainsEmptyArray {"
        output += " values: "
        output += "["
        for (__cjbindDebugIndex0 in 0..4) {
            if (__cjbindDebugIndex0 != 0) {
                output += ", "
            }
            output += this.values[__cjbindDebugIndex0].toString()
        }
        output += "]"
        output += " }"
        return output
    }
    public init(values: VArray<Empty_Empty, $4>) {
        this.values = values
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<ContainsEmptyArray_ContainsEmptyArray>()
        if (size != 4) {
            throw Exception("Size of ContainsEmptyArray_ContainsEmptyArray is not 4 but ${size} bytes")
        }
        let align = alignOf<ContainsEmptyArray_ContainsEmptyArray>()
        if (align != 1) {
            throw Exception("Alignment of ContainsEmptyArray_ContainsEmptyArray is not 1 but ${align} bytes")
        }
}

@C
public struct EmptyTemplate_EmptyTemplate {
    let _cjbind_empty: UInt8
    public func clone(): EmptyTemplate_EmptyTemplate {
        return this
    }
    public func toString(): String {
        var output = "EmptyTemplate_EmptyTemplate {"
        output += " }"
        return output
    }
    public init(_cjbind_empty: UInt8) {
        this._cjbind_empty = _cjbind_empty
    }
}

@C
public struct TemplateEmptyBase_TemplateEmptyBase {
    public let value: UInt8
    public func clone(): TemplateEmptyBase_TemplateEmptyBase {
        return this
    }
    public func toString(): String {
        var output = "TemplateEmptyBase_TemplateEmptyBase {"
        output += " value: "
        output += this.value.toString()
        output += " }"
        return output
    }
    public init(value: UInt8) {
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<TemplateEmptyBase_TemplateEmptyBase>()
        if (size != 1) {
            throw Exception("Size of TemplateEmptyBase_TemplateEmptyBase is not 1 but ${size} bytes")
        }
        let align = alignOf<TemplateEmptyBase_TemplateEmptyBase>()
        if (align != 1) {
            throw Exception("Alignment of TemplateEmptyBase_TemplateEmptyBase is not 1 but ${align} bytes")
        }
}

@C
public struct TemplateEmptyMember_TemplateEmptyMember {
    public let empty: EmptyTemplate_EmptyTemplate
    public let value: UInt8
    public func clone(): TemplateEmptyMember_TemplateEmptyMember {
        return this
    }
    public func toString(): String {
        var output = "TemplateEmptyMember_TemplateEmptyMember {"
        output += " empty: "
        output += this.empty.toString()
        output += ", value: "
        output += this.value.toString()
        output += " }"
        return output
    }
    public init(empty: EmptyTemplate_EmptyTemplate, value: UInt8) {
        this.empty = empty
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<TemplateEmptyMember_TemplateEmptyMember>()
        if (size != 2) {
            throw Exception("Size of TemplateEmptyMember_TemplateEmptyMember is not 2 but ${size} bytes")
        }
        let align = alignOf<TemplateEmptyMember_TemplateEmptyMember>()
        if (align != 1) {
            throw Exception("Alignment of TemplateEmptyMember_TemplateEmptyMember is not 1 but ${align} bytes")
        }
}

@C
public struct DeepEmptyBase_DeepEmptyBase {
    public let value: UInt8
    public func clone(): DeepEmptyBase_DeepEmptyBase {
        return this
    }
    public func toString(): String {
        var output = "DeepEmptyBase_DeepEmptyBase {"
        output += " value: "
        output += this.value.toString()
        output += " }"
        return output
    }
    public init(value: UInt8) {
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<DeepEmptyBase_DeepEmptyBase>()
        if (size != 1) {
            throw Exception("Size of DeepEmptyBase_DeepEmptyBase is not 1 but ${size} bytes")
        }
        let align = alignOf<DeepEmptyBase_DeepEmptyBase>()
        if (align != 1) {
            throw Exception("Alignment of DeepEmptyBase_DeepEmptyBase is not 1 but ${align} bytes")
        }
}

@C
public struct BaseWithVtable_open0_char_ptr_close0_BaseWithVtable_open0_char_ptr_close0 {
    public let vtable_: CPointer<Unit>
    public let value: CPointer<UInt8>
    public func clone(): BaseWithVtable_open0_char_ptr_close0_BaseWithVtable_open0_char_ptr_close0 {
        return this
    }
    public func toString(): String {
        var output = "BaseWithVtable_open0_char_ptr_close0_BaseWithVtable_open0_char_ptr_close0 {"
        output += " vtable_: "
        output += CPointer<Unit>(this.vtable_).toUIntNative().toString()
        output += ", value: "
        output += CPointer<Unit>(this.value).toUIntNative().toString()
        output += " }"
        return output
    }
    public init(vtable_: CPointer<Unit>, value: CPointer<UInt8>) {
        this.vtable_ = vtable_
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<BaseWithVtable_open0_char_ptr_close0_BaseWithVtable_open0_char_ptr_close0>()
        if (size != 16) {
            throw Exception(
                "Size of BaseWithVtable_open0_char_ptr_close0_BaseWithVtable_open0_char_ptr_close0 is not 16 but ${size} bytes")
        }
        let align = alignOf<BaseWithVtable_open0_char_ptr_close0_BaseWithVtable_open0_char_ptr_close0>()
        if (align != 8) {
            throw Exception(
                "Alignment of BaseWithVtable_open0_char_ptr_close0_BaseWithVtable_open0_char_ptr_close0 is not 8 but ${align} bytes")
        }
}

@C
public struct DerivedFromVtable_DerivedFromVtable {
    public let _base: BaseWithVtable_open0_char_ptr_close0_BaseWithVtable_open0_char_ptr_close0
    public func clone(): DerivedFromVtable_DerivedFromVtable {
        return this
    }
    public func toString(): String {
        var output = "DerivedFromVtable_DerivedFromVtable {"
        output += " _base: "
        output += this._base.toString()
        output += " }"
        return output
    }
    public init(_base: BaseWithVtable_open0_char_ptr_close0_BaseWithVtable_open0_char_ptr_close0) {
        this._base = _base
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<DerivedFromVtable_DerivedFromVtable>()
        if (size != 16) {
            throw Exception("Size of DerivedFromVtable_DerivedFromVtable is not 16 but ${size} bytes")
        }
        let align = alignOf<DerivedFromVtable_DerivedFromVtable>()
        if (align != 8) {
            throw Exception("Alignment of DerivedFromVtable_DerivedFromVtable is not 8 but ${align} bytes")
        }
}

foreign func _ZN18DerivedAddsVirtual5extraEv(this_: CPointer<Unit>): Int32

public unsafe func DerivedAddsVirtual_extra(this_: CPointer<Unit>): Int32 {
    return _ZN18DerivedAddsVirtual5extraEv(this_)
}

@C
public struct DerivedAddsVirtual_DerivedAddsVirtual {
    public let _base: BaseWithVtable_open0_char_ptr_close0_BaseWithVtable_open0_char_ptr_close0
    public func clone(): DerivedAddsVirtual_DerivedAddsVirtual {
        return this
    }
    public func toString(): String {
        var output = "DerivedAddsVirtual_DerivedAddsVirtual {"
        output += " _base: "
        output += this._base.toString()
        output += " }"
        return output
    }
    public init(_base: BaseWithVtable_open0_char_ptr_close0_BaseWithVtable_open0_char_ptr_close0) {
        this._base = _base
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<DerivedAddsVirtual_DerivedAddsVirtual>()
        if (size != 16) {
            throw Exception("Size of DerivedAddsVirtual_DerivedAddsVirtual is not 16 but ${size} bytes")
        }
        let align = alignOf<DerivedAddsVirtual_DerivedAddsVirtual>()
        if (align != 8) {
            throw Exception("Alignment of DerivedAddsVirtual_DerivedAddsVirtual is not 8 but ${align} bytes")
        }
}

@C
public struct BaseWithoutVtable_open0_int_close0_BaseWithoutVtable_open0_int_close0 {
    public let value: Int32
    public func clone(): BaseWithoutVtable_open0_int_close0_BaseWithoutVtable_open0_int_close0 {
        return this
    }
    public func toString(): String {
        var output = "BaseWithoutVtable_open0_int_close0_BaseWithoutVtable_open0_int_close0 {"
        output += " value: "
        output += this.value.toString()
        output += " }"
        return output
    }
    public init(value: Int32) {
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<BaseWithoutVtable_open0_int_close0_BaseWithoutVtable_open0_int_close0>()
        if (size != 4) {
            throw Exception(
                "Size of BaseWithoutVtable_open0_int_close0_BaseWithoutVtable_open0_int_close0 is not 4 but ${size} bytes")
        }
        let align = alignOf<BaseWithoutVtable_open0_int_close0_BaseWithoutVtable_open0_int_close0>()
        if (align != 4) {
            throw Exception(
                "Alignment of BaseWithoutVtable_open0_int_close0_BaseWithoutVtable_open0_int_close0 is not 4 but ${align} bytes")
        }
}

foreign func _ZN23DerivedIntroducesVtable3runEv(this_: CPointer<Unit>): Unit

public unsafe func DerivedIntroducesVtable_run(this_: CPointer<Unit>): Unit {
    return _ZN23DerivedIntroducesVtable3runEv(this_)
}

@C
public struct DerivedIntroducesVtable_DerivedIntroducesVtable {
    public let vtable_: CPointer<Unit>
    public let _base: BaseWithoutVtable_open0_int_close0_BaseWithoutVtable_open0_int_close0
    public func clone(): DerivedIntroducesVtable_DerivedIntroducesVtable {
        return this
    }
    public func toString(): String {
        var output = "DerivedIntroducesVtable_DerivedIntroducesVtable {"
        output += " vtable_: "
        output += CPointer<Unit>(this.vtable_).toUIntNative().toString()
        output += ", _base: "
        output += this._base.toString()
        output += " }"
        return output
    }
    public init(vtable_: CPointer<Unit>, _base: BaseWithoutVtable_open0_int_close0_BaseWithoutVtable_open0_int_close0) {
        this.vtable_ = vtable_
        this._base = _base
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<DerivedIntroducesVtable_DerivedIntroducesVtable>()
        if (size != 16) {
            throw Exception("Size of DerivedIntroducesVtable_DerivedIntroducesVtable is not 16 but ${size} bytes")
        }
        let align = alignOf<DerivedIntroducesVtable_DerivedIntroducesVtable>()
        if (align != 8) {
            throw Exception("Alignment of DerivedIntroducesVtable_DerivedIntroducesVtable is not 8 but ${align} bytes")
        }
}

@C
public struct DerivedWithoutVtable_DerivedWithoutVtable {
    public let _base: BaseWithoutVtable_open0_int_close0_BaseWithoutVtable_open0_int_close0
    public func clone(): DerivedWithoutVtable_DerivedWithoutVtable {
        return this
    }
    public func toString(): String {
        var output = "DerivedWithoutVtable_DerivedWithoutVtable {"
        output += " _base: "
        output += this._base.toString()
        output += " }"
        return output
    }
    public init(_base: BaseWithoutVtable_open0_int_close0_BaseWithoutVtable_open0_int_close0) {
        this._base = _base
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<DerivedWithoutVtable_DerivedWithoutVtable>()
        if (size != 4) {
            throw Exception("Size of DerivedWithoutVtable_DerivedWithoutVtable is not 4 but ${size} bytes")
        }
        let align = alignOf<DerivedWithoutVtable_DerivedWithoutVtable>()
        if (align != 4) {
            throw Exception("Alignment of DerivedWithoutVtable_DerivedWithoutVtable is not 4 but ${align} bytes")
        }
}

foreign func _ZN11VirtualRoot4rootEv(this_: CPointer<Unit>): CPointer<VirtualRoot_VirtualRoot>

public unsafe func VirtualRoot_root(this_: CPointer<Unit>): CPointer<VirtualRoot_VirtualRoot> {
    return _ZN11VirtualRoot4rootEv(this_)
}

@C
public struct VirtualRoot_VirtualRoot__cjbind_vtable {
    public let VirtualRoot_root: CFunc<(this_: CPointer<Unit>) -> CPointer<VirtualRoot_VirtualRoot>>
    public init(VirtualRoot_root: CFunc<(this_: CPointer<Unit>) -> CPointer<VirtualRoot_VirtualRoot>>) {
        this.VirtualRoot_root = VirtualRoot_root
    }
}

@C
public struct VirtualRoot_VirtualRoot {
    public let vtable_: CPointer<VirtualRoot_VirtualRoot__cjbind_vtable>
    public func clone(): VirtualRoot_VirtualRoot {
        return this
    }
    public func toString(): String {
        var output = "VirtualRoot_VirtualRoot {"
        output += " vtable_: "
        output += CPointer<Unit>(this.vtable_).toUIntNative().toString()
        output += " }"
        return output
    }
    public init(vtable_: CPointer<VirtualRoot_VirtualRoot__cjbind_vtable>) {
        this.vtable_ = vtable_
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<VirtualRoot_VirtualRoot>()
        if (size != 8) {
            throw Exception("Size of VirtualRoot_VirtualRoot is not 8 but ${size} bytes")
        }
        let align = alignOf<VirtualRoot_VirtualRoot>()
        if (align != 8) {
            throw Exception("Alignment of VirtualRoot_VirtualRoot is not 8 but ${align} bytes")
        }
}

@C
public struct VirtualMiddle_VirtualMiddle {
    public let _base: VirtualRoot_VirtualRoot
    public func clone(): VirtualMiddle_VirtualMiddle {
        return this
    }
    public func toString(): String {
        var output = "VirtualMiddle_VirtualMiddle {"
        output += " _base: "
        output += this._base.toString()
        output += " }"
        return output
    }
    public init(_base: VirtualRoot_VirtualRoot) {
        this._base = _base
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<VirtualMiddle_VirtualMiddle>()
        if (size != 8) {
            throw Exception("Size of VirtualMiddle_VirtualMiddle is not 8 but ${size} bytes")
        }
        let align = alignOf<VirtualMiddle_VirtualMiddle>()
        if (align != 8) {
            throw Exception("Alignment of VirtualMiddle_VirtualMiddle is not 8 but ${align} bytes")
        }
}

@C
public struct VirtualLeaf_VirtualLeaf {
    public let _base: VirtualMiddle_VirtualMiddle
    public func clone(): VirtualLeaf_VirtualLeaf {
        return this
    }
    public func toString(): String {
        var output = "VirtualLeaf_VirtualLeaf {"
        output += " _base: "
        output += this._base.toString()
        output += " }"
        return output
    }
    public init(_base: VirtualMiddle_VirtualMiddle) {
        this._base = _base
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<VirtualLeaf_VirtualLeaf>()
        if (size != 8) {
            throw Exception("Size of VirtualLeaf_VirtualLeaf is not 8 but ${size} bytes")
        }
        let align = alignOf<VirtualLeaf_VirtualLeaf>()
        if (align != 8) {
            throw Exception("Alignment of VirtualLeaf_VirtualLeaf is not 8 but ${align} bytes")
        }
}

foreign func _ZN13RecursiveBase7derivedEv(this_: CPointer<Unit>): CPointer<RecursiveDerived_RecursiveDerived>

public unsafe func RecursiveBase_derived(this_: CPointer<Unit>): CPointer<RecursiveDerived_RecursiveDerived> {
    return _ZN13RecursiveBase7derivedEv(this_)
}

@C
public struct RecursiveBase_RecursiveBase__cjbind_vtable {
    public let RecursiveBase_derived: CFunc<(this_: CPointer<Unit>) -> CPointer<RecursiveDerived_RecursiveDerived>>
    public init(RecursiveBase_derived: CFunc<(this_: CPointer<Unit>) -> CPointer<RecursiveDerived_RecursiveDerived>>) {
        this.RecursiveBase_derived = RecursiveBase_derived
    }
}

@C
public struct RecursiveBase_RecursiveBase {
    public let vtable_: CPointer<RecursiveBase_RecursiveBase__cjbind_vtable>
    public func clone(): RecursiveBase_RecursiveBase {
        return this
    }
    public func toString(): String {
        var output = "RecursiveBase_RecursiveBase {"
        output += " vtable_: "
        output += CPointer<Unit>(this.vtable_).toUIntNative().toString()
        output += " }"
        return output
    }
    public init(vtable_: CPointer<RecursiveBase_RecursiveBase__cjbind_vtable>) {
        this.vtable_ = vtable_
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<RecursiveBase_RecursiveBase>()
        if (size != 8) {
            throw Exception("Size of RecursiveBase_RecursiveBase is not 8 but ${size} bytes")
        }
        let align = alignOf<RecursiveBase_RecursiveBase>()
        if (align != 8) {
            throw Exception("Alignment of RecursiveBase_RecursiveBase is not 8 but ${align} bytes")
        }
}

foreign func _ZN16RecursiveDerived7derivedEv(this_: CPointer<Unit>): CPointer<RecursiveDerived_RecursiveDerived>

public unsafe func RecursiveDerived_derived(this_: CPointer<Unit>): CPointer<RecursiveDerived_RecursiveDerived> {
    return _ZN16RecursiveDerived7derivedEv(this_)
}

@C
public struct RecursiveDerived_RecursiveDerived {
    public let _base: RecursiveBase_RecursiveBase
    public func clone(): RecursiveDerived_RecursiveDerived {
        return this
    }
    public func toString(): String {
        var output = "RecursiveDerived_RecursiveDerived {"
        output += " _base: "
        output += this._base.toString()
        output += " }"
        return output
    }
    public init(_base: RecursiveBase_RecursiveBase) {
        this._base = _base
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<RecursiveDerived_RecursiveDerived>()
        if (size != 8) {
            throw Exception("Size of RecursiveDerived_RecursiveDerived is not 8 but ${size} bytes")
        }
        let align = alignOf<RecursiveDerived_RecursiveDerived>()
        if (align != 8) {
            throw Exception("Alignment of RecursiveDerived_RecursiveDerived is not 8 but ${align} bytes")
        }
}

@C
public struct DependentSize_open0_int_close0_DependentSize_open0_int_close0 {
    public let value: Int32
    public func clone(): DependentSize_open0_int_close0_DependentSize_open0_int_close0 {
        return this
    }
    public func toString(): String {
        var output = "DependentSize_open0_int_close0_DependentSize_open0_int_close0 {"
        output += " value: "
        output += this.value.toString()
        output += " }"
        return output
    }
    public init(value: Int32) {
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<DependentSize_open0_int_close0_DependentSize_open0_int_close0>()
        if (size != 4) {
            throw Exception(
                "Size of DependentSize_open0_int_close0_DependentSize_open0_int_close0 is not 4 but ${size} bytes")
        }
        let align = alignOf<DependentSize_open0_int_close0_DependentSize_open0_int_close0>()
        if (align != 4) {
            throw Exception(
                "Alignment of DependentSize_open0_int_close0_DependentSize_open0_int_close0 is not 4 but ${align} bytes")
        }
}

@C
public struct LayoutAnalysisHolder_LayoutAnalysisHolder {
    public let empty: Empty_Empty
    public let emptyDerived: EmptyDerived_EmptyDerived
    public let inherits: InheritsEmpty_InheritsEmpty
    public let contains: ContainsEmpty_ContainsEmpty
    public let array: ContainsEmptyArray_ContainsEmptyArray
    public let templateBase: TemplateEmptyBase_TemplateEmptyBase
    public let templateMember: TemplateEmptyMember_TemplateEmptyMember
    public let deepBase: DeepEmptyBase_DeepEmptyBase
    public let dependentNonZero: DependentSize_open0_int_close0_DependentSize_open0_int_close0
    public let inheritedVtable: CPointer<DerivedFromVtable_DerivedFromVtable>
    public let introducedVtable: CPointer<DerivedIntroducesVtable_DerivedIntroducesVtable>
    public let noVtable: CPointer<DerivedWithoutVtable_DerivedWithoutVtable>
    public let deepVtable: CPointer<VirtualLeaf_VirtualLeaf>
    public let recursiveVtable: CPointer<RecursiveDerived_RecursiveDerived>
    public func clone(): LayoutAnalysisHolder_LayoutAnalysisHolder {
        return this
    }
    public func toString(): String {
        var output = "LayoutAnalysisHolder_LayoutAnalysisHolder {"
        output += " empty: "
        output += this.empty.toString()
        output += ", emptyDerived: "
        output += this.emptyDerived.toString()
        output += ", inherits: "
        output += this.inherits.toString()
        output += ", contains: "
        output += this.contains.toString()
        output += ", array: "
        output += this.array.toString()
        output += ", templateBase: "
        output += this.templateBase.toString()
        output += ", templateMember: "
        output += this.templateMember.toString()
        output += ", deepBase: "
        output += this.deepBase.toString()
        output += ", dependentNonZero: "
        output += this.dependentNonZero.toString()
        output += ", inheritedVtable: "
        output += CPointer<Unit>(this.inheritedVtable).toUIntNative().toString()
        output += ", introducedVtable: "
        output += CPointer<Unit>(this.introducedVtable).toUIntNative().toString()
        output += ", noVtable: "
        output += CPointer<Unit>(this.noVtable).toUIntNative().toString()
        output += ", deepVtable: "
        output += CPointer<Unit>(this.deepVtable).toUIntNative().toString()
        output += ", recursiveVtable: "
        output += CPointer<Unit>(this.recursiveVtable).toUIntNative().toString()
        output += " }"
        return output
    }
    public init(empty: Empty_Empty, emptyDerived: EmptyDerived_EmptyDerived, inherits: InheritsEmpty_InheritsEmpty,
        contains: ContainsEmpty_ContainsEmpty, array: ContainsEmptyArray_ContainsEmptyArray,
        templateBase: TemplateEmptyBase_TemplateEmptyBase, templateMember: TemplateEmptyMember_TemplateEmptyMember,
        deepBase: DeepEmptyBase_DeepEmptyBase,
        dependentNonZero: DependentSize_open0_int_close0_DependentSize_open0_int_close0,
        inheritedVtable: CPointer<DerivedFromVtable_DerivedFromVtable>,
        introducedVtable: CPointer<DerivedIntroducesVtable_DerivedIntroducesVtable>,
        noVtable: CPointer<DerivedWithoutVtable_DerivedWithoutVtable>, deepVtable: CPointer<VirtualLeaf_VirtualLeaf>,
        recursiveVtable: CPointer<RecursiveDerived_RecursiveDerived>) {
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
        let size = sizeOf<LayoutAnalysisHolder_LayoutAnalysisHolder>()
        if (size != 64) {
            throw Exception("Size of LayoutAnalysisHolder_LayoutAnalysisHolder is not 64 but ${size} bytes")
        }
        let align = alignOf<LayoutAnalysisHolder_LayoutAnalysisHolder>()
        if (align != 8) {
            throw Exception("Alignment of LayoutAnalysisHolder_LayoutAnalysisHolder is not 8 but ${align} bytes")
        }
}
