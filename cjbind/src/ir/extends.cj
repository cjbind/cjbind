package cjbind.ir

import cjbind.clang
import cjbind.result.Result

extend clang.Type {
    public func fallibleLayout(ctx: CjbindContext): Result<Layout, LayoutError> {
        let args = this.fallibleLayoutArgs(UIntNative(ctx.pointerWidth()))
        match(args) {
            case Ok(v) => return Ok(Layout(Int32(v[0]), Int32(v[1])))
            case Err(e) => return Err(LayoutError.from(Int32(e)))
        }
    }
}

extend clang.Cursor {
    // Returns offset in bits, not bytes.
    public func offsetOfField(): Result<UIntNative, LayoutError> {
        let offset = this.offsetOfFieldRaw()
        if (offset < 0) {
            return Result.Err(LayoutError.from(Int32(offset)))
        } else {
            if (offset < Int64(Int32.Min) || offset > Int64(Int32.Max)) {
                return Result.Err(LayoutError.LayoutErrorUnknown)
            }
            return Result.Ok(UIntNative(offset))
        }
    }
}