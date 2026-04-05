package cjbind.codegen

import cjbind_token.*
import cjbind_token.macros.*
import std.collection.{ArrayList, HashMap, HashSet}
import cjbind.ir.*
import cjbind.options.ObjcCodegenMode
import cjbind.result.Result

extend ObjCInterface <: CodeGenerator<Item, Unit> {
    public func codegen(
        ctx: CjbindContext,
        result: CodegenResult,
        item: Item
    ): Unit {
        if (ctx.options.objcCodegenMode == ObjcCodegenMode.Compiler) {
            this.codegenCompiler(ctx, result, item)
        } else {
            this.codegenRuntime(ctx, result, item)
        }
    }

    func codegenRuntime(
        ctx: CjbindContext,
        result: CodegenResult,
        item: Item
    ): Unit {
        // Generate runtime declarations once
        if (!result.seenVar("__objc_runtime_decls__")) {
            result.sawVar("__objc_runtime_decls__")
            result.items.add(genRuntimeDecls(ctx))
        }

        if (let Some(_) <- this.category) {
            this.codegenRuntimeCategory(ctx, result, item)
        } else if (this.isProtocol) {
            this.codegenRuntimeProtocol(ctx, result, item)
        } else {
            this.codegenRuntimeClass(ctx, result, item)
        }
    }

    func codegenRuntimeClass(
        ctx: CjbindContext,
        result: CodegenResult,
        item: Item
    ): Unit {
        var nameTokens = Tokens(ctx.cjIdentRaw(this.name))
        // Append generic type parameters as comment (ObjC lightweight generics)
        if (!this.templateNames.isEmpty()) {
            let tpNames = String.join(this.templateNames.toArray(), delimiter: ", ")
            nameTokens.append("/*<${tpNames}>*/")
        }
        let name = nameTokens
        let className = this.name

        let propertySelectors = this.propertySelectors()
        let clashNames = this.staticClashNames()

        // Generate methods
        let methodTokens = ArrayList<Tokens>()

        for (m in this.methods) {
            if (!propertySelectors.contains(m.selector)) {
                methodTokens.add(genRuntimeMethod(ctx, m, className, false))
            }
        }
        for (m in this.classMethods) {
            if (!propertySelectors.contains(m.selector)) {
                let method = if (clashNames.contains(m.name)) { m.renamedForClassClash() } else { m }
                methodTokens.add(genRuntimeMethod(ctx, method, className, true))
            }
        }
        for (p in this.properties) {
            methodTokens.add(genRuntimeProperty(ctx, p, className))
        }

        // Generate alloc() if not already defined as a class method
        let hasAlloc = this.classMethods.iterator().any { m => m.selector == "alloc" }
        if (!hasAlloc) {
            methodTokens.add(@tmpl(
                public static func alloc(): ${name} {
                    let cls = cachedClass("${className}")
                    let sel = cachedSel("alloc")
                    let f = CFunc<(CPointer<Unit>, CPointer<Unit>) -> CPointer<Unit>>(CPointer<Unit>(objc_msgSend))
                    return ${name}(unsafe { f(CPointer<Unit>(cls), sel) })
                }
            ))
        }

        // Generate up-cast methods for all ancestors (recursive)
        var currentParent = this.parentClass
        while (let Some(pid) <- currentParent) {
            let ancestorItem = ctx.resolveItem(pid)
            let ancestorName = ancestorItem.canonicalName(ctx)
            let ancestorIdent = ctx.cjIdentRaw(ancestorName)
            let castMethodName = ctx.cjIdentRaw("as${ancestorName}")
            methodTokens.add(Tokens(
                "public func ${castMethodName}(): ${ancestorIdent} { ${ancestorIdent}(this.id) }"
            ))
            // Walk up the chain
            match (ancestorItem.kind) {
                case ItemKind.KindType(ancestorTy) =>
                    match (ancestorTy.kind) {
                        case TypeKind.TypeKindObjCInterface(ancestorIface) =>
                            currentParent = ancestorIface.parentClass
                        case _ => currentParent = None
                    }
                case _ => currentParent = None
            }
        }

        let body = joinTokens(methodTokens, "\n")

        let classTokens = @tmpl(
            public class ${name} {
                public let id: CPointer<Unit>
                public init(id: CPointer<Unit>) { this.id = id }
                ${body}
            }
        )

        result.items.add(classTokens)
    }

    func codegenRuntimeProtocol(
        ctx: CjbindContext,
        result: CodegenResult,
        item: Item
    ): Unit {
        let name = ctx.cjIdentRaw("I${this.name}")

        let methodTokens = ArrayList<Tokens>()
        for (m in this.methods) {
            let sig = m.signature
            let ret = Utils.fnsigReturnTy(ctx, sig)
            let arguments = Utils.fnsigArguments(ctx, sig)
            let joined = joinTokens(arguments, ", ")
            let mname = ctx.cjIdent(m.name)
            methodTokens.add(Tokens(
                "func ${mname}(${joined}): ${ret}"
            ))
        }
        for (m in this.classMethods) {
            let sig = m.signature
            let ret = Utils.fnsigReturnTy(ctx, sig)
            let arguments = Utils.fnsigArguments(ctx, sig)
            let joined = joinTokens(arguments, ", ")
            let mname = ctx.cjIdent(m.name)
            methodTokens.add(Tokens(
                "static func ${mname}(${joined}): ${ret}"
            ))
        }

        let body = joinTokens(methodTokens, "\n")

        let protoTokens = @tmpl(
            public interface ${name} {
                ${body}
            }
        )

        result.items.add(protoTokens)
    }

    func codegenRuntimeCategory(
        ctx: CjbindContext,
        result: CodegenResult,
        item: Item
    ): Unit {
        let name = ctx.cjIdentRaw(this.name)
        let className = this.name

        let methodTokens = ArrayList<Tokens>()
        for (m in this.methods) {
            methodTokens.add(genRuntimeMethod(ctx, m, className, false))
        }
        for (m in this.classMethods) {
            methodTokens.add(genRuntimeMethod(ctx, m, className, true))
        }
        for (p in this.properties) {
            methodTokens.add(genRuntimeProperty(ctx, p, className))
        }

        let body = joinTokens(methodTokens, "\n")

        let extTokens = @tmpl(
            extend ${name} {
                ${body}
            }
        )
        result.items.add(extTokens)
    }

    func codegenCompiler(
        ctx: CjbindContext,
        result: CodegenResult,
        item: Item
    ): Unit {
        // Emit compiler mode imports once
        if (!result.seenVar("__objc_compiler_decls__")) {
            result.sawVar("__objc_compiler_decls__")
            result.items.add(@tmpl(
                import interoplib.objc.*
                import objc.lang.*
            ))
        }

        if (let Some(_) <- this.category) {
            // Category => extend block
            this.codegenCompilerCategory(ctx, result, item)
        } else if (this.isProtocol) {
            this.codegenCompilerProtocol(ctx, result, item)
        } else {
            this.codegenCompilerClass(ctx, result, item)
        }
    }

    func codegenCompilerClass(
        ctx: CjbindContext,
        result: CodegenResult,
        item: Item
    ): Unit {
        var nameTokens = Tokens(ctx.cjIdentRaw(this.name))
        // Append generic type parameters as comment (ObjC lightweight generics)
        if (!this.templateNames.isEmpty()) {
            let tpNames = String.join(this.templateNames.toArray(), delimiter: ", ")
            nameTokens.append("/*<${tpNames}>*/")
        }
        let name = nameTokens
        let genDefs = ctx.options.objcGenerateDefinitions
        var atObjCMirror = Tokens("@${ctx.cjIdentRaw("ObjCMirror")}")
        atObjCMirror = commentizeAnnotation(atObjCMirror, genDefs)

        let propertySelectors = this.propertySelectors()
        let clashNames = this.staticClashNames()

        // Build method tokens
        let methodTokens = ArrayList<Tokens>()

        // Detect init overloads (same param count -> must become static func)
        let overloadedInits = detectOverloadedInits(this.methods)

        for (m in this.methods) {
            if (!propertySelectors.contains(m.selector)) {
                let forceStatic = overloadedInits.contains(m.selector)
                methodTokens.add(genCompilerMethod(ctx, m, isStatic: false, isProtocol: false, forceStaticInit: forceStatic))
            }
        }
        for (m in this.classMethods) {
            if (!propertySelectors.contains(m.selector)) {
                let method = if (clashNames.contains(m.name)) { m.renamedForClassClash() } else { m }
                methodTokens.add(genCompilerMethod(ctx, method, isStatic: true, isProtocol: false))
            }
        }
        for (p in this.properties) {
            methodTokens.add(genCompilerProperty(ctx, p, isProtocol: false))
        }

        let body = joinTokens(methodTokens, "\n")

        // Build inheritance clause: <: Parent & Proto1 & Proto2
        let superTypes = ArrayList<Tokens>()
        if (let Some(parentId) <- this.parentClass) {
            let parentItem = ctx.resolveItem(parentId)
            let parentName = parentItem.canonicalName(ctx)
            superTypes.add(Tokens(ctx.cjIdentRaw(parentName)))
        }
        for (protoId in this.conformsTo) {
            let protoItem = ctx.resolveItem(protoId)
            let protoName = protoItem.canonicalName(ctx)
            superTypes.add(Tokens(ctx.cjIdentRaw(protoName)))
        }

        if (superTypes.isEmpty()) {
            let classTokens = @tmpl(
                ${atObjCMirror}
                public open class ${name} {
                    ${body}
                }
            )
            result.items.add(classTokens)
        } else {
            let inheritance = joinTokens(superTypes, " & ")
            let classTokens = @tmpl(
                ${atObjCMirror}
                public open class ${name} <: ${inheritance} {
                    ${body}
                }
            )
            result.items.add(classTokens)
        }
    }

    func codegenCompilerProtocol(
        ctx: CjbindContext,
        result: CodegenResult,
        item: Item
    ): Unit {
        let name = ctx.cjIdentRaw(this.name)
        let genDefs = ctx.options.objcGenerateDefinitions
        var atObjCMirror = Tokens("@${ctx.cjIdentRaw("ObjCMirror")}")
        atObjCMirror = commentizeAnnotation(atObjCMirror, genDefs)

        let methodTokens = ArrayList<Tokens>()

        for (m in this.methods) {
            methodTokens.add(genCompilerMethod(ctx, m, isStatic: false, isProtocol: true))
        }
        for (p in this.properties) {
            methodTokens.add(genCompilerProperty(ctx, p, isProtocol: true))
        }

        let body = joinTokens(methodTokens, "\n")

        // Build super-protocol list
        let superTypes = ArrayList<Tokens>()
        for (protoId in this.conformsTo) {
            let protoItem = ctx.resolveItem(protoId)
            let protoName = protoItem.canonicalName(ctx)
            superTypes.add(Tokens(ctx.cjIdentRaw(protoName)))
        }

        if (superTypes.isEmpty()) {
            let protoTokens = @tmpl(
                ${atObjCMirror}
                public interface ${name} {
                    ${body}
                }
            )
            result.items.add(protoTokens)
        } else {
            let inheritance = joinTokens(superTypes, " & ")
            let protoTokens = @tmpl(
                ${atObjCMirror}
                public interface ${name} <: ${inheritance} {
                    ${body}
                }
            )
            result.items.add(protoTokens)
        }
    }

    func codegenCompilerCategory(
        ctx: CjbindContext,
        result: CodegenResult,
        item: Item
    ): Unit {
        let name = ctx.cjIdentRaw(this.name)

        let methodTokens = ArrayList<Tokens>()

        for (m in this.methods) {
            methodTokens.add(genCompilerMethod(ctx, m, isStatic: false, isProtocol: false))
        }
        for (m in this.classMethods) {
            methodTokens.add(genCompilerMethod(ctx, m, isStatic: true, isProtocol: false))
        }
        for (p in this.properties) {
            methodTokens.add(genCompilerProperty(ctx, p, isProtocol: false))
        }

        let body = joinTokens(methodTokens, "\n")

        let extTokens = @tmpl(
            extend ${name} {
                ${body}
            }
        )
        result.items.add(extTokens)
    }
}

