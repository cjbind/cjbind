package cjbind.ir

import cjbind.clang
import cjbind.result.Result

extend clang.Type {
    public func fallibleLayout(ctx: CjbindContext): Result<Layout, LayoutError> {
        let args = this.fallibleLayoutArgs(UIntNative(ctx.targetInfo.pointerWidth))
        match(args) {
            case Ok(v) => return Ok(Layout(Int32(v[0]), Int32(v[1])))
            case Err(e) => return Err(LayoutError.from(Int32(e)))
        }
    }
}