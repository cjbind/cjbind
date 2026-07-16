package cjbind_ffi

foreign func foo(): Int32

public type number = Int32

foreign func bar(x: number): Int32

@C
public struct Point {
    public var x: number
    public var y: number
    public init(x: number, y: number) {
        this.x = x
        this.y = y
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<Point>()
        if (size != 8) {
            throw Exception("Size of Point is not 8 but ${size} bytes")
        }
        let align = alignOf<Point>()
        if (align != 4) {
            throw Exception("Alignment of Point is not 4 but ${align} bytes")
        }
}

@C
public struct Angle {
    public var a: number
    public var b: number
    public init(a: number, b: number) {
        this.a = a
        this.b = b
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<Angle>()
        if (size != 8) {
            throw Exception("Size of Angle is not 8 but ${size} bytes")
        }
        let align = alignOf<Angle>()
        if (align != 4) {
            throw Exception("Alignment of Angle is not 4 but ${align} bytes")
        }
}

foreign func baz(point: Point): Int32

public const NUMBER: number = 42
