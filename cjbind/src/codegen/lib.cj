package cjbind.codegen

import cjbind_token.*
import cjbind_token.macros.*
import std.env
import std.collection.{ArrayList, HashMap, HashSet}
import cjbind.build.VERSION
import cjbind.ir.*
import cjbind.ir.analysis.{computeCoreAnalyses}
import cjbind.clang
import cjbind.options.{CjbindOptions, DefaultEnumStyle, DefaultAliasStyle}
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
    public let headers: ArrayList<TokenStream> = ArrayList<TokenStream>()
    public let items: ArrayList<TokenStream> = ArrayList<TokenStream>()
    public let helpers: ArrayList<TokenStream> = ArrayList<TokenStream>()
    public let staticWrappers: ArrayList<StaticWrapper> = ArrayList<StaticWrapper>()

    public var sawCjbindUnion: Bool = false
    public var sawIncompleteArray: Bool = false
    public var sawBitfieldUnit: Bool = false

    public let itemsSeen: HashSet<ItemId> = HashSet()

    public let functionsSeen: HashSet<String> = HashSet()
    private let skippedFunctionDiagnostics: HashSet<ItemId> = HashSet()
    public let generatedFunctionNames: HashSet<String> = HashSet()
    public let generatedTypeNames: HashSet<String> = HashSet()
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

    func shouldReportSkippedFunction(id: ItemId): Bool {
        if (this.skippedFunctionDiagnostics.contains(id)) {
            return false
        }
        this.skippedFunctionDiagnostics.add(id)
        return true
    }

    func reportSkippedFunction(
        id: ItemId,
        declarationName: String,
        symbolName: String,
        reason: String
    ): Unit {
        if (!this.shouldReportSkippedFunction(id)) {
            return
        }
        eprintln(skippedFunctionErrorMessage(declarationName, symbolName, reason))
    }

    public func uniqueFunctionName(baseName: String): String {
        if (!this.generatedFunctionNames.contains(baseName)) {
            this.generatedFunctionNames.add(baseName)
            return baseName
        }

        var suffix = 1
        while (true) {
            let candidate = "${baseName}${suffix}"
            if (!this.generatedFunctionNames.contains(candidate)) {
                this.generatedFunctionNames.add(candidate)
                return candidate
            }
            suffix += 1
        }
        throw Exception("unreachable")
    }

    public func seenType(name: String): Bool {
        return this.generatedTypeNames.contains(name)
    }

    public func sawType(name: String): Unit {
        this.generatedTypeNames.add(name)
    }

    public func seenVar(name: String): Bool {
        this.varsSeen.contains(name)
    }

    public func sawVar(name: String): Unit {
        this.varsSeen.add(name)
    }

    public func inner(cb: (CodegenResult) -> Unit): ArrayList<TokenStream> {
        let next = CodegenResult()
        cb(next)

        this.sawIncompleteArray ||= next.sawIncompleteArray
        this.sawCjbindUnion ||= next.sawCjbindUnion
        this.sawBitfieldUnit ||= next.sawBitfieldUnit
        this.headers.add(all: next.headers)
        this.helpers.add(all: next.helpers)
        this.staticWrappers.add(all: next.staticWrappers)

        return next.items
    }
}

public interface CodeGenerator<Extra, Return> {
    func codegen(ctx: CjbindContext, result: CodegenResult, extra: Extra): Return
}

public func codegen(tctx: CjbindContext): Result<TokenStream, CodegenError> {
    tctx.prepareForAnalysis()
    let analyses = computeCoreAnalyses(tctx)
    tctx.prepareForCodegen(analyses)

    let result = CodegenResult()
    tctx.resolveItem(tctx.rootModule).codegen(tctx, result, ())

    match (serializeStaticWrappers(tctx, result.staticWrappers)) {
        case Ok(_) => ()
        case Err(error) => return Err<TokenStream, CodegenError>(error)
    }

    let allItems = ArrayList<TokenStream>()
    allItems.add(all: result.headers)
    if (tctx.codegenSawFloat16) {
        allItems.add(Helpers.float16Type())
    }
    if (tctx.codegenSawComplex) {
        allItems.add(Helpers.complexTypes())
    }
    if (result.sawIncompleteArray) {
        allItems.add(Helpers.incompleteArrayViewType())
    }
    var maximumVariadicArity: Int64 = -1
    for (arity in tctx.codegenVariadicFunctionArities) {
        maximumVariadicArity = max(maximumVariadicArity, arity)
    }
    if (maximumVariadicArity >= 0) {
        for (arity in 0..=maximumVariadicArity) {
            if (tctx.codegenVariadicFunctionArities.contains(arity)) {
                allItems.add(Helpers.variadicFunctionAlias(arity))
            }
        }
    }
    allItems.add(all: result.helpers)
    allItems.add(all: result.items)
    let ret = joinStreams(allItems, "\n\n")
    return Ok<TokenStream, CodegenError>(ret)
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
        if (!this.kind.isModule() && !this.kind.isType() &&
            !allTemplateParams(this.id, ctx).isEmpty()) {
            let category = match (this.kind) {
                case ItemKind.KindFunction(_) => "function"
                case ItemKind.KindVar(_) => "variable"
                case _ => "item"
            }
            eprintln(
                "Warning: skipping C++ template ${category} '${this.canonicalName(ctx)}' because a generic foreign symbol cannot be represented by the current Cangjie FFI"
            )
            return
        }
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
            let cliArgs = String.join(env.getCommandLine(), delimiter: " ")
            let pkgName = ctx.cjIdent(ctx.options.packageName)

            let header = @tmpl(
                // cjbind ${VERSION} 生成，请勿编辑, DO NOT EDIT
                // cjbind 命令行：${cliArgs}

                package ${pkgName}
            )

            result.headers.add(header)
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

        if (isInternal && !ctx.options.wrapStaticFns) {
            return
        }

        if (!ctx.options.generatePureVirtualFunctions) {
            match (this.kind) {
                case FunctionKind.KindMethod(MethodKind.Virtual(true)) |
                    FunctionKind.KindMethod(MethodKind.VirtualDestructor(true)) => return
                case _ => ()
            }
        }

        let signatureItem = ctx.resolveItem(this.signature)
        let signatureTy = signatureItem.kind.expectType().canonicalType(ctx)

        let signature = match (signatureTy.kind) {
            case TypeKind.TypeKindFunction(sig) => sig
            case _ => throw Exception("expected function type for sig")
        }

        let declarationName = item.canonicalName(ctx)
        let symbolName = this.symbolName()

        let isCxx = usesCxxLanguage(ctx.options)
        let isStaticWrapperVariadic = if (isCxx) {
            signature.rawIsVariadic()
        } else {
            signature.getIsVariadic()
        }
        if (isInternal && isStaticWrapperVariadic) {
            result.reportSkippedFunction(
                item.id,
                declarationName,
                symbolName,
                "variadic functions are not supported by --wrap-static-fns"
            )
            return
        }

        if (isInternal) {
            let isFreeFunction = match (this.kind) {
                case FunctionKind.KindFunction => true
                case FunctionKind.KindMethod(_) => false
            }
            if (!isFreeFunction) {
                result.reportSkippedFunction(
                    item.id,
                    declarationName,
                    symbolName,
                    "C++ member functions are not supported by --wrap-static-fns"
                )
                return
            }
            if (isCxx && staticWrapperSignatureHasIncompleteTemplateIdentity(ctx, signature)) {
                result.reportSkippedFunction(
                    item.id,
                    declarationName,
                    symbolName,
                    "the C++ template argument identity in this signature cannot be reconstructed losslessly"
                )
                return
            }
        }

        if (!isInternal && isCxx && signature.rawIsVariadic() &&
            signature.argumentTypes.isEmpty()) {
            result.reportSkippedFunction(
                item.id,
                declarationName,
                symbolName,
                "ellipsis-only variadic functions cannot be represented by the current Cangjie FFI"
            )
            return
        }

        if (!isInternal && !signature.abi.isForeignCompatibleForTarget(ctx.targetInfo)) {
            result.reportSkippedFunction(
                item.id,
                declarationName,
                symbolName,
                "calling convention '${signature.abi.diagnosticName()}' cannot be represented by the current Cangjie FFI"
            )
            return
        }
        if (signature.valueAbiUnsupported) {
            result.reportSkippedFunction(
                item.id,
                declarationName,
                symbolName,
                "the value ABI contains a type that cannot be represented safely by the current Cangjie FFI"
            )
            return
        }
        if (hasOpaqueValueAbi(signature, ctx)) {
            result.reportSkippedFunction(
                item.id,
                declarationName,
                symbolName,
                "an opaque, union, or bitfield-backed value ABI cannot be represented safely by the current Cangjie FFI"
            )
            return
        }

        let name = this.name

        if (result.seenFunction(symbolName)) {
            return
        }

        result.sawFunction(symbolName)

        let internalWrapperBase: ?String = if (isInternal) {
            Some(result.uniqueFunctionName(declarationName))
        } else {
            None
        }
        let foreignSymbolName = match (internalWrapperBase) {
            case Some(base) => "${base}${ctx.options.wrapStaticFnsSuffix}"
            case None => symbolName
        }

        if (!clang.isValidIdentifier(foreignSymbolName)) {
            result.reportSkippedFunction(
                item.id,
                declarationName,
                foreignSymbolName,
                unsupportedFunctionSymbolReason(foreignSymbolName)
            )
            return
        }

        let commentToken: ?TokenStream = if (let Some(c) <- item.comment) {
            let pc = preprocessComment(c)
            Some(Attributes.doc(pc))
        } else {
            None
        }

        let typedArgs = Utils.fnsigArguments(ctx, signature)
        let typedRet = Utils.fnsigReturnTy(ctx, signature)
        let hasNewTypeValueAbi = newTypeFunctionNeedsWrapper(ctx, signature)
        let abiArgs = if (hasNewTypeValueAbi) {
            newTypeAbiArguments(ctx, signature)
        } else {
            ArrayList<TokenStream>(typedArgs)
        }
        let abiRet = if (hasNewTypeValueAbi) {
            newTypeAbiReturnType(ctx, signature)
        } else {
            typedRet
        }

        let ident = if (!isInternal && this.mangledName.isSome()) {
            ctx.cjIdentRaw(foreignSymbolName)
        } else {
            ctx.cjIdent(foreignSymbolName)
        }

        if (signature.getIsVariadic()) {
            abiArgs.add(tokenStreamFromTemplate("..."))
        }

        let abiArgsToken = joinStreams(abiArgs, ", ")

        let declaration = if (!isInternal && signature.abi.isStdcall()) {
            @tmpl(
                @CallingConv[STDCALL]
                foreign func ${ident} ( ${abiArgsToken} ) : ${abiRet}
            )
        } else {
            tokenStreamFromTemplate("foreign func ${ident} ( ${abiArgsToken} ) : ${abiRet}")
        }

        let tokens = optionalComment(
            ctx,
            commentToken,
            declaration
        )

        result.items.add(tokens)

        if (isInternal) {
            result.staticWrappers.add(StaticWrapper(item.id, foreignSymbolName))
        }

        let needsWrapper = isInternal || this.mangledName.isSome() ||
            ctx.options.makeFuncWrapper || hasNewTypeValueAbi
        if (needsWrapper && !signature.getIsVariadic()) {
            let wrapperBase = if (let Some(base) <- internalWrapperBase) {
                base
            } else if (this.mangledName.isSome()) {
                match (this.kind) {
                    case FunctionKind.KindMethod(MethodKind.Constructor) =>
                        "${constructorCanonicalName(ctx, item, name)}_constructor"
                    case _ => item.canonicalName(ctx)
                }
            } else {
                "${name}${ctx.options.funcWrapperSuffix}"
            }
            let wrapperName = if (isInternal) {
                ctx.cjIdent(wrapperBase)
            } else {
                ctx.cjIdent(result.uniqueFunctionName(wrapperBase))
            }
            let wrapperArgsName = if (hasNewTypeValueAbi) {
                newTypeAbiCallArguments(ctx, signature)
            } else {
                Utils.fnsigArgumentNames(ctx, signature)
            }
            let wrapperArgsNameToken = joinStreams(wrapperArgsName, ", ")
            let typedArgsToken = joinStreams(typedArgs, ", ")
            let foreignCall = tokenStreamFromTemplate("${ident}( ${wrapperArgsNameToken} )")
            let wrapperResult = if (valueBoundaryNeedsConversion(ctx, signature.returnType)) {
                wrapValueBoundary(ctx, signature.returnType, foreignCall)
            } else {
                foreignCall
            }
            let tokens = optionalComment(
                ctx,
                commentToken,
                @tmpl(
                    public unsafe func ${wrapperName} ( ${typedArgsToken} ) : ${typedRet} {
                    return ${wrapperResult}
                    }
                )
            )

            result.items.add(tokens)

            if (this.constructorCanReturnByValue) {
                if (let FunctionKind.KindMethod(MethodKind.Constructor) <- this.kind) {
                if (!signature.argumentTypes.isEmpty()) {
                    let receiverType = ctx.resolveType(signature.argumentTypes[0][1]).canonicalType(ctx)
                    if (let TypeKind.TypeKindPointer(receiverInner) <- receiverType.kind) {
                        let classType = receiverInner.toCjTyOrOpaque(ctx, ())
                        let className = ctx.resolveItem(receiverInner).canonicalName(ctx)
                        let constructorName = ctx.cjIdent(result.uniqueFunctionName("${className}_new"))
                        let constructorArgs = ArrayList<TokenStream>(typedArgs)
                        constructorArgs.remove(at: 0)
                        let constructorArgNames = ArrayList<TokenStream>(wrapperArgsName)
                        constructorArgNames.remove(at: 0)
                        let constructorArgsToken = joinStreams(constructorArgs, ", ")
                        let constructorCallArgs = ArrayList<TokenStream>()
                        constructorCallArgs.add(tokenStreamFromTemplate("CPointer<${classType}>(inout value)"))
                        constructorCallArgs.add(all: constructorArgNames)
                        let constructorCallArgsToken = joinStreams(constructorCallArgs, ", ")
                        result.items.add(optionalComment(
                            ctx,
                            commentToken,
                            @tmpl(
                                public unsafe func ${constructorName} ( ${constructorArgsToken} ) : ${classType} {
                                var value = unsafe { zeroValue<${classType}>() }
                                ${ident}( ${constructorCallArgsToken} )
                                return value
                                }
                            )
                        ))
                    }
                }
            }
            }
        }
    }
}

