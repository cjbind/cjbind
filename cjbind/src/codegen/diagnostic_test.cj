package cjbind.codegen

import std.unittest.*
import std.unittest.testmacro.*

@Test
public class SkippedFunctionDiagnosticTest {
    @TestCase
    func describesDeclarationSymbolAndReason(): Unit {
        let message = skippedFunctionErrorMessage(
            "Widget_call",
            "?call@Widget@@QEAAXXZ",
            unsupportedFunctionSymbolReason("?call@Widget@@QEAAXXZ")
        )
        @Expect(
            message,
            "Error: skipping function 'Widget_call' (ABI symbol '?call@Widget@@QEAAXXZ'): " +
                "MSVC-decorated ABI symbols cannot be represented by the current Cangjie FFI"
        )
    }

    @TestCase
    func distinguishesOtherInvalidSymbols(): Unit {
        @Expect(
            unsupportedFunctionSymbolReason("invalid@symbol"),
            "the ABI symbol is not a valid foreign-function identifier in the current Cangjie FFI"
        )
    }

    @TestCase
    func reportsEachDeclarationOnlyOnce(): Unit {
        let result = CodegenResult()
        @Expect(result.shouldReportSkippedFunction(17), true)
        @Expect(result.shouldReportSkippedFunction(17), false)
        @Expect(result.shouldReportSkippedFunction(18), true)
    }
}
