package cjbind

import cjbind.options.CjbindOptions
import std.unittest.*
import std.unittest.testmacro.*

func generatedAlignmentFixture(language: String): String {
    let options = CjbindOptions()
    options.headers.add("cjbind_test/testdata/headers/support/ir/aligned-generated-layout.h")
    options.noDetectIncludePath = true
    options.clangArgs.add(all: ["-x", language, "--target=x86_64-unknown-linux-gnu"])
    return generate(options).replace(" ", "").replace("\n", "").replace("\r", "").replace("\t", "")
}

@Test
public class GeneratedRecordLayoutTest {
    @TestCase
    func preservesLayoutWhenAliasEnumAndArrayAlignmentCannotBeEmitted(): Unit {
        for (language in ["c", "c++"]) {
            let binding = generatedAlignmentFixture(language)
            for (name in ["AlignedAliasRecord", "NestedAliasRecord", "AlignedEnumRecord",
                "AlignedArrayRecord", "AlignedZeroArrayRecord", "SameSizeWrongOffset"]) {
                @Expect(binding.contains("publicstruct${name}{let_cjbind_opaque_blob:VArray<UInt64,\$2>"), true)
            }
            @Expect(binding.contains("publictypeAlignedInt=Int32"), true)
            @Expect(binding.contains("publicstructAlignedInner{let_cjbind_opaque_blob:UInt64"), true)
            @Expect(binding.contains("publicstructAlignedOuter{publicvarbefore:Int32"), true)
            @Expect(binding.contains("inner:AlignedInner"), true)
        }
    }

    @TestCase
    func rejectsUnderalignedOrdinaryFieldsWithoutHidingValidBitfieldGaps(): Unit {
        let binding = generatedAlignmentFixture("c")
        @Expect(binding.contains("publicstructUnderAlignedRecord{let_cjbind_opaque_blob:VArray<UInt16,\$7>"), true)
        @Expect(binding.contains("publicstructBitfieldGap{publicvarbefore:UInt8"), true)
        @Expect(binding.contains("CPointer<UInt8>(inouts),24,30"), true)
        @Expect(binding.contains("foreignfuncaligned_record_value"), false)
        @Expect(binding.contains("foreignfuncaligned_record_pointer"), true)
    }
}
