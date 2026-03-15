package cjbind.codegen

import std.ast.*
import std.env
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
    public let unionHelpersSeen: HashSet<String> = HashSet<String>()

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
    ): Unit {
        let codegenItems = ctx.codegenItems.getOrThrow()
        for (child in this.children) {
            if (codegenItems.contains(child)) {
                ctx.resolveItem(child).codegen(ctx, result, ())
            }
        }

        if (item.id == ctx.rootModule) {
            // TODO: 实现Union，Complex，不透明Array，位域等类型的适配
            let header = Tokens(Token(TokenKind.COMMENT, "// cjbind ${VERSION} 生成，请勿编辑, DO NOT EDIT"))
            let cliArgs = String.join(env.getCommandLine(), delimiter: " ")
            header.append(quote(
                // cjbind 命令行：$(cliArgs)
            ))

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

        if (ctx.options.makeFuncWrapper && !signature.getIsVariadic()) {
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
        let canonicalName = item.canonicalName(ctx)

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

                        let dataSize = data.size
                        let dataTokens = data.toArray()

                        let tokens = quote(public const $(canonicalIdent) : VArray<UInt8, \$$(dataSize)> = $(dataTokens))

                        let origStr = Token(TokenKind.COMMENT, "// String value: ${vv}")
                        if (let Some(v) <- commentToken) {
                            v.append(Token(TokenKind.NL))
                            v.append(origStr)
                        } else {
                            commentToken = Tokens(origStr)
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
                        let floatTokens = float64toTokens(vv)
                        result
                            .items
                            .add(
                                optionalComment(
                                    ctx,
                                    commentToken,
                                    quote(public const $(canonicalIdent) : $(ty) = $(floatTokens))
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
            case TypeKind.TypeKindObjCInterface(iface) => iface.codegen(ctx, result, item)
            case TypeKind.TypeKindObjCId | TypeKind.TypeKindObjCSel | TypeKind.TypeKindObjCBlockPointer(_) => ()
            case TypeKind.TypeKindComp(ci) => ci.codegen(ctx, result, item)
            case TypeKind.TypeKindAlias(inner) =>
                let innerItem = inner.intoResolver().throughTypeRefs().resolve(ctx)
                let name = item.canonicalName(ctx)

                let throughTypeAliases = inner.intoResolver().throughTypeRefs().throughTypeAliases().resolve(ctx)

                if (throughTypeAliases.canonicalName(ctx) == name) {
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

        let canonicalName = item.canonicalName(ctx)
        var isOpaque = item.isOpaque(ctx, ())

        let packed = this.isPacked(ctx, layout)
        if (packed) {
            // 仓颉当前无法创建 packed 的结构体
            eprintln("警告：${canonicalName} 是一个 packed 类型，cj 暂不支持，跳过生成")
            return
        }

        let hasBitfields = if (let CompFieldsAfter(v) <- this.fields) {
            !this.isUnion() && v.hasBitfieldUnits
        } else {
            throw Exception("${canonicalName} 的字段应该已经被正确计算")
        }

        let canonicalIdent = ctx.cjIdent(canonicalName)

        let fields = ArrayList<Tokens>()

        // (fieldName, fieldType)
        let sigs = Tokens()
        let inits = ArrayList<Tokens>()

        if (this.isUnion()) {
            // Union: blob storage + getter/setter accessors
            match (layout) {
                case Some(l) =>
                    let blobTy = Helpers.blob(ctx, l)
                    fields.add(quote(var _storage: $(blobTy) = unsafe { zeroValue<$(blobTy)>() }))
                    fields.add(quote(
                        public init() {}
                    ))

                    let fieldDecls = this.getFields()
                    for (field in fieldDecls) {
                        match (field) {
                            case Field.DataMember(data) =>
                                let fieldName = match (data.name) {
                                    case Some(n) => ctx.cjMangle(n)
                                    case None => continue
                                }
                                let fieldIdent = ctx.cjIdent(fieldName)
                                let fieldTy = data.ty.toCjTyOrOpaque(ctx, ())
                                let typeName = fieldTy.toString().replace(" ", "")

                                // Ensure helper functions are generated for this type
                                if (!result.unionHelpersSeen.contains(typeName)) {
                                    result.unionHelpersSeen.add(typeName)
                                    result.items.add(Helpers.unionReadHelper(typeName, fieldTy))
                                    result.items.add(Helpers.unionWriteHelper(typeName, fieldTy))
                                }

                                let readFuncName = "__cjbind_read_${typeName}"
                                let writeFuncName = "__cjbind_write_${typeName}"
                                let readIdent = Tokens(Token(TokenKind.IDENTIFIER, readFuncName))
                                let writeIdent = Tokens(Token(TokenKind.IDENTIFIER, writeFuncName))

                                // getter (non-mut, copy _storage then read)
                                fields.add(quote(
                                    public func $(fieldIdent)(): $(fieldTy) {
                                        var s = this._storage
                                        return unsafe { $(readIdent)(inout s) }
                                    }
                                ))
                                // setter (mut, write in-place)
                                fields.add(quote(
                                    public mut func $(fieldIdent)(val!: $(fieldTy)): Unit {
                                        unsafe { $(writeIdent)(inout this._storage, val) }
                                    }
                                ))
                            case _ => ()
                        }
                    }
                    result.sawCjbindUnion = true
                case None => throw Exception("Expect layout for union")
            }
        } else if (!isOpaque) {
            let fieldDecls = this.getFields()

            if (hasBitfields) {
                // Bitfield struct: use var fields with zero defaults, empty init, getter/setter methods
                for (field in fieldDecls) {
                    match (field) {
                        case Field.DataMember(data) =>
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
                                quote(public var $(fieldIdent) : $(ty) = unsafe { zeroValue<$(ty)>() })
                            )
                            fields.add(fieldToken)

                        case Field.Bitfields(unit) =>
                            let unitSize = Int64(unit.layout.size)
                            let unitNth = Int64(unit.nth)
                            let storageName = "_bitfield_${unitNth}"
                            let storageIdent = ctx.cjIdent(storageName)

                            // Generate storage field: var _bitfield_N: VArray<UInt8, $SIZE>
                            fields.add(
                                quote(var $(storageIdent) : VArray<UInt8, \$$(unitSize)> = VArray<UInt8, \$$(unitSize)>(repeat: 0))
                            )

                            // Generate getter/setter for each bitfield
                            for (bf in unit.bitfields) {
                                let bfName = match (bf.data.name) {
                                    case Some(n) => ctx.cjMangle(n)
                                    case None => continue
                                }
                                let bfIdent = ctx.cjIdent(bfName)
                                let bfTy = bf.data.ty.toCjTyOrOpaque(ctx, ())
                                let bitOffset = Int64(bf.offsetIntoUnit)
                                let bitWidth = Int64(bf.data.bitfieldWidth.getOrThrow())

                                // Determine if the bitfield type is signed and select the appropriate read helper
                                let bfFieldItem = bf.data.ty.intoResolver().throughTypeRefs().resolve(ctx)
                                let bfFieldTy = bfFieldItem.kind.expectType()
                                let isSigned = match (bfFieldTy.canonicalType(ctx).kind) {
                                    case TypeKind.TypeKindInt(ik) => ik.isSigned()
                                    case _ => false
                                }
                                let readFunc = Tokens(Token(TokenKind.IDENTIFIER,
                                    if (isSigned) { "__cjbind_bitfield_read_signed" } else { "__cjbind_bitfield_read" }
                                ))

                                // Getter: read via appropriate helper, cast to target type
                                fields.add(quote(
                                    public func $(bfIdent)(): $(bfTy) {
                                        var s = this.$(storageIdent)
                                        return $(bfTy)(unsafe { $(readFunc)(inout s, $(bitOffset), $(bitWidth)) })
                                    }
                                ))

                                // Setter: convert to UInt64, call __cjbind_bitfield_write
                                fields.add(quote(
                                    public mut func $(bfIdent)(val!: $(bfTy)): Unit {
                                        unsafe { __cjbind_bitfield_write(inout this.$(storageIdent), $(bitOffset), $(bitWidth), UInt64(val)) }
                                    }
                                ))
                            }

                            // Mark that we need bitfield helper functions
                            if (!result.sawBitfieldUnit) {
                                result.sawBitfieldUnit = true
                                result.items.add(Helpers.bitfieldReadHelper())
                                result.items.add(Helpers.bitfieldWriteHelper())
                                result.items.add(Helpers.bitfieldReadSignedHelper())
                            }
                    }
                }

                // Add empty init for bitfield struct (all fields have default values)
                fields.add(quote(public init() {}))
            } else {
                // Normal struct: use let fields with constructor params
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
        }

        if (isOpaque) {
            match (layout) {
                case Some(l) =>
                    let ty = Helpers.blob(ctx, l)
                    fields.add(quote(let _cjbind_opaque_blob: $(ty)))
                    inits.add(quote(this._cjbind_opaque_blob = unsafe { zeroValue<$(ty)>() }))

                case None => throw Exception("Expect layout for opaque comp")
            }
        }

        if (this.isForwardDeclaration) {
            inits.add(quote(throw Exception("type should not be inited")))
        }

        let commentToken: ?Tokens = if (let Some(c) <- item.comment) {
            let pc = preprocessComment(c)
            Some(Attributes.doc(pc))
        } else {
            None
        }

        let fieldsToken = joinTokens(fields, Tokens(Token(TokenKind.NL)))

        let initToken = Tokens()
        let initVisibility = if (this.isForwardDeclaration) {
            Tokens()
        } else {
            quote(public )
        }

        if (!inits.isEmpty()) {
            let initExpr = joinTokens(inits, Tokens(Token(TokenKind.NL)))

            let initBody = quote(

                $(initVisibility)init($(sigs)) {
                    $(initExpr)
                }
            )
            initToken.append(initBody)
        }

        let ret = optionalComment(
            ctx,
            commentToken,
            quote(
            @C
            public struct $(canonicalIdent) {
                $(fieldsToken)$(initToken)
            })
        )

        result.items.add(ret)

        if (!ctx.options.noLayoutTests && !this.isForwardDeclaration) {
            if (let Some(l) <- layout) {
                let size = l.size
                let align = l.align
                let sizeOfExpr = quote(sizeOf<$(canonicalIdent)>())
                let alignOfExpr = quote(alignOf<$(canonicalIdent)>())

                func generateErrorMsg(ty: String, num: Int32, expr: String): String {
                    return "${ty} of ${canonicalName} is not ${num} but \${${expr}} bytes"
                }

                let sizeOfErr = generateErrorMsg("Size", size, "size")
                let alignOfErr = generateErrorMsg("Alignment", align, "align")
                

                let testToken = removePrefixNL(
                    quote(
                    @When[debug]
                    let _ = {
                    =>
                        let size = $(sizeOfExpr)
                        if (size != $size) {
                            throw Exception($(sizeOfErr))
                        }
                        let align = $(alignOfExpr)
                        if (align != $(align)) {
                            throw Exception($(alignOfErr))
                        }
                    })
                )

                result.items.add(testToken)
            }
        }
    }
    // cjlint-ignore -end
}

func enumVariantExpr(val: EnumVariantValue): Tokens {
    match (val) {
        case EnumVariantValue.Boolean(b) => quote($(b))
        case EnumVariantValue.Signed(s) => quote($(s))
        case EnumVariantValue.Unsigned(u) => quote($(u))
    }
}

extend Enum <: CodeGenerator<Item, Unit> {
    // cjlint-ignore -start !G.FUN.01
    public func codegen(
        ctx: CjbindContext,
        result: CodegenResult,
        item: Item
    ): Unit {
        let name = item.canonicalName(ctx)
        let ident = ctx.cjIdent(name)
        let enumTy = item.kind.expectType()

        let reprTy: Type = match (this.repr.map {
            r => ctx.resolveType(r)
        }) {
            case Some(r) => r
            case None => Type(None, None, TypeKind.TypeKindInt(TypeKindIntKind.IntKindInt), false)
        }

        let commentToken: ?Tokens = if (let Some(c) <- item.comment) {
            let pc = preprocessComment(c)
            Some(Attributes.doc(pc))
        } else {
            None
        }

        let repr = reprTy.toCjTyOrOpaque(ctx, item)

        if (ctx.options.defaultEnumStyle == "newtype") {
            // NewType style: generate @C struct wrapper
            let structFields = ArrayList<Tokens>()

            // rawValue field
            structFields.add(quote(public var rawValue: $(repr) = unsafe { zeroValue<$(repr)>() }))

            // Named-parameter constructor
            structFields.add(quote(
                public init(rawValue!: $(repr)) { this.rawValue = rawValue }
            ))

            // Static constants for each variant (no enum prefix since struct provides namespace)
            for (v in this.variants) {
                let variantName = ctx.cjMangle(v.name)
                let vIdent = ctx.cjIdent(variantName)
                let vexpr = enumVariantExpr(v.val)
                structFields.add(quote(
                    public static let $(vIdent) = $(ident)(rawValue: $(vexpr))
                ))
            }

            // == operator
            structFields.add(quote(
                public operator func ==(right: $(ident)): Bool { this.rawValue == right.rawValue }
            ))

            // != operator
            structFields.add(quote(
                public operator func !=(right: $(ident)): Bool { this.rawValue != right.rawValue }
            ))

            let fieldsToken = joinTokens(structFields, Tokens(Token(TokenKind.NL)))
            result.items.add(optionalComment(ctx, commentToken, quote(
                @C
                public struct $(ident) {
                    $(fieldsToken)
                }
            )))
            return
        }

        // Consts style (existing behavior)
        let hasTypedef = ctx.isEnumTypedefCombo(item.id)
        let enumCjTy = item.toCjTyOrOpaque(ctx, ())

        for (v in this.variants) {
            let variantName = ctx.cjMangle(v.name)
            let vexpr = enumVariantExpr(v.val)

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