func skippedFunctionErrorMessage(
    declarationName: String,
    symbolName: String,
    reason: String
): String {
    return "Error: skipping function '${declarationName}' (ABI symbol '${symbolName}'): ${reason}"
}

func unsupportedFunctionSymbolReason(symbolName: String): String {
    if (symbolName.startsWith("?")) {
        return "MSVC-decorated ABI symbols cannot be represented by the current Cangjie FFI"
    }
    return "the ABI symbol is not a valid foreign-function identifier in the current Cangjie FFI"
}

func constructorCanonicalName(ctx: CjbindContext, item: Item, name: String): String {
    let canonical = item.canonicalName(ctx)
    let repeatedSuffix = "_${name}"
    if (canonical.endsWith(repeatedSuffix) && canonical.size > repeatedSuffix.size) {
        return canonical[..(canonical.size - repeatedSuffix.size)]
    }
    return canonical
}

func scalarConstantDeclaration(
    ctx: CjbindContext,
    ident: String,
    typeId: TypeId,
    expression: TokenStream,
    expectFloat!: Bool = false,
    expectBool!: Bool = false
): ?TokenStream {
    let canonical = ctx.resolveType(typeId).canonicalType(ctx)
    let representation = match (canonical.kind) {
        case TypeKind.TypeKindInt(kind) =>
            let isBool = match (kind) {
                case TypeKindIntKind.IntKindBool => true
                case _ => false
            }
            if (expectFloat || isBool != expectBool) {
                return None
            }
            AstTy.intKindCjType(ctx, kind, canonical.getLayout(ctx)).toString()
        case TypeKind.TypeKindFloat(kind) =>
            if (!expectFloat || expectBool) {
                return None
            }
            AstTy.floatKindCjType(ctx, kind, canonical.getLayout(ctx)).toString()
        case _ => return None
    }
    let isPrimitive = representation == "Bool" ||
        representation == "Int8" || representation == "UInt8" ||
        representation == "Int16" || representation == "UInt16" ||
        representation == "Int32" || representation == "UInt32" ||
        representation == "Int64" || representation == "UInt64" ||
        representation == "Float32" || representation == "Float64"
    if (!isPrimitive) {
        return None
    }

    let value = wrapAliasValue(ctx, typeId, expression)
    let declaration = if (aliasChainNeedsValueConversion(ctx, typeId)) { "let" } else { "const" }
    let ty = typeId.toCjTyOrOpaque(ctx, ())
    return Some(tokenStreamFromTemplate("public ${declaration} ${ident} : ${ty} = ${value}"))
}