func capitalizeFirst(s: String): String {
    if (s.isEmpty()) {
        return s
    }
    let chars = s.toRuneArray()
    let first = chars[0]
    let upper: Rune = if (first >= r'a' && first <= r'z') {
        Rune(UInt32(first) - UInt32(r'a') + UInt32(r'A'))
    } else {
        first
    }
    var result = "${upper}"
    for (i in 1..chars.size) {
        result += "${chars[i]}"
    }
    return result
}

func defaultReturnValue(ctx: CjbindContext, sig: FunctionSig): Tokens {
    let retItem = ctx.resolveItem(sig.returnType)
    match (retItem.kind.asType()) {
        case Some(retTy) =>
            match (retTy.kind) {
                case TypeKind.TypeKindVoid => return Tokens()
                case TypeKind.TypeKindInt(_) => return Tokens("0")
                case TypeKind.TypeKindFloat(_) => return Tokens("0.0")
                case TypeKind.TypeKindPointer(_) => return Tokens("CPointer<Unit>()")
                case TypeKind.TypeKindObjCId => return Tokens("CPointer<Unit>()")
                case TypeKind.TypeKindObjCSel => return Tokens("CPointer<Unit>()")
                case TypeKind.TypeKindObjCBlockPointer(_) => return Tokens("CPointer<Unit>()")
                case TypeKind.TypeKindEnum(_) => return Tokens("0")
                case TypeKind.TypeKindObjCInterface(_) =>
                    let retName = retItem.canonicalName(ctx)
                    let retIdent = ctx.cjIdentRaw(retName)
                    return Tokens("${retIdent}(unsafe { zeroValue() })")
                case _ =>
                    let retTokens = Utils.fnsigReturnTy(ctx, sig)
                    return Tokens("unsafe { zeroValue<${retTokens}>() }")
            }
        case None => return Tokens("unsafe { zeroValue() }")
    }
}

