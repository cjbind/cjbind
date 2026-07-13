package cjbind.ir

import std.collection.{ArrayList, HashSet}
import cjbind_token.*

import cjbind.clang
import cjbind.result.Result

public enum FunctionKind {
    KindFunction
    | KindMethod(MethodKind)

    public static func fromCursor(cursor: clang.Cursor): ?FunctionKind {
        let kind = cursor.kind()
        if (kind == clang.CXCursorKind_CXCursor_FunctionDecl) {
            return Some(FunctionKind.KindFunction)
        }
        if (kind == clang.CXCursorKind_CXCursor_Constructor) {
            return Some(FunctionKind.KindMethod(MethodKind.Constructor))
        }
        if (kind == clang.CXCursorKind_CXCursor_Destructor) {
            if (cursor.methodIsVirtual()) {
                return Some(FunctionKind.KindMethod(
                    MethodKind.VirtualDestructor(cursor.methodIsPureVirtual())
                ))
            }
            return Some(FunctionKind.KindMethod(MethodKind.Destructor))
        }
        if (kind == clang.CXCursorKind_CXCursor_CXXMethod) {
            if (cursor.methodIsVirtual()) {
                return Some(FunctionKind.KindMethod(
                    MethodKind.Virtual(cursor.methodIsPureVirtual())
                ))
            }
            if (cursor.methodIsStatic()) {
                return Some(FunctionKind.KindMethod(MethodKind.Static))
            }
            return Some(FunctionKind.KindMethod(MethodKind.Normal))
        }
        return None
    }
}

public enum FunctionLinkage {
    LinkageExternal
    | LinkageInternal
}

public class Function <: ClangSubItemParser<Function> {
    public let name: String
    public let signature: TypeId
    public let kind: FunctionKind
    public let linkage: FunctionLinkage
    public let mangledName: ?String
    public let constructorCanReturnByValue: Bool

    public init(
        name: String,
        signature: TypeId,
        kind: FunctionKind,
        linkage: FunctionLinkage,
        mangledName!: ?String = None,
        constructorCanReturnByValue!: Bool = false
    ) {
        this.name = name
        this.signature = signature
        this.kind = kind
        this.linkage = linkage
        this.mangledName = mangledName
        this.constructorCanReturnByValue = constructorCanReturnByValue
    }

    public func symbolName(): String {
        return this.mangledName ?? this.name
    }