extend Var <: CodeGenerator<Item, Unit> {
    // cjlint-ignore -start !G.FUN.01
    public func codegen(
        ctx: CjbindContext,
        result: CodegenResult,
        item: Item
    ): Unit {
        let canonicalName = item.canonicalName(ctx)

        if (result.seenVar(canonicalName)) {
            return
        }
        result.sawVar(canonicalName)

        let canonicalIdent = ctx.cjIdent(canonicalName)

        var commentToken: ?TokenStream = if (let Some(c) <- item.comment) {
            let pc = preprocessComment(c)
            Some(Attributes.doc(pc))
        } else {
            None
        }

        let varTy = this.ty

        if (let Some(v) <- this.val) {
            match (v) {
                case VarType.VarBool(vv) =>
                    if (let Some(tokens) <- scalarConstantDeclaration(
                        ctx,
                        canonicalIdent,
                        varTy,
                        tokenStreamFromTemplate("${vv}"),
                        expectBool: true
                    )) {
                        result.items.add(optionalComment(ctx, commentToken, tokens))
                    } else {
                        eprintln("Warning: skipping constant '${canonicalName}' because its typed value cannot be represented as a Cangjie constant")
                    }
                case VarType.VarInt(vv) =>
                    if (let Some(tokens) <- scalarConstantDeclaration(
                        ctx,
                        canonicalIdent,
                        varTy,
                        tokenStreamFromTemplate("${vv}")
                    )) {
                        result.items.add(optionalComment(ctx, commentToken, tokens))
                    } else {
                        eprintln("Warning: skipping constant '${canonicalName}' because its typed value cannot be represented as a Cangjie constant")
                    }
                case VarType.VarString(vv) =>
                    let emitByteArray = {=>
                        // Intentionally includes null terminator for C string FFI compatibility
                        let data = ArrayList<UInt8>()
                        let ptr = vv.getChars()
                        let size = vv.size()
                        for (i in 0..=size) {
                            let d = unsafe { (ptr + i).read() }
                            data.add(d)
                        }
                        let dataSize = data.size
                        let dataTokens = data.toArray()
                        tokenStreamFromTemplate("public const ${canonicalIdent} : VArray<UInt8, \$${dataSize}> = ${dataTokens}")
                    }

                    let tokens = if (!ctx.options.makeCjString) {
                        let origStr = try { "// String value: ${vv}" } catch (_: Exception) { "// String value: <non-UTF-8>" }
                        if (let Some(v) <- commentToken) {
                            v.appendLiteral("\n")
                            v.appendLiteral(origStr)
                        } else {
                            commentToken = tokenStreamFromTemplate(origStr)
                        }
                        emitByteArray()
                    } else {
                        try {
                            tokenStreamFromTemplate("public const ${canonicalIdent} : String = ${vv.toString()}")
                        } catch (_: Exception) {
                            emitByteArray()
                        }
                    }

                    result.items.add(
                        optionalComment(ctx, commentToken, tokens)
                    )
                case VarType.VarFloat(vv) =>
                    if (let Ok(expr) <- AstTy.floatExpr(ctx, vv)) {
                        if (let Some(tokens) <- scalarConstantDeclaration(
                            ctx,
                            canonicalIdent,
                            varTy,
                            expr,
                            expectFloat: true
                        )) {
                            result.items.add(optionalComment(ctx, commentToken, tokens))
                        } else {
                            eprintln("Warning: skipping float constant '${canonicalName}' because its typed carrier cannot be represented as a Cangjie constant")
                        }
                    } else {
                        eprintln("Warning: skipping float constant '${canonicalName}' (NaN/Infinity/subnormal cannot be represented)")
                    }
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
                    .TypeKindComplex(_) | TypeKind.TypeKindFunction(_) | TypeKind
                    .TypeKindArray(_, _) | TypeKind.TypeKindVector(_, _) | TypeKind
                    .TypeKindPointer(_) | TypeKind.TypeKindReference(_) | TypeKind.ResolvedTypeRef(_) | TypeKind
                    .TypeKindTypeParam | TypeKind.TypeKindTemplateInstantiation(_) | TypeKind
                    .TypeKindOpaque => ()
            case TypeKind.TypeKindObjCInterface(iface) => iface.codegen(ctx, result, item)
            case TypeKind.TypeKindObjCId | TypeKind.TypeKindObjCSel | TypeKind.TypeKindObjCBlockPointer(_) => ()
            case TypeKind.TypeKindComp(ci) => ci.codegen(ctx, result, item)
            case TypeKind.TypeKindAlias(inner) => codegenTypeAlias(this, inner, ctx, result, item)
            case TypeKind.TypeKindTemplateAlias(inner, _) => codegenTypeAlias(this, inner, ctx, result, item)
            case TypeKind.TypeKindEnum(ei) =>
                if (ctx.usesAnyTemplateParameters(item.id)) {
                    eprintln(
                        "Warning: skipping C++ enum '${item.canonicalName(ctx)}' because a generic C ABI enum cannot be represented by the current Cangjie FFI"
                    )
                } else {
                    ei.codegen(ctx, result, item)
                }
            case TypeKind.UnresolvedTypeRef(_, _, _) => throw Exception("should have been resolved by now")
        }
    }
}

func validateTemplateAliasDefinition(
    ctx: CjbindContext,
    item: Item,
    inner: TypeId,
    requiresCType!: Bool = false
): Result<Bool, Error> {
    if (item.isOpaque(ctx, ())) {
        return Ok(true)
    }
    let usedParameters = ctx.usedTemplateParams(item.id)
    if (usedParameters.isEmpty()) {
        return Ok(true)
    }
    let substitutions = HashMap<ItemId, String>()
    let seenParameterNames = HashSet<String>()
    for (parameter in usedParameters) {
        let parameterItem = ctx.resolveItem(parameter)
        let parameterName = uniqueName(
            seenParameterNames,
            ctx.cjIdent(parameterItem.baseName(ctx))
        )
        substitutions.add(parameter, parameterName)
        let resolvedParameter = parameter
            .intoResolver()
            .throughTypeRefs()
            .throughTypeAliases()
            .resolve(ctx)
        if (!substitutions.contains(resolvedParameter.id)) {
            substitutions.add(resolvedParameter.id, parameterName)
        }
    }
    let degraded = Box(false)
    return renderGenericAliasType(
        ctx,
        inner,
        substitutions,
        ItemSet(),
        requiresCType: requiresCType,
        degraded: degraded
    ).map({ _ => !degraded.value })
}

func codegenTypeAlias(
    source: Type,
    inner: TypeId,
    ctx: CjbindContext,
    result: CodegenResult,
    item: Item
): Unit {
    let innerItem = inner.intoResolver().throughTypeRefs().resolve(ctx)
    let name = item.canonicalName(ctx)
    if (let Err(error) <- validateTemplateAliasDefinition(ctx, item, inner)) {
        eprintln(
            "${genericAliasDiagnosticLevel(error)}: skipping C++ template alias '${name}' because ${genericAliasErrorReason(error)}"
        )
        return
    }
    let throughTypeAliases = inner.intoResolver().throughTypeRefs().throughTypeAliases().resolve(ctx)
    if (throughTypeAliases.canonicalName(ctx) == name) {
        return
    }
    let spelling = source.name.getOrThrow()
    if (Utils.typeFromNamed(ctx, spelling).isSome() || result.seenType(name)) {
        return
    }
    let usedParameters = if (item.isOpaque(ctx, ())) {
        Array<TypeId>()
    } else {
        ctx.usedTemplateParams(item.id)
    }
    result.sawType(name)
    let parameterNames = ArrayList<TokenStream>()
    let substitutions = HashMap<ItemId, String>()
    let seenParameterNames = HashSet<String>()
    for (parameter in usedParameters) {
        let parameterItem = ctx.resolveItem(parameter)
        let parameterName = uniqueName(
            seenParameterNames,
            ctx.cjIdent(parameterItem.baseName(ctx))
        )
        parameterNames.add(tokenStreamFromTemplate(parameterName))
        substitutions.add(parameter, parameterName)
        let resolvedParameter = parameter.intoResolver().throughTypeRefs().throughTypeAliases().resolve(ctx)
        if (!substitutions.contains(resolvedParameter.id)) {
            substitutions.add(resolvedParameter.id, parameterName)
        }
    }
    let innerCjType = if (usedParameters.isEmpty()) {
        let converted = if (item.isOpaque(ctx, ())) {
            innerItem.tryToOpaque(ctx, ())
        } else {
            innerItem.tryToCjTyOrOpaque(ctx, ())
        }
        match (converted) {
            case Ok(value) => value
            case Err(error) =>
                eprintln(
                    "Warning: skipping C++ type alias '${name}' because ${genericAliasErrorReason(error)}"
                )
                return
        }
    } else {
        match (renderGenericAliasType(ctx, inner, substitutions, ItemSet())) {
            case Ok(rendered) => rendered
            case Err(error) =>
                eprintln(
                    "${genericAliasDiagnosticLevel(error)}: skipping C++ template alias '${name}' because ${genericAliasErrorReason(error)}"
                )
                return
        }
    }
    let commentToken: ?TokenStream = if (let Some(comment) <- item.comment) {
        Some(Attributes.doc(preprocessComment(comment)))
    } else {
        None
    }
    let genericParameters = if (parameterNames.isEmpty()) {
        TokenStream()
    } else {
        let joined = joinStreams(parameterNames, ", ")
        tokenStreamFromTemplate("<${joined}>")
    }
    let ident = ctx.cjIdent(name)
    let aliasStyle = effectiveAliasStyle(
        ctx,
        item,
        throughTypeAliases,
        !parameterNames.isEmpty()
    )
    let declaration = if (aliasStyle == DefaultAliasStyle.TypeAlias) {
        tokenStreamFromTemplate("public type ${ident}${genericParameters} = ${innerCjType}")
    } else {
        newTypeAliasDeclaration(ident, innerCjType, aliasStyle)
    }
    result.items.add(optionalComment(ctx, commentToken, declaration))
}

func renderGenericAliasType(
    ctx: CjbindContext,
    typeId: TypeId,
    substitutions: HashMap<ItemId, String>,
    visiting: ItemSet,
    ctypeSubstitutions!: ItemSet = ItemSet(),
    valueAbiSubstitutions!: ItemSet = ItemSet(),
    requiresCType!: Bool = false,
    degraded!: Box<Bool> = Box(false)
): Result<TokenStream, Error> {
    if (let Some(parameterName) <- substitutions.get(typeId)) {
        if (requiresCType && !ctypeSubstitutions.contains(typeId)) {
            return Err(Error.Unsupported(
                "the generic alias requires a CType constraint that Cangjie type aliases cannot express"
            ))
        }
        return Ok(tokenStreamFromTemplate(parameterName))
    }

    let item = ctx.resolveItem(typeId)
    if (let Some(parameterName) <- substitutions.get(item.id)) {
        if (requiresCType && !ctypeSubstitutions.contains(item.id)) {
            return Err(Error.Unsupported(
                "the generic alias requires a CType constraint that Cangjie type aliases cannot express"
            ))
        }
        return Ok(tokenStreamFromTemplate(parameterName))
    }
    if (!ctx.usesAnyTemplateParameters(item.id)) {
        return item.tryToCjTy(ctx, ())
    }
    if (!visiting.add(item.id)) {
        return Err(Error.Unsupported("the alias RHS contains a recursive dependent type"))
    }

    let ty = item.kind.expectType()
    let rendered: Result<TokenStream, Error> = match (ty.kind) {
        case TypeKind.ResolvedTypeRef(inner) =>
            renderGenericAliasType(
                ctx,
                inner,
                substitutions,
                visiting,
                ctypeSubstitutions: ctypeSubstitutions,
                valueAbiSubstitutions: valueAbiSubstitutions,
                requiresCType: requiresCType,
                degraded: degraded
            )
        case TypeKind.TypeKindAlias(inner) =>
            match (validateTemplateAliasDefinition(
                ctx,
                item,
                inner,
                requiresCType: requiresCType
            )) {
                case Err(error) => Err<TokenStream, Error>(error)
                case Ok(exact) =>
                    if (!exact) {
                        degraded.value = true
                    }
                    renderGenericAliasPath(ctx, item, substitutions)
            }
        case TypeKind.TypeKindTemplateAlias(inner, _) =>
            match (validateTemplateAliasDefinition(
                ctx,
                item,
                inner,
                requiresCType: requiresCType
            )) {
                case Err(error) => Err<TokenStream, Error>(error)
                case Ok(exact) =>
                    if (!exact) {
                        degraded.value = true
                    }
                    renderGenericAliasPath(ctx, item, substitutions)
            }
        case TypeKind.TypeKindTypeParam =>
            Err<TokenStream, Error>(Error.Unsupported(
                "the alias RHS refers to an unmapped template parameter '${item.baseName(ctx)}'"
            ))
        case TypeKind.TypeKindPointer(inner) =>
            let canonicalInner = ctx.resolveType(inner).canonicalType(ctx)
            let innerIsFunction = canonicalInner.isFunction()
            let innerResult = renderGenericAliasType(
                ctx,
                inner,
                substitutions,
                visiting,
                ctypeSubstitutions: ctypeSubstitutions,
                valueAbiSubstitutions: valueAbiSubstitutions,
                degraded: degraded
            )
            match (innerResult) {
                case Ok(innerType) =>
                    if (innerIsFunction) {
                        Ok<TokenStream, Error>(innerType)
                    } else {
                        Ok<TokenStream, Error>(innerType.toPtr())
                    }
                case Err(error) =>
                    if (let Error.UnsupportedAbi(_) <- error) {
                        Err<TokenStream, Error>(error)
                    } else {
                        degraded.value = true
                        Ok<TokenStream, Error>(tokenStreamFromTemplate("CPointer<Unit>"))
                    }
            }
        case TypeKind.TypeKindReference(inner) =>
            match (renderGenericAliasType(
                ctx,
                inner,
                substitutions,
                visiting,
                ctypeSubstitutions: ctypeSubstitutions,
                valueAbiSubstitutions: valueAbiSubstitutions,
                degraded: degraded
            )) {
                case Ok(innerType) => Ok<TokenStream, Error>(innerType.toPtr())
                case Err(_) =>
                    degraded.value = true
                    Ok<TokenStream, Error>(tokenStreamFromTemplate("CPointer<Unit>"))
            }
        case TypeKind.TypeKindArray(inner, length) =>
            let innerResult = renderGenericAliasType(
                ctx,
                inner,
                substitutions,
                visiting,
                ctypeSubstitutions: ctypeSubstitutions,
                valueAbiSubstitutions: valueAbiSubstitutions,
                requiresCType: length != 0,
                degraded: degraded
            )
            match (innerResult) {
                case Ok(innerType) =>
                    Ok<TokenStream, Error>(tokenStreamFromTemplate(
                        "VArray<${innerType}, \$${Int64(length)}>"
                    ))
                case Err(error) =>
                    if (length == 0) {
                        degraded.value = true
                        Ok<TokenStream, Error>(tokenStreamFromTemplate("CPointer<Unit>"))
                    } else {
                        Err<TokenStream, Error>(error)
                    }
            }
        case TypeKind.TypeKindVector(inner, length) =>
            renderGenericAliasType(
                ctx,
                inner,
                substitutions,
                visiting,
                ctypeSubstitutions: ctypeSubstitutions,
                valueAbiSubstitutions: valueAbiSubstitutions,
                requiresCType: true,
                degraded: degraded
            ).map {
                innerType => tokenStreamFromTemplate("VArray<${innerType}, \$${Int64(length)}>")
            }
        case TypeKind.TypeKindFunction(signature) =>
            renderGenericAliasFunction(
                ctx,
                signature,
                substitutions,
                visiting,
                ctypeSubstitutions,
                valueAbiSubstitutions,
                degraded
            )
        case TypeKind.TypeKindTemplateInstantiation(instantiation) =>
            let definition = instantiation.definition
                .intoResolver()
                .throughTypeRefs()
                .resolve(ctx)
            match (definition.kind.expectType().kind) {
                case TypeKind.TypeKindTemplateAlias(inner, _) =>
                    if (definition.isOpaque(ctx, ())) {
                        visiting.remove(item.id)
                        return Ok(tokenStreamFromTemplate(
                            ctx.cjIdentRaw(definition.canonicalName(ctx))
                        ))
                    }
                    let parameters = selfTemplateParams(definition.id, ctx)
                    let validation = validateTemplateAliasDefinition(
                        ctx,
                        definition,
                        inner,
                        requiresCType: requiresCType
                    )
                    let argumentsAreConcrete = instantiation.arguments.all {
                        argument => !ctx.usesAnyTemplateParameters(argument)
                    }
                    let requiresConcreteRendering = match (validation) {
                        case Ok(exact) => !exact && argumentsAreConcrete
                        case Err(_) => true
                    }
                    if (let Ok(false) <- validation) {
                        degraded.value = true
                    }
                    if (requiresConcreteRendering) {
                        let result = renderConcreteTemplateAlias(
                            ctx,
                            inner,
                            parameters,
                            instantiation.arguments,
                            substitutions,
                            visiting,
                            outerCTypeSubstitutions: ctypeSubstitutions,
                            outerValueAbiSubstitutions: valueAbiSubstitutions,
                            requiresCType: requiresCType,
                            outerDegraded: degraded
                        )
                        visiting.remove(item.id)
                        return result
                    }
                    let arguments = ArrayList<TokenStream>()
                    let count = min(parameters.size, instantiation.arguments.size)
                    for (index in 0..count) {
                        let parameter = parameters[index]
                        if (!ctx.usesTemplateParameter(definition.id, parameter)) {
                            continue
                        }
                        let renderedArgument = match (renderGenericAliasType(
                            ctx,
                            instantiation.arguments[index],
                            substitutions,
                            visiting,
                            ctypeSubstitutions: ctypeSubstitutions,
                            valueAbiSubstitutions: valueAbiSubstitutions,
                            degraded: degraded
                        )) {
                            case Ok(value) => value
                            case Err(error) =>
                                visiting.remove(item.id)
                                return Err(error)
                        }
                        arguments.add(renderedArgument)
                    }
                    let name = ctx.cjIdentRaw(definition.canonicalName(ctx))
                    if (arguments.isEmpty()) {
                        Ok<TokenStream, Error>(tokenStreamFromTemplate(name))
                    } else {
                        let joined = joinStreams(arguments, ", ")
                        Ok<TokenStream, Error>(tokenStreamFromTemplate("${name}<${joined}>"))
                    }
                case _ => Err<TokenStream, Error>(Error.Unsupported(
                    "a generic C++ record cannot be represented as an @C type by the current Cangjie FFI"
                ))
            }
        case TypeKind.TypeKindComp(_) =>
            Err<TokenStream, Error>(Error.Unsupported(
                "a generic C++ record cannot be represented as an @C type by the current Cangjie FFI"
            ))
        case TypeKind.TypeKindEnum(_) =>
            Err<TokenStream, Error>(Error.Unsupported(
                "a dependent C++ enum cannot be represented by the current Cangjie FFI"
            ))
        case TypeKind.TypeKindOpaque =>
            Err<TokenStream, Error>(Error.Unsupported(
                "the dependent alias RHS has no representable layout"
            ))
        case TypeKind.TypeKindVoid | TypeKind.TypeKindNullPtr |
            TypeKind.TypeKindInt(_) | TypeKind.TypeKindFloat(_) |
            TypeKind.TypeKindComplex(_) | TypeKind.TypeKindObjCInterface(_) |
            TypeKind.TypeKindObjCId | TypeKind.TypeKindObjCSel |
            TypeKind.TypeKindObjCBlockPointer(_) => item.tryToCjTy(ctx, ())
        case TypeKind.UnresolvedTypeRef(_, _, _) =>
            Err<TokenStream, Error>(Error.Unsupported(
                "the alias RHS contains an unresolved dependent type"
            ))
    }
    visiting.remove(item.id)
    return rendered
}

func renderGenericAliasPath(
    ctx: CjbindContext,
    item: Item,
    substitutions: HashMap<ItemId, String>
): Result<TokenStream, Error> {
    let arguments = ArrayList<TokenStream>()
    for (parameter in ctx.usedTemplateParams(item.id)) {
        let resolved = parameter
            .intoResolver()
            .throughTypeRefs()
            .throughTypeAliases()
            .resolve(ctx)
        let argument = match (substitutions.get(parameter)) {
            case Some(value) => value
            case None => match (substitutions.get(resolved.id)) {
                case Some(value) => value
                case None => return Err(Error.Unsupported(
                    "the alias RHS refers to an unmapped template parameter '${ctx.resolveItem(parameter).baseName(ctx)}'"
                ))
            }
        }
        arguments.add(tokenStreamFromTemplate(argument))
    }
    let name = ctx.cjIdentRaw(item.canonicalName(ctx))
    if (arguments.isEmpty()) {
        return Ok(tokenStreamFromTemplate(name))
    }
    let joined = joinStreams(arguments, ", ")
    return Ok(tokenStreamFromTemplate("${name}<${joined}>"))
}

func renderConcreteTemplateAlias(
    ctx: CjbindContext,
    inner: TypeId,
    parameters: Array<TypeId>,
    arguments: Array<TypeId>,
    outerSubstitutions: HashMap<ItemId, String>,
    visiting: ItemSet,
    outerCTypeSubstitutions!: ItemSet = ItemSet(),
    outerValueAbiSubstitutions!: ItemSet = ItemSet(),
    requiresCType!: Bool = false,
    outerDegraded!: Box<Bool> = Box(false)
): Result<TokenStream, Error> {
    let substitutions = HashMap<ItemId, String>()
    for ((key, value) in outerSubstitutions) {
        substitutions[key] = value
    }
    let ctypeSubstitutions = ItemSet()
    for (id in outerCTypeSubstitutions) {
        ctypeSubstitutions.add(id)
    }
    let valueAbiSubstitutions = ItemSet()
    for (id in outerValueAbiSubstitutions) {
        valueAbiSubstitutions.add(id)
    }

    let count = min(parameters.size, arguments.size)
    for (index in 0..count) {
        let parameter = parameters[index]
        let argument = arguments[index]
        let renderedArgument = match (renderGenericAliasType(
            ctx,
            argument,
            outerSubstitutions,
            visiting,
            ctypeSubstitutions: outerCTypeSubstitutions,
            valueAbiSubstitutions: outerValueAbiSubstitutions,
            degraded: outerDegraded
        )) {
            case Ok(value) => value.toString()
            case Err(error) => return Err(error)
        }
        let resolvedParameter = parameter
            .intoResolver()
            .throughTypeRefs()
            .throughTypeAliases()
            .resolve(ctx)
        substitutions[parameter] = renderedArgument
        substitutions[resolvedParameter.id] = renderedArgument

        let resolvedArgument = argument
            .intoResolver()
            .throughTypeRefs()
            .throughTypeAliases()
            .resolve(ctx)
        let argumentIsConcrete = !ctx.usesAnyTemplateParameters(argument)
        let argumentIsCType = outerCTypeSubstitutions.contains(argument) ||
            outerCTypeSubstitutions.contains(resolvedArgument.id) ||
            (argumentIsConcrete && argument.tryToCjTy(ctx, ()).isOk())
        if (argumentIsCType) {
            ctypeSubstitutions.add(parameter)
            ctypeSubstitutions.add(resolvedParameter.id)
        }
        // A C/C++ typedef selected as a Cangjie newtype has the same object
        // layout, but its single-field @C struct does not have the typedef's
        // scalar call ABI. Generic callback aliases cannot insert a wrapper at
        // the callback boundary, so do not claim that such a substitution is
        // directly representable by value. Pointer uses remain valid.
        let argumentNeedsValueConversion = valueBoundaryNeedsConversion(ctx, argument)
        let argumentHasRepresentableValueAbi = !argumentNeedsValueConversion &&
            (outerValueAbiSubstitutions.contains(argument) ||
                outerValueAbiSubstitutions.contains(resolvedArgument.id) ||
                (argumentIsConcrete && !typeHasOpaqueValueAbiForCodegen(argument, ctx)))
        if (argumentHasRepresentableValueAbi) {
            valueAbiSubstitutions.add(parameter)
            valueAbiSubstitutions.add(resolvedParameter.id)
        }
    }

    return renderGenericAliasType(
        ctx,
        inner,
        substitutions,
        visiting,
        ctypeSubstitutions: ctypeSubstitutions,
        valueAbiSubstitutions: valueAbiSubstitutions,
        requiresCType: requiresCType,
        degraded: outerDegraded
    )
}

func renderGenericAliasFunction(
    ctx: CjbindContext,
    signature: FunctionSig,
    substitutions: HashMap<ItemId, String>,
    visiting: ItemSet,
    ctypeSubstitutions: ItemSet,
    valueAbiSubstitutions: ItemSet,
    degraded: Box<Bool>
): Result<TokenStream, Error> {
    if (!signature.abi.isCFuncCompatibleForTarget(ctx.targetInfo)) {
        return Err(Error.UnsupportedAbi(signature.abi.diagnosticName()))
    }
    if (signature.valueAbiUnsupported || hasOpaqueValueAbiWithRepresentedTypeParams(
        signature,
        ctx,
        valueAbiSubstitutions
    )) {
        return Err(Error.Unsupported(
            "the function pointer value ABI cannot be represented safely by the current Cangjie FFI"
        ))
    }

    let arguments = ArrayList<TokenStream>()
    let argumentTypes = ArrayList<TokenStream>()
    var unnamedArgument = 0
    for ((argumentName, argumentTypeId) in signature.argumentTypes) {
        let argumentItem = ctx.resolveItem(argumentTypeId)
        let argumentType = argumentItem.kind.expectType()
        let renderedArgument = if (!ctx.options.arrayPointersInArgs &&
            let TypeKind.TypeKindArray(element, _) <- argumentType.canonicalType(ctx).kind) {
            match (renderGenericAliasType(
                ctx,
                element,
                substitutions,
                visiting,
                ctypeSubstitutions: ctypeSubstitutions,
                valueAbiSubstitutions: valueAbiSubstitutions,
                degraded: degraded
            )) {
                case Ok(elementType) => elementType.toPtr()
                case Err(error) => return Err(error)
            }
        } else {
            // Named newtypes are object-layout compatible with their source
            // typedef, but not necessarily call-ABI compatible with the
            // underlying scalar. A callback has nowhere to insert the public
            // wrap/unwrap shim used for ordinary foreign functions, so spell
            // its direct value boundary with the source ABI type instead.
            let abiArgumentType = if (valueBoundaryNeedsConversion(ctx, argumentTypeId)) {
                valueBoundaryAbiTarget(ctx, argumentTypeId)
            } else {
                argumentTypeId
            }
            match (renderGenericAliasType(
                ctx,
                abiArgumentType,
                substitutions,
                visiting,
                ctypeSubstitutions: ctypeSubstitutions,
                valueAbiSubstitutions: valueAbiSubstitutions,
                requiresCType: true,
                degraded: degraded
            )) {
                case Ok(value) => value
                case Err(error) => return Err(error)
            }
        }
        let name = match (argumentName) {
            case Some(value) => ctx.cjIdent(value)
            case None =>
                unnamedArgument += 1
                "arg${unnamedArgument}"
        }
        argumentTypes.add(renderedArgument)
        arguments.add(tokenStreamFromTemplate("${name}: ${renderedArgument}"))
    }

    let returnItem = ctx.resolveItem(signature.returnType)
    let returnType = if (let TypeKind.TypeKindVoid <- returnItem.kind.expectType().canonicalType(ctx).kind) {
        tokenStreamFromTemplate("Unit")
    } else {
        let abiReturnType = if (valueBoundaryNeedsConversion(ctx, signature.returnType)) {
            valueBoundaryAbiTarget(ctx, signature.returnType)
        } else {
            signature.returnType
        }
        match (renderGenericAliasType(
            ctx,
            abiReturnType,
            substitutions,
            visiting,
            ctypeSubstitutions: ctypeSubstitutions,
            valueAbiSubstitutions: valueAbiSubstitutions,
            requiresCType: true,
            degraded: degraded
        )) {
            case Ok(value) => value
            case Err(error) => return Err(error)
        }
    }
    if (signature.rawIsVariadic()) {
        ctx.codegenVariadicFunctionArities.add(signature.argumentTypes.size)
        let typeArguments = ArrayList<TokenStream>()
        typeArguments.add(returnType)
        typeArguments.add(all: argumentTypes)
        let joinedTypeArguments = joinStreams(typeArguments, ", ")
        let typeName = Helpers.variadicFunctionTypeName(signature.argumentTypes.size)
        return Ok(tokenStreamFromTemplate("${typeName}<${joinedTypeArguments}>") )
    }
    let joinedArguments = joinStreams(arguments, ", ")
    return Ok(tokenStreamFromTemplate("CFunc<(${joinedArguments}) -> ${returnType}>") )
}

func genericAliasErrorReason(error: Error): String {
    return match (error) {
        case Error.Unsupported(reason) => reason
        case Error.UnsupportedAbi(abi) =>
            "calling convention '${abi}' cannot be represented by the current Cangjie FFI"
        case Error.InvalidPointerSize(name, size, pointerSize) =>
            "pointer type '${name}' has size ${size}, but the target pointer size is ${pointerSize}"
        case Error.NoLayoutForOpaqueBlob =>
            "the alias RHS has no layout that can be represented by the current Cangjie FFI"
    }
}

func genericAliasDiagnosticLevel(error: Error): String {
    return match (error) {
        case Error.UnsupportedAbi(_) => "Error"
        case _ => "Warning"
    }
}

func reportUnsupportedVirtualMethodAbis(
    ctx: CjbindContext,
    comp: CompInfo,
    owner: Item
): Unit {
    for (method in comp.methods) {
        if (!method.kind.isVirtual()) {
            continue
        }
        let methodItem = ctx.resolveItem(method.signature)
        let function = match (methodItem.kind) {
            case ItemKind.KindFunction(value) => value
            case _ => continue
        }
        let signature = match (ctx.resolveType(function.signature).canonicalType(ctx).kind) {
            case TypeKind.TypeKindFunction(value) => value
            case _ => continue
        }
        if (!signature.abi.isCFuncCompatibleForTarget(ctx.targetInfo)) {
            eprintln(
                "Error: skipping virtual method '${methodItem.canonicalName(ctx)}' in generated vtable for '${owner.canonicalName(ctx)}' because calling convention '${signature.abi.diagnosticName()}' cannot be represented by the current Cangjie FFI"
            )
        }
    }
}

func directZeroLengthArrayElement(
    ctx: CjbindContext,
    typeId: TypeId,
    visiting: ItemSet
): ?TypeId {
    if (!visiting.add(typeId)) {
        return None
    }
    let ty = ctx.resolveType(typeId)
    return match (ty.kind) {
        case TypeKind.ResolvedTypeRef(inner) =>
            directZeroLengthArrayElement(ctx, inner, visiting)
        case TypeKind.TypeKindAlias(inner) =>
            directZeroLengthArrayElement(ctx, inner, visiting)
        case TypeKind.TypeKindTemplateAlias(inner, _) =>
            directZeroLengthArrayElement(ctx, inner, visiting)
        case TypeKind.TypeKindArray(inner, length) =>
            if (length == 0) { Some(inner) } else { None }
        // Following another template instantiation here would cross a new
        // template-parameter scope. Without composing both substitutions we
        // cannot prove the concrete element type, so let the caller skip the
        // accessor instead of leaking an unbound type parameter.
        case _ => None
    }
}

func zeroLengthArrayElementType(
    ctx: CjbindContext,
    typeId: TypeId,
    visiting: ItemSet
): ?TokenStream {
    if (!visiting.add(typeId)) {
        return None
    }

    if (let Some(replacement) <- ctx.codegenTemplateReplacement(typeId)) {
        if (replacement != typeId) {
            if (let Some(rendered) <- zeroLengthArrayElementType(ctx, replacement, visiting)) {
                return Some(rendered)
            }
        }
    }

    let item = ctx.resolveItem(typeId)
    let ty = item.kind.expectType()
    return match (ty.kind) {
        case TypeKind.ResolvedTypeRef(inner) =>
            zeroLengthArrayElementType(ctx, inner, visiting)
        case TypeKind.TypeKindAlias(inner) =>
            zeroLengthArrayElementType(ctx, inner, visiting)
        case TypeKind.TypeKindTemplateAlias(inner, _) =>
            zeroLengthArrayElementType(ctx, inner, visiting)
        case TypeKind.TypeKindArray(inner, length) =>
            if (length != 0 || ctx.usesAnyTemplateParameters(inner)) {
                None
            } else {
                match (inner.tryToCjTyOrOpaque(ctx, ())) {
                    case Ok(rendered) => Some(rendered)
                    case Err(_) => None
                }
            }
        case TypeKind.TypeKindTemplateInstantiation(instantiation) =>
            let definition = instantiation.definition
                .intoResolver()
                .throughTypeRefs()
                .resolve(ctx)
            match (definition.kind.expectType().kind) {
                case TypeKind.TypeKindTemplateAlias(inner, _) =>
                    let parameters = selfTemplateParams(definition.id, ctx)
                    if (!instantiation.nonTypeArguments.isEmpty() ||
                        parameters.size != instantiation.arguments.size) {
                        return None
                    }
                    let element = match (directZeroLengthArrayElement(
                        ctx,
                        inner,
                        ItemSet()
                    )) {
                        case Some(value) => value
                        case None => return None
                    }
                    let degraded = Box(false)
                    let rendered = renderConcreteTemplateAlias(
                        ctx,
                        element,
                        parameters,
                        instantiation.arguments,
                        HashMap<ItemId, String>(),
                        ItemSet(),
                        requiresCType: true,
                        outerDegraded: degraded
                    )
                    if (degraded.value) {
                        return None
                    }
                    match (rendered) {
                        case Ok(value) => Some(value)
                        case Err(_) => None
                    }
                case _ => None
            }
        case _ => None
    }
}

/// Only expose direct field assignment when the source type is known to have
/// value-like assignment semantics. Arrays and references are not assignable
/// in C/C++, and C++ record assignment may invoke unavailable special members.
func fieldHasValueLikeAccess(ctx: CjbindContext, typeId: TypeId): Bool {
    let canonical = match (ctx.resolveType(typeId).safeCanonicalType(ctx)) {
        case Some(value) => value
        case None => return false
    }
    return match (canonical.kind) {
        case TypeKind.TypeKindNullPtr |
            TypeKind.TypeKindInt(_) |
            TypeKind.TypeKindFloat(_) |
            TypeKind.TypeKindComplex(_) |
            TypeKind.TypeKindVector(_, _) |
            TypeKind.TypeKindEnum(_) |
            TypeKind.TypeKindPointer(_) |
            TypeKind.TypeKindObjCId |
            TypeKind.TypeKindObjCSel |
            TypeKind.TypeKindObjCBlockPointer(_) => true
        case _ => false
    }
}

func typeUseIsConst(ctx: CjbindContext, typeId: TypeId): Bool {
    let useType = ctx.resolveType(typeId)
    if (useType.isConst) {
        return true
    }
    return useType.safeCanonicalType(ctx).map({value => value.isConst}).getOrDefault({=> false})
}

func fieldStorageKeyword(ctx: CjbindContext, typeId: TypeId): String {
    if (typeUseIsConst(ctx, typeId) || !fieldHasValueLikeAccess(ctx, typeId)) {
        return "let"
    }
    return "var"
}

func zeroLengthArrayAccessor(
    ctx: CjbindContext,
    result: CodegenResult,
    ownerName: String,
    ownerIdent: String,
    data: FieldData,
    element: TypeId
): ?TokenStream {
    let rawFieldName = match (data.name) {
        case Some(value) => value
        case None => return None
    }
    let bitOffset = match (data.offset) {
        case Some(value) => value
        case None => return None
    }
    if (bitOffset % 8 != 0) {
        eprintln("Warning: cannot generate an array pointer accessor for '${ownerName}.${rawFieldName}' because its offset is not byte aligned")
        return None
    }

    let elementTy = match (zeroLengthArrayElementType(ctx, data.ty, ItemSet())) {
        case Some(value) => value
        case None =>
            eprintln(
                "Warning: cannot generate an array pointer accessor for '${ownerName}.${rawFieldName}' because its concrete element type could not be represented safely"
            )
            return None
    }
    let fieldName = ctx.cjMangle(rawFieldName)
    // Cangjie treats extension member names as package-wide even when the
    // specialized CPointer receiver types differ, so include the owner.
    let viewName = ctx.cjIdent(result.uniqueFunctionName("${ownerName}_${fieldName}_view"))
    let byteOffset = Int64(bitOffset / 8)
    let visibility = if (ctx.options.respectCxxAccessSpecs && !data.isPublic) {
        "private "
    } else {
        "public "
    }

    result.sawIncompleteArray = true
    let elementIsConst = typeUseIsConst(ctx, element) || typeUseIsConst(ctx, data.ty)
    if (elementIsConst) {
        return Some(@tmpl(
            ${visibility}unsafe func ${viewName}(value: CPointer<${ownerIdent}>, count!: Int64): __CjbindConstArrayView<${elementTy}> {
                let pointer = CPointer<${elementTy}>(CPointer<UInt8>(value) + ${byteOffset})
                return __CjbindConstArrayView<${elementTy}>(pointer: pointer, size: count)
            }
        ))
    }

    let accessorName = ctx.cjIdent(result.uniqueFunctionName("${ownerName}_${fieldName}_ptr"))
    return Some(@tmpl(
        ${visibility}unsafe func ${accessorName}(value: CPointer<${ownerIdent}>): CPointer<${elementTy}> {
            return CPointer<${elementTy}>(CPointer<UInt8>(value) + ${byteOffset})
        }

        ${visibility}unsafe func ${viewName}(value: CPointer<${ownerIdent}>, count!: Int64): __CjbindArrayView<${elementTy}> {
            return __CjbindArrayView<${elementTy}>(pointer: ${accessorName}(value), size: count)
        }
    ))
}

extend CompInfo <: CodeGenerator<Item, Unit> {
    // cjlint-ignore -start !G.FUN.01
    public func codegen(
        ctx: CjbindContext,
        result: CodegenResult,
        item: Item
    ): Unit {
        if (this.hasNonTypeTemplateParams) {
            eprintln(
                "Warning: skipping C++ record '${item.canonicalName(ctx)}' because non-type template parameters cannot be represented by the current Cangjie FFI"
            )
            return
        }
        if (ctx.usesAnyTemplateParameters(item.id)) {
            eprintln(
                "Warning: skipping C++ record '${item.canonicalName(ctx)}' because a generic @C record cannot be represented by the current Cangjie FFI"
            )
            return
        }
        let ty = item.kind.expectType()
        let layout = ty.getLayout(ctx)
        let hasRepresentableAlignment = layout
            .map({value => value.align <= ctx.pointerWidth() && Layout.knownCjTypeForSize(value.align).isSome()})
            .getOrDefault({=> true})

        let canonicalName = item.canonicalName(ctx)
        if (result.seenType(canonicalName)) {
            return
        }
        result.sawType(canonicalName)
        var isOpaque = item.isOpaque(ctx, ()) || this.isCodegenOpaque(ctx, layout, itemId: item.id)

        let packed = this.isPacked(ctx, layout)
        if (packed && layout.isSome()) {
            eprintln("警告：${canonicalName} 是一个 packed 类型，将生成不透明布局")
            isOpaque = true
        }
        if (!hasRepresentableAlignment) {
            eprintln("警告：${canonicalName} 的对齐要求无法由当前 FFI 类型表达；该类型仅适合通过指针使用")
            isOpaque = true
        }
        if (ctx.options.vtableGeneration && ctx.hasVtablePointer(item.id)) {
            reportUnsupportedVirtualMethodAbis(ctx, this, item)
        }

        let hasBitfields = if (isOpaque) {
            false
        } else if (let CompFieldsAfter(v) <- this.fields) {
            !this.isUnion() && v.hasBitfieldUnits
        } else {
            throw Exception("${canonicalName} 的字段应该已经被正确计算")
        }

        let canonicalIdent = ctx.cjIdent(canonicalName)

        let fields = ArrayList<TokenStream>()
        let zeroLengthArrayAccessors = ArrayList<TokenStream>()

        let sigs = TokenStream()
        let inits = ArrayList<TokenStream>()

        if (!this.isUnion() && !isOpaque) {
            if (ctx.hasVtablePointer(item.id)) {
                let vtableName = ctx.cjIdent("vtable_")
                let vtableTy = if (ctx.options.vtableGeneration && this.canGenerateTypedVtable(ctx)) {
                    let generatedVtableName = "${canonicalName}__cjbind_vtable"
                    let generatedVtableIdent = ctx.cjIdent(generatedVtableName)
                    let vtableFields = ArrayList<TokenStream>()
                    let vtableSigs = TokenStream()
                    let vtableInits = ArrayList<TokenStream>()
                    let vtableNames = HashSet<String>()

                    for (method in this.methods) {
                        if (!method.kind.isVirtual()) {
                            continue
                        }
                        let methodItem = ctx.resolveItem(method.signature)
                        let methodFunction = match (methodItem.kind) {
                            case ItemKind.KindFunction(function) => function
                            case _ => continue
                        }
                        let fieldBase = methodItem.canonicalName(ctx)
                        let fieldName = ctx.cjIdent(uniqueName(vtableNames, fieldBase))
                        let fieldTy = methodFunction.signature.toCjTyOrOpaque(ctx, ())
                        vtableFields.add(tokenStreamFromTemplate("public let ${fieldName} : ${fieldTy}"))
                        if (!vtableSigs.isEmpty()) {
                            vtableSigs.appendLiteral(", ")
                        }
                        vtableSigs.appendLiteral("${fieldName} : ${fieldTy}")
                        vtableInits.add(tokenStreamFromTemplate("this.${fieldName} = ${fieldName}"))
                    }

                    let vtableFieldsToken = joinStreams(vtableFields, "\n")
                    let vtableInitToken = if (vtableInits.isEmpty()) {
                        TokenStream()
                    } else {
                        let vtableInitBody = joinStreams(vtableInits, "\n")
                        @tmpl(
                            public init(${vtableSigs}) {
                                ${vtableInitBody}
                            }
                        )
                    }
                    result.items.add(@tmpl(
                        @C
                        public struct ${generatedVtableIdent} {
                            ${vtableFieldsToken}
                            ${vtableInitToken}
                        }
                    ))
                    tokenStreamFromTemplate("CPointer<${generatedVtableIdent}>")
                } else {
                    tokenStreamFromTemplate("CPointer<Unit>")
                }
                fields.add(tokenStreamFromTemplate("public let ${vtableName} : ${vtableTy}"))
                sigs.appendLiteral("${vtableName} : ${vtableTy}")
                inits.add(tokenStreamFromTemplate("this.${vtableName} = ${vtableName}"))
            }

            for (base in this.baseMembers) {
                if (!base.requiresStorage(ctx)) {
                    continue
                }
                let baseName = ctx.cjIdent(base.fieldName)
                let baseTy = base.ty.toCjTyOrOpaque(ctx, ())
                let visibility = if (ctx.options.respectCxxAccessSpecs && !base.isPublic) {
                    "private "
                } else {
                    "public "
                }
                fields.add(tokenStreamFromTemplate("${visibility}let ${baseName} : ${baseTy}"))
                if (!sigs.isEmpty()) {
                    sigs.appendLiteral(", ")
                }
                sigs.appendLiteral("${baseName} : ${baseTy}")
                inits.add(tokenStreamFromTemplate("this.${baseName} = ${baseName}"))
            }
        }

        if (this.isUnion() && !isOpaque) {
            match (layout) {
                case Some(l) =>
                    let blobTy = Helpers.blob(ctx, l)
                    fields.add(tokenStreamFromTemplate("var _storage: ${blobTy} = unsafe { zeroValue<${blobTy}>() }"))
                    let unionInitVisibility = if (this.isCxxRecord) { "private " } else { "public " }
                    fields.add(tokenStreamFromTemplate("${unionInitVisibility}init() {}"))

                    let fieldDecls = this.getFields()
                    for (field in fieldDecls) {
                        match (field) {
                            case Field.DataMember(data) =>
                                let fieldName = match (data.name) {
                                    case Some(n) => ctx.cjMangle(n)
                                    case None => continue
                                }
                                let fieldIdent = ctx.cjIdent(fieldName)
                                let fieldItem = data.ty.intoResolver().throughTypeRefs().resolve(ctx)
                                let fieldType = fieldItem.kind.expectType()
                                if (let Some(element) <- fieldType.isInCompleteArray(ctx)) {
                                    if (let Some(accessor) <- zeroLengthArrayAccessor(
                                        ctx,
                                        result,
                                        canonicalName,
                                        canonicalIdent,
                                        data,
                                        element
                                    )) {
                                        zeroLengthArrayAccessors.add(accessor)
                                    }
                                    continue
                                }
                                if (!fieldHasValueLikeAccess(ctx, data.ty)) {
                                    eprintln(
                                        "Warning: not generating a union property for '${canonicalName}.${fieldName}' because its value semantics cannot be represented safely"
                                    )
                                    continue
                                }
                                let fieldTy = data.ty.toCjTyOrOpaque(ctx, ())
                                let fieldTypeName = Helpers.unionHelperSuffix(ctx, fieldTy)
                                let storageTypeName = Helpers.unionHelperSuffix(ctx, blobTy)
                                let typeName = "${fieldTypeName}_from_${storageTypeName}"

                                if (!result.unionHelpersSeen.contains(typeName)) {
                                    result.unionHelpersSeen.add(typeName)
                                    if (ctx.options.useUnionAccessorWorkaround) {
                                        result.helpers.add(Helpers.unionReadHelper(typeName, blobTy, fieldTy))
                                        result.helpers.add(Helpers.unionWriteHelper(typeName, blobTy, fieldTy))
                                    } else {
                                        result.helpers.add(Helpers.unionReadPointerHelper(typeName, fieldTy))
                                        result.helpers.add(Helpers.unionWritePointerHelper(typeName, fieldTy))
                                    }
                                }

                                let readFuncName = "__cjbind_read_${typeName}"
                                let writeFuncName = "__cjbind_write_${typeName}"
                                let visibility = if (ctx.options.respectCxxAccessSpecs && !data.isPublic) {
                                    "private "
                                } else {
                                    "public "
                                }

                                if (typeUseIsConst(ctx, data.ty) && ctx.options.useUnionAccessorWorkaround) {
                                    fields.add(@tmpl(
                                        ${visibility}prop ${fieldIdent}: ${fieldTy} {
                                            get() {
                                                return ${readFuncName}(this._storage)
                                            }
                                        }
                                    ))
                                } else if (typeUseIsConst(ctx, data.ty)) {
                                    fields.add(@tmpl(
                                        ${visibility}prop ${fieldIdent}: ${fieldTy} {
                                            get() {
                                                var s = this._storage
                                                return unsafe { ${readFuncName}(CPointer<UInt8>(inout s)) }
                                            }
                                        }
                                    ))
                                } else if (ctx.options.useUnionAccessorWorkaround) {
                                    fields.add(@tmpl(
                                        ${visibility}mut prop ${fieldIdent}: ${fieldTy} {
                                            get() {
                                                return ${readFuncName}(this._storage)
                                            }
                                            set(value) {
                                                this._storage = ${writeFuncName}(this._storage, value)
                                            }
                                        }
                                    ))
                                } else {
                                    fields.add(@tmpl(
                                        ${visibility}mut prop ${fieldIdent}: ${fieldTy} {
                                            get() {
                                                var s = this._storage
                                                return unsafe { ${readFuncName}(CPointer<UInt8>(inout s)) }
                                            }
                                            set(value) {
                                                unsafe { ${writeFuncName}(CPointer<UInt8>(inout this._storage), value) }
                                            }
                                        }
                                    ))
                                }
                            case _ => ()
                        }
                    }
                    result.sawCjbindUnion = true
                case None => throw Exception("Expect layout for union")
            }
        } else if (!isOpaque) {
            let fieldDecls = this.getFields()

            if (hasBitfields) {
                let occupiedFieldNames = HashSet<String>()
                for (field in fieldDecls) {
                    match (field) {
                        case Field.DataMember(data) =>
                            if (let Some(name) <- data.name) {
                                occupiedFieldNames.add(ctx.cjMangle(name))
                            }
                        case Field.Bitfields(unit) =>
                            for (bitfield in unit.bitfields) {
                                if (let Some(name) <- bitfield.data.name) {
                                    occupiedFieldNames.add(ctx.cjMangle(name))
                                }
                            }
                    }
                }
                for (field in fieldDecls) {
                    match (field) {
                        case Field.DataMember(data) =>
                            let fieldItem = data.ty.intoResolver().throughTypeRefs().resolve(ctx)
                            let fieldTy = fieldItem.kind.expectType()
                            let ty = data.ty.toCjTyOrOpaque(ctx, ())

                            let fcomment: ?TokenStream = if (let Some(c) <- data.comment) {
                                let pc = preprocessComment(c)
                                Some(Attributes.doc(pc))
                            } else {
                                None
                            }

                            let fieldName = data.name.map {
                                d => ctx.cjMangle(d)
                            }.getOrThrow()
                            let fieldIdent = ctx.cjIdent(fieldName)
                            let visibility = if (ctx.options.respectCxxAccessSpecs && !data.isPublic) {
                                "private "
                            } else {
                                "public "
                            }

                            if (let Some(element) <- fieldTy.isInCompleteArray(ctx)) {
                                let fieldStorage = fieldStorageKeyword(ctx, data.ty)
                                let fieldToken = optionalComment(
                                    ctx,
                                    fcomment,
                                    tokenStreamFromTemplate("${visibility}${fieldStorage} ${fieldIdent} : ${ty} = unsafe { zeroValue<${ty}>() }")
                                )
                                fields.add(fieldToken)
                                if (let Some(accessor) <- zeroLengthArrayAccessor(
                                    ctx,
                                    result,
                                    canonicalName,
                                    canonicalIdent,
                                    data,
                                    element
                                )) {
                                    zeroLengthArrayAccessors.add(accessor)
                                }
                                continue
                            }

                            let fieldStorage = fieldStorageKeyword(ctx, data.ty)
                            let fieldToken = optionalComment(
                                ctx,
                                fcomment,
                                tokenStreamFromTemplate("${visibility}${fieldStorage} ${fieldIdent} : ${ty} = unsafe { zeroValue<${ty}>() }")
                            )
                            fields.add(fieldToken)

                        case Field.Bitfields(unit) =>
                            let unitNth = Int64(unit.nth)
                            let storageName = uniqueName(occupiedFieldNames, "_bitfield_${unitNth}")
                            let storageIdent = ctx.cjIdent(storageName)
                            let storageTy = Helpers.blob(ctx, unit.layout)

                            fields.add(
                                tokenStreamFromTemplate("var ${storageIdent} : ${storageTy} = unsafe { zeroValue<${storageTy}>() }")
                            )

                            for (bf in unit.bitfields) {
                                let bfName = match (bf.data.name) {
                                    case Some(n) => ctx.cjMangle(n)
                                    case None => continue
                                }
                                let bfIdent = ctx.cjIdent(bfName)
                                let bfTy = bf.data.ty.toCjTyOrOpaque(ctx, ())
                                let bitOffset = Int64(bf.offsetIntoUnit)
                                let bitWidth = Int64(bf.data.bitfieldWidth.getOrThrow())
                                let visibility = if (ctx.options.respectCxxAccessSpecs && !bf.data.isPublic) {
                                    "private "
                                } else {
                                    "public "
                                }

                                let baseItem = bf.data.ty
                                    .intoResolver()
                                    .throughTypeRefs()
                                    .throughTypeAliases()
                                    .resolve(ctx)
                                let baseType = baseItem.kind.expectType()
                                let reprId = match (baseType.kind) {
                                    case TypeKind.TypeKindEnum(en) => match (en.repr) {
                                        case Some(value) => value
                                        case None => throw Exception("bitfield enum has no integer representation")
                                    }
                                    case _ => baseItem.id
                                }
                                let reprItem = reprId
                                    .intoResolver()
                                    .throughTypeRefs()
                                    .throughTypeAliases()
                                    .resolve(ctx)
                                let reprType = reprItem.kind.expectType().canonicalType(ctx)
                                let reprTy = reprItem.id.toCjTyOrOpaque(ctx, ())
                                let isBool = reprType.isBool()
                                let isSigned = match (reprType.kind) {
                                    case TypeKind.TypeKindInt(ik) => ik.isSigned().getOrDefault({=> false})
                                    case _ => false
                                }
                                let readFunc = if (isSigned) { "__cjbind_bitfield_read_signed" } else { "__cjbind_bitfield_read" }
                                let rawRead = tokenStreamFromTemplate(
                                    "unsafe { ${readFunc}(CPointer<UInt8>(inout s), ${bitOffset}, ${bitWidth}) }"
                                )
                                let reprValue = if (isBool) {
                                    tokenStreamFromTemplate("(${rawRead}) != 0")
                                } else {
                                    tokenStreamFromTemplate("${reprTy}(${rawRead})")
                                }
                                let baseValue = match (baseType.kind) {
                                    case TypeKind.TypeKindEnum(_) =>
                                        if (ctx.options.defaultEnumStyle == DefaultEnumStyle.NewType) {
                                            let enumIdent = ctx.cjIdent(baseItem.canonicalName(ctx))
                                            tokenStreamFromTemplate("${enumIdent}(rawValue: ${reprValue})")
                                        } else {
                                            reprValue
                                        }
                                    case _ => reprValue
                                }
                                let readValue = wrapAliasValue(ctx, bf.data.ty, baseValue)
                                let unwrappedValue = unwrapAliasValue(
                                    ctx,
                                    bf.data.ty,
                                    tokenStreamFromTemplate("value")
                                )
                                let baseWriteValue = match (baseType.kind) {
                                    case TypeKind.TypeKindEnum(_) =>
                                        if (ctx.options.defaultEnumStyle == DefaultEnumStyle.NewType) {
                                            tokenStreamFromTemplate("${unwrappedValue}.rawValue")
                                        } else {
                                            unwrappedValue
                                        }
                                    case _ => unwrappedValue
                                }
                                let writeValue = if (isBool) {
                                    tokenStreamFromTemplate(
                                        "if (${baseWriteValue}) { UInt64(1) } else { UInt64(0) }"
                                    )
                                } else if (isSigned) {
                                    tokenStreamFromTemplate(
                                        "__cjbind_bitfield_int64_to_uint64(Int64(${baseWriteValue}))"
                                    )
                                } else {
                                    tokenStreamFromTemplate("UInt64(${baseWriteValue})")
                                }

                                if (typeUseIsConst(ctx, bf.data.ty)) {
                                    fields.add(@tmpl(
                                        ${visibility}prop ${bfIdent}: ${bfTy} {
                                            get() {
                                                var s = this.${storageIdent}
                                                return ${readValue}
                                            }
                                        }
                                    ))
                                } else {
                                    fields.add(@tmpl(
                                        ${visibility}mut prop ${bfIdent}: ${bfTy} {
                                            get() {
                                                var s = this.${storageIdent}
                                                return ${readValue}
                                            }
                                            set(value) {
                                                unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this.${storageIdent}), ${bitOffset}, ${bitWidth}, ${writeValue}) }
                                            }
                                        }
                                    ))
                                }
                            }

                            if (!result.sawBitfieldUnit) {
                                result.sawBitfieldUnit = true
                                result.helpers.add(Helpers.bitfieldReadHelper())
                                result.helpers.add(Helpers.bitfieldWriteHelper())
                                result.helpers.add(Helpers.bitfieldReadSignedHelper())
                                result.helpers.add(Helpers.bitfieldSignedConversionHelpers())
                            }
                    }
                }

                if (let Some(recordLayout) <- layout) {
                    if (recordLayout.align > 1) {
                        let alignmentTy = Layout.knownCjTypeForSize(recordLayout.align).getOrThrow()
                        let markerTy = tokenStreamFromTemplate("VArray<${alignmentTy}, \$0>")
                        let markerIdent = ctx.cjIdent(uniqueName(
                            occupiedFieldNames,
                            "_cjbind_bitfield_alignment_marker"
                        ))
                        fields.add(tokenStreamFromTemplate(
                            "let ${markerIdent} : ${markerTy} = unsafe { zeroValue<${markerTy}>() }"
                        ))
                    }
                }
                let bitfieldInitVisibility = if (this.isCxxRecord) { "private " } else { "public " }
                fields.add(tokenStreamFromTemplate("${bitfieldInitVisibility}init() {}"))
            } else {
                for (field in fieldDecls) {
                    match (field) {
                        case Field.DataMember(data) =>
                            let fieldItem = data.ty.intoResolver().throughTypeRefs().resolve(ctx)
                            let fieldTy = fieldItem.kind.expectType()
                            let ty = data.ty.toCjTyOrOpaque(ctx, ())

                            let fcomment: ?TokenStream = if (let Some(c) <- data.comment) {
                                let pc = preprocessComment(c)
                                Some(Attributes.doc(pc))
                            } else {
                                None
                            }

                            let fieldName = data.name.map {
                                d => ctx.cjMangle(d)
                            }.getOrThrow()
                            let fieldIdent = ctx.cjIdent(fieldName)

                            let visibility = if (ctx.options.respectCxxAccessSpecs && !data.isPublic) {
                                "private "
                            } else {
                                "public "
                            }
                            if (let Some(element) <- fieldTy.isInCompleteArray(ctx)) {
                                let fieldStorage = fieldStorageKeyword(ctx, data.ty)
                                let fieldToken = optionalComment(
                                    ctx,
                                    fcomment,
                                    tokenStreamFromTemplate("${visibility}${fieldStorage} ${fieldIdent} : ${ty} = unsafe { zeroValue<${ty}>() }")
                                )
                                fields.add(fieldToken)
                                if (let Some(accessor) <- zeroLengthArrayAccessor(
                                    ctx,
                                    result,
                                    canonicalName,
                                    canonicalIdent,
                                    data,
                                    element
                                )) {
                                    zeroLengthArrayAccessors.add(accessor)
                                }
                                continue
                            }
                            let fieldStorage = fieldStorageKeyword(ctx, data.ty)
                            let fieldToken = optionalComment(
                                ctx,
                                fcomment,
                                tokenStreamFromTemplate("${visibility}${fieldStorage} ${fieldIdent} : ${ty}")
                            )
                            fields.add(fieldToken)

                            if (!sigs.isEmpty()) {
                                sigs.appendLiteral(", ")
                            }
                            sigs.appendLiteral("${fieldIdent} : ${ty}")
                            inits.add(tokenStreamFromTemplate("this.${fieldIdent} = ${fieldIdent}"))

                        case _ => throw Exception("Only support normal field")
                    }
                }
            }
        }

        if (!this.isForwardDeclaration && fields.isEmpty() && ctx.isZeroSized(item.id)) {
            let needsAddress = if (isOpaque) {
                layout.isNone()
            } else if (this.isUnion()) {
                false
            } else {
                layout.map({value => value.size != 0}).getOrDefault({=> true})
            }
            if (needsAddress) {
                let emptyFieldName = ctx.cjIdent("_cjbind_empty")
                fields.add(tokenStreamFromTemplate("let ${emptyFieldName}: UInt8"))
                sigs.appendLiteral("${emptyFieldName}: UInt8")
                inits.add(tokenStreamFromTemplate("this.${emptyFieldName} = ${emptyFieldName}"))
            }
        }

        if (isOpaque) {
            match (layout) {
                case Some(l) =>
                    let ty = Helpers.blob(ctx, l)
                    fields.add(tokenStreamFromTemplate("let _cjbind_opaque_blob: ${ty}"))
                    inits.add(tokenStreamFromTemplate("this._cjbind_opaque_blob = unsafe { zeroValue<${ty}>() }"))

                case None =>
                    if (!this.isForwardDeclaration) {
                        eprintln(
                            "Warning: opaque type '${canonicalName}' has no known layout; using a one-byte address placeholder"
                        )
                    }
            }
        }

        if (this.isForwardDeclaration) {
            inits.add(tokenStreamFromTemplate("throw Exception(\"type should not be inited\")"))
        }

        let commentToken: ?TokenStream = if (let Some(c) <- item.comment) {
            let pc = preprocessComment(c)
            Some(Attributes.doc(pc))
        } else {
            None
        }

        let fieldsToken = joinStreams(fields, "\n")

        let initToken = TokenStream()
        let initVisibility = if (this.isForwardDeclaration) {
            ""
        } else if (this.isCxxRecord || !hasRepresentableAlignment ||
            (ctx.options.respectCxxAccessSpecs && this.hasNonPublicMembers())) {
            "private "
        } else {
            "public "
        }

        if (!inits.isEmpty()) {
            let initExpr = joinStreams(inits, "\n")

            initToken.appendLiteral("\n")
            initToken.`extend`(@tmpl(
                ${initVisibility}init(${sigs}) {
                    ${initExpr}
                }
            ))
        }

        let ret = optionalComment(
            ctx,
            commentToken,
            @tmpl(
                @C
                public struct ${canonicalIdent} {
                ${fieldsToken}${initToken}
                }
            )
        )

        result.items.add(ret)
        result.items.add(all: zeroLengthArrayAccessors)

        if (!ctx.options.noLayoutTests && !this.isForwardDeclaration && hasRepresentableAlignment) {
            if (let Some(l) <- layout) {
                let size = l.size
                let align = l.align
                let sizeOfExpr = "sizeOf<${canonicalIdent}>()"
                let alignOfExpr = "alignOf<${canonicalIdent}>()"

                let sizeErr = tokenStreamFromTemplate("\"Size of ${canonicalName} is not ${size} but \${size} bytes\"")
                let alignErr = tokenStreamFromTemplate("\"Alignment of ${canonicalName} is not ${align} but \${align} bytes\"")

                let testToken = @tmpl(
                    @When[debug]
                    let _ = {
                    =>
                        let size = ${sizeOfExpr}
                        if (size != ${size}) {
                            throw Exception(${sizeErr})
                        }
                        let align = ${alignOfExpr}
                        if (align != ${align}) {
                            throw Exception(${alignErr})
                        }
                    }
                )

                result.items.add(testToken)
            }
        }

        let codegenItems = ctx.codegenItems.getOrThrow()
        for (innerType in this.innerTypes) {
            if (codegenItems.contains(innerType)) {
                ctx.resolveItem(innerType).codegen(ctx, result, ())
            }
        }
        for (innerVar in this.innerVars) {
            if (codegenItems.contains(innerVar)) {
                ctx.resolveItem(innerVar).codegen(ctx, result, ())
            }
        }
    }
    // cjlint-ignore -end
}

