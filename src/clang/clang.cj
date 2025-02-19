package cjbind.clang

import std.collection.{HashMap, ArrayList}

import cjbind.result.Result

func cxstringToString(x: CXString): String {
    if (x.data.isNull()) {
        return ""
    }

    unsafe {
        let strPtr = clang_getCString(x)
        let str = strPtr.toString()

        clang_disposeString(x)
        return str
    }
}

public func getClangVersion(): String {
    unsafe {
        cxstringToString(clang_getClangVersion())
    }
}

// workaround cfunc capture limit
// thus we can only work as single thread
var CursorVisitCallback: HashMap<Int64, ?(Cursor) -> CXChildVisitResult> = HashMap<Int64, ?(Cursor) -> CXChildVisitResult>()
var CurrentCallbackId = 0

func getNextCallbackId(): Int64 {
    let id = CurrentCallbackId
    CurrentCallbackId += 1
    return id
}

public class Cursor <: ToString & Hashable & Equatable<Cursor> {
    let x: CXCursor

    init(x: CXCursor) {
        this.x = x
    }

    /// Get the Unified Symbol Resolution for this cursor's referent, if
    /// available.
    ///
    /// The USR can be used to compare entities across translation units.
    public func usr(): Option<String> {
        unsafe {
            let s = cxstringToString(clang_getCursorUSR(x))
            if (s.isEmpty()) {
                return None
            } else {
                return Some(s)
            }
        }
    }

    public func isDeclaration(): Bool {
        unsafe {
            return clang_isDeclaration(clang_getCursorKind(x)) != 0
        }
    }

    public func isAnonymous(): Bool {
        unsafe {
            return clang_Cursor_isAnonymous(x) != 0
        }
    }

    /// Get this cursor's referent's spelling.
    public func spelling(): String {
        unsafe {
            return cxstringToString(clang_getCursorSpelling(x))
        }
    }

    /// Get this cursor's referent's display name.
    ///
    /// This is not necessarily a valid identifier. It includes extra
    /// information, such as parameters for a function, etc.
    public func displayName(): String {
        unsafe {
            return cxstringToString(clang_getCursorDisplayName(x))
        }
    }

    /// Get the mangled name of this cursor's referent.
    public func mangling(): String {
        unsafe {
            return cxstringToString(clang_Cursor_getMangling(x))
        }
    }

    public func location(): SourceLocation {
        unsafe {
            return SourceLocation(clang_getCursorLocation(x))
        }
    }

    public func isBuiltin(): Bool {
        let (file, _, _, _) = this.location().location()
        return file.name().isNone()
    }

    public func isInSystemHeader(): Bool {
        let ex = this.extent()

        unsafe {
            if (clang_Range_isNull(ex) == 0) {
                let start = clang_getRangeStart(ex)
                let ret = clang_Location_isInSystemHeader(start) != 0
                return ret
            } else {
                return false
            }
        }
    }

    public func translationUnit(): Cursor {
        unsafe {
            let tu = clang_Cursor_getTranslationUnit(x)
            let cursor = Cursor(clang_getTranslationUnitCursor(tu))
            return cursor
        }
    }

    public func isMacroFunctionLike(): Bool {
        unsafe {
            return clang_Cursor_isMacroFunctionLike(x) != 0
        }
    }

    public func kind(): CXCursorKind {
        return this.x.kind
    }

    public func isDefinition(): Bool {
        unsafe {
            return clang_isCursorDefinition(x) != 0
        }
    }

    public func isValid(): Bool {
        unsafe {
            return clang_isInvalid(this.kind()) == 0
        }
    }

    func extent(): CXSourceRange {
        unsafe {
            return clang_getCursorExtent(x)
        }
    }

    public func rawComment(): Option<String> {
        let s = unsafe {
            cxstringToString(clang_Cursor_getRawCommentText(x))
        }
        if (s.size == 0) {
            return None
        }
        return Some(s)
    }

    public func comment(): Comment {
        unsafe {
            return Comment(clang_Cursor_getParsedComment(x))
        }
    }

