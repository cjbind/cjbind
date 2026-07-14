package cjbind_test

import std.unittest.*
import std.unittest.testmacro.*
import cjbind.options.CjbindOptions

@Test
public class AnalysisPolicyOptionsTest {
    @TestCase
    func headerDirectivesConfigurePublicSelectionPolicies(): Unit {
        let opt = CjbindOptions()
        applyTestOptions(opt, "${testdataDir}/headers/analysis-policy-options.hpp")

        @Expect(opt.blocklistedTypes.matches("NeverType"), true)
        @Expect(opt.blocklistedFunctions.matches("neverFunction"), true)
        @Expect(opt.blocklistedItems.matches("NeverItem"), true)
        @Expect(opt.blocklistedVars.matches("NEVER_VAR"), true)
        @Expect(opt.blocklistedFiles.matches("never/file"), true)
        @Expect(opt.opaqueTypes.matches("NeverOpaque"), true)
        @Expect(opt.allowlistedTypes.matches("PolicyOptionFixture"), true)
        @Expect(opt.allowlistedFunctions.matches("neverAllowedFunction"), true)
        @Expect(opt.allowlistedItems.matches("neverAllowedItem"), true)
        @Expect(opt.allowlistedVars.matches("NEVER_ALLOWED_VAR"), true)
        @Expect(opt.allowlistedFiles.matches("never/allowed/file"), true)
        @Expect(opt.allowlistRecursively, false)
        @Expect(opt.recordMatches, false)
        @Expect(opt.untaggedUnion, false)
        @Expect(opt.sizeTIsUsize, false)
    }
}