func uniqueName(seen: HashSet<String>, baseName: String): String {
    if (!seen.contains(baseName)) {
        seen.add(baseName)
        return baseName
    }
    var suffix = 1
    while (true) {
        let candidate = "${baseName}${suffix}"
        if (!seen.contains(candidate)) {
            seen.add(candidate)
            return candidate
        }
        suffix += 1
    }
    throw Exception("unreachable")
}

func enumVariantExpr(val: EnumVariantValue): TokenStream {
    match (val) {
        case EnumVariantValue.Boolean(b) => tokenStreamFromTemplate("${b}")
        case EnumVariantValue.Signed(s) => tokenStreamFromTemplate("${s}")
        case EnumVariantValue.Unsigned(u) => tokenStreamFromTemplate("${u}")
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

        let commentToken: ?TokenStream = if (let Some(c) <- item.comment) {
            let pc = preprocessComment(c)
            Some(Attributes.doc(pc))
        } else {
            None
        }

        let repr = reprTy.toCjTyOrOpaque(ctx, item)

        if (ctx.options.defaultEnumStyle == DefaultEnumStyle.NewType) {
            let structFields = ArrayList<TokenStream>()

            structFields.add(tokenStreamFromTemplate("public var rawValue: ${repr} = unsafe { zeroValue<${repr}>() }"))

            structFields.add(tokenStreamFromTemplate(
                "public init(rawValue!: ${repr}) { this.rawValue = rawValue }"
            ))

            for (v in this.variants) {
                let variantName = ctx.cjMangle(v.name)
                let vIdent = ctx.cjIdent(variantName)
                let vexpr = enumVariantExpr(v.val)
                structFields.add(tokenStreamFromTemplate(
                    "public static let ${vIdent} = ${ident}(rawValue: ${vexpr})"
                ))
            }

            structFields.add(tokenStreamFromTemplate(
                "public operator func ==(right: ${ident}): Bool { this.rawValue == right.rawValue }"
            ))

            structFields.add(tokenStreamFromTemplate(
                "public operator func !=(right: ${ident}): Bool { this.rawValue != right.rawValue }"
            ))

            let fieldsToken = joinStreams(structFields, "\n")
            result.items.add(optionalComment(ctx, commentToken, @tmpl(
                @C
                public struct ${ident} {
                ${fieldsToken}
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

            let vComment: ?TokenStream = if (let Some(c) <- v.comment) {
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
                    tokenStreamFromTemplate("public const ${vIdent} : ${enumCjTy} = ${vexpr}")
                )
            )
        }

        if (!hasTypedef) {
            result.items.add(
                optionalComment(
                    ctx,
                    commentToken,
                    tokenStreamFromTemplate("public type ${ident} = ${repr}")
                )
            )
        }
    }
    // cjlint-ignore -end
}