    public func curType(): Type {
        unsafe {
            return Type(clang_getCursorType(x))
        }
    }

    public func definition(): Option<Cursor> {
        unsafe {
            let ret = Cursor(clang_getCursorDefinition(x))
            if (ret.isValid() && ret.kind() != CXCursorKind_CXCursor_NoDeclFound) {
                return Some(ret)
            } else {
                return None
            }
        }
    }

    public func referenced(): Option<Cursor> {
        unsafe {
            let ret = Cursor(clang_getCursorReferenced(x))
            if (ret.isValid()) {
                return Some(ret)
            } else {
                None
            }
        }
    }

    public func canonical(): Cursor {
        unsafe {
            return Cursor(clang_getCanonicalCursor(x))
        }
    }

    public func linkage(): CXLinkageKind {
        unsafe {
            return clang_getCursorLinkage(x)
        }
    }

    public func visibility(): CXVisibilityKind {
        unsafe {
            return clang_getCursorVisibility(x)
        }
    }

    public func isInlinedFunction(): Bool {
        unsafe {
            clang_Cursor_isFunctionInlined(x) != 0
        }
    }

    public func semanticParent(): Cursor {
        this.fallibleSemanticParent().getOrThrow()
    }

    public func fallibleSemanticParent(): ?Cursor {
        let pp = unsafe {
            Cursor(clang_getCursorSemanticParent(x))
        }

        if (pp == this || !pp.isValid()) {
            return None
        }
        return Some(pp)
    }

    public func numArgs(): Result<UInt32, Unit> {
        unsafe {
            let w = clang_Cursor_getNumArguments(x)
            if (w == -1) {
                return Result<UInt32, Unit>.Err(())
            } else {
                return Result<UInt32, Unit>.Ok(UInt32(w))
            }
        }
    }

    public func args(): ?Array<Cursor> {
        let numArgs = this.numArgs().ok()
        if (let Some(n) <- numArgs) {
            return Array<Cursor>(Int64(n)) {
                i => unsafe {
                    let arg = clang_Cursor_getArgument(x, UInt32(i))
                    return Cursor(arg)
                }
            }
        }
        return None
    }

    public func typedefType(): ?Type {
        let inner = unsafe {
            Type(clang_getTypedefDeclUnderlyingType(x))
        }
        if (inner.isValid()) {
            return Some(inner)
        } else {
            return None
        }
    }

    public func enumType(): ?Type {
        unsafe {
            let t = Type(clang_getEnumDeclIntegerType(x))
            if (t.isValid()) {
                return Some(t)
            } else {
                return None
            }
        }
    }

    public func enumValBoolean(): ?Bool {
        unsafe {
            if (this.kind() == CXCursorKind_CXCursor_EnumConstantDecl) {
                let v = clang_getEnumConstantDeclValue(x) != 0
                return Some(v)
            } else {
                return None
            }
        }
    }

    public func enumValSigned(): ?Int64 {
        unsafe {
            if (this.kind() == CXCursorKind_CXCursor_EnumConstantDecl) {
                let v = clang_getEnumConstantDeclValue(x)
                return Some(Int64(v))
            } else {
                None
            }
        }
    }

    public func enumValUnsigned(): ?UInt64 {
        unsafe {
            if (this.kind() == CXCursorKind_CXCursor_EnumConstantDecl) {
                let v = clang_getEnumConstantDeclValue(x)
                return Some(UInt64(v))
            } else {
                None
            }
        }
    }

    public func bitWidth(): ?UInt32 {
        unsafe {
            let w = clang_getFieldDeclBitWidth(x)
            if (w == -1) {
                None
            } else {
                Some(UInt32(w))
            }
        }
    }

    public func isBitField(): Bool {
        unsafe {
            return clang_Cursor_isBitField(x) != 0
        }
    }

    public func offsetOfFieldRaw(): Int64 {
        unsafe {
            return clang_Cursor_getOffsetOfField(x)
        }
    }

