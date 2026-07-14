package cjbind_ffi

public type number_number = Int32

foreign func bar(x: number_number): Int32

@C
public struct Point_Point {
    public let x: number_number
    public let y: number_number
    public func clone(): Point_Point {
        return this
    }
    public func toString(): String {
        var output = "Point_Point {"
        output += " x: "
        output += this.x.toString()
        output += ", y: "
        output += this.y.toString()
        output += " }"
        return output
    }
    public init(x: number_number, y: number_number) {
        this.x = x
        this.y = y
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<Point_Point>()
        if (size != 8) {
            throw Exception("Size of Point_Point is not 8 but ${size} bytes")
        }
        let align = alignOf<Point_Point>()
        if (align != 4) {
            throw Exception("Alignment of Point_Point is not 4 but ${align} bytes")
        }
}

@C
public struct Angle_Angle {
    public let a: number_number
    public let b: number_number
    public func clone(): Angle_Angle {
        return this
    }
    public func toString(): String {
        var output = "Angle_Angle {"
        output += " a: "
        output += this.a.toString()
        output += ", b: "
        output += this.b.toString()
        output += " }"
        return output
    }
    public init(a: number_number, b: number_number) {
        this.a = a
        this.b = b
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<Angle_Angle>()
        if (size != 8) {
            throw Exception("Size of Angle_Angle is not 8 but ${size} bytes")
        }
        let align = alignOf<Angle_Angle>()
        if (align != 4) {
            throw Exception("Alignment of Angle_Angle is not 4 but ${align} bytes")
        }
}

foreign func baz(point: Point_Point): Int32

public const NUMBER_NUMBER: number_number = 42