    public static func parse(
        cursor: clang.Cursor,
        context: CjbindContext
    ): Result<ParseResult<Function>, ParseError> {
        let _kind = match (FunctionKind.fromCursor(cursor)) {
            case Some(v) => v
            case None => return Result.Err(ParseError.Continue)
        }
        let isCxx = usesCxxLanguage(context.options)

        if (cursor.accessSpecifier() == clang.CX_CXXAccessSpecifier_CX_CXXPrivate &&
            !context.options.generatePrivateFunctions) {
            return Result.Err(ParseError.Continue)
        }

        let originalName = cursor.spelling()
        if (originalName.startsWith("operator") && !clang.isValidIdentifier(originalName) &&
            !context.options.representCxxOperators) {
            return Result.Err(ParseError.Continue)
        }

        if (cursor.isDeletedFunction() && !context.options.generateDeletedFunctions) {
            return Result.Err(ParseError.Continue)
        }

        let visibility = cursor.visibility()
        if (visibility != clang.CXVisibilityKind_CXVisibility_Default) {
            return Result.Err(ParseError.Continue)
        }

        let linkage_c = cursor.linkage()
        let _linkage = match (linkage_c) {
            case 3 | 4 => FunctionLinkage.LinkageExternal  // CXLinkage_UniqueExternal | CXLinkage_External
            case 2 => FunctionLinkage.LinkageInternal  // CXLinkage_Internal
            case _ => return Result.Err(ParseError.Continue)
        }

        if (!context.options.generateInlineFunctions &&
            isCxx &&
            (cursor.isInlinedFunction() || cursor
            .definition()
            .map({
                d => d.isInlinedFunction()
            })
            .getOrDefault({=> false}))) {
            return Result.Err(ParseError.Continue)
        }

        let cursorKind = cursor.kind()
        let isCxxMember = cursorKind == clang.CXCursorKind_CXCursor_Constructor ||
            cursorKind == clang.CXCursorKind_CXCursor_Destructor ||
            cursorKind == clang.CXCursorKind_CXCursor_CXXMethod
        if (isCxxMember && cursor.lexicalParent() != cursor.semanticParent()) {
            return Result.Err(ParseError.Continue)
        }

        if (hasUnsupportedValueAbi(
            cursor.curType(),
            UIntNative(context.pointerWidth()),
            isCxx
        )) {
            eprintln("Warning: skipping '${cursor.displayName()}' because its value ABI cannot be represented safely")
            return Result.Err(ParseError.Continue)
        }

        let sige = Item.fromTy(cursor.curType(), cursor, None, context)
        let sig = match (sige) {
            case Ok(v) => v
            case Err(e) => return Result.Err(e)
        }

        var nname = cxxFunctionName(originalName)
        if (cursorKind == clang.CXCursorKind_CXCursor_Destructor) {
            if (nname.startsWith("~")) {
                nname = nname[1..]
            }
            nname += "_destructor"
        }

        let newFunc = Function(
            nname,
            sig,
            _kind,
            _linkage,
            mangledName: cursorMangling(cursor, isCxx, context.targetInfo),
            constructorCanReturnByValue: cursorKind == clang.CXCursorKind_CXCursor_Constructor &&
                cursor.semanticParent().curType().canonicalType().isPod() &&
                cursor.semanticParent().curType().canonicalType().align(UIntNative(context.pointerWidth())) <=
                    UIntNative(context.pointerWidth())
        )

        Result.Ok(ParseResult.New(newFunc, cursor))
    }
}

func cxxFunctionName(spelling: String): String {
    if (!spelling.startsWith("operator") || clang.isValidIdentifier(spelling)) {
        return spelling
    }

    let suffix = spelling["operator".size..].trimAscii()
    let operatorName = match (suffix) {
        case "=" => "equals"
        case "==" => "equal"
        case "!=" => "not_equal"
        case "+" => "add"
        case "-" => "subtract"
        case "*" => "multiply"
        case "/" => "divide"
        case "%" => "remainder"
        case "<" => "less"
        case ">" => "greater"
        case "<=" => "less_equal"
        case ">=" => "greater_equal"
        case "<<" => "shift_left"
        case ">>" => "shift_right"
        case "[]" => "index"
        case "()" => "call"
        case "++" => "increment"
        case "--" => "decrement"
        case "&" => "bit_and"
        case "|" => "bit_or"
        case "^" => "bit_xor"
        case "~" => "bit_not"
        case "!" => "not"
        case "&&" => "and"
        case "||" => "or"
        case "->" => "arrow"
        case "->*" => "arrow_star"
        case "new" => "new"
        case "new[]" => "new_array"
        case "delete" => "delete"
        case "delete[]" => "delete_array"
        case _ => "conversion"
    }
    return "operator_${operatorName}"
}

