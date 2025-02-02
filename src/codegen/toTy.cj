package cjbind.codegen

import std.ast.*
import cjbind.ir.*
import cjbind.result.{Result}

// 实现时应该添加对于 ToOpaque 的实现
interface TryToOpaque<Extra> {
    func tryGetLayout(
        ctx: CjbindContext,
        extra: Extra
    ): Result<Layout, Error>

    func tryToOpaque(
        ctx: CjbindContext,
        extra: Extra
    ): Result<Tokens, Error> {
        this.tryGetLayout(ctx, extra).map {
            layout => return Helpers.blob(ctx, layout)
        }
    }
}

interface ToOpaque<Extra> <: TryToOpaque<Extra> {
    func getLayoutUnsafe(
        ctx: CjbindContext,
        extra: Extra
    ): Layout {
        this.tryGetLayout(ctx, extra).unwrapOrElse {
            _ => return Layout.forSize(ctx, 1)
        }
    }

    func toOpaque(
        ctx: CjbindContext,
        extra: Extra
    ): Tokens {
        let layout = this.getLayoutUnsafe(ctx, extra)
        Helpers.blob(ctx, layout)
    }
}

interface TryToCjTy<Extra> {
    func tryToCjTy(
        ctx: CjbindContext,
        extra: Extra
    ): Result<Tokens, Error>
}

interface TryToCjTyOrOpaque<Extra> <: TryToCjTy<Extra> & TryToOpaque<Extra> {
    func tryToCjTyOrOpaque(
        ctx: CjbindContext,
        extra: Extra
    ): Result<Tokens, Error> {
        this
            .tryToCjTy(ctx, extra)
            .orElse {
                _ => if (let Ok(layout) <- this.tryGetLayout(ctx, extra)) {
                    Ok(Helpers.blob(ctx, layout))
                } else {
                    Err(Error.NoLayoutForOpaqueBlob)
                }
            }
    }
}

interface ToCjTyOrOpaque<Extra> <: TryToCjTy<Extra> & ToOpaque<Extra> {
    func toCjTyOrOpaque(
        ctx: CjbindContext,
        extra: Extra
    ): Tokens {
        this.tryToCjTy(ctx, extra).unwrapOrElse {
            _ => this.toOpaque(ctx, extra)
        }
    }
}

extend ItemId <: TryToCjTy<Unit> {
    public func tryToCjTy(
        ctx: CjbindContext,
        _: Unit
    ): Result<Tokens, Error> {
        return ctx.resolveItem(this).tryToCjTy(ctx, ())
    }
}

extend ItemId <: TryToOpaque<Unit> {
    public func tryGetLayout(
        ctx: CjbindContext,
        _: Unit
    ): Result<Layout, Error> {
        return ctx.resolveItem(this).tryGetLayout(ctx, ())
    }
}

extend ItemId <: ToOpaque<Unit> {}

extend ItemId <: ToCjTyOrOpaque<Unit> & TryToCjTyOrOpaque<Unit> {}

extend Item <: TryToCjTy<Unit> {
    public func tryToCjTy(
        ctx: CjbindContext,
        _: Unit
    ): Result<Tokens, Error> {
        return this.kind.expectType().tryToCjTy(ctx, this)
    }
}

extend Item <: TryToOpaque<Unit> {
    public func tryGetLayout(
        ctx: CjbindContext,
        _: Unit
    ): Result<Layout, Error> {
        return this.kind.expectType().tryGetLayout(ctx, this)
    }
}

extend Item <: ToCjTyOrOpaque<Unit> & TryToCjTyOrOpaque<Unit> {}