    public func evalutate(): EvalResult {
        return EvalResult(this)
    }

    public func getIncludedFileName(): ?String {
        unsafe {
            let file = clang_getIncludedFile(x)
            if (file.isNull()) {
                return None
            } else {
                return cxstringToString(clang_getFileName(file))
            }
        }
    }

    public func toString(): String {
        return "Cursor ${this.spelling()}"
    }

    public func hashCode(): Int64 {
        unsafe {
            return Int64(clang_hashCursor(x))
        }
    }

    public func visitContinue(visitor: (Cursor) -> Unit) {
        this.visit {
            c =>
            visitor(c)
            return CXChildVisitResult_CXChildVisit_Continue
        }
    }

    public func visit(visitor: (Cursor) -> CXChildVisitResult) {
        let cbId = getNextCallbackId()
        CursorVisitCallback.add(cbId, visitor)

        unsafe {
            let cb: CFunc<(CXCursor, CXCursor, CPointer<Unit>) -> CXChildVisitResult> = {
                cxcs, _, cbIdData => 
                    let id = CPointer<Int64>(cbIdData).read()

                    let cb = CursorVisitCallback[id].getOrThrow()
                    cb(Cursor(cxcs))
            }

            let cbIdData = LibC.malloc<Int64>(count: 1)
            cbIdData.write(cbId)

            clang_visitChildren(x, cb, CPointer<Unit>(cbIdData))

            LibC.free<Int64>(cbIdData)
        }

        CursorVisitCallback.remove(cbId)
    }

    // cjlint-ignore -start !G.OPR.01 eq
    public operator func ==(that: Cursor): Bool {
        unsafe {
            return clang_equalCursors(x, that.x) != 0
        }
    }
    // cjlint-ignore -end eq
}

public class Type <: Equatable<Type> {
    let x: CXType
    init(x: CXType) {
        this.x = x
    }

    public func declaration(): Cursor {
        unsafe {
            return Cursor(clang_getTypeDeclaration(x))
        }
    }

    public func kind(): CXTypeKind {
        return this.x.kind
    }

    public func canonicalType(): Type {
        unsafe {
            return Type(clang_getCanonicalType(x))
        }
    }

    public func isVariadic(): Bool {
        unsafe {
            return clang_isFunctionTypeVariadic(x) != 0
        }
    }

    public func retType(): ?Type {
        unsafe {
            let ret = Type(clang_getResultType(x))
            if (ret.isValid()) {
                return Some(ret)
            } else {
                return None
            }
        }
    }

    public func isValid(): Bool {
        return this.x.kind != CXTypeKind_CXType_Invalid
    }

    public func elemType(): ?Type {
        unsafe {
            let cur = Type(clang_getElementType(x))
            if (cur.isValid()) {
                return Some(cur)
            } else {
                return None
            }
        }
    }

    public func isConst(): Bool {
        unsafe {
            return clang_isConstQualifiedType(x) != 0
        }
    }

    public func spelling(): String {
        unsafe {
            return cxstringToString(clang_getTypeSpelling(x))
        }
    }

    public func fallibleLayoutArgs(ptrSize: UIntNative): Result<(Int64, Int64), Int64> {
        let size = this.clangSizeOf(ptrSize)
        if (size < 0) {
            return Result.Err(size)
        }

        let align = this.clangAlignOf(ptrSize)
        if (align < 0) {
            return Result.Err(align)
        }
        return Result.Ok((size, align))
    }

    public func isNonDeductibleAutoType(): Bool {
        return this.canonicalType() == this
    }

    public func size(ptrSize: UIntNative): UIntNative {
        let val = this.clangSizeOf(ptrSize)
        if (val < 0) {
            return 0
        } else {
            return UIntNative(val)
        }
    }

    public func clangSizeOf(ptrSize: UIntNative): Int64 {
        let k = this.kind()
        if (k == CXTypeKind_CXType_RValueReference || k == CXTypeKind_CXType_LValueReference) {
            return Int64(ptrSize)
        }

        if (k == CXTypeKind_CXType_Auto) {
            if (this.isNonDeductibleAutoType()) {
                return -6
            }
        }

        unsafe {
            return clang_Type_getSizeOf(x)
        }
    }