func cursorMangling(cursor: clang.Cursor, isCxx: Bool, targetInfo: clang.TargetInfo): ?String {
    let isConstructor = cursor.kind() == clang.CXCursorKind_CXCursor_Constructor
    let isDestructor = cursor.kind() == clang.CXCursorKind_CXCursor_Destructor
    if (let Ok(manglings) <- cursor.cxxManglings()) {
        var fallback: ?String = None
        var index = manglings.size
        while (index > 0) {
            index -= 1
            let mangling = manglings[index]
            if (mangling.isEmpty()) {
                continue
            }
            if (fallback.isNone()) {
                fallback = Some(mangling)
            }
            if ((isConstructor && isCompleteObjectVariant(mangling, manglings, 67u8)) ||
                (isDestructor && isCompleteObjectVariant(mangling, manglings, 68u8)) ||
                (!isConstructor && !isDestructor) ||
                ((isConstructor || isDestructor) && !mangling.startsWith("_Z") && manglings.size == 1)) {
                return normalizedCursorMangling(mangling, cursor, isCxx, targetInfo)
            }
        }
        if (let Some(mangling) <- fallback) {
            return normalizedCursorMangling(mangling, cursor, isCxx, targetInfo)
        }
    }

    let mangling = cursor.mangling()
    if (mangling.isEmpty()) {
        return None
    }
    var selected = mangling
    let isItanium = match (targetInfo.abi) {
        case clang.ABIKind.GenericItanium => true
        case clang.ABIKind.Microsoft => false
    }
    if (isDestructor && isItanium) {
        if (let Some(position) <- mangling.lastIndexOf("D0")) {
            selected = mangling[..(position + 1)] + "1" + mangling[(position + 2)..]
        }
    }
    return normalizedCursorMangling(selected, cursor, isCxx, targetInfo)
}

func normalizedCursorMangling(
    mangling: String,
    cursor: clang.Cursor,
    isCxx: Bool,
    targetInfo: clang.TargetInfo
): ?String {
    let isStdcall = getAbi(cursor.curType().callConv()).isStdcall()
    let normalized = normalizePlatformMangling(
        mangling,
        isStdcall,
        targetInfo.triple,
        targetInfo.pointerWidth
    )
    if (normalized.isEmpty() || normalized == cursor.spelling()) {
        return None
    }
    if (!isCxx && !clang.isValidIdentifier(normalized)) {
        return None
    }
    return Some(normalized)
}

func normalizePlatformMangling(
    mangling: String,
    isStdcall: Bool,
    targetTriple: String,
    pointerWidth: Int32
): String {
    var normalized = mangling
    let hasPlatformPrefix = targetTriple.contains("apple") || targetTriple.contains("darwin") ||
        targetTriple.contains("macos") || targetTriple.contains("ios") ||
        targetTriple.contains("tvos") || targetTriple.contains("watchos") ||
        targetTriple.contains("visionos") ||
        (pointerWidth == 32 && (targetTriple.contains("windows") ||
        targetTriple.contains("mingw") || targetTriple.contains("win32")))
    if (hasPlatformPrefix && normalized.startsWith("_") && normalized.size > 1) {
        normalized = normalized[1..]
    }
    if (isStdcall) {
        if (let Some(suffix) <- normalized.lastIndexOf("@")) {
            normalized = normalized[..suffix]
        }
    }
    return normalized
}

func isCompleteObjectVariant(candidate: String, manglings: Array<String>, prefix: UInt8): Bool {
    for (other in manglings) {
        if (candidate == other || candidate.size != other.size) {
            continue
        }
        var differences = 0
        var validVariantDifference = false
        for (index in 0..candidate.size) {
            if (candidate[index] == other[index]) {
                continue
            }
            differences += 1
            if (differences > 1 || index == 0 || candidate[index - 1] != prefix ||
                other[index - 1] != prefix || candidate[index] != 49u8 ||
                (other[index] != 48u8 && other[index] != 50u8)) {
                validVariantDifference = false
                break
            }
            validVariantDifference = true
        }
        if (differences == 1 && validVariantDifference) {
            return true
        }
    }
    return false
}

public func hasOpaqueValueAbi(signature: FunctionSig, ctx: CjbindContext): Bool {
    let visiting = HashSet<ItemId>()
    if (typeHasOpaqueValueAbi(signature.returnType, ctx, visiting)) {
        return true
    }
    for ((_, argument) in signature.argumentTypes) {
        if (typeHasOpaqueValueAbi(argument, ctx, visiting)) {
            return true
        }
    }
    return false
}

