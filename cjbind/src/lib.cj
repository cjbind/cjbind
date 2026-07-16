package cjbind

import std.collection.*
import cjbind.options.CjbindOptions
import cjbind.clang
import cjbind.codegen
import cjbind.codegen.{CodegenError}
import cjbind.ir.*

func parseOne(ctx: CjbindContext, cursor: clang.Cursor, parent: ?ItemId): Unit {
    let builtin = cursor.isBuiltin() || cursor.isInSystemHeader()
    if (builtin && !ctx.options.builtins) {
        return
    }

    // ObjC mode: handle ObjC declarations
    if (ctx.options.objc) {
        let k = cursor.kind()
        if (k == clang.CXCursorKind_CXCursor_ObjCInterfaceDecl ||
            k == clang.CXCursorKind_CXCursor_ObjCProtocolDecl ||
            k == clang.CXCursorKind_CXCursor_ObjCCategoryDecl) {
            parseObjCInterface(ctx, cursor)
            return
        }
    }

    if (cursor.kind() == clang.CXCursorKind_CXCursor_Namespace) {
        let moduleId = ctx.module(cursor)
        ctx.withModule(moduleId) {
            moduleCtx => cursor.visitContinue {
                child => parseOne(moduleCtx, child, Some(moduleId))
            }
        }
        return
    }

    match (Item.parse(cursor, parent, ctx)) {
        case Ok(_) => ()
        case Err(ParseError.Continue) => ()
        case Err(ParseError.Recurse) => cursor.visitContinue {
            child => parseOne(ctx, child, parent)
        }
    }
}

func parse(context: CjbindContext) {
    var error: ?String = None

    for (d in context.translationUnit.diags()) {
        let msg = d.toString()
        let isError = d.severity() >= clang.CXDiagnosticSeverity_CXDiagnostic_Error
        d.close()

        if (isError) {
            error = match (error) {
                case None => Some(msg + "\n")
                case Some(oldmsg) => Some(oldmsg + msg + "\n")
            }
        } else {
            eprintln("clang diag: ${msg}")
        }
    }

    if (let Some(e) <- error) {
        throw Exception(e)
    }

    let cursor = context.translationUnit.cursor()

    let root = context.rootModule
    context.withModule(root) {
        ctx => cursor.visitContinue {
            child => parseOne(ctx, child, None)
        }
    }
}

func detectIncludePaths(options: CjbindOptions) {
    if (options.noDetectIncludePath) {
        return
    }

    let clangArgsForClang = {
        =>
        let lastWasIncludePrefix = Box(false)
        options
            .clangArgs
            .iterator()
            .filter {
                arg =>
                if (lastWasIncludePrefix.value) {
                    lastWasIncludePrefix.value = false
                    return false
                }

                if (arg == "-I" || arg == "--include-directory") {
                    lastWasIncludePrefix.value = true
                    return false
                }

                if (arg.startsWith("-I") || arg.startsWith("--include-directory=")) {
                    return false
                }

                return true
            } |> collectArrayList
    }().toArray()

    let detectionArgs = ArrayList<String>(clangArgsForClang)
    if (hasCxxHeader(options.headers) && !hasExplicitLanguage(detectionArgs)) {
        detectionArgs.add("-x")
        detectionArgs.add("c++")
    }

    let searchPaths = clang.getSearchPaths(detectionArgs.toArray())

    if (let Some(ps) <- searchPaths) {
        for (p in ps) {
            options.clangArgs.add("-isystem")
            options.clangArgs.add(p)
        }
    }
}

func hasExplicitLanguage(args: Collection<String>): Bool {
    for (arg in args) {
        if (arg == "-x" || (arg.startsWith("-x") && arg.size > 2)) {
            return true
        }
    }
    return false
}

func hasCxxHeader(headers: Collection<String>): Bool {
    for (header in headers) {
        if (header.endsWith(".hpp") || header.endsWith(".hxx") || header.endsWith(".hh") ||
            header.endsWith(".h++") || header.endsWith(".HPP") || header.endsWith(".HXX") ||
            header.endsWith(".HH") || header.endsWith(".H++") || header.endsWith(".H") ||
            header.endsWith(".cc") || header.endsWith(".cpp") || header.endsWith(".cxx") ||
            header.endsWith(".c++") || header.endsWith(".C")) {
            return true
        }
    }
    return false
}

