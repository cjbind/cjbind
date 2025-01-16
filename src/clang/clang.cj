package cjbind.clang

import cjbind.result.Result

func cxstringToString(x: CXString): String {
    if (x.data.isNull()) {
        return ""
    }

    unsafe {
        let str = clang_getCString(x).toString()
        clang_disposeString(x)
        return str
    }
}

// workaround cfunc capture limit
// thus we can only work as single thread
var CursorVisitCallback: ?(Cursor) -> CXChildVisitResult = None

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
            if (ret.isValid() && ret.kind() != CXCursor_NoDeclFound) {
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
                return CXChildVisit_Continue
        }
    }

    public func visit(visitor: (Cursor) -> CXChildVisitResult) {
        CursorVisitCallback = visitor
        unsafe {
            let cb: CFunc<(CXCursor, CXCursor, CPointer<Unit>) -> CXChildVisitResult> = {
                cxcs, _, data =>
                return CursorVisitCallback.getOrThrow()(Cursor(cxcs))
            }

            clang_visitChildren(x, cb, CPointer<Unit>())
        }
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
        return this.x.kind != CXType_Invalid
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
        if (k == CXType_RValueReference || k == CXType_LValueReference) {
            return Int64(ptrSize)
        }

        if (k == CXType_Auto) {
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
        if (k == CXType_RValueReference || k == CXType_LValueReference) {
            return Int64(ptrSize)
        }

        if (k == CXType_Auto) {
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

    public func caninicalDeclaration(location: ?Cursor): ?CanonicalTypeDeclaration {
        let decl = this.declaration()
        let canonical = decl.canonical()
        if (canonical.isValid() && canonical.kind() != CXCursor_NoDeclFound) {
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
        if (k == CXType_Pointer || k == CXType_RValueReference || k == CXType_LValueReference || k == CXType_MemberPointer || k == CXType_BlockPointer) {
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

            let c_args = LibC.malloc<CString>(count: cmdArgs.size)

            for (i in 0..cmdArgs.size) {
                let s = LibC.mallocCString(cmdArgs[i])
                let ptr = c_args + i
                ptr.write(s)
            }

            this.x = clang_parseTranslationUnit(
                ix.x,
                fname,
                c_args,
                Int32(cmdArgs.size),
                CPointer<CXUnsavedFile>(),
                0,
                UInt32(options)
            )

            if (this.x.isNull()) {
                throw Exception("parse failed")
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
