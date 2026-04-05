package cjbind.ir

import std.unittest.*
import std.unittest.testmacro.*

@Test
public class IntKindSignednessTest {
    @TestCase
    func unsignedTypes(): Unit {
        let unsignedKinds = [
            TypeKindIntKind.IntKindBool,
            TypeKindIntKind.IntKindUChar,
            TypeKindIntKind.IntKindUShort,
            TypeKindIntKind.IntKindUInt,
            TypeKindIntKind.IntKindULong,
            TypeKindIntKind.IntKindULongLong,
            TypeKindIntKind.IntKindU8,
            TypeKindIntKind.IntKindU16,
            TypeKindIntKind.IntKindU32,
            TypeKindIntKind.IntKindU64,
            TypeKindIntKind.IntKindU128
        ]
        for (kind in unsignedKinds) {
            @Expect(kind.isSigned().getOrThrow(), false)
        }
    }

    @TestCase
    func signedTypes(): Unit {
        let signedKinds = [
            TypeKindIntKind.IntKindSChar,
            TypeKindIntKind.IntKindShort,
            TypeKindIntKind.IntKindInt,
            TypeKindIntKind.IntKindLong,
            TypeKindIntKind.IntKindLongLong,
            TypeKindIntKind.IntKindI8,
            TypeKindIntKind.IntKindI16,
            TypeKindIntKind.IntKindI32,
            TypeKindIntKind.IntKindI64,
            TypeKindIntKind.IntKindI128
        ]
        for (kind in signedKinds) {
            @Expect(kind.isSigned().getOrThrow(), true)
        }
    }

    @TestCase
    func charSignedness(): Unit {
        let signedChar = TypeKindIntKind.IntKindChar(true)
        let unsignedChar = TypeKindIntKind.IntKindChar(false)
        @Expect(signedChar.isSigned().getOrThrow(), true)
        @Expect(unsignedChar.isSigned().getOrThrow(), false)
    }

    @TestCase
    func wcharSignedness(): Unit {
        let signedWchar = TypeKindIntKind.IntKindWChar(true)
        let unsignedWchar = TypeKindIntKind.IntKindWChar(false)
        @Expect(signedWchar.isSigned().getOrThrow(), true)
        @Expect(unsignedWchar.isSigned().getOrThrow(), false)
    }

    @TestCase
    func customSignedness(): Unit {
        let signed = TypeKindIntKind.IntKindCustom(IntKindCustomValue("myint", true))
        let unsigned = TypeKindIntKind.IntKindCustom(IntKindCustomValue("myuint", false))
        @Expect(signed.isSigned().getOrThrow(), true)
        @Expect(unsigned.isSigned().getOrThrow(), false)
    }
}

@Test
public class IntKindSizeTest {
    @TestCase
    func oneByteTypes(): Unit {
        let oneByteKinds = [
            TypeKindIntKind.IntKindBool,
            TypeKindIntKind.IntKindUChar,
            TypeKindIntKind.IntKindSChar,
            TypeKindIntKind.IntKindU8,
            TypeKindIntKind.IntKindI8,
            TypeKindIntKind.IntKindChar(true),
            TypeKindIntKind.IntKindChar(false)
        ]
        for (kind in oneByteKinds) {
            @Expect(kind.knownSize().getOrThrow(), 1)
        }
    }

    @TestCase
    func twoByteTypes(): Unit {
        @Expect(TypeKindIntKind.IntKindU16.knownSize().getOrThrow(), 2)
        @Expect(TypeKindIntKind.IntKindI16.knownSize().getOrThrow(), 2)
    }

    @TestCase
    func fourByteTypes(): Unit {
        @Expect(TypeKindIntKind.IntKindU32.knownSize().getOrThrow(), 4)
        @Expect(TypeKindIntKind.IntKindI32.knownSize().getOrThrow(), 4)
    }

    @TestCase
    func eightByteTypes(): Unit {
        @Expect(TypeKindIntKind.IntKindU64.knownSize().getOrThrow(), 8)
        @Expect(TypeKindIntKind.IntKindI64.knownSize().getOrThrow(), 8)
    }

    @TestCase
    func sixteenByteTypes(): Unit {
        @Expect(TypeKindIntKind.IntKindI128.knownSize().getOrThrow(), 16)
        @Expect(TypeKindIntKind.IntKindU128.knownSize().getOrThrow(), 16)
    }

    @TestCase
    func unknownSizeTypes(): Unit {
        let unknownKinds = [
            TypeKindIntKind.IntKindShort,
            TypeKindIntKind.IntKindUShort,
            TypeKindIntKind.IntKindInt,
            TypeKindIntKind.IntKindUInt,
            TypeKindIntKind.IntKindLong,
            TypeKindIntKind.IntKindULong,
            TypeKindIntKind.IntKindLongLong,
            TypeKindIntKind.IntKindULongLong,
            TypeKindIntKind.IntKindWChar(true),
            TypeKindIntKind.IntKindCustom(IntKindCustomValue("x", true))
        ]
        for (kind in unknownKinds) {
            @Expect(kind.knownSize().isNone(), true)
        }
    }
}

@Test
public class IntKindCharTest {
    @TestCase
    func charTypes(): Unit {
        @Expect(TypeKindIntKind.IntKindChar(true).isChar(), true)
        @Expect(TypeKindIntKind.IntKindChar(false).isChar(), true)
        @Expect(TypeKindIntKind.IntKindSChar.isChar(), true)
        @Expect(TypeKindIntKind.IntKindUChar.isChar(), true)
    }

    @TestCase
    func nonCharTypes(): Unit {
        @Expect(TypeKindIntKind.IntKindBool.isChar(), false)
        @Expect(TypeKindIntKind.IntKindInt.isChar(), false)
        @Expect(TypeKindIntKind.IntKindI8.isChar(), false)
        @Expect(TypeKindIntKind.IntKindWChar(true).isChar(), false)
    }
}

@Test
public class IntKindSignednessMatchTest {
    @TestCase
    func nonNegativeAlwaysMatches(): Unit {
        @Expect(TypeKindIntKind.IntKindInt.signednessMatches(true), true)
        @Expect(TypeKindIntKind.IntKindUInt.signednessMatches(true), true)
    }

    @TestCase
    func negativeMatchesSigned(): Unit {
        @Expect(TypeKindIntKind.IntKindInt.signednessMatches(false), true)
        @Expect(TypeKindIntKind.IntKindI32.signednessMatches(false), true)
    }

    @TestCase
    func negativeDoesNotMatchUnsigned(): Unit {
        @Expect(TypeKindIntKind.IntKindUInt.signednessMatches(false), false)
        @Expect(TypeKindIntKind.IntKindU32.signednessMatches(false), false)
        @Expect(TypeKindIntKind.IntKindBool.signednessMatches(false), false)
    }
}