public func generate(opts: CjbindOptions): String {
    if (opts.headers.isEmpty()) {
        throw Exception("没有指定头文件")
    }
    if (opts.wrapStaticFns && opts.wrapStaticFnsSuffix.isEmpty()) {
        throw Exception("wrapStaticFnsSuffix 不能为空")
    }
    if (opts.wrapStaticFns && opts.wrapStaticFnsPath.map({value => value.isEmpty()}).getOrDefault({=> false})) {
        throw Exception("wrapStaticFnsPath 不能为空")
    }

    clang.ensureSupportedClangVersion()

    detectIncludePaths(opts)

    // Clone clangArgs so we do not mutate the caller's options object
    let localArgs = ArrayList<String>(opts.clangArgs)

    if (opts.objc) {
        localArgs.add("-x")
        localArgs.add("objective-c")
    } else if (!hasExplicitLanguage(localArgs) && hasCxxHeader(opts.headers)) {
        localArgs.add("-x")
        localArgs.add("c++")
    }

    // Last header is used as the main translation unit file. All preceding headers are pre-included via -include.
    let headerOpts = ArrayList<String>()
    for ((i, h) in opts.headers.iterator().enumerate()) {
        if (i != opts.headers.size - 1) {
            headerOpts.add("-include")
        }
        headerOpts.add(h)
    }
    localArgs.add(all: headerOpts)

    // Build a context options view with the local (non-mutated) clang args
    let ctxOpts = CjbindOptions(opts.headers, localArgs)
    ctxOpts.packageName = opts.packageName
    ctxOpts.noEnumPrefix = opts.noEnumPrefix
    ctxOpts.noDetectIncludePath = opts.noDetectIncludePath
    ctxOpts.noLayoutTests = opts.noLayoutTests
    ctxOpts.builtins = opts.builtins
    ctxOpts.noComment = opts.noComment
    ctxOpts.makeFuncWrapper = opts.makeFuncWrapper
    ctxOpts.funcWrapperSuffix = opts.funcWrapperSuffix
    ctxOpts.wrapStaticFns = opts.wrapStaticFns
    ctxOpts.wrapStaticFnsSuffix = opts.wrapStaticFnsSuffix
    ctxOpts.wrapStaticFnsPath = opts.wrapStaticFnsPath
    ctxOpts.autoCString = opts.autoCString
    ctxOpts.arrayPointersInArgs = opts.arrayPointersInArgs
    ctxOpts.makeCjString = opts.makeCjString
    ctxOpts.objc = opts.objc
    ctxOpts.objcCodegenMode = opts.objcCodegenMode
    ctxOpts.objcGenerateDefinitions = opts.objcGenerateDefinitions
    ctxOpts.defaultEnumStyle = opts.defaultEnumStyle
    ctxOpts.defaultAliasStyle = opts.defaultAliasStyle
    ctxOpts.fitMacroConstants = opts.fitMacroConstants
    ctxOpts.useUnionAccessorWorkaround = opts.useUnionAccessorWorkaround
    ctxOpts.enableCxxNamespaces = opts.enableCxxNamespaces
    ctxOpts.conservativeInlineNamespaces = opts.conservativeInlineNamespaces
    ctxOpts.generateFunctions = opts.generateFunctions
    ctxOpts.generateTypes = opts.generateTypes
    ctxOpts.generateVars = opts.generateVars
    ctxOpts.generateMethods = opts.generateMethods
    ctxOpts.generateConstructors = opts.generateConstructors
    ctxOpts.generateDestructors = opts.generateDestructors
    ctxOpts.representCxxOperators = opts.representCxxOperators
    ctxOpts.respectCxxAccessSpecs = opts.respectCxxAccessSpecs
    ctxOpts.useSpecificVirtualFunctionReceiver = opts.useSpecificVirtualFunctionReceiver
    ctxOpts.generateInlineFunctions = opts.generateInlineFunctions
    ctxOpts.generateDeletedFunctions = opts.generateDeletedFunctions
    ctxOpts.generatePureVirtualFunctions = opts.generatePureVirtualFunctions
    ctxOpts.generatePrivateFunctions = opts.generatePrivateFunctions
    ctxOpts.vtableGeneration = opts.vtableGeneration
    ctxOpts.allowlistRecursively = opts.allowlistRecursively
    ctxOpts.recordMatches = opts.recordMatches
    ctxOpts.untaggedUnion = opts.untaggedUnion
    ctxOpts.sizeTIsUsize = opts.sizeTIsUsize
    ctxOpts.blocklistedTypes.add(opts.blocklistedTypes.toArray())
    ctxOpts.blocklistedFunctions.add(opts.blocklistedFunctions.toArray())
    ctxOpts.blocklistedItems.add(opts.blocklistedItems.toArray())
    ctxOpts.blocklistedVars.add(opts.blocklistedVars.toArray())
    ctxOpts.blocklistedFiles.add(opts.blocklistedFiles.toArray())
    ctxOpts.opaqueTypes.add(opts.opaqueTypes.toArray())
    ctxOpts.allowlistedTypes.add(opts.allowlistedTypes.toArray())
    ctxOpts.allowlistedFunctions.add(opts.allowlistedFunctions.toArray())
    ctxOpts.allowlistedItems.add(opts.allowlistedItems.toArray())
    ctxOpts.allowlistedVars.add(opts.allowlistedVars.toArray())
    ctxOpts.allowlistedFiles.add(opts.allowlistedFiles.toArray())
    ctxOpts.typeAliases.add(opts.typeAliases.toArray())
    ctxOpts.newTypeAliases.add(opts.newTypeAliases.toArray())
    ctxOpts.newTypeDerefAliases.add(opts.newTypeDerefAliases.toArray())
    ctxOpts.fieldNameCallback = opts.fieldNameCallback

    let ctx = CjbindContext(ctxOpts)

    try {
        parse(ctx)

        let module = match (codegen.codegen(ctx)) {
            case Ok(v) => v
            case Err(e) =>
                let detail = match (e) {
                    case CodegenError.Serialize(se) => "${se.msg} at ${se.loc}"
                    case CodegenError.Io(msg) => "IO: ${msg}"
                }
                throw Exception("Failed to generate code: ${detail}")
        }
        return module.toString()
    } finally {
        ctx.close()
    }
}

