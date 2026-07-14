package cjbind_ffi

@C
public struct SelectedDependency_SelectedDependency {
    public let value: Int32
    public func clone(): SelectedDependency_SelectedDependency {
        return this
    }
    public func toString(): String {
        var output = "SelectedDependency_SelectedDependency {"
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
        let size = sizeOf<SelectedDependency_SelectedDependency>()
        if (size != 4) {
            throw Exception("Size of SelectedDependency_SelectedDependency is not 4 but ${size} bytes")
        }
        let align = alignOf<SelectedDependency_SelectedDependency>()
        if (align != 4) {
            throw Exception("Alignment of SelectedDependency_SelectedDependency is not 4 but ${align} bytes")
        }
}

foreign func _Z12selected_api18SelectedDependency(value: SelectedDependency_SelectedDependency): SelectedDependency_SelectedDependency

public unsafe func selected_api(value: SelectedDependency_SelectedDependency): SelectedDependency_SelectedDependency {
    return _Z12selected_api18SelectedDependency(value)
}