func commentizeAnnotation(tokens: Tokens, generateDefinitions: Bool): Tokens {
    if (generateDefinitions && !tokens.isEmpty()) {
        return Tokens("/* ${tokens} */")
    }
    return tokens
}

// Groups init methods by parameter count. In Cangjie, init overloads with the same param count clash
// because selector names are not preserved. Selectors in the returned set must be emitted as static func.
func detectOverloadedInits(methods: ArrayList<ObjCMethod>): HashSet<String> {
    let paramCountMap = HashMap<Int64, ArrayList<String>>()
    for (m in methods) {
        if (m.isInitMethod) {
            let count = Int64(m.signature.argumentTypes.size)
            if (!paramCountMap.contains(count)) {
                paramCountMap[count] = ArrayList<String>()
            }
            paramCountMap[count].add(m.selector)
        }
    }
    let overloaded = HashSet<String>()
    for ((_, selectors) in paramCountMap) {
        if (selectors.size > 1) {
            for (sel in selectors) {
                overloaded.add(sel)
            }
        }
    }
    return overloaded
}

func genCompilerMethod(ctx: CjbindContext, m: ObjCMethod, isStatic!: Bool, isProtocol!: Bool, forceStaticInit!: Bool = false): Tokens {
    let sig = m.signature
    var ret = Utils.fnsigReturnTy(ctx, sig)
    ret = wrapNullable(ret, m.returnsNullable)
    let mname = ctx.cjIdent(m.name)
    let sel = m.selector
    let genDefs = ctx.options.objcGenerateDefinitions

    let arguments = fnsigArgumentsWithNullability(ctx, sig, m.nullableParams)
    let joinedArgs = joinTokens(arguments, ", ")

    // Handle init methods as constructors (unless overloaded -- then generate static func)
    if (m.isInitMethod && !isProtocol && !forceStaticInit) {
        // Determine if this is a non-standard init (needs @ObjCInit)
        let isStandardInit = sel == "init" || sel.startsWith("initWith")
        var objcInitAnnotation = if (!isStandardInit) {
            Tokens("@${ctx.cjIdentRaw("ObjCInit")}\n")
        } else { Tokens() }
        objcInitAnnotation = commentizeAnnotation(objcInitAnnotation, genDefs)

        if (sel != m.name) {
            var foreignName = Tokens("@${ctx.cjIdentRaw("ForeignName")}")
            foreignName.append("[\"${sel}\"]")
            foreignName = commentizeAnnotation(foreignName, genDefs)
            return @tmpl(
                ${objcInitAnnotation}
                ${foreignName}
                public init(${joinedArgs}) {}
            )
        } else {
            return @tmpl(
                ${objcInitAnnotation}
                public init(${joinedArgs}) {}
            )
        }
    }

    let effectivelyStatic = isStatic || forceStaticInit

    // Determine if @ForeignName is needed (selector differs from method name)
    let needsForeignName = (sel != m.name)

    var foreignNameAnnotation = if (needsForeignName || forceStaticInit) {
        let foreignName = Tokens("@${ctx.cjIdentRaw("ForeignName")}")
        foreignName.append("[\"${sel}\"]")
        foreignName
    } else {
        Tokens()
    }
    foreignNameAnnotation = commentizeAnnotation(foreignNameAnnotation, genDefs)

    var objcInitAnnotation = if (forceStaticInit) {
        Tokens("@${ctx.cjIdentRaw("ObjCInit")}\n")
    } else {
        Tokens()
    }
    objcInitAnnotation = commentizeAnnotation(objcInitAnnotation, genDefs)

    if (isProtocol) {
        // Protocol methods: no public/open modifiers
        var optionalAnnotation = if (m.isOptional) {
            Tokens("@${ctx.cjIdentRaw("ObjCOptional")}\n")
        } else { Tokens() }
        optionalAnnotation = commentizeAnnotation(optionalAnnotation, genDefs)
        if (needsForeignName) {
            return @tmpl(
                ${optionalAnnotation}
                ${foreignNameAnnotation}
                func ${mname}(${joinedArgs}): ${ret}
            )
        } else {
            return @tmpl(
                ${optionalAnnotation}
                func ${mname}(${joinedArgs}): ${ret}
            )
        }
    } else if (effectivelyStatic) {
        if (ctx.options.objcGenerateDefinitions) {
            let defVal = defaultReturnValue(ctx, sig)
            if (needsForeignName || forceStaticInit) {
                return @tmpl(
                    ${objcInitAnnotation}
                    ${foreignNameAnnotation}
                    public static func ${mname}(${joinedArgs}): ${ret} { ${defVal} }
                )
            } else {
                return Tokens(
                    "public static func ${mname}(${joinedArgs}): ${ret} { ${defVal} }"
                )
            }
        } else {
            if (needsForeignName || forceStaticInit) {
                return @tmpl(
                    ${objcInitAnnotation}
                    ${foreignNameAnnotation}
                    public static func ${mname}(${joinedArgs}): ${ret}
                )
            } else {
                return Tokens(
                    "public static func ${mname}(${joinedArgs}): ${ret}"
                )
            }
        }
    } else {
        // Instance method: public open func
        if (ctx.options.objcGenerateDefinitions) {
            let defVal = defaultReturnValue(ctx, sig)
            if (needsForeignName) {
                return @tmpl(
                    ${foreignNameAnnotation}
                    public open func ${mname}(${joinedArgs}): ${ret} { ${defVal} }
                )
            } else {
                return Tokens(
                    "public open func ${mname}(${joinedArgs}): ${ret} { ${defVal} }"
                )
            }
        } else {
            if (needsForeignName) {
                return @tmpl(
                    ${foreignNameAnnotation}
                    public open func ${mname}(${joinedArgs}): ${ret}
                )
            } else {
                return Tokens(
                    "public open func ${mname}(${joinedArgs}): ${ret}"
                )
            }
        }
    }
}

