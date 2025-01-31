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

    public func seenFunction(name: String): Bool {
        this.functionsSeen.contains(name)
    }

    public func sawFunction(name: String): Unit {
        this.functionsSeen.add(name)
    }

    public func seenVar(name: String): Bool {
        this.varsSeen.contains(name)
    }

    public func sawVar(name: String): Unit {
        this.varsSeen.add(name)
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

    public func codegen(
        ctx: CjbindContext,
        result: CodegenResult,
        _: Unit
    ): Unit {
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
            // TODO: 实现Union，Complex，不透明Array，位域等类型的适配
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

        // TODO: 支持自动生成 ABI 注解
        // https://gitcode.com/Cangjie/UsersForum/issues/1595
        // let abi = signature.abi

        let args = Utils.fnsigArguments(ctx, signature)
        let ret = Utils.fnsigReturnTy(ctx, signature)

        let ident = ctx.cjIdent(name)

        if (signature.isVariadic) {
            args.add(quote(...))
        }

        let argsToken = joinTokens(args, quote(,))

        let tokens = optionalComment(
            commentToken,
            quote(foreign func $(ident) ( $(argsToken) ) : $(ret))
        )

        result.items.add(tokens)
    }
}

extend Var <: CodeGenerator<Item, Unit> {
    public func codegen(
        ctx: CjbindContext,
        result: CodegenResult,
        item: Item
    ): Unit {
        // 只支持 C，不需要考虑 namespace
        let canonicalName = item.baseName(ctx)

        if (result.seenVar(canonicalName)) {
            return
        }
        result.sawVar(canonicalName)

        let canonicalIdent = ctx.cjIdent(canonicalName)

        let commentToken: ?Tokens = if (let Some(c) <- item.comment) {
            let pc = preprocessComment(c)
            Some(Attributes.doc(pc))
        } else {
            None
        }

        let varTy = this.ty
        let ty = varTy.toCjTyOrOpaque(ctx, ())

        if (let Some(v) <- this.val) {
            match (v) {
                case VarType.VarBool(vv) => result
                    .items
                    .add(
                        optionalComment(
                            commentToken,
                            quote(public const $(canonicalIdent) : $(ty) = $(vv))
                        )
                    )
                case VarType.VarInt(vv) => result
                    .items
                    .add(
                        optionalComment(
                            commentToken,
                            quote(public const $(canonicalIdent) : $(ty) = $(vv))
                        )
                    )
                case VarType.VarString(vv) =>
                    let data = ArrayList(vv.toArray())
                    data.add(0u8)

                    let tokens = quote(public const $(canonicalIdent) : VArray<UInt8, $(data.size)> = $(data))
                    if (let Some(v) <- commentToken) {
                        v.append(Token(TokenKind.NL))
                        v.append(Token(TokenKind.COMMENT, "// String value: ${vv}"))
                    }
                    result.items.add(
                        optionalComment(
                            commentToken,
                            tokens
                        )
                    )
                case VarType.VarFloat(vv) =>
                    if (let Ok(expr) <- AstTy.floatExpr(ctx, vv)) {
                        result
                            .items
                            .add(
                                optionalComment(
                                    commentToken,
                                    quote(public const $(canonicalIdent) : $(ty) = $(expr))
                                )
                            )
                    }
                case VarType.VarChar(vv) => result
                    .items
                    .add(
                        optionalComment(
                            commentToken,
                            quote(public const $(canonicalIdent) : $(ty) = $(vv))
                        )
                    )
            }
        } else {
            // 仓颉没有提供 extern C 的变量支持，忽略
        }
    }
}

extend Type <: CodeGenerator<Item, Unit> {
    public func codegen(
        ctx: CjbindContext,
        result: CodegenResult,
        item: Item
    ): Unit {
        match (this.kind) {
            case TypeKind.TypeKindVoid | TypeKind.TypeKindNullPtr | TypeKind.TypeKindInt(_) | TypeKind.TypeKindFloat(_) | TypeKind
                    .TypeKindComplex(_) | TypeKind.TypeKindArray(_, _) | TypeKind.TypeKindVector(_, _) | TypeKind
                    .TypeKindPointer(_) | TypeKind.TypeKindFunction(_) | TypeKind.ResolvedTypeRef(_) | TypeKind
                    .TypeKindOpaque => ()
            case TypeKind.TypeKindComp(ci) => ci.codegen(ctx, result, item)
            case TypeKind.TypeKindAlias(inner) =>
                let innerItem = inner.intoResolver().throughTypeRefs().resolve(ctx)
                let name = item.baseName(ctx)

                let throughTypeAliases = inner.intoResolver().throughTypeRefs().throughTypeAliases().resolve(ctx)

                if (throughTypeAliases.baseName(ctx) == name) {
                    return
                }

                let spelling = this.name.getOrThrow()
                if (Utils.typeFromNamed(ctx, spelling).isSome()) {
                    return
                }

                let isOpaque = item.isOpaque(ctx, ())
                let innerCjType = if (isOpaque) {
                    this.toOpaque(ctx, item)
                } else {
                    innerItem.tryToCjTyOrOpaque(ctx, ()).unwrapOrElse {
                        _ => this.toOpaque(ctx, item)
                    }
                }

                let cjName = ctx.cjIdent(name)
                let commentToken: ?Tokens = if (let Some(c) <- item.comment) {
                    let pc = preprocessComment(c)
                    Some(Attributes.doc(pc))
                } else {
                    None
                }

                let tokens = optionalComment(
                    commentToken,
                    quote(public type $(cjName) = $(innerCjType))
                )
                result.items.add(tokens)
            case TypeKind.TypeKindEnum(ei) => ei.codegen(ctx, result, item)
            case TypeKind.UnresolvedTypeRef(_, _, _) => throw Exception("should have been resolved by now")
        }
    }
}

extend CompInfo <: CodeGenerator<Item, Unit> {
    // TODO: 支持 union 和 bitfield
    public func codegen(
        ctx: CjbindContext,
        result: CodegenResult,
        item: Item
    ): Unit {
        let ty = item.kind.expectType()
        let layout = ty.getLayout(ctx)

        let packed = this.isPacked(ctx, layout)
        if (packed) {
            // 仓颉当前无法创建 packed 的结构体
            return
        }

        if (this.isUnion()) {
            // TODO: 支持 Union
            return
        }

        if (let CompFieldsAfter(v) <- this.fields) {
            if (v.hasBitfieldUnits) {
                // TODO: 支持 bitfield
                return
            }
        } else {
            // 处理错误？
            return
        }

        let canonicalName = item.baseName(ctx)
        let canonicalIdent = ctx.cjIdent(canonicalName)

        throw Exception("TODO")
    }
}
