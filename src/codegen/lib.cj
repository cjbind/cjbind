package cjbind.codegen

import std.ast.*
import std.collection.{ArrayList, HashSet}
import cjbind.build.VERSION
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

public func codegen(tctx: CjbindContext): Result<Tokens, CodegenError> {
    return tctx.gen<CodegenError> {
        context =>
        let result = CodegenResult()

        context.resolveItem(context.rootModule).codegen(
            context,
            result,
            ()
        )

        let ret = joinTokens(result.items, Tokens(Token(TokenKind.NL), Token(TokenKind.NL)))
        return Ok<Tokens, CodegenError>(ret)
    }
}

extend Item <: CodeGenerator<Unit, Unit> {
    func processBeforeCodegen(
        _: CjbindContext,
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

            let header = Tokens(Token(TokenKind.COMMENT, "// cjbind ${VERSION} 生成，请勿编辑, DO NOT EDIT"))
            let pkgName = ctx.cjIdent(ctx.options.packageName)
            header.append(quote(
                
                package $(pkgName)))

            result.items.add(header, at: 0)
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

        if (signature.getIsVariadic()) {
            args.add(quote(...))
        }

        let argsToken = joinTokens(args, quote(,))

        let tokens = optionalComment(
            ctx,
            commentToken,
            quote(foreign func $(ident) ( $(argsToken) ) : $(ret))
        )

        result.items.add(tokens)

        if (ctx.options.makeFuncWrapper) {
            let wrapperName = ctx.cjIdent("${name}${ctx.options.funcWrapperSuffix}")
            let argsName = Utils.fnsigArgumentNames(ctx, signature)
            let argsNameToken = joinTokens(argsName, quote(,))
            let tokens = optionalComment(
                ctx,
                commentToken,
                quote(
                    public unsafe func $(wrapperName) ( $(argsToken) ) : $(ret) {
                    return $(ident)( $(argsNameToken) )
                })
            )

            result.items.add(tokens)
        }
    }
}

extend Var <: CodeGenerator<Item, Unit> {
    // cjlint-ignore -start !G.FUN.01
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

        var commentToken: ?Tokens = if (let Some(c) <- item.comment) {
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
                            ctx,
                            commentToken,
                            quote(public const $(canonicalIdent) : $(ty) = $(vv))
                        )
                    )
                case VarType.VarInt(vv) => result
                    .items
                    .add(
                        optionalComment(
                            ctx,
                            commentToken,
                            quote(public const $(canonicalIdent) : $(ty) = $(vv))
                        )
                    )
                case VarType.VarString(vv) =>
                    if (!ctx.options.makeCjString) {
                        let data = ArrayList<UInt8>()

                        let ptr = vv.getChars()
                        let size = vv.size()
                        for (i in 0..=size) {
                            let d = unsafe { (ptr + i).read() }
                            data.add(d)
                        }

                        let tokens = quote(
                            public const $(canonicalIdent) : VArray<UInt8, \$$(data.size)> = $(data.toArray()))
                        if (commentToken.isNone()) {
                            commentToken = Tokens()
                        }

                        if (let Some(v) <- commentToken) {
                            v.append(Token(TokenKind.NL))
                            v.append(Token(TokenKind.COMMENT, "// String value: ${vv}"))
                        }
                        result.items.add(
                            optionalComment(
                                ctx,
                                commentToken,
                                tokens
                            )
                        )
                    } else {
                        let str = vv.toString()
                        let tokens = quote(public const $(canonicalIdent) : String = $(str))
                        result.items.add(
                            optionalComment(
                                ctx,
                                commentToken,
                                tokens
                            )
                        )
                    }
                case VarType.VarFloat(vv) =>
                    if (let Ok(expr) <- AstTy.floatExpr(ctx, vv)) {
                        result
                            .items
                            .add(
                                optionalComment(
                                    ctx,
                                    commentToken,
                                    quote(public const $(canonicalIdent) : $(ty) = $(expr))
                                )
                            )
                    }
                case VarType.VarChar(vv) => result
                    .items
                    .add(
                        optionalComment(
                            ctx,
                            commentToken,
                            quote(public const $(canonicalIdent) : $(ty) = $(vv))
                        )
                    )
            }
        } else {
            // 仓颉没有提供 extern C 的变量支持，忽略
        }
    }
    // cjlint-ignore -end
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
                    ctx,
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
    // cjlint-ignore -start !G.FUN.01
    public func codegen(
        ctx: CjbindContext,
        result: CodegenResult,
        item: Item
    ): Unit {
        let ty = item.kind.expectType()
        let layout = ty.getLayout(ctx)

        let canonicalName = item.baseName(ctx)
        var isOpaque = item.isOpaque(ctx, ())

        let packed = this.isPacked(ctx, layout)
        if (packed) {
            // 仓颉当前无法创建 packed 的结构体
            eprintln("警告：${canonicalName} 是一个 packed 类型，cj 暂不支持，跳过生成")
            return
        }

        if (this.isUnion()) {
            // TODO: 支持 Union
            isOpaque = true
        }

        if (let CompFieldsAfter(v) <- this.fields) {
            if (v.hasBitfieldUnits) {
                // TODO: 支持 bitfield
                isOpaque = true
            }
        } else {
            throw Exception("${canonicalName} 的字段应该被正确计算")
        }

        let canonicalIdent = ctx.cjIdent(canonicalName)

        let fields = ArrayList<Tokens>()

        // (fieldName, fieldType)
        let sigs = Tokens()
        let inits = ArrayList<Tokens>()

        if (!isOpaque) {
            let fieldDecls = this.getFields()

            for ((idx, field) in fieldDecls.iterator().enumerate()) {
                let isLast = idx == fieldDecls.size - 1

                match (field) {
                    case Field.DataMember(data) =>
                        let fieldItem = data.ty.intoResolver().throughTypeRefs().resolve(ctx)
                        let fieldTy = fieldItem.kind.expectType()
                        let ty = data.ty.toCjTyOrOpaque(ctx, ())

                        let fcomment: ?Tokens = if (let Some(c) <- data.comment) {
                            let pc = preprocessComment(c)
                            Some(Attributes.doc(pc))
                        } else {
                            None
                        }

                        let fieldName = data.name.map {
                            d => ctx.cjMangle(d)
                        }.getOrThrow()
                        let fieldIdent = ctx.cjIdent(fieldName)

                        let fieldToken = optionalComment(
                            ctx,
                            fcomment,
                            quote(public let $(fieldIdent) : $(ty))
                        )
                        fields.add(fieldToken)

                        sigs.append(quote($(fieldIdent) : $(ty)))
                        if (!isLast) {
                            sigs.append(quote(,))
                        }
                        inits.add(quote(this.$(fieldIdent) = $(fieldIdent)))

                    case _ => throw Exception("Only support normal field")
                }
            }
        }

        if (isOpaque) {
            match (layout) {
                case Some(l) =>
                    let ty = Helpers.blob(ctx, l)
                    fields.add(quote(let _cjbind_opaque_blob: $(ty)))
                case None => throw Exception("Expect layout for opaque comp")
            }
        }

        if (this.isForwardDeclaration || isOpaque) {
            inits.add(quote(throw Exception("opaque type should not be inited")))
        }

        let commentToken: ?Tokens = if (let Some(c) <- item.comment) {
            let pc = preprocessComment(c)
            Some(Attributes.doc(pc))
        } else {
            None
        }

        let fieldsToken = joinTokens(fields, Tokens(Token(TokenKind.NL)))

        let initToken = Tokens()

        if (!inits.isEmpty()) {
            let initExpr = joinTokens(inits, Tokens(Token(TokenKind.NL)))

            let initBody = quote(

                init($(sigs)) {
                    $(initExpr)
                }
            )
            initToken.append(initBody)
        }

        let ret = optionalComment(
            ctx,
            commentToken,
            quote(@C
            public struct $(canonicalIdent) {
                $(fieldsToken)$(initToken)
            })
        )

        result.items.add(ret)
    }
    // cjlint-ignore -end
}

