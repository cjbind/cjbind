package cjbind.clang

import std.unittest.*
import std.unittest.testmacro.*

@Test
public class ClangVersionCompatibilityTest {
    @TestCase
    func acceptsSupportedVersions(): Unit {
        for (version in [
            "clang version 20.1.0",
            "Apple clang version 20.0.0 (clang-2000.0.0.0)",
            "clang version 21.0.0git"
        ]) {
            validateClangVersion(version)
        }
    }

    @TestCase
    func rejectsOlderVersion(): Unit {
        var message = ""
        try {
            validateClangVersion("Debian clang version 19.1.7")
        } catch (e: UnsupportedException) {
            message = e.message
        }

        @Expect(message.contains("19.1.7"), true)
        @Expect(message.contains("libclang 20 or newer"), true)
    }

    @TestCase
    func rejectsUnknownVersion(): Unit {
        var message = ""
        try {
            validateClangVersion("unknown compiler")
        } catch (e: UnsupportedException) {
            message = e.message
        }

        @Expect(message.contains("Unable to determine libclang version"), true)
        @Expect(message.contains("libclang 20 or newer"), true)
    }
}
