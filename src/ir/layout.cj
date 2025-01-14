package cjbind.ir

import cjbind.clang

public open class Layout {
    public let size: Int32
    public let align: Int32
    public let packed: Bool = false

    public init(
        size: Int32, 
        align: Int32, 
    ) {
        this.size = size
        this.align = align
    }
}

public class Opaque <: Layout {
    public init(
        size: Int32, 
        align: Int32,
    ) {
        super(size, align)
    }

    public static func fromClangTy(
        ty: clang.Type,
        ctx: CjbindContext
    ) {
        let ptrSize = UIntNative(ctx.targetInfo.pointerWidth)
        let layout = Layout(Int32(ty.size(ptrSize)), Int32(ty.align(ptrSize)))
        
    }
}