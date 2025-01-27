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

}

interface ToCjTyOrOpaque<Extra> <: TryToCjTy<Extra> & ToOpaque<Extra> {
    
}