    public func align(ptrSize: UIntNative): UIntNative {
        let val = this.clangAlignOf(ptrSize)
        if (val < 0) {
            return 0
        } else {
            return UIntNative(val)
        }
    }

    public func clangAlignOf(ptrSize: UIntNative): Int64 {
        let k = this.kind()
        if (k == CXTypeKind_CXType_RValueReference || k == CXTypeKind_CXType_LValueReference) {
            return Int64(ptrSize)
        }

        if (k == CXTypeKind_CXType_Auto) {
            return -6
        }

        unsafe {
            return clang_Type_getAlignOf(x)
        }
    }

    public func args(): ?Array<Type> {
        let numArgs = this.numArgs().ok()
        match (numArgs) {
            case Some(n) => return Array<Type>(Int64(n)) {
                i => unsafe {
                    let arg = clang_getArgType(x, UInt32(i))
                    return Type(arg)
                }
            }
            case None => return None
        }
    }

    public func numArgs(): Result<UInt32, Unit> {
        unsafe {
            let w = clang_getNumArgTypes(x)
            if (w == -1) {
                Err(())
            } else {
                Ok(UInt32(w))
            }
        }
    }

    public func numElements(): ?UIntNative {
        let num = unsafe {
            clang_getNumElements(x)
        }
        if (num != -1) {
            return UIntNative(num)
        } else {
            return None
        }
    }

    public func canonicalDeclaration(_: ?Cursor): ?CanonicalTypeDeclaration {
        let decl = this.declaration()
        let canonical = decl.canonical()
        if (canonical.isValid() && canonical.kind() != CXCursorKind_CXCursor_NoDeclFound) {
            return CanonicalTypeDeclaration(this, canonical)
        } else {
            return None
        }
    }

    public func callConv(): CXCallingConv {
        unsafe {
            return clang_getFunctionTypeCallingConv(x)
        }
    }

    public func pointeeType(): ?Type {
        let k = this.kind()
        if (k == CXTypeKind_CXType_Pointer || k == CXTypeKind_CXType_RValueReference || k == CXTypeKind_CXType_LValueReference || k ==
            CXTypeKind_CXType_MemberPointer || k == CXTypeKind_CXType_BlockPointer) {
            unsafe {
                let p = Type(clang_getPointeeType(x))
                if (!p.isValid()) {
                    throw Exception("clang_getPointeeType failed")
                }
                return Some(p)
            }
        }
        return None
    }

    public func named(): Type {
        unsafe {
            return Type(clang_Type_getNamedType(x))
        }
    }

    public func atomicValueType(): Type {
        unsafe {
            return Type(clang_Type_getValueType(x))
        }
    }

    // cjlint-ignore -start !G.OPR.01 eq
    public operator func ==(rhs: Type): Bool {
        unsafe {
            return clang_equalTypes(x, rhs.x) != 0
        }
    }
    // cjlint-ignore -end eq
}

public class Comment {
    let x: CXComment
    init(x: CXComment) {
        this.x = x
    }
}

public class SourceLocation {
    let x: CXSourceLocation
    init(x: CXSourceLocation) {
        this.x = x
    }

    public func location(): (File, UInt32, UInt32, UInt32) {
        unsafe {
            var file = CXFile()
            var line = UInt32(0)
            var column = UInt32(0)
            var offset = UInt32(0)
            clang_getFileLocation(
                this.x,
                inout file,
                inout line,
                inout column,
                inout offset
            )
            return (File(file), line, column, offset)
        }
    }
}

public class File {
    let x: CXFile
    init(x: CXFile) {
        this.x = x
    }

    public func name(): Option<String> {
        if (x.isNull()) {
            return None
        }

        unsafe {
            return cxstringToString(clang_getFileName(x))
        }
    }
}

public class Index {
    let x: CXIndex