func registerObjCInterface(ctx: CjbindContext, name: String, iface: ObjCInterface): ItemId {
    let ty = Type(Some(name), None, TypeKind.TypeKindObjCInterface(iface), false)
    let id = ctx.nextItemId()
    let item = Item(id, None, ctx.currentModule, ItemKind.KindType(ty), None)
    ctx.addItem(item, None, None)
    ctx.objcInterfaces[name] = id
    return id
}

func parseObjCInterface(ctx: CjbindContext, cursor: clang.Cursor): Unit {
    let name = cursor.spelling()
    if (name.isEmpty()) {
        return
    }

    let k = cursor.kind()
    let isProtocol = k == clang.CXCursorKind_CXCursor_ObjCProtocolDecl
    let isCategory = k == clang.CXCursorKind_CXCursor_ObjCCategoryDecl

    // Single pass over children to: find ObjCClassRef (for categories), check hasBody
    var className = name
    var hasBody = false
    let children = cursor.collectChildren()
    for (c in children) {
        let ck = c.kind()
        if (isCategory && ck == clang.CXCursorKind_CXCursor_ObjCClassRef) {
            className = c.spelling()
        }
        if (!hasBody) {
            hasBody = ck == clang.CXCursorKind_CXCursor_ObjCInstanceMethodDecl ||
                ck == clang.CXCursorKind_CXCursor_ObjCClassMethodDecl ||
                ck == clang.CXCursorKind_CXCursor_ObjCPropertyDecl ||
                ck == clang.CXCursorKind_CXCursor_ObjCIvarDecl ||
                ck == clang.CXCursorKind_CXCursor_ObjCSuperClassRef ||
                ck == clang.CXCursorKind_CXCursor_ObjCProtocolRef
        }
    }

    let iface = ObjCInterface(if (isCategory) { className } else { name })
    iface.isProtocol = isProtocol
    if (isCategory) {
        iface.category = Some(name)
    }

    if (!hasBody && !isCategory) {
        // Forward declaration — register placeholder if not already known
        if (!ctx.objcInterfaces.contains(name)) {
            iface.isForwardDeclaration = true
            registerObjCInterface(ctx, name, iface)
        }
        return
    }

    // Visit children to populate the interface
    cursor.visitContinue {
        child =>
        let ck = child.kind()
        if (ck == clang.CXCursorKind_CXCursor_ObjCSuperClassRef) {
            let superName = child.spelling()
            if (let Some(parentId) <- ctx.objcInterfaces.get(superName)) {
                iface.parentClass = Some(parentId)
            }
        } else if (ck == clang.CXCursorKind_CXCursor_ObjCProtocolRef) {
            let protoName = child.spelling()
            if (let Some(protoId) <- ctx.objcInterfaces.get(protoName)) {
                iface.conformsTo.add(protoId)
            } else {
                // Protocol not yet seen — create forward declaration placeholder
                let protoIface = ObjCInterface(protoName)
                protoIface.isProtocol = true
                protoIface.isForwardDeclaration = true
                let protoId = registerObjCInterface(ctx, protoName, protoIface)
                iface.conformsTo.add(protoId)
            }
        } else if (ck == clang.CXCursorKind_CXCursor_ObjCInstanceMethodDecl) {
            if (let Some(method) <- parseObjCMethod(ctx, child, false, name)) {
                iface.methods.add(method)
            }
        } else if (ck == clang.CXCursorKind_CXCursor_ObjCClassMethodDecl) {
            if (let Some(method) <- parseObjCMethod(ctx, child, true, name)) {
                iface.classMethods.add(method)
            }
        } else if (ck == clang.CXCursorKind_CXCursor_ObjCPropertyDecl) {
            if (let Some(p) <- parseObjCProperty(ctx, child)) {
                iface.properties.add(p)
            }
        } else if (ck == clang.CXCursorKind_CXCursor_TemplateTypeParameter) {
            // Collect ObjC lightweight generic type parameters
            let tpName = child.spelling()
            if (!tpName.isEmpty()) {
                iface.templateNames.add(tpName)
            }
        }
    }

    // Remove duplicate methods (same selector)
    iface.dedupMethods()

    if (isCategory) {
        // For categories, find the original interface and merge methods/properties
        if (let Some(origId) <- ctx.objcInterfaces.get(className)) {
            let origItem = ctx.resolveItem(origId)
            match (origItem.kind) {
                case ItemKind.KindType(origType) =>
                    match (origType.kind) {
                        case TypeKind.TypeKindObjCInterface(origIface) =>
                            for (m in iface.methods) { origIface.methods.add(m) }
                            for (m in iface.classMethods) { origIface.classMethods.add(m) }
                            for (p in iface.properties) { origIface.properties.add(p) }
                            origIface.dedupMethods()
                        case _ => ()
                    }
                case _ => ()
            }
        } else {
            // Original class not yet seen — register category as standalone item for codegen
            registerObjCInterface(ctx, className, iface)
        }
        return
    }

    // Register as a new item, or replace a forward declaration
    if (let Some(existingId) <- ctx.objcInterfaces.get(name)) {
        // Replace forward declaration with full definition
        let existingItem = ctx.resolveItem(existingId)
        match (existingItem.kind) {
            case ItemKind.KindType(existingType) =>
                match (existingType.kind) {
                    case TypeKind.TypeKindObjCInterface(existingIface) =>
                        if (existingIface.isForwardDeclaration) {
                            // Overwrite the forward decl with the full definition
                            existingType.kind = TypeKind.TypeKindObjCInterface(iface)
                            return
                        }
                    case _ => ()
                }
            case _ => ()
        }
    }

    registerObjCInterface(ctx, name, iface)
}

