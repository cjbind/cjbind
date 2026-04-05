package cjbind.ir

import std.unittest.*
import std.unittest.testmacro.*

@Test
public class LayoutBasicTest {
    @TestCase
    func construction(): Unit {
        let l = Layout(16, 8)
        @Expect(l.size, 16)
        @Expect(l.align, 8)
        @Expect(l.packed, false)
    }

    @TestCase
    func opaque(): Unit {
        let l = Layout(16, 8)
        let o = l.opaque()
        @Expect(o.size, 16)
        @Expect(o.align, 8)
    }
}

@Test
public class LayoutForSizeInternalTest {
    @TestCase
    func zeroSize(): Unit {
        let l = Layout.forSizeInternal(8, 0)
        @Expect(l.size, 0)
        @Expect(l.align, 1)
    }

    @TestCase
    func sizeEqualsPtrSize(): Unit {
        let l = Layout.forSizeInternal(8, 8)
        @Expect(l.size, 8)
        @Expect(l.align, 8)
    }

    @TestCase
    func sizeMultipleOfPtrSize(): Unit {
        let l = Layout.forSizeInternal(8, 24)
        @Expect(l.size, 24)
        @Expect(l.align, 8)
    }

    @TestCase
    func sizeOne(): Unit {
        let l = Layout.forSizeInternal(8, 1)
        @Expect(l.size, 1)
        @Expect(l.align, 1)
    }

    @TestCase
    func sizeTwo(): Unit {
        let l = Layout.forSizeInternal(8, 2)
        @Expect(l.size, 2)
        @Expect(l.align, 2)
    }

    @TestCase
    func sizeFour(): Unit {
        let l = Layout.forSizeInternal(8, 4)
        @Expect(l.size, 4)
        @Expect(l.align, 4)
    }

    @TestCase
    func sizeThree(): Unit {
        let l = Layout.forSizeInternal(8, 3)
        @Expect(l.size, 3)
        @Expect(l.align, 1)
    }

    @TestCase
    func sizeSix(): Unit {
        let l = Layout.forSizeInternal(8, 6)
        @Expect(l.size, 6)
        @Expect(l.align, 2)
    }

    @TestCase
    func ptrSize4(): Unit {
        let l = Layout.forSizeInternal(4, 8)
        @Expect(l.size, 8)
        @Expect(l.align, 4)
    }

    @TestCase
    func sizeTwelve(): Unit {
        let l = Layout.forSizeInternal(8, 12)
        @Expect(l.size, 12)
        @Expect(l.align, 4)
    }
}

@Test
public class LayoutKnownCjTypeTest {
    @TestCase
    func size1(): Unit {
        let ts = Layout.knownCjTypeForSize(1).getOrThrow()
        @Expect(ts.toString(), "UInt8")
    }

    @TestCase
    func size2(): Unit {
        let ts = Layout.knownCjTypeForSize(2).getOrThrow()
        @Expect(ts.toString(), "UInt16")
    }

    @TestCase
    func size4(): Unit {
        let ts = Layout.knownCjTypeForSize(4).getOrThrow()
        @Expect(ts.toString(), "UInt32")
    }

    @TestCase
    func size8(): Unit {
        let ts = Layout.knownCjTypeForSize(8).getOrThrow()
        @Expect(ts.toString(), "UInt64")
    }

    @TestCase
    func unknownSizes(): Unit {
        @Expect(Layout.knownCjTypeForSize(0).isNone(), true)
        @Expect(Layout.knownCjTypeForSize(3).isNone(), true)
        @Expect(Layout.knownCjTypeForSize(16).isNone(), true)
    }
}

@Test
public class OpaqueTest {
    @TestCase
    func knownCjTypeForArray(): Unit {
        let o = Opaque(8, 4)
        let ty = o.knownCjTypeForArray().getOrThrow()
        @Expect(ty.toString(), "UInt32")
    }

    @TestCase
    func knownCjTypeForArrayUnknownAlign(): Unit {
        let o = Opaque(8, 3)
        @Expect(o.knownCjTypeForArray().isNone(), true)
    }

    @TestCase
    func arraySize(): Unit {
        let o = Opaque(16, 4)
        @Expect(o.arraySize().getOrThrow(), 4)
    }

    @TestCase
    func arraySizeAlign8(): Unit {
        let o = Opaque(24, 8)
        @Expect(o.arraySize().getOrThrow(), 3)
    }

    @TestCase
    func arraySizeUnknownAlign(): Unit {
        let o = Opaque(16, 3)
        @Expect(o.arraySize().isNone(), true)
    }
}