func genCompilerProperty(ctx: CjbindContext, p: ObjCProperty, isProtocol!: Bool): Tokens {
    let propName = ctx.cjIdent(p.name)
    var ty = p.ty.toCjTyOrOpaque(ctx, ())
    ty = wrapNullable(ty, p.isNullable)
    let genDefs = ctx.options.objcGenerateDefinitions

    // Check if getter name differs from default (property name)
    let needsGetterAnnotation = (p.getterName != p.name)
    var getterAnnotation = if (needsGetterAnnotation) {
        let ann = Tokens("@${ctx.cjIdentRaw("ForeignGetterName")}")
        ann.append("[\"${p.getterName}\"]")
        ann
    } else {
        Tokens()
    }
    getterAnnotation = commentizeAnnotation(getterAnnotation, genDefs)

    // Check if setter name differs from default (setPropertyName:)
    let capitalizedName = capitalizeFirst(p.name)
    let defaultSetterName = "set${capitalizedName}:"
    let needsSetterAnnotation = if (let Some(setter) <- p.setterName) {
        setter != defaultSetterName
    } else {
        false
    }
    var setterAnnotation = if (let Some(setter) <- p.setterName) {
        if (needsSetterAnnotation) {
            let ann = Tokens("@${ctx.cjIdentRaw("ForeignSetterName")}")
            ann.append("[\"${setter}\"]")
            ann
        } else {
            Tokens()
        }
    } else {
        Tokens()
    }
    setterAnnotation = commentizeAnnotation(setterAnnotation, genDefs)

    let annotations = Tokens()
    if (needsGetterAnnotation) {
        annotations.append(getterAnnotation)
        annotations.append("\n")
    }
    if (needsSetterAnnotation) {
        annotations.append(setterAnnotation)
        annotations.append("\n")
    }

    let hasSetter = match (p.setterName) {
        case Some(_) => !p.isReadonly
        case None => false
    }

    if (p.isReadonly && p.setterName.isSome()) {
        eprintln("Warning: property '${p.name}' is readonly but has setterName '${p.setterName.getOrThrow()}'")
    }

    // Add static modifier for class properties
    let staticMod = if (p.isClassProperty) { "static " } else { "" }

    if (isProtocol) {
        if (p.isOptional) {
            var optAnn = Tokens("@${ctx.cjIdentRaw("ObjCOptional")}")
            optAnn = commentizeAnnotation(optAnn, genDefs)
            annotations.append(optAnn)
            annotations.append("\n")
        }
        if (hasSetter) {
            return @tmpl(
                ${annotations}
                ${staticMod}mut prop ${propName}: ${ty}
            )
        } else {
            return @tmpl(
                ${annotations}
                ${staticMod}prop ${propName}: ${ty}
            )
        }
    } else {
        if (hasSetter) {
            return @tmpl(
                ${annotations}
                public ${staticMod}open mut prop ${propName}: ${ty}
            )
        } else {
            return @tmpl(
                ${annotations}
                public ${staticMod}open prop ${propName}: ${ty}
            )
        }
    }
}

