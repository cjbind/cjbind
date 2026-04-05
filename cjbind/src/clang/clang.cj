package cjbind.clang

import std.fs.{File as FSFile, remove}
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

    public func retType(): ?Type {
        unsafe {
            let ret = Type(clang_getCursorResultType(x))
            if (ret.isValid()) {
                return Some(ret)
            } else {
                return None
            }
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

        let ppValid = pp.isValid()
        if (pp == this || !ppValid) {
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
                let v = clang_getEnumConstantDeclUnsignedValue(x)
                return Some(v)
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

    public func visitContinue(visitor: (Cursor) -> Unit): Unit {
        this.visit {
            c =>
            visitor(c)
            return CXChildVisitResult_CXChildVisit_Continue
        }
    }

    public func visit(visitor: (Cursor) -> CXChildVisitResult): Unit {
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

            try {
                clang_visitChildren(x, cb, CPointer<Unit>(cbIdData))
            } finally {
                LibC.free<Int64>(cbIdData)
                CursorVisitCallback.remove(cbId)
            }
        }
    }

    public func collectChildren(): ArrayList<Cursor> {
        let children = ArrayList<Cursor>()
        this.visit {
            c =>
            children.add(c)
            return CXChildVisitResult_CXChildVisit_Continue
        }
        return children
    }

    // --- ObjC support ---

    /// Get ObjC property attributes (readonly, copy, retain, etc.)
    public func objcPropertyAttributes(): UInt32 {
        unsafe {
            return clang_Cursor_getObjCPropertyAttributes(x, 0)
        }
    }

    /// Get ObjC property getter name
    public func objcPropertyGetterName(): String {
        unsafe {
            return cxstringToString(clang_Cursor_getObjCPropertyGetterName(x))
        }
    }

    /// Get ObjC property setter name
    public func objcPropertySetterName(): String {
        unsafe {
            return cxstringToString(clang_Cursor_getObjCPropertySetterName(x))
        }
    }

    /// Check if this cursor is an ObjC @optional method/property
    public func isObjCOptional(): Bool {
        unsafe {
            return clang_Cursor_isObjCOptional(x) != 0
        }
    }

    /// Get ObjC declaration qualifiers (in, out, inout, bycopy, byref, oneway)
    public func objcDeclQualifiers(): UInt32 {
        unsafe {
            return clang_Cursor_getObjCDeclQualifiers(x)
        }
    }

    /// Get ObjC selector index for this cursor
    public func objcSelectorIndex(): Int32 {
        unsafe {
            return clang_Cursor_getObjCSelectorIndex(x)
        }
    }

    /// Get ObjC type encoding for a declaration
    public func objcTypeEncoding(): String {
        unsafe {
            return cxstringToString(clang_getDeclObjCTypeEncoding(x))
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
            CXTypeKind_CXType_MemberPointer || k == CXTypeKind_CXType_BlockPointer || k == CXTypeKind_CXType_ObjCObjectPointer) {
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

    // --- ObjC support ---

    /// Get nullability of this type (NonNull, Nullable, Unspecified, Invalid)
    public func nullability(): CXTypeNullabilityKind {
        unsafe {
            return clang_Type_getNullability(x)
        }
    }

    public func isNullable(): Bool {
        let n = this.nullability()
        return n == CXTypeNullabilityKind_CXTypeNullability_Nullable ||
            n == CXTypeNullabilityKind_CXTypeNullability_NullableResult
    }

    /// Get ObjC type encoding string
    public func objcEncoding(): String {
        unsafe {
            return cxstringToString(clang_Type_getObjCEncoding(x))
        }
    }

    /// Get the base type of an ObjC object type
    public func objcObjectBaseType(): Type {
        unsafe {
            return Type(clang_Type_getObjCObjectBaseType(x))
        }
    }

    /// Get the number of ObjC type arguments
    public func numObjCTypeArgs(): UInt32 {
        unsafe {
            return clang_Type_getNumObjCTypeArgs(x)
        }
    }

    /// Get an ObjC type argument at the given index
    public func objcTypeArg(index: UInt32): Type {
        unsafe {
            return Type(clang_Type_getObjCTypeArg(x, index))
        }
    }

    /// Get the number of ObjC protocol references
    public func numObjCProtocolRefs(): UInt32 {
        unsafe {
            return clang_Type_getNumObjCProtocolRefs(x)
        }
    }

    /// Get ObjC protocol declaration at the given index
    public func objcProtocolDecl(index: UInt32): Cursor {
        unsafe {
            return Cursor(clang_Type_getObjCProtocolDecl(x, index))
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
            let s = cxstringToString(clang_getFileName(x))
            if (s.isEmpty()) {
                return None
            }
            return Some(s)
        }
    }
}

public class Index {
    let x: CXIndex
    var _released: Bool = false

    public func release(): Unit {
        if (!_released) {
            unsafe { clang_disposeIndex(x) }
            _released = true
        }
    }

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
        if (!_released) {
            unsafe { clang_disposeIndex(x) }
            _released = true
        }
    }
}

extend CString {
    func toPtr(): CPointer<Int8> {
        return CPointer<Int8>(this.getChars())
    }
}

public class TranslationUnit {
    var x: CXTranslationUnit
    var _released: Bool = false

    public func release(): Unit {
        if (!_released) {
            unsafe { clang_disposeTranslationUnit(x) }
            _released = true
        }
    }

    public init(
        ix: Index,
        file: String,
        cmdArgs: Array<String>,
        options: CXTranslationUnit_Flags
    ) {
        unsafe {
            let fname = CStringOwned(file)

            let releaser = ArrayList<() -> Unit>()
            releaser.add({=> fname.release()})

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
                fname.pointer,
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

    public func save(file: String): Result<Unit, CXSaveError> {
        let fs = CStringOwned(file)
        try {
            unsafe {
                let ret = clang_saveTranslationUnit(
                    this.x,
                    fs.pointer,
                    clang_defaultSaveOptions(this.x)
                )
                if (ret != 0) {
                    return Result.Err(UInt32(ret))
                } else {
                    return Result.Ok(())
                }
            }
        } finally {
            fs.release()
        }
    }

    ~init() {
        if (!_released) {
            unsafe { clang_disposeTranslationUnit(x) }
            _released = true
        }
    }
}

public class UnsavedFile {
    public let x: CXUnsavedFile
    public let name: CString
    public let contents: CString

    public init(name: String, contents: String) {
        unsafe {
            let name = LibC.mallocCString(name)
            let contents = LibC.mallocCString(contents)
            this.name = name
            this.contents = contents
            this.x = CXUnsavedFile(
                name,
                contents,
                UInt64(contents.size())
            )
        }
    }

    ~init() {
        unsafe {
            LibC.free(this.name)
            LibC.free(this.contents)
        }
    }
}

public class FallbackTranslationUnit {
    public let filePath: String
    public let pchPath: String
    public let idx: Index
    public let tu: TranslationUnit

    public init(
        file: String,
        pch_path: String,
        cArgs: Array<String>
    ) {
        let buf = Array<Byte>()
        FSFile.writeTo(file, buf)

        let fIndex = Index(true, false)
        let fTranslationUnit = TranslationUnit(
            fIndex,
            file,
            cArgs,
            CXTranslationUnit_Flags_CXTranslationUnit_None
        )

        this.filePath = file
        this.pchPath = pch_path
        this.idx = fIndex
        this.tu = fTranslationUnit
    }

    var _released: Bool = false

    public func release(): Unit {
        if (!_released) {
            this.tu.release()
            this.idx.release()
            try { remove(this.filePath) } catch (_: Exception) {}
            try { remove(this.pchPath) } catch (_: Exception) {}
            _released = true
        }
    }

    ~init() {
        if (!_released) {
            try { remove(this.filePath) } catch (_: Exception) {}
            try { remove(this.pchPath) } catch (_: Exception) {}
            _released = true
        }
    }

    public func reparse(
        unsavedContents: String
    ): Result<Unit, CXErrorCode> {
        let content = CStringOwned(unsavedContents)
        try {
            unsafe {
                let uf = UnsavedFile(this.filePath, unsavedContents)
                var unsaved: VArray<CXUnsavedFile, $1> = [uf.x]

                let ret = clang_reparseTranslationUnit(
                    this.tu.x,
                    1,
                    inout unsaved,
                    clang_defaultReparseOptions(this.tu.x)
                )

                if (ret != 0) {
                    return Result.Err(UInt32(ret))
                } else {
                    return Result.Ok(())
                }
            }
        } finally {
            content.release()
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
        let ti = unsafe { OwnedTargetInfo(clang_getTranslationUnitTargetInfo(tu.x)) }
        this.triple = ti.triple
        this.pointerWidth = ti.pointerWidth

        if (!(pointerWidth > 0)) {
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
    let _owned: OwnedTokens

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
            this._owned = OwnedTokens(tu, tokens, tokenCount)
        }
    }

    // The translation unit that owns the token array (non-owning reference).
    public prop tu: CXTranslationUnit {
        get() { return _owned.tu }
    }

    // Pointer to the token array.
    public prop tokens: CPointer<CXToken> {
        get() { return _owned.tokens }
    }

    // Number of tokens in the array.
    public prop tokenCount: UInt32 {
        get() { return _owned.count }
    }

    public func iterator(): ClangTokenIterator {
        return ClangTokenIterator(this)
    }
}

public class ClangToken {
    let _spelling: String
    let extent: CXSourceRange
    public let kind: CXTokenKind

    init(
        spelling: String,
        kind: CXTokenKind,
        range: CXSourceRange
    ) {
        this._spelling = spelling
        this.extent = range
        this.kind = kind
    }

    public func spelling(): String {
        return _spelling
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
            let spell = cxstringToString(clang_getTokenSpelling(rt.tu, data))
            let extent = clang_getTokenExtent(rt.tu, data)

            this.cur += 1

            return ClangToken(spell, kind, extent)
        }
    }
}

public enum EvalResultInt {
    Int(Int64) |
    UInt(UInt64)
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

    ~init() {
        unsafe {
            clang_EvalResult_dispose(x)
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

    public func asInt(): ?EvalResultInt {
        if (this.kind() != CXEvalResultKind_CXEval_Int) {
            return None
        }

        unsafe {
            if (clang_EvalResult_isUnsignedInt(x) != 0) {
                let v = clang_EvalResult_getAsUnsigned(x)

                return Some(EvalResultInt.UInt(UInt64(v)))
            }

            let v = clang_EvalResult_getAsLongLong(x)
            return Some(EvalResultInt.Int(v))
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
                // Copy the string to prevent use-after-free when EvalResult is disposed.
                // Cannot use LibC.mallocCString(ret.toString()) because the string may contain invalid UTF-8.
                let len = ret.size()
                let buf = LibC.malloc<UInt8>(count: Int64(len) + 1)
                for (i in 0..len) {
                    (buf + i).write((ret.getChars() + i).read())
                }
                (buf + len).write(0u8)
                let copied = CString(buf)
                return Some(copied)
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
