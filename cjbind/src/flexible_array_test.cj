package cjbind

import std.env.getTempDirectory
import std.fs.{Directory, File, remove}
import std.unittest.*
import std.unittest.testmacro.*

import cjbind.options.CjbindOptions

@Test
public class FlexibleArrayTest {
    @TestCase
    func substitutesTemplateAliasElementInZeroLengthArrayAccessor(): Unit {
        let directory = Directory.createTemp(getTempDirectory())
        try {
            let header = directory.join("template_alias_zero_array.hpp")
            File.writeTo(header, """
template <typename T>
using ZeroArray = T[0];

struct Packet {
    int size;
    ZeroArray<unsigned short> payload;
};
""".toArray())

            let options = CjbindOptions()
            options.headers.add(header.toString())
            options.noDetectIncludePath = true
            options.clangArgs.add(all: [
                "-x", "c++", "-std=gnu++14", "--target=x86_64-unknown-linux-gnu"
            ])

            let binding = generate(options)

            @Expect(binding.contains("public unsafe func Packet_payload_ptr"), true)
            @Expect(binding.contains("CPointer<UInt16>"), true)
            @Expect(
                binding.contains("Packet_payload_ptr(value: CPointer<Packet>): CPointer<T>"),
                false
            )
            @Expect(binding.contains("public struct __CjbindArrayView<T> where T <: CType"), true)
            @Expect(
                binding.contains("public unsafe func Packet_payload_view(value: CPointer<Packet>, count!: Int64)"),
                true
            )
            @Expect(binding.contains("__CjbindArrayView<UInt16>"), true)
            @Expect(binding.contains("public prop size: Int64"), true)
            @Expect(binding.contains("public prop isEmpty: Bool"), true)
            @Expect(binding.contains("unsafe prop"), false)
        } finally {
            remove(directory, recursive: true)
        }
    }

    @TestCase
    func keepsConstFlexibleAndZeroLengthArraysReadOnly(): Unit {
        let directory = Directory.createTemp(getTempDirectory())
        try {
            let header = directory.join("const_flexible_array.h")
            File.writeTo(header, """
typedef struct ConstPacket {
    int size;
    const unsigned short payload[];
} ConstPacket;

typedef union ConstZero {
    const int values[0];
    int scalar;
} ConstZero;
""".toArray())

            let options = CjbindOptions()
            options.headers.add(header.toString())
            options.noDetectIncludePath = true
            options.clangArgs.add(all: [
                "-x", "c", "-std=gnu11", "--target=x86_64-w64-mingw32"
            ])

            let binding = generate(options)

            @Expect(binding.contains("public struct __CjbindConstArrayView<T> where T <: CType"), true)
            @Expect(
                binding.contains("public unsafe func ConstPacket_payload_view(value: CPointer<ConstPacket>, count!: Int64): __CjbindConstArrayView<UInt16>"),
                true
            )
            @Expect(binding.contains("public unsafe func ConstPacket_payload_ptr"), false)
            @Expect(
                binding.contains("public unsafe func ConstZero_values_view(value: CPointer<ConstZero>, count!: Int64): __CjbindConstArrayView<Int32>"),
                true
            )
            @Expect(binding.contains("public unsafe func ConstZero_values_ptr"), false)
        } finally {
            remove(directory, recursive: true)
        }
    }
}