    public init(pch: Bool, diag: Bool) {
        let pch_c: Int32 = if (pch) {
            1
        } else {
            0
        }
        let diag_c: Int32 = if (diag) {
            1
        } else {
            0
        }

        unsafe {
            this.x = clang_createIndex(pch_c, diag_c)
        }
    }

    ~init() {
        unsafe {
            clang_disposeIndex(x)
        }
    }
}

extend CString {
    func toPtr(): CPointer<Int8> {
        return CPointer<Int8>(this.getChars())
    }
}

public class TranslationUnit {
    let x: CXTranslationUnit

    public init(
        ix: Index,
        file: String,
        cmdArgs: Array<String>,
        options: CXTranslationUnit_Flags
    ) {
        unsafe {
            let fname = LibC.mallocCString(file)

            let releaser = ArrayList<() -> Unit>()

            let c_args = LibC.malloc<CString>(count: cmdArgs.size)
            releaser.add({=> LibC.free(c_args)})

            for (i in 0..cmdArgs.size) {
                let s = LibC.mallocCString(cmdArgs[i])
                let ptr = c_args + i
                ptr.write(s)
                releaser.add({=> LibC.free(s)})
            }

            let unsaved = CPointer<CXUnsavedFile>()

            var tu = CXTranslationUnit()

            let code = clang_parseTranslationUnit2(
                ix.x,
                fname,
                c_args,
                Int32(cmdArgs.size),
                unsaved,
                0,
                UInt32(options),
                inout tu
            )

            if (tu.isNull()) {
                throw Exception("parse failed ${code}")
            }

            this.x = tu

            for(v in releaser) {
                v()
            }
        }
    }

    public func diags(): Array<Diagnostic> {
        unsafe {
            let cnt = clang_getNumDiagnostics(x)
            return Array<Diagnostic>(Int64(cnt)) {
                i => return Diagnostic(clang_getDiagnostic(this.x, UInt32(i)))
            }
        }
    }

    public func cursor(): Cursor {
        unsafe {
            return Cursor(clang_getTranslationUnitCursor(x))
        }
    }

    public func isNull(): Bool {
        return this.x.isNull()
    }

    ~init() {
        unsafe {
            clang_disposeTranslationUnit(x)
        }
    }
}

public enum ABIKind {
    GenericItanium
    // Microsoft not supported yet
}

public class TargetInfo {
    public let triple: String
    public let pointerWidth: Int32
    public let abi: ABIKind

    public init(tu: TranslationUnit) {
        unsafe {
            let ti = clang_getTranslationUnitTargetInfo(tu.x)
            this.triple = cxstringToString(clang_TargetInfo_getTriple(ti))
            this.pointerWidth = clang_TargetInfo_getPointerWidth(ti)
        }

        if (!pointerWidth > 0) {
            throw Exception("pointer width is not > 0")
        }
        if (!(pointerWidth % 8 == 0)) {
            throw Exception("pointer width is not a multiple of 8")
        }

        this.abi = ABIKind.GenericItanium
    }
}

public class Diagnostic <: ToString {
    public let x: CXDiagnostic

    init(x: CXDiagnostic) {
        this.x = x
    }

    // cjlint-ignore -start !G.NAM.04 name
    ~init() {
        unsafe {
            clang_disposeDiagnostic(x)
        }
    }
    // cjlint-ignore -end name

    public func toString(): String {
        unsafe {
            let opts = clang_defaultDiagnosticDisplayOptions();
            return cxstringToString(clang_formatDiagnostic(x, opts))
        }
    }

    public func severity(): CXDiagnosticSeverity {
        unsafe {
            return clang_getDiagnosticSeverity(x)
        }
    }
}

public class CanonicalTypeDeclaration {
    public let ty: Type
    public let cursor: Cursor

    public init(
        ty: Type,
        cursor: Cursor
    ) {
        this.ty = ty
        this.cursor = cursor
    }
}

public class RawTokens <: Iterable<ClangToken> {
    public let cursor: Cursor
    public let tu: CXTranslationUnit
    public let tokens: CPointer<CXToken>
    public let tokenCount: UInt32

