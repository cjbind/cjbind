package cjbind.codegen

import std.ast.*

import cjbind.ir.*
import cjbind.result.Result

interface TryToCjTy<Extra> {
    func tryToCjTy(
        ctx: CjbindContext,
        extra: Extra
    ): Result<Tokens, Error>
}

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
            layout => 
                return Helpers.blob(ctx, layout)
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
        return ctx.resolveItem(this).tryToCjType(ctx, ())
    }
}

extend ItemId <: ToOpaque<Unit> {
    public func tryGetLayout(
        ctx: CjbindContext,
        _: Unit
    ): Result<Layout, Error> {
        return ctx.resolveItem(this).tryGetLayout(ctx, ())
    }
}

extend ItemId <: ToCjTyOrOpaque<Unit> {
}

extend Item <: TryToCjTy<Unit> {
    public func tryToCjTy(
        ctx: CjbindContext,
        _: Unit
    ): Result<Tokens, Error> {
        return this.kind.expectType().tryToCjTy(ctx, this)
    }
}

extend Item <: ToOpaque<Unit> {
    public func tryGetLayout(
        ctx: CjbindContext,
        _: Unit
    ): Result<Layout, Error> {
        return this.kind.expectType().tryGetLayout(ctx, this)
    }
}

extend Item <: ToCjTyOrOpaque<Unit> {
}

extend Type <: TryToCjTy<Item> {
    public func tryToCjTy(
        ctx: CjbindContext,
        item: Item
    ): Result<Tokens, Error> {
        match (this.kind) {
            case TypeKind.TypeKindVoid => 
                
        }
    }
}

extend Type <: ToOpaque<Item> {
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