func typeHasOpaqueValueAbi(typeId: TypeId, ctx: CjbindContext, visiting: HashSet<ItemId>): Bool {
    let item = typeId
        .intoResolver()
        .throughTypeRefs()
        .throughTypeAliases()
        .resolve(ctx)
    if (item.isOpaque(ctx, ())) {
        return true
    }
    if (visiting.contains(item.id)) {
        return false
    }

    let ty = item.kind.expectType()
    return match (ty.kind) {
        case TypeKind.TypeKindArray(inner, _) => typeHasOpaqueValueAbi(inner, ctx, visiting)
        case TypeKind.TypeKindVector(_, _) |
            TypeKind.TypeKindComplex(_) |
            TypeKind.TypeKindTemplateInstantiation(_) |
            TypeKind.TypeKindTypeParam => true
        case TypeKind.TypeKindComp(comp) =>
            if (comp.isUnion()) {
                return true
            }
            visiting.add(item.id)
            for (field in comp.getFields()) {
                match (field) {
                    case Field.DataMember(data) =>
                        if (typeHasOpaqueValueAbi(data.ty, ctx, visiting)) {
                            return true
                        }
                    case Field.Bitfields(_) => return true
                }
            }
            for (base in comp.baseMembers) {
                if (typeHasOpaqueValueAbi(base.ty, ctx, visiting)) {
                    return true
                }
            }
            false
        case _ => false
    }
}

func hasUnsupportedValueAbi(functionType: clang.Type, pointerWidth: UIntNative, cxx: Bool): Bool {
    if (let Some(returnType) <- functionType.retType()) {
        if (isUnsupportedValueType(returnType, pointerWidth, cxx)) {
            return true
        }
    }
    if (let Some(arguments) <- functionType.args()) {
        for (argument in arguments) {
            if (isUnsupportedValueType(argument, pointerWidth, cxx)) {
                return true
            }
        }
    }
    return false
}

func isUnsupportedValueType(ty: clang.Type, pointerWidth: UIntNative, cxx: Bool): Bool {
    let canonical = ty.canonicalType()
    let kind = canonical.kind()
    if (kind == clang.CXTypeKind_CXType_Record) {
        return canonical.align(pointerWidth) > pointerWidth ||
            (cxx && (!canonical.isPod() || recordHasUnsupportedValueLayout(canonical)))
    }
    if (kind == clang.CXTypeKind_CXType_Pointer) {
        if (let Some(pointee) <- canonical.pointeeType()) {
            let pointeeKind = pointee.kind()
            if (pointeeKind == clang.CXTypeKind_CXType_FunctionProto ||
                pointeeKind == clang.CXTypeKind_CXType_FunctionNoProto) {
                return hasUnsupportedValueAbi(pointee, pointerWidth, cxx)
            }
        }
    }
    return kind == clang.CXTypeKind_CXType_Int128 ||
        kind == clang.CXTypeKind_CXType_UInt128 ||
        kind == clang.CXTypeKind_CXType_Float128 ||
        kind == clang.CXTypeKind_CXType_Complex ||
        kind == clang.CXTypeKind_CXType_Vector ||
        kind == clang.CXTypeKind_CXType_ExtVector ||
        (kind == clang.CXTypeKind_CXType_LongDouble && canonical.size(pointerWidth) > 8)
}

func recordHasUnsupportedValueLayout(ty: clang.Type): Bool {
    return recordHasUnsupportedValueLayoutInner(ty, false)
}