func genRuntimeDecls(ctx: CjbindContext): Tokens {
    return @tmpl(
        import std.collection.HashMap

        // ObjC Runtime declarations
        foreign func objc_getClass(name: CString): CPointer<Unit>
        foreign func sel_registerName(name: CString): CPointer<Unit>
        foreign func objc_msgSend(): Unit
        foreign func objc_msgSend_stret(): Unit
        foreign func objc_retain(obj: CPointer<Unit>): CPointer<Unit>
        foreign func objc_release(obj: CPointer<Unit>): Unit
        foreign func objc_autorelease(obj: CPointer<Unit>): CPointer<Unit>

        // Selector and class caching to avoid repeated allocation
        var _objcSelCache = HashMap<String, CPointer<Unit>>()
        func cachedSel(name: String): CPointer<Unit> {
            if (let Some(sel) <- _objcSelCache.get(name)) {
                return sel
            }
            let cs = unsafe { LibC.mallocCString(name) }
            let sel = unsafe { sel_registerName(cs) }
            unsafe { LibC.free(cs) }
            _objcSelCache[name] = sel
            return sel
        }
        var _objcClsCache = HashMap<String, CPointer<Unit>>()
        func cachedClass(name: String): CPointer<Unit> {
            if (let Some(cls) <- _objcClsCache.get(name)) {
                return cls
            }
            let cs = unsafe { LibC.mallocCString(name) }
            let cls = unsafe { objc_getClass(cs) }
            unsafe { LibC.free(cs) }
            _objcClsCache[name] = cls
            return cls
        }
    )
}