func parseObjCMethod(ctx: CjbindContext, cursor: clang.Cursor, isClassMethod: Bool, className: String): ?ObjCMethod {
    let selector = cursor.spelling()
    if (selector.isEmpty()) {
        return None
    }

    // Convert selector to Cangjie method name: "initWithFrame:" -> "initWithFrame"
    let cjName = selector.replace(":", "_").trimEnd([r'_'])

    let isInitMethod = selector == "init" || (selector.startsWith("init") && selector.size > 4 && selector[4] >= 65 && selector[4] <= 90)  // 'A'..'Z' in ASCII

    // Parse return type (with cursor fallback)
    let cursorType = cursor.curType()
    var retType = cursorType.retType()
    if (retType.isNone()) {
        retType = cursor.retType()
    }
    if (retType.isNone()) {
        return None
    }
    let retTy = retType.getOrThrow()

    // Check for variadic methods — skip with warning
    if (cursorType.isVariadic()) {
        eprintln("警告：跳过变参 ObjC 方法 ${className}.${selector}")
        return None
    }

    // Handle instancetype: map to the declaring class type
    let retId = if (retTy.spelling() == "instancetype") {
        // Look up or create the class type
        match (ctx.objcInterfaces.get(className)) {
            case Some(classId) => classId
            case None => Item.fromTyOrRef(retTy, cursor, None, ctx)
        }
    } else {
        Item.fromTyOrRef(retTy, cursor, None, ctx)
    }

    // Check return type nullability
    let returnsNullable = retTy.isNullable()

    // Parse parameters with nullability tracking
    let args = ArrayList<(?String, TypeId)>()
    let nullableParams = ArrayList<Bool>()
    cursor.visitContinue {
        child =>
        if (child.kind() == clang.CXCursorKind_CXCursor_ParmDecl) {
            let paramName = child.spelling()
            let paramType = child.curType()
            let paramTy = Item.fromTyOrRef(paramType, child, None, ctx)
            let pname: ?String = if (paramName.isEmpty()) { None } else { Some(paramName) }
            args.add((pname, paramTy))
            nullableParams.add(paramType.isNullable())
        }
    }

    let sig = FunctionSig(
        cjName,
        retId,
        args.toArray(),
        false,
        ClangAbi.Known(Abi.C)
    )

    let isOptional = cursor.isObjCOptional()

    return Some(ObjCMethod(cjName, selector, sig, isClassMethod: isClassMethod, isOptional: isOptional,
        returnsNullable: returnsNullable, nullableParams: nullableParams, isInitMethod: isInitMethod))
}