func recordHasUnsupportedValueLayoutInner(ty: clang.Type, requireAccessibleCopy: Bool): Bool {
    let declaration = ty.declaration()
    if (declaration.kind() == clang.CXCursorKind_CXCursor_UnionDecl) {
        return true
    }
    let unsupported = Box(false)
    declaration.visit {
        child =>
        let kind = child.kind()
        let unavailableSpecialMember = kind == clang.CXCursorKind_CXCursor_Constructor &&
            (child.constructorIsCopy() || child.constructorIsMove()) &&
            (child.isDeletedFunction() || (requireAccessibleCopy && !child.isPublic()))
        let unsupportedNestedRecord = kind == clang.CXCursorKind_CXCursor_FieldDecl &&
            fieldContainsUnsupportedRecord(child.curType())
        if (kind == clang.CXCursorKind_CXCursor_PackedAttr ||
            kind == clang.CXCursorKind_CXCursor_CXXBaseSpecifier ||
            (kind == clang.CXCursorKind_CXCursor_FieldDecl && child.isBitField()) ||
            unavailableSpecialMember || unsupportedNestedRecord) {
            unsupported.value = true
            return clang.CXChildVisitResult_CXChildVisit_Break
        }
        return clang.CXChildVisitResult_CXChildVisit_Continue
    }
    return unsupported.value
}

func fieldContainsUnsupportedRecord(ty: clang.Type): Bool {
    let canonical = ty.canonicalType()
    let kind = canonical.kind()
    if (kind == clang.CXTypeKind_CXType_Record) {
        return recordHasUnsupportedValueLayoutInner(canonical, true)
    }
    if (kind == clang.CXTypeKind_CXType_ConstantArray ||
        kind == clang.CXTypeKind_CXType_IncompleteArray ||
        kind == clang.CXTypeKind_CXType_VariableArray ||
        kind == clang.CXTypeKind_CXType_DependentSizedArray) {
        if (let Some(element) <- canonical.elemType()) {
            return fieldContainsUnsupportedRecord(element)
        }
    }
    return false
}

public enum Abi <: ToTokens {
    C
    | Stdcall
    | Fastcall
    | ThisCall
    | Vectorcall
    | Aapcs
    | AapcsVfp
    | Win64
    | SysV64

    public func appendToStream(tokens: TokenStream): Unit {
        match (this) {
            case Stdcall => tokens.appendLiteral("@CallingConv[STDCALL]")
            case _ => tokens.appendLiteral("@CallingConv[CDECL]")
        }
    }
}

public enum ClangAbi <: ToTokens {
    Known(Abi)
    | Unknown(clang.CXCallingConv)

    public func appendToStream(tokens: TokenStream): Unit {
        match (this) {
            case Known(v) => v.appendToStream(tokens)
            case Unknown(_) =>
                // Fall back to C calling convention for unknown ABIs
                Abi.C.appendToStream(tokens)
        }
    }

    public func isStdcall(): Bool {
        return match (this) {
            case Known(Abi.Stdcall) => true
            case _ => false
        }
    }

    public func isCFuncCompatible(): Bool {
        return match (this) {
            case Known(Abi.C) => true
            case _ => false
        }
    }

    public func isCFuncCompatibleForTarget(targetInfo: clang.TargetInfo): Bool {
        return match (this) {
            case Known(Abi.C) => true
            case Known(Abi.Win64) => targetInfo.pointerWidth == 64 &&
                (targetInfo.triple.contains("windows") || targetInfo.triple.contains("mingw") ||
                targetInfo.triple.contains("win32"))
            case Known(Abi.SysV64) => targetInfo.pointerWidth == 64 &&
                targetInfo.triple.contains("x86_64") && !targetInfo.triple.contains("windows") &&
                !targetInfo.triple.contains("mingw") && !targetInfo.triple.contains("win32")
            case Known(Abi.Aapcs) => (targetInfo.triple.startsWith("arm") ||
                targetInfo.triple.startsWith("thumb")) && !targetInfo.triple.contains("eabihf")
            case Known(Abi.AapcsVfp) => (targetInfo.triple.startsWith("arm") ||
                targetInfo.triple.startsWith("thumb")) && targetInfo.triple.contains("eabihf")
            case _ => false
        }
    }

    public func isForeignCompatible(): Bool {
        return this.isCFuncCompatible() || this.isStdcall()
    }

    public func isForeignCompatibleForTarget(targetInfo: clang.TargetInfo): Bool {
        return this.isCFuncCompatibleForTarget(targetInfo) || this.isStdcall()
    }
}