func fnsigArgumentsWithNullability(ctx: CjbindContext, sig: FunctionSig, nullableParams: ArrayList<Bool>): ArrayList<Tokens> {
    let args = ArrayList<Tokens>()
    let unnamedArgs = Box(0)
    for ((i, arg) in sig.argumentTypes.iterator().enumerate()) {
        let argName = if (let Some(n) <- arg[0]) {
            ctx.cjMangle(n)
        } else {
            unnamedArgs.value += 1
            "arg${unnamedArgs.value}"
        }
        let argIdent = ctx.cjIdent(argName)
        var argTy = Utils.fnsigArgumentType(ctx, arg[1])
        if (i < nullableParams.size && nullableParams[i]) {
            argTy = wrapNullable(argTy, true)
        }
        args.add(Tokens("${argIdent} : ${argTy}"))
    }
    return args
}

func wrapNullable(ty: Tokens, isNullable: Bool): Tokens {
    if (isNullable) {
        return Tokens("?${ty}")
    }
    return ty
}

func genRuntimeMethod(ctx: CjbindContext, m: ObjCMethod, className: String, isStatic: Bool): Tokens {
    let sig = m.signature
    var ret = Utils.fnsigReturnTy(ctx, sig)
    ret = wrapNullable(ret, m.returnsNullable)
    let mname = ctx.cjIdent(m.name)
    let sel = m.selector

    let arguments = fnsigArgumentsWithNullability(ctx, sig, m.nullableParams)
    let joinedArgs = joinTokens(arguments, ", ")

    // Build CFunc parameter types: (CPointer<Unit>, CPointer<Unit>, ...paramTypes) -> RetType
    let paramTypes = ArrayList<Tokens>()
    paramTypes.add(Tokens("CPointer<Unit>"))  // self/class pointer
    paramTypes.add(Tokens("CPointer<Unit>"))  // _cmd (selector)
    for (arg in sig.argumentTypes) {
        let ty = arg[1].toCjTyOrOpaque(ctx, ())
        paramTypes.add(ty)
    }
    let joinedParamTypes = joinTokens(paramTypes, ", ")

    // Build the argument forwarding name list
    let argNames = Utils.fnsigArgumentNames(ctx, sig)
    let joinedArgNames = joinTokens(argNames, ", ")

    if (isStatic) {
        // Class method
        if (argNames.isEmpty()) {
            return @tmpl(
                public static func ${mname}(${joinedArgs}): ${ret} {
                    let cls = cachedClass("${className}")
                    let sel = cachedSel("${sel}")
                    let f = CFunc<(${joinedParamTypes}) -> ${ret}>(CPointer<Unit>(objc_msgSend))
                    return unsafe { f(CPointer<Unit>(cls), sel) }
                }
            )
        } else {
            return @tmpl(
                public static func ${mname}(${joinedArgs}): ${ret} {
                    let cls = cachedClass("${className}")
                    let sel = cachedSel("${sel}")
                    let f = CFunc<(${joinedParamTypes}) -> ${ret}>(CPointer<Unit>(objc_msgSend))
                    return unsafe { f(CPointer<Unit>(cls), sel, ${joinedArgNames}) }
                }
            )
        }
    } else {
        // Instance method
        if (argNames.isEmpty()) {
            return @tmpl(
                public func ${mname}(${joinedArgs}): ${ret} {
                    let sel = cachedSel("${sel}")
                    let f = CFunc<(${joinedParamTypes}) -> ${ret}>(CPointer<Unit>(objc_msgSend))
                    return unsafe { f(this.id, sel) }
                }
            )
        } else {
            return @tmpl(
                public func ${mname}(${joinedArgs}): ${ret} {
                    let sel = cachedSel("${sel}")
                    let f = CFunc<(${joinedParamTypes}) -> ${ret}>(CPointer<Unit>(objc_msgSend))
                    return unsafe { f(this.id, sel, ${joinedArgNames}) }
                }
            )
        }
    }
}

