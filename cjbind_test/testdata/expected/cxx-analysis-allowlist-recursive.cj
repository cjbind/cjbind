package cjbind_ffi

@C
public struct SelectedDependency {
    public var value: Int32
    private init(value: Int32) {
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<SelectedDependency>()
        if (size != 4) {
            throw Exception("Size of SelectedDependency is not 4 but ${size} bytes")
        }
        let align = alignOf<SelectedDependency>()
        if (align != 4) {
            throw Exception("Alignment of SelectedDependency is not 4 but ${align} bytes")
        }
}

foreign func _Z12selected_api18SelectedDependency(value: SelectedDependency): SelectedDependency

public unsafe func selected_api(value: SelectedDependency): SelectedDependency {
    return _Z12selected_api18SelectedDependency(value)
}
