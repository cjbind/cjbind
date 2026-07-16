package cjbind

import cjbind.options.CjbindOptions
import std.env.getTempDirectory
import std.fs.{Directory, File, remove}
import std.unittest.*
import std.unittest.testmacro.*

@Test
public class TemplateMaterializationTest {
    @TestCase
    func concreteNestedAliasesDoNotLeakAcrossInstantiations(): Unit {
        let options = CjbindOptions()
        options.headers.add("cjbind_test/testdata/headers/cxx-analysis-template-array.hpp")
        options.noDetectIncludePath = true
        options.noLayoutTests = true
        options.clangArgs.add(all: [
            "-x", "c++", "-std=c++14", "--target=x86_64-unknown-linux-gnu"
        ])

        let binding = generate(options)

        @Expect(binding.contains("VArray<Float64, \$2>"), true)
        @Expect(binding.contains("VArray<Float32, \$2>"), true)
        @Expect(binding.contains("public type Element ="), false)
        @Expect(binding.contains("VArray<Element,"), false)
    }

    @TestCase
    func concreteClassInstancesKeepTheirOwnLayoutAndIncompleteNttpsStayOpaque(): Unit {
        let options = CjbindOptions()
        options.headers.add("cjbind_test/testdata/headers/cxx-analysis-template-array.hpp")
        options.noDetectIncludePath = true
        options.clangArgs.add(all: [
            "-x", "c++", "-std=c++14", "--target=x86_64-unknown-linux-gnu"
        ])

        let binding = generate(options)

        // The primary-template dependency analysis historically considered
        // ContainsParameterArray<T> parameter-free and collapsed <short> to a
        // one-byte placeholder.  The concrete instance is six bytes/aligned 2.
        @Expect(binding.contains("public struct ContainsParameterArray_open0_short_close0"), true)
        @Expect(binding.contains(
            "contained : ContainsParameterArray_open0_short_close0"
        ), true)
        @Expect(binding.contains(
            "Size of ContainsParameterArray_open0_short_close0 is not 6"
        ), true)
        @Expect(binding.contains(
            "Alignment of ContainsParameterArray_open0_short_close0 is not 2"
        ), true)

        // Declaration/nullptr NTTP identities are intentionally not modeled.
        // Each field must use its own concrete Clang layout (5 and 3 bytes),
        // with no synthesized named specialization that could be shared.
        @Expect(binding.contains("pointerArgument : VArray<UInt8, \$5>"), true)
        @Expect(binding.contains("nullPointerArgument : VArray<UInt8, \$3>"), true)
        @Expect(binding.contains("PointerSelectedArray_open0"), false)
    }

    @TestCase
    func deducedAutoNttpTypesNeverShareAValueOnlyIdentity(): Unit {
        let directory = Directory.createTemp(getTempDirectory())
        try {
            let header = directory.join("auto_nttp_identity.hpp")
            File.writeTo(header, """
template <auto V>
struct AutoBox {
    decltype(V) value;
};

struct AutoIdentityHolder {
    AutoBox<1> signedValue;
    AutoBox<1ULL> unsignedValue;
};

template <class T, T V>
struct DependentBox {
    T value;
};

struct DependentIdentityHolder {
    DependentBox<int, 1> dependentSignedValue;
    DependentBox<unsigned long long, 1> dependentUnsignedValue;
};

template <__int128 V>
struct WideBox {
    char bytes[(V >> 64) == 0 ? 3 : 5];
};

struct WideIdentityHolder {
    WideBox<1> lowBitsOnly;
    WideBox<((__int128)1 << 64) + 1> highAndLowBits;
};

template <class... Ts>
struct PackBox {
    char bytes[sizeof...(Ts) + 2];
};

struct PackIdentityHolder {
    PackBox<int> oneType;
    PackBox<int, unsigned long long> twoTypes;
};
""".toArray())

            let options = CjbindOptions()
            options.headers.add(header.toString())
            options.noDetectIncludePath = true
            options.clangArgs.add(all: [
                "-x", "c++", "-std=c++17", "--target=x86_64-unknown-linux-gnu"
            ])

            let binding = generate(options)

            // libclang exposes both values as the integer 1, but their deduced
            // NTTP types are distinct and determine a four/eight-byte layout.
            // Keep each instance opaque instead of inventing one shared key.
            @Expect(binding.contains("signedValue : UInt32"), true)
            @Expect(binding.contains("unsignedValue : UInt64"), true)
            @Expect(binding.contains("AutoBox_open0"), false)
            @Expect(binding.contains("Size of AutoIdentityHolder is not 16"), true)
            @Expect(binding.contains("Alignment of AutoIdentityHolder is not 8"), true)
            @Expect(binding.contains("dependentSignedValue : UInt32"), true)
            @Expect(binding.contains("dependentUnsignedValue : UInt64"), true)
            @Expect(binding.contains("DependentBox_open0"), false)
            @Expect(binding.contains("Size of DependentIdentityHolder is not 16"), true)
            @Expect(binding.contains("Alignment of DependentIdentityHolder is not 8"), true)

            // libclang's integral template-argument API exposes at most 64
            // bits. These values share their low 64 bits, so materializing a
            // value-only identity would merge distinct three/five-byte types.
            @Expect(binding.contains("lowBitsOnly : VArray<UInt8, \$3>"), true)
            @Expect(binding.contains("highAndLowBits : VArray<UInt8, \$5>"), true)
            @Expect(binding.contains("WideBox_open0"), false)
            @Expect(binding.contains("Size of WideIdentityHolder is not 8"), true)

            // A parameter pack is not a one-to-one positional substitution,
            // even when it happens to contain exactly one type.
            @Expect(binding.contains("oneType : VArray<UInt8, \$3>"), true)
            @Expect(binding.contains("twoTypes : VArray<UInt8, \$4>"), true)
            @Expect(binding.contains("PackBox_open0"), false)
            @Expect(binding.contains("Size of PackIdentityHolder is not 7"), true)
        } finally {
            remove(directory, recursive: true)
        }
    }
}