extend Enum <: CodeGenerator<Item, Unit> {
    // cjlint-ignore -start !G.FUN.01
    public func codegen(
        ctx: CjbindContext,
        result: CodegenResult,
        item: Item
    ): Unit {
        let name = item.baseName(ctx)
        let ident = ctx.cjIdent(name)
        let enumTy = item.kind.expectType()

        let reprTy: Type = match (this.repr.map {
            r => ctx.resolveType(r)
        }) {
            case Some(r) => r
            case None => Type(None, None, TypeKind.TypeKindInt(TypeKindIntKind.IntKindI8), false)
        }

        let commentToken: ?Tokens = if (let Some(c) <- item.comment) {
            let pc = preprocessComment(c)
            Some(Attributes.doc(pc))
        } else {
            None
        }

        let repr = reprTy.toCjTyOrOpaque(ctx, item)
        let hasTypedef = ctx.isEnumTypedefCombo(item.id)

        let enumCjTy = item.toCjTyOrOpaque(ctx, ())

        for (v in this.variants) {
            let variantName = ctx.cjMangle(v.name)
            let vexpr = match (v.val) {
                case EnumVariantValue.Boolean(b) => quote($(b))
                case EnumVariantValue.Signed(s) => quote($(s))
                case EnumVariantValue.Unsigned(u) => quote($(u))
            }

            let vComment: ?Tokens = if (let Some(c) <- v.comment) {
                let pc = preprocessComment(c)
                Some(Attributes.doc(pc))
            } else {
                None
            }

            let vConstantName = match (enumTy.name) {
                case Some(n) =>
                    if (ctx.options.noEnumPrefix) {
                        variantName
                    } else {
                        "${n}_${variantName}"
                    }
                case None => variantName
            }
            let vIdent = ctx.cjIdent(vConstantName)
            result.items.add(
                optionalComment(
                    ctx,
                    vComment,
                    quote(public const $(vIdent) : $(enumCjTy) = $(vexpr))
                )
            )
        }

        if (!hasTypedef) {
            result.items.add(
                optionalComment(
                    ctx,
                    commentToken,
                    quote(public type $(ident) = $(repr))
                )
            )
        }
    }
    // cjlint-ignore -end
}
