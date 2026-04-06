package cjbind.clang

// RAII wrapper types for libclang resources.
//
// All types implement Resource, so use try-with-resources:
//
//   try (owned = CStringOwned(myString)) {
//       someFFICall(owned.pointer)
//   }

// ---------------------------------------------------------------------------
// CStringOwned
// ---------------------------------------------------------------------------

// Wraps a heap-allocated C string produced by `LibC.mallocCString()`.
//
// Callers must call `release()` when done, or let the destructor handle it
// at GC time. The `pointer` field is valid until `release()` is called.
public class CStringOwned <: Resource {
    private var _pointer: CString
    private var _released: Bool = false

    public init(s: String) {
        unsafe {
            this._pointer = LibC.mallocCString(s)
        }
    }

    // The raw CString pointer to the null-terminated C string.
    // Valid until `close()` is called.
    public prop pointer: CString {
        get() {
            return _pointer
        }
    }

    public func isClosed(): Bool { _released }

    // Frees the underlying C string immediately.
    // Safe to call multiple times; subsequent calls are no-ops.
    public func close(): Unit {
        if (!_released) {
            _released = true
            unsafe {
                LibC.free(_pointer)
            }
        }
    }

}

// ---------------------------------------------------------------------------
// OwnedTargetInfo
// ---------------------------------------------------------------------------

// Wraps a `CXTargetInfo` handle, eagerly extracting `.triple` and
// `.pointerWidth` in the constructor, then disposing the handle.
//
// Because the `CXTargetInfo` object cannot outlive the `CXTranslationUnit`
// that produced it, eager extraction is the safest strategy.
public class OwnedTargetInfo <: Resource {
    public let triple: String
    public let pointerWidth: Int32
    private var _handle: CXTargetInfo
    private var _released: Bool = false

    public init(handle: CXTargetInfo) {
        this._handle = handle
        unsafe {
            this.triple = cxstringToString(clang_TargetInfo_getTriple(handle))
            this.pointerWidth = clang_TargetInfo_getPointerWidth(handle)
        }
        // Dispose immediately after extracting all data.
        unsafe {
            clang_TargetInfo_dispose(handle)
        }
        this._released = true
    }

    public func isClosed(): Bool { _released }

    // Frees the underlying `CXTargetInfo` handle immediately.
    // Safe to call multiple times; subsequent calls are no-ops.
    public func close(): Unit {
        if (!_released) {
            _released = true
            unsafe {
                clang_TargetInfo_dispose(_handle)
            }
        }
    }

}

// ---------------------------------------------------------------------------
// OwnedTokens
// ---------------------------------------------------------------------------

// Wraps the triplet `(CXTranslationUnit, CPointer<CXToken>, UInt32)` produced
// by `clang_tokenize`. Disposes the token array via `clang_disposeTokens`
// when released.
//
// The `tu` reference is non-owning: this class does NOT dispose the
// translation unit. The translation unit must outlive this object.
public class OwnedTokens <: Resource {
    private let _tu: CXTranslationUnit
    private let _tokens: CPointer<CXToken>
    private let _count: UInt32
    private var _released: Bool = false

    public init(tu: CXTranslationUnit, tokens: CPointer<CXToken>, count: UInt32) {
        this._tu = tu
        this._tokens = tokens
        this._count = count
    }

    public func isClosed(): Bool { _released }

    // The translation unit this token array belongs to (non-owning reference).
    public prop tu: CXTranslationUnit {
        get() {
            return _tu
        }
    }

    // Pointer to the first element of the token array.
    public prop tokens: CPointer<CXToken> {
        get() {
            return _tokens
        }
    }

    // Number of tokens in the array.
    public prop count: UInt32 {
        get() {
            return _count
        }
    }

    // Frees the token array immediately via `clang_disposeTokens`.
    // Safe to call multiple times; subsequent calls are no-ops.
    public func close(): Unit {
        if (!_released) {
            _released = true
            unsafe {
                clang_disposeTokens(_tu, _tokens, _count)
            }
        }
    }

}
