package cjbind

import std.env.getTempDirectory
import std.fs.{Directory, File, remove}
import std.unittest.*
import std.unittest.testmacro.*

import cjbind.options.CjbindOptions

@Test
public class Float16AbiTest {
    @TestCase
    func usesBitStorageAndRejectsUnsupportedValueCalls(): Unit {
        let directory = Directory.createTemp(getTempDirectory())
        try {
            let header = directory.join("float16_abi.h")
            File.writeTo(header, """
typedef _Float16 half_t;

struct HalfStorage {
    half_t value;
    half_t *pointer;
};

half_t round_trip_half(half_t value);
struct HalfStorage round_trip_storage(struct HalfStorage value);
half_t *round_trip_half_pointer(half_t *value);
""".toArray())

            let options = CjbindOptions()
            options.headers.add(header.toString())
            options.noDetectIncludePath = true
            options.clangArgs.add(all: [
                "-x", "c", "-std=gnu11", "--target=x86_64-unknown-linux-gnu"
            ])

            let binding = generate(options)

            @Expect(binding.contains("public struct __CjbindFloat16"), true)
            @Expect(binding.contains("public var bits: UInt16"), true)
            @Expect(binding.contains("public mut prop value: Float16"), true)
            @Expect(binding.contains("Float16.fromBits(this.bits)"), true)
            @Expect(binding.contains("value.toBits()"), true)
            @Expect(binding.contains("public type half_t = __CjbindFloat16"), true)
            @Expect(binding.contains("public struct HalfStorage"), true)
            @Expect(binding.contains("CPointer<half_t>"), true)
            @Expect(binding.contains("CPointer<Float16>"), false)
            @Expect(binding.contains("foreign func round_trip_half ("), false)
            @Expect(binding.contains("foreign func round_trip_storage ("), false)
            @Expect(binding.contains("foreign func round_trip_half_pointer ("), true)
        } finally {
            remove(directory, recursive: true)
        }
    }
}