func genRuntimeProperty(ctx: CjbindContext, p: ObjCProperty, className: String): Tokens {
    let propName = ctx.cjIdent(p.name)
    var ty = p.ty.toCjTyOrOpaque(ctx, ())
    ty = wrapNullable(ty, p.isNullable)
    let getterSel = p.getterName

    if (p.isClassProperty) {
        // Static property -- use class pointer instead of this.id
        if (let Some(setterSel) <- p.setterName) {
            return @tmpl(
                public static mut prop ${propName}: ${ty} {
                    get() {
                        let cls = cachedClass("${className}")
                        let sel = cachedSel("${getterSel}")
                        let f = CFunc<(CPointer<Unit>, CPointer<Unit>) -> ${ty}>(CPointer<Unit>(objc_msgSend))
                        return unsafe { f(CPointer<Unit>(cls), sel) }
                    }
                    set(value) {
                        let cls = cachedClass("${className}")
                        let sel = cachedSel("${setterSel}")
                        let f = CFunc<(CPointer<Unit>, CPointer<Unit>, ${ty}) -> Unit>(CPointer<Unit>(objc_msgSend))
                        unsafe { f(CPointer<Unit>(cls), sel, value) }
                    }
                }
            )
        } else {
            return @tmpl(
                public static prop ${propName}: ${ty} {
                    get() {
                        let cls = cachedClass("${className}")
                        let sel = cachedSel("${getterSel}")
                        let f = CFunc<(CPointer<Unit>, CPointer<Unit>) -> ${ty}>(CPointer<Unit>(objc_msgSend))
                        return unsafe { f(CPointer<Unit>(cls), sel) }
                    }
                }
            )
        }
    }

    if (let Some(setterSel) <- p.setterName) {
        return @tmpl(
            public mut prop ${propName}: ${ty} {
                get() {
                    let sel = cachedSel("${getterSel}")
                    let f = CFunc<(CPointer<Unit>, CPointer<Unit>) -> ${ty}>(CPointer<Unit>(objc_msgSend))
                    return unsafe { f(this.id, sel) }
                }
                set(value) {
                    let sel = cachedSel("${setterSel}")
                    let f = CFunc<(CPointer<Unit>, CPointer<Unit>, ${ty}) -> Unit>(CPointer<Unit>(objc_msgSend))
                    unsafe { f(this.id, sel, value) }
                }
            }
        )
    } else {
        return @tmpl(
            public prop ${propName}: ${ty} {
                get() {
                    let sel = cachedSel("${getterSel}")
                    let f = CFunc<(CPointer<Unit>, CPointer<Unit>) -> ${ty}>(CPointer<Unit>(objc_msgSend))
                    return unsafe { f(this.id, sel) }
                }
            }
        )
    }
}