extend Type <: TryToCjTy<Item> {
    // cjlint-ignore -start !G.FUN.01
    public func tryToCjTy(
        ctx: CjbindContext,
        item: Item
    ): Result<Tokens, Error> {
        match (this.kind) {
            case TypeKind.TypeKindVoid => return Ok(AstTy.cVoid(ctx))
            case TypeKind.TypeKindNullPtr => return Ok(AstTy.cVoid(ctx).toPtr())
            case TypeKind.TypeKindInt(ik) =>
                let ret = AstTy.intKindCjType(ctx, ik, this.getLayout(ctx))
                return Ok(ret)
            case TypeKind.TypeKindFloat(fk) =>
                let ret = AstTy.floatKindCjType(ctx, fk, this.getLayout(ctx))
                return Ok(ret)
            case TypeKind.TypeKindComplex(_) => return Err(Error.Unsupported("complex not supported yet"))
            case TypeKind.TypeKindFunction(signature) =>
                let ty = match (signature.tryToCjTy(ctx, item)) {
                    case Ok(v) => v
                    case Err(e) => return Err(e)
                }
                return Ok(ty)
            case TypeKind.TypeKindArray(item, len) =>
                let ty = match (item.tryToCjTy(ctx, ())) {
                    case Ok(v) => v
                    case Err(e) => return Err(e)
                }
                let lenOk = Int64(len)
                let token = quote(VArray<$(ty), \$$(lenOk)>)
                return Ok(token)
            case TypeKind.TypeKindVector(item, len) =>
                let ty = match (item.tryToCjTy(ctx, ())) {
                    case Ok(v) => v
                    case Err(e) => return Err(e)
                }
                let lenOk = Int64(len)
                let token = quote(VArray<$(ty), \$$(lenOk)>)
                return Ok(token)
            case TypeKind.TypeKindEnum(_) => return Ok(Tokens(ctx.cjIdentRaw(item.baseName(ctx))))
            case TypeKind.ResolvedTypeRef(inner) => return inner.tryToCjTy(ctx, ())
            case TypeKind.TypeKindAlias(_) =>
                if (let Some(n) <- this.name) {
                    let named = Utils.typeFromNamed(ctx, n)
                    if (let Some(nn) <- named) {
                        return Ok(nn)
                    }
                }
                return Ok(Tokens(ctx.cjIdentRaw(item.baseName(ctx))))
            case TypeKind.TypeKindComp(info) => return Ok(Tokens(ctx.cjIdentRaw(item.baseName(ctx))))
            case TypeKind.TypeKindOpaque => return this.tryToOpaque(ctx, item)
            case TypeKind.TypeKindPointer(inner) =>
                let size = this.getLayoutUnsafe(ctx, item).size
                if (size != ctx.targetInfo.pointerWidth) {
                    return Err(
                        Error.InvalidPointerSize(
                            this.name.getOrDefault {=> "unknown"},
                            UIntNative(size),
                            UIntNative(ctx.targetInfo.pointerWidth)
                        )
                    )
                }

                let innerTy = inner.intoResolver().throughTypeRefs().resolve(ctx).kind.expectType()

                let ty = inner.toCjTyOrOpaque(ctx, ())

                if (innerTy.canonicalType(ctx).isFunction()) {
                    return Ok(ty)
                } else {
                    return Ok(ty.toPtr())
                }
            case TypeKind.UnresolvedTypeRef(_, _, _) => throw Exception("unreachable")
        }
    }
    // cjlint-ignore -end
}

extend Type <: TryToOpaque<Item> {
    public func tryGetLayout(
        ctx: CjbindContext,
        _: Item
    ): Result<Layout, Error> {
        match (this.getLayout(ctx)) {
            case Some(v) => Ok(v)
            case None => Err(Error.NoLayoutForOpaqueBlob)
        }
    }
}

extend Type <: ToOpaque<Item> {}
extend Type <: ToCjTyOrOpaque<Item> {}

extend FunctionSig <: TryToCjTy<Item> {
    public func tryToCjTy(
        ctx: CjbindContext,
        _: Item
    ): Result<Tokens, Error> {
        if (this.isVariadic) {
            return Err(Error.Unsupported("variadic func type not supported"))
        }

        let ret = Utils.fnsigReturnTy(ctx, this)
        let arguments = Utils.fnsigArguments(ctx, this)

        let joined = joinTokens(arguments, quote(,))

        let retToken = quote(CFunc<$(joined)> -> $(ret))
        return Ok(retToken)
    }
}