func getAbi(cc: clang.CXCallingConv): ClangAbi {
    if (cc == clang.CXCallingConv_CXCallingConv_C || cc == clang.CXCallingConv_CXCallingConv_Default) {
        return Known(Abi.C)
    }
    if (cc == clang.CXCallingConv_CXCallingConv_X86StdCall) {
        return Known(Abi.Stdcall)
    }
    if (cc == clang.CXCallingConv_CXCallingConv_X86FastCall) {
        return Known(Abi.Fastcall)
    }
    if (cc == clang.CXCallingConv_CXCallingConv_X86ThisCall) {
        return Known(Abi.ThisCall)
    }
    if (cc == clang.CXCallingConv_CXCallingConv_X86VectorCall || cc == clang.CXCallingConv_CXCallingConv_AArch64VectorCall) {
        return Known(Abi.Vectorcall)
    }
    if (cc == clang.CXCallingConv_CXCallingConv_AAPCS) {
        return Known(Abi.Aapcs)
    }
    if (cc == clang.CXCallingConv_CXCallingConv_AAPCS_VFP) {
        return Known(Abi.AapcsVfp)
    }
    if (cc == clang.CXCallingConv_CXCallingConv_X86_64Win64) {
        return Known(Abi.Win64)
    }
    if (cc == clang.CXCallingConv_CXCallingConv_X86_64SysV) {
        return Known(Abi.SysV64)
    }
    return Unknown(cc)
}

func argsFromTyAndCursor(
    ty: clang.Type,
    cursor: clang.Cursor,
    ctx: CjbindContext
): ArrayList<(?String, TypeId)> {
    let cursorArgs = cursor.args().getOrDefault() {=> return Array<clang.Cursor>()}
    let typeArgs = ty.args().getOrDefault() {=> return Array<clang.Type>()}

    let cursorArgsIt = cursorArgs.iterator()
    let typeArgsIt = typeArgs.iterator()

    let result = ArrayList<(?String, TypeId)>()

    while (true) {
        let argCur = cursorArgsIt.next()
        let argTy = typeArgsIt.next()

        if (argCur.isNone() && argTy.isNone()) {
            break
        }

        let name: ?String = match (argCur) {
            case Some(a) =>
                let spelling = a.spelling()
                if (!spelling.isEmpty()) {
                    Some(spelling)
                } else {
                    None
                }
            case _ => None
        }

        let ncursor = match (argCur) {
            case Some(v) => v
            case None => cursor
        }

        let nty = match (argTy) {
            case Some(v) => v
            case None => cursor.curType()
        }

        result.add((name, Item.fromTyOrRef(nty, ncursor, None, ctx)))
    }

    return result
}

public class FunctionSig <: Trace<Tracer, Unit> {
    public let name: String
    public let returnType: TypeId
    public let argumentTypes: Array<(?String, TypeId)>

    private let isVariadic: Bool
    public let valueAbiUnsupported: Bool

    public let abi: ClangAbi

    public init(
        name: String,
        returnType: TypeId,
        argumentTypes: Array<(?String, TypeId)>,
        isVariadic: Bool,
        abi: ClangAbi,
        valueAbiUnsupported!: Bool = false
    ) {
        this.name = name
        this.returnType = returnType
        this.argumentTypes = argumentTypes
        this.isVariadic = isVariadic
        this.abi = abi
        this.valueAbiUnsupported = valueAbiUnsupported
    }

