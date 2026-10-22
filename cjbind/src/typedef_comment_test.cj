package cjbind

import cjbind.options.CjbindOptions
import std.unittest.*
import std.unittest.testmacro.*

@Test
public class OverlappingTypedefCommentTest {
    @TestCase
    func inheritsHiddenAliasCommentsWithoutReplacingDeclarationComments(): Unit {
        for (language in ["c", "c++"]) {
            let options = CjbindOptions()
            options.headers.add("cjbind_test/testdata/headers/support/comments/overlapping-typedef.h")
            options.noDetectIncludePath = true
            options.clangArgs.add(all: ["-x", language])
            let output = generate(options)
            @Expect(output.contains("Hidden typedef documentation."), true)
            @Expect(output.contains("Preferred declaration documentation."), true)
            @Expect(output.contains("Ignored overlapping alias documentation."), false)
            // A visible, differently named alias keeps its own documentation.
            @Expect(output.split("Different alias documentation.").size, 2)
        }
    }
}