    public init(cursor: Cursor) {
        var tokens = CPointer<CXToken>()
        var tokenCount = UInt32(0)
        let range = cursor.extent()
        unsafe {
            let tu = clang_Cursor_getTranslationUnit(cursor.x)
            clang_tokenize(
                tu,
                range,
                inout tokens,
                inout tokenCount,
            )

            this.cursor = cursor
            this.tu = tu
            this.tokens = tokens
            this.tokenCount = tokenCount
        }
    }

    public func iterator(): ClangTokenIterator {
        return ClangTokenIterator(this)
    }
}

public class ClangToken {
    let _spelling: CXString
    let extent: CXSourceRange
    public let kind: CXTokenKind

    init(
        spelling: CXString,
        kind: CXTokenKind,
        range: CXSourceRange
    ) {
        this._spelling = spelling
        this.extent = range
        this.kind = kind
    }
    
    public func spelling(): String {
        unsafe {
            return cxstringToString(_spelling)
        }
    }
}

public class ClangTokenIterator <: Iterator<ClangToken> {
    public let rt: RawTokens
    var cur: Int64 = 0

    public init(rt: RawTokens) {
        this.rt = rt
    }

    public func next(): Option<ClangToken> {
        if (this.cur >= Int64(rt.tokenCount)) {
            return None
        }

        unsafe {
            let ptr = rt.tokens + Int64(cur)
            let data = ptr.read()

            let kind = clang_getTokenKind(data)
            let spell = clang_getTokenSpelling(rt.tu, data)
            let extent = clang_getTokenExtent(rt.tu, data)

            this.cur += 1

            return ClangToken(spell, kind, extent)
        }
    }
}

public class EvalResult {
    let x: CXEvalResult
    let ty: Type

    public init(cursor: Cursor) {
        unsafe {
            this.x = clang_Cursor_Evaluate(cursor.x)
            this.ty = cursor.curType().canonicalType()
        }
    }

    public func kind(): CXEvalResultKind {
        unsafe {
            return clang_EvalResult_getKind(x)
        }
    }

    public func asDouble(): ?Float64 {
        if (this.kind() == CXEvalResultKind_CXEval_Float) {
            unsafe {
                return clang_EvalResult_getAsDouble(x)
            }
        } else {
            return None
        }
    }

    public func asInt(): ?Int64 {
        if (this.kind() != CXEvalResultKind_CXEval_Int) {
            return None
        }

        unsafe {
            if (clang_EvalResult_isUnsignedInt(x) != 0) {
                let v = clang_EvalResult_getAsUnsigned(x)
                return Some(Int64(v))
            }

            let v = clang_EvalResult_getAsLongLong(x)
            return Some(v)
        }
    }

    public func asLiteralString(): ?CString {
        if (this.kind() != CXEvalResultKind_CXEval_StrLiteral) {
            return None
        }

        var charTyO = this.ty.pointeeType()
        if (charTyO.isNone()) {
            charTyO = this.ty.elemType()
        }
        if (charTyO.isNone()) {
            return None
        }
        let charTy = charTyO.getOrThrow()
        let k = charTy.kind()
        if (k == CXTypeKind_CXType_Char_S || 
        k == CXTypeKind_CXType_SChar ||
        k == CXTypeKind_CXType_Char_U ||
        k == CXTypeKind_CXType_UChar
        ) {
            unsafe {
                let ret = clang_EvalResult_getAsStr(x)
                return Some(ret)
            }
        }

        return None
    }
}

public func isValidIdentifier(name: String): Bool {
    let runes = name.toRuneArray()
    if (runes.isEmpty()) {
        return false
    }
    let it = runes.iterator()
    let first = it.next().getOrThrow()
    if (!first.isAsciiLetter() && first != r'_') {
        return false
    }

    for (r in it) {
        if (!r.isAsciiNumberOrLetter() && r != r'_') {
            return false
        }
    }

    return true
}
