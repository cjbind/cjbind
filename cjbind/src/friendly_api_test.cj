package cjbind

import std.env.getTempDirectory
import std.fs.{Directory, File, remove}
import std.unittest.*
import std.unittest.testmacro.*

import cjbind.options.{CjbindOptions, DefaultAliasStyle}

@Test
public class FriendlyApiGenerationTest {
    @TestCase
    func usesPropertiesForComputedFieldsAndKeepsConstFieldsReadOnly(): Unit {
        let directory = Directory.createTemp(getTempDirectory())
        try {
            let header = directory.join("friendly_api.h")
            File.writeTo(header, """
typedef int IntAlias;
typedef const int ConstIntAlias;

typedef union Value {
    int integer;
    float floating;
    const IntAlias readOnly;
    ConstIntAlias aliasReadOnly;
} Value;

typedef struct Child {
    int value;
} Child;

typedef struct Record {
    unsigned int enabled : 1;
    signed int displacement : 3;
    unsigned int remaining : 4;
    const unsigned int locked : 1;
    ConstIntAlias aliasLocked : 1;
    int count;
    const int tag;
    const IntAlias aliasTag;
    ConstIntAlias aliasDeclaredConst;
    const int *pointeeConst;
    int * const pointerConst;
    int values[2];
    Child child;
} Record;
""".toArray())

            let options = CjbindOptions()
            options.headers.add(header.toString())
            options.noDetectIncludePath = true
            options.clangArgs.add(all: [
                "-x", "c", "-std=gnu11", "--target=x86_64-w64-mingw32"
            ])

            let binding = generate(options)

            @Expect(binding.contains("public mut prop integer: Int32"), true)
            @Expect(binding.contains("public mut prop floating: Float32"), true)
            @Expect(binding.contains("public prop readOnly: IntAlias"), true)
            @Expect(binding.contains("public mut prop readOnly: IntAlias"), false)
            @Expect(binding.contains("public prop aliasReadOnly: ConstIntAlias"), true)
            @Expect(binding.contains("public mut prop aliasReadOnly: ConstIntAlias"), false)
            @Expect(binding.contains("public mut prop enabled: UInt32"), true)
            @Expect(binding.contains("public mut prop displacement: Int32"), true)
            @Expect(binding.contains("__cjbind_bitfield_int64_to_uint64(Int64(value))"), true)
            @Expect(binding.contains("func __cjbind_bitfield_uint64_to_int64"), true)
            @Expect(binding.contains("Int64(raw |"), false)
            @Expect(binding.contains("public prop locked: UInt32"), true)
            @Expect(binding.contains("public mut prop locked: UInt32"), false)
            @Expect(binding.contains("public prop aliasLocked: ConstIntAlias"), true)
            @Expect(binding.contains("public mut prop aliasLocked: ConstIntAlias"), false)
            @Expect(binding.contains("public var count : Int32"), true)
            @Expect(binding.contains("public let tag : Int32"), true)
            @Expect(binding.contains("public let aliasTag : IntAlias"), true)
            @Expect(binding.contains("public let aliasDeclaredConst : ConstIntAlias"), true)
            @Expect(binding.contains("public var pointeeConst : CPointer<Int32>"), true)
            @Expect(binding.contains("public let pointerConst : CPointer<Int32>"), true)
            @Expect(binding.contains("public let values : VArray<Int32, $2>"), true)
            @Expect(binding.contains("public let child : Child"), true)
            @Expect(binding.contains("func integer()"), false)
            @Expect(binding.contains("mut func enabled"), false)
        } finally {
            remove(directory, recursive: true)
        }
    }

    @TestCase
    func keepsCxxReferencesAndUnprovenRecordAssignmentReadOnly(): Unit {
        let directory = Directory.createTemp(getTempDirectory())
        try {
            let header = directory.join("friendly_api.hpp")
            File.writeTo(header, """
struct NonAssignable {
    int value;
    NonAssignable& operator=(const NonAssignable&) = delete;
};

struct Holder {
    int& reference;
    NonAssignable nested;
    int scalar;
    int* pointer;
    int array[2];
};

struct WithDestructor {
    int value;
    ~WithDestructor();
};

union UnionOwnDestructor {
    int scalar;
    NonAssignable nested;
    int array[2];
    ~UnionOwnDestructor();
};

using NonTrivialAlias = NonAssignable;
""".toArray())

            let options = CjbindOptions()
            options.headers.add(header.toString())
            options.noDetectIncludePath = true
            options.defaultAliasStyle = DefaultAliasStyle.NewType
            options.clangArgs.add(all: [
                "-x", "c++", "-std=gnu++14", "--target=x86_64-w64-mingw32"
            ])

            let binding = generate(options)

            @Expect(binding.contains("public let reference : CPointer<Int32>"), true)
            @Expect(binding.contains("public let nested : NonAssignable"), true)
            @Expect(binding.contains("public var scalar : Int32"), true)
            @Expect(binding.contains("public var pointer : CPointer<Int32>"), true)
            @Expect(binding.contains("public let array : VArray<Int32, $2>"), true)
            @Expect(binding.contains("private init(reference : CPointer<Int32>"), true)
            @Expect(binding.contains("private init(value : Int32)"), true)
            @Expect(binding.contains("public init(reference : CPointer<Int32>"), false)
            @Expect(binding.contains("public mut prop scalar: Int32"), true)
            @Expect(binding.contains("prop nested: NonAssignable"), false)
            @Expect(binding.contains("prop array: VArray<Int32, $2>"), false)
            @Expect(binding.contains("private init()"), true)
            @Expect(binding.contains("public type NonTrivialAlias = NonAssignable"), true)
            @Expect(binding.contains("public struct NonTrivialAlias"), false)
        } finally {
            remove(directory, recursive: true)
        }
    }
}
