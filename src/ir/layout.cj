package cjbind.ir

import std.ast.Tokens

import cjbind.clang

public open class Layout {
    public let size: Int32
    public let align: Int32
    public let packed: Bool = false

    public init(
        size: Int32, 
        align: Int32
    ) {
        this.size = size
        this.align = align
    }

    public func opaque(): Opaque {
        return Opaque(this.size, this.align)
    }

    static func forSizeInternal(ptrSize: Int32, size: Int32): Layout {
        var nextAlign = 2i32
        while (size % nextAlign == 0 && nextAlign <= ptrSize) {
            nextAlign *= 2
        }

        return Layout(size, nextAlign / 2)
    }

    public static func forSize(ctx: CjbindContext, size: Int32): Layout {
        return Layout.forSizeInternal(ctx.targetInfo.pointerWidth / 8, size)
    }

    public static func knownCjTypeForSize(size: Int32): ?Tokens {
        return match (size) {
            case 1 => quote(UInt8)
            case 2 => quote(UInt16)
            case 4 => quote(UInt32)
            case 8 => quote(UInt64)
            case _ => None
        }
    }
}

public class Opaque <: Layout {
    public init(
        size: Int32, 
        align: Int32
    ) {
        super(size, align)
    }

    public static func fromClangTy(
        ty: clang.Type,
        ctx: CjbindContext
    ): Type {
        let ptrSize = UIntNative(ctx.targetInfo.pointerWidth)
        let layout = Layout(Int32(ty.size(ptrSize)), Int32(ty.align(ptrSize)))
        return Type(None, layout, TypeKind.TypeKindOpaque, ty.isConst())   
    }

    public func knownCjTypeForArray(): ?Tokens {
        return Layout.knownCjTypeForSize(this.align)
    }

    public func arraySize(): ?Int32 {
        if (this.knownCjTypeForArray().isSome()) {
            return Some(this.size / max(this.align, 1))
        } else {
            return None
        }
    }
}

public enum LayoutError {
    LayoutErrorInvalid |
    LayoutErrorDependent |
    LayoutErrorNotConstantSize |
    LayoutErrorInvalidFieldName |
    LayoutErrorUnknown

    public static func from(val: Int32): LayoutError {
        if (val == clang.CXTypeLayoutError_Invalid) {
            return LayoutErrorInvalid
        }
        if (val == clang.CXTypeLayoutError_Dependent) {
            return LayoutErrorDependent
        }
        if (val == clang.CXTypeLayoutError_NotConstantSize) {
            return LayoutErrorNotConstantSize
        }
        if (val == clang.CXTypeLayoutError_InvalidFieldName) {
            return LayoutErrorInvalidFieldName
        }
        return LayoutErrorUnknown
    }
}