    // cjlint-ignore -start !G.FUN.01
    public static func fromTy(
        ty: clang.Type,
        cursor: clang.Cursor,
        ctx: CjbindContext
    ): Result<FunctionSig, ParseError> {
        let kind = cursor.kind()
        let spelling = cursor.spelling()

        let ncursor = if (cursor.isValid()) {
            cursor
        } else {
            ty.declaration()
        }

        let argsWithoutReceiver = if (kind == clang.CXCursorKind_CXCursor_FunctionDecl ||
            kind == clang.CXCursorKind_CXCursor_Constructor ||
            kind == clang.CXCursorKind_CXCursor_Destructor ||
            kind == clang.CXCursorKind_CXCursor_CXXMethod) {
            argsFromTyAndCursor(ty, cursor, ctx)
        } else {
            let targs: ArrayList<(?String, TypeId)> = ArrayList()
            cursor.visit {
                c =>
                if (c.kind() == clang.CXCursorKind_CXCursor_ParmDecl) {
                    let tty = Item.fromTyOrRef(
                        c.curType(),
                        c,
                        None,
                        ctx
                    )
                    let _spelling = c.spelling()
                    let _name: ?String = if (!_spelling.isEmpty()) {
                        Some(_spelling)
                    } else {
                        None
                    }
                    targs.add((_name, tty))
                }
                return clang.CXChildVisitResult_CXChildVisit_Continue
            }

            if (targs.isEmpty()) {
                argsFromTyAndCursor(ty, ncursor, ctx)
            } else {
                targs
            }
        }

        let isMethod = kind == clang.CXCursorKind_CXCursor_CXXMethod
        let isConstructor = kind == clang.CXCursorKind_CXCursor_Constructor
        let isDestructor = kind == clang.CXCursorKind_CXCursor_Destructor
        let isStatic = isMethod && cursor.methodIsStatic()
        let isVirtual = (isMethod || isDestructor) && cursor.methodIsVirtual()
        let args = if ((isMethod || isConstructor || isDestructor) && !isStatic) {
            let receiverInner = if (isMethod && isVirtual && !ctx.options.useSpecificVirtualFunctionReceiver) {
                Item.builtinType(TypeKind.TypeKindVoid, false, ctx)
            } else {
                let parent = cursor.semanticParent()
                match (Item.parse(parent, None, ctx)) {
                    case Ok(id) => id
                    case Err(err) => return Err(err)
                }
            }
            let receiverType = Item.builtinType(TypeKind.TypeKindPointer(receiverInner), false, ctx)
            let withReceiver = ArrayList<(?String, TypeId)>()
            withReceiver.add((Some("this"), receiverType))
            withReceiver.add(all: argsWithoutReceiver)
            withReceiver
        } else {
            argsWithoutReceiver
        }

        let tyRetType = match(ty.retType()) {
            case Some(v) => v
            case None => return Err(ParseError.Continue)
        }

        let ret = Item.fromTyOrRef(tyRetType, cursor, None, ctx)

        var callConv = ty.callConv()
        if (let Some(tty) <- cursor.curType().canonicalType().pointeeType()) {
            let cursorCallConv = tty.callConv()
            if (cursorCallConv != clang.CXCallingConv_CXCallingConv_Invalid) {
                callConv = cursorCallConv
            }
        }

        let curAbi = getAbi(callConv)

        return Result.Ok(FunctionSig(
            spelling,
            ret,
            args.toArray(),
            ty.isVariadic(),
            curAbi,
            valueAbiUnsupported: hasUnsupportedValueAbi(
                ty,
                UIntNative(ctx.pointerWidth()),
                usesCxxLanguage(ctx.options)
            )
        ))
    }
    // cjlint-ignore -end

    // cjlint-ignore -start !G.ITF.04
    public func trace(_: CjbindContext, tracer: Tracer, _: Unit): Unit {
        tracer.visitKind(this.returnType, EdgeKind.FunctionReturnEdge)

        for (arg in this.argumentTypes) {
            tracer.visitKind(arg[1], EdgeKind.FunctionParameterEdge)
        }
    }
    // cjlint-ignore -end

    // Returns false for C functions with variadic args but no named parameters
    // (e.g., `f(...)`), as these cannot be represented in Cangjie FFI.
    public func getIsVariadic(): Bool {
        return this.isVariadic && !this.argumentTypes.isEmpty()
    }

    public func isVariadicFunction(): Bool {
        return this.isVariadic
    }
}
