package cjbind.codegen

import std.ast.*
import std.collection.{ArrayList, HashSet}
import cjbind.ir.*
import cjbind.options.CjbindOptions
import cjbind.result.Result

public struct CodegenSerializeError {
    public let msg: String
    public let loc: String

    public init(
        msg: String,
        loc: String
    ) {
        this.msg = msg
        this.loc = loc
    }
}

public enum CodegenError {
    Serialize(CodegenSerializeError)
    | Io(String)
}

public class CodegenResult {
    public let items: ArrayList<Tokens> = ArrayList<Tokens>()

    public var sawCjbindUnion: Bool = false
    public var sawIncompleteArray: Bool = false
    public var sawBitfieldUnit: Bool = false

    public let itemsSeen: HashSet<ItemId> = HashSet()

    public let functionsSeen: HashSet<String> = HashSet()
    public let varsSeen: HashSet<String> = HashSet<String>()

    public func seen(id: ItemId): Bool {
        return this.itemsSeen.contains(id)
    }

    public func setSeen(id: ItemId): Unit {
        this.itemsSeen.add(id)
    }

    public func seenFunction(name: String) {
        this.functionsSeen.contains(name)
    }

    public func sawFunction(name: String) {
        this.functionsSeen.add(name)
    }

    public func inner(cb: (CodegenResult) -> Unit): ArrayList<Tokens> {
        let next = CodegenResult()
        cb(next)

        this.sawIncompleteArray ||= next.sawIncompleteArray
        this.sawCjbindUnion ||= next.sawCjbindUnion
        this.sawBitfieldUnit ||= next.sawBitfieldUnit

        return next.items
    }
}

public interface CodeGenerator<Extra, Return> {
    func codegen(ctx: CjbindContext, result: CodegenResult, extra: Extra): Return
}

public func codegen(tctx: CjbindContext): Result<(Tokens, CjbindOptions), CodegenError> {
    tctx.gen<CodegenError> {
        context =>
        let result = CodegenResult()

        context.resolveItem(context.rootModule).codegen(
            context,
            result,
            ()
        )

        throw Exception("TODO")
    }

    throw Exception()
}

extend Item <: CodeGenerator<Unit, Unit> {
    func processBeforeCodegen(
        ctx: CjbindContext,
        result: CodegenResult
    ): Bool {
        if (result.seen(this.id)) {
            return false
        }

        result.setSeen(this.id)
        return true
    }

    func codegen(
        ctx: CjbindContext,
        result: CodegenResult,
        _: Unit
    ) {
        if (!this.processBeforeCodegen(ctx, result)) {
            return
        }

        match (this.kind) {
            case ItemKind.KindModule(module) => module.codegen(ctx, result, this)
            case ItemKind.KindFunction(fun) => fun.codegen(ctx, result, this)
            case ItemKind.KindVar(v) => v.codegen(ctx, result, this)
            case ItemKind.KindType(ty) => ty.codegen(ctx, result, this)
        }
    }
}

extend Module <: CodeGenerator<Item, Unit> {
    public func codegen(
        ctx: CjbindContext,
        result: CodegenResult,
        item: Item
    ) {
        let codegenItems = ctx.codegenItems.getOrThrow()
        for (child in this.children) {
            if (codegenItems.contains(child)) {
                ctx.resolveItem(child).codegen(ctx, result, ())
            }
        }

        if (item.id == ctx.rootModule) {
            // TODO: 实现Union，Complex，透明Array，位域等类型的适配
        }
    }
}

extend Function <: CodeGenerator<Item, Unit> {
    public func codegen(
        ctx: CjbindContext,
        result: CodegenResult,
        item: Item
    ): Unit {
        let isInternal = match (this.linkage) {
            case FunctionLinkage.LinkageInternal => true
            case FunctionLinkage.LinkageExternal => false
        }

        if (isInternal) {
            return
        }

        let signatureItem = ctx.resolveItem(this.signature)
        let signatureTy = signatureItem.kind.expectType().canonicalType(ctx)

        let signature = match (signatureTy.kind) {
            case TypeKind.TypeKindFunction(sig) => sig
            case _ => throw Exception("expected function type for sig")
        }

        // if (signature.isVariadic) {
        //     // TODO: 支持可变参数调用
        //     return
        // }

        let name = this.name

        if (result.seenFunction(name)) {
            return
        }

        result.sawFunction(name)

        let commentToken: ?Tokens = if (let Some(c) <- item.comment) {
            let pc = preprocessComment(c)
            Some(Attributes.doc(pc))
        } else {
            None
        }

        let abi = signature.abi



        throw Exception("TODO")
    }
}