func parseObjCProperty(ctx: CjbindContext, cursor: clang.Cursor): ?ObjCProperty {
    let name = cursor.spelling()
    if (name.isEmpty()) {
        return None
    }

    let ty = cursor.curType()
    let tyId = Item.fromTyOrRef(ty, cursor, None, ctx)

    let attrs = cursor.objcPropertyAttributes()
    let isReadonly = (attrs & clang.CXObjCPropertyAttrKind_CXObjCPropertyAttr_readonly) != 0
    let isClassProp = (attrs & clang.CXObjCPropertyAttrKind_CXObjCPropertyAttr_class) != 0
    let isOptional = cursor.isObjCOptional()

    // Use clang API for getter/setter names
    var getterName = cursor.objcPropertyGetterName()
    if (getterName.isEmpty()) {
        getterName = name
    }

    let setterName: ?String = if (isReadonly) {
        None
    } else {
        var sn = cursor.objcPropertySetterName()
        if (sn.isEmpty()) {
            sn = "set" + name + ":"
        }
        Some(sn)
    }

    // Check nullability
    let isNullable = ty.isNullable()

    return Some(ObjCProperty(name, tyId, getterName, setterName: setterName,
                isClassProperty: isClassProp, isOptional: isOptional, isReadonly: isReadonly,
                isNullable: isNullable))
}
