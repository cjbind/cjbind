package cjbind.result

import std.unittest.*
import std.unittest.testmacro.*

@Test
public class ResultBasicTest {
    @TestCase
    func okIsOk(): Unit {
        let r: Result<Int64, String> = Ok(42)
        @Expect(r.isOk(), true)
        @Expect(r.isErr(), false)
    }

    @TestCase
    func errIsErr(): Unit {
        let r: Result<Int64, String> = Err("fail")
        @Expect(r.isOk(), false)
        @Expect(r.isErr(), true)
    }

    @TestCase
    func okValue(): Unit {
        let r: Result<Int64, String> = Ok(42)
        @Expect(r.ok().getOrThrow(), 42)
        @Expect(r.err().isNone(), true)
    }

    @TestCase
    func errValue(): Unit {
        let r: Result<Int64, String> = Err("fail")
        @Expect(r.ok().isNone(), true)
        @Expect(r.err().getOrThrow(), "fail")
    }
}

@Test
public class ResultPredicateTest {
    @TestCase
    func isOkAnd(): Unit {
        let r: Result<Int64, String> = Ok(42)
        @Expect(r.isOkAnd { v: Int64 => v > 0 }, true)
        @Expect(r.isOkAnd { v: Int64 => v < 0 }, false)
    }

    @TestCase
    func isOkAndOnErr(): Unit {
        let r: Result<Int64, String> = Err("fail")
        @Expect(r.isOkAnd { _: Int64 => true }, false)
    }

    @TestCase
    func isErrAnd(): Unit {
        let r: Result<Int64, String> = Err("fail")
        @Expect(r.isErrAnd { e: String => e == "fail" }, true)
        @Expect(r.isErrAnd { e: String => e == "other" }, false)
    }

    @TestCase
    func isErrAndOnOk(): Unit {
        let r: Result<Int64, String> = Ok(42)
        @Expect(r.isErrAnd { _: String => true }, false)
    }
}

@Test
public class ResultTransformTest {
    @TestCase
    func mapOk(): Unit {
        let r: Result<Int64, String> = Ok(2)
        let mapped = r.map { v: Int64 => v * 3 }
        @Expect(mapped.unwrap(), 6)
    }

    @TestCase
    func mapErr(): Unit {
        let r: Result<Int64, String> = Err("fail")
        let mapped = r.map { v: Int64 => v * 3 }
        @Expect(mapped.isErr(), true)
        @Expect(mapped.err().getOrThrow(), "fail")
    }

    @TestCase
    func mapOrOnOk(): Unit {
        let r: Result<Int64, String> = Ok(2)
        @Expect(r.mapOr(0) { v: Int64 => v * 3 }, 6)
    }

    @TestCase
    func mapOrOnErr(): Unit {
        let r: Result<Int64, String> = Err("fail")
        @Expect(r.mapOr(0) { v: Int64 => v * 3 }, 0)
    }

    @TestCase
    func mapOrElse(): Unit {
        let ok: Result<Int64, String> = Ok(2)
        let err: Result<Int64, String> = Err("fail")
        @Expect(ok.mapOrElse({ _: String => -1 }) { v: Int64 => v * 3 }, 6)
        @Expect(err.mapOrElse({ e: String => Int64(e.size) }) { v: Int64 => v * 3 }, 4)
    }

    @TestCase
    func mapErrTransform(): Unit {
        let r: Result<Int64, String> = Err("fail")
        let mapped = r.mapErr { e: String => e.size }
        @Expect(mapped.unwrapErr(), 4)
    }

    @TestCase
    func mapErrOnOk(): Unit {
        let r: Result<Int64, String> = Ok(42)
        let mapped = r.mapErr { e: String => e.size }
        @Expect(mapped.unwrap(), 42)
    }
}

@Test
public class ResultUnwrapTest {
    @TestCase
    func unwrapOk(): Unit {
        let r: Result<Int64, String> = Ok(42)
        @Expect(r.unwrap(), 42)
    }

    @TestCase
    func expectOk(): Unit {
        let r: Result<Int64, String> = Ok(42)
        @Expect(r.expect("should work"), 42)
    }

    @TestCase
    func unwrapErrOnErr(): Unit {
        let r: Result<Int64, String> = Err("fail")
        @Expect(r.unwrapErr(), "fail")
    }

    @TestCase
    func unwrapOrOnOk(): Unit {
        let r: Result<Int64, String> = Ok(42)
        @Expect(r.unwrapOr(0), 42)
    }

    @TestCase
    func unwrapOrOnErr(): Unit {
        let r: Result<Int64, String> = Err("fail")
        @Expect(r.unwrapOr(0), 0)
    }

    @TestCase
    func unwrapOrElseOnErr(): Unit {
        let r: Result<Int64, String> = Err("fail")
        @Expect(r.unwrapOrElse { e: String => Int64(e.size) }, 4)
    }

    @TestCase
    func unwrapOnErrThrows(): Unit {
        let r: Result<Int64, String> = Err("boom")
        var threw = false
        try {
            let _ = r.unwrap()
        } catch (e: ResultException) {
            threw = true
        }
        @Expect(threw, true)
    }

    @TestCase
    func expectOnErrThrows(): Unit {
        let r: Result<Int64, String> = Err("boom")
        var threw = false
        try {
            let _ = r.expect("custom msg")
        } catch (e: ResultException) {
            threw = true
            @Expect(e.message.contains("custom msg"), true)
        }
        @Expect(threw, true)
    }
}

@Test
public class ResultChainTest {
    @TestCase
    func andOnOk(): Unit {
        let a: Result<Int64, String> = Ok(1)
        let b: Result<String, String> = Ok("hello")
        let result = a.and(b)
        @Expect(result.unwrap(), "hello")
    }

    @TestCase
    func andOnErr(): Unit {
        let a: Result<Int64, String> = Err("first")
        let b: Result<String, String> = Ok("hello")
        let result = a.and(b)
        @Expect(result.unwrapErr(), "first")
    }

    @TestCase
    func andThenOnOk(): Unit {
        let r: Result<Int64, String> = Ok(2)
        let result = r.andThen { v: Int64 => Result<Int64, String>.Ok(v * 3) }
        @Expect(result.unwrap(), 6)
    }

    @TestCase
    func andThenOnErr(): Unit {
        let r: Result<Int64, String> = Err("fail")
        let result = r.andThen { v: Int64 => Result<Int64, String>.Ok(v * 3) }
        @Expect(result.unwrapErr(), "fail")
    }

    @TestCase
    func orOnOk(): Unit {
        let a: Result<Int64, String> = Ok(1)
        let b: Result<Int64, Int64> = Ok(2)
        let result = a.or(b)
        @Expect(result.unwrap(), 1)
    }

    @TestCase
    func orOnErr(): Unit {
        let a: Result<Int64, String> = Err("first")
        let b: Result<Int64, Int64> = Ok(2)
        let result = a.or(b)
        @Expect(result.unwrap(), 2)
    }

    @TestCase
    func orElseOnErr(): Unit {
        let r: Result<Int64, String> = Err("fail")
        let result = r.orElse { e: String => Result<Int64, Int64>.Ok(Int64(e.size)) }
        @Expect(result.unwrap(), 4)
    }
}

@Test
public class ResultInspectTest {
    @TestCase
    func inspectOk(): Unit {
        let r: Result<Int64, String> = Ok(42)
        let same = r.inspect { _: Int64 => () }
        @Expect(same.unwrap(), 42)
    }

    @TestCase
    func inspectSkipsErr(): Unit {
        let r: Result<Int64, String> = Err("fail")
        let same = r.inspect { _: Int64 => () }
        @Expect(same.isErr(), true)
    }

    @TestCase
    func inspectErrOnErr(): Unit {
        let r: Result<Int64, String> = Err("fail")
        let same = r.inspectErr { _: String => () }
        @Expect(same.isErr(), true)
    }

    @TestCase
    func inspectErrSkipsOk(): Unit {
        let r: Result<Int64, String> = Ok(42)
        let same = r.inspectErr { _: String => () }
        @Expect(same.unwrap(), 42)
    }
}

@Test
public class ResultStaticTest {
    @TestCase
    func transposeSomeOk(): Unit {
        let r: Result<Option<Int64>, String> = Ok(Some(42))
        let opt = Result<Option<Int64>, String>.transpose(r)
        @Expect(opt.isSome(), true)
        @Expect(opt.getOrThrow().unwrap(), 42)
    }

    @TestCase
    func transposeNoneOk(): Unit {
        let r: Result<Option<Int64>, String> = Ok(None)
        let opt = Result<Option<Int64>, String>.transpose(r)
        @Expect(opt.isNone(), true)
    }

    @TestCase
    func transposeErr(): Unit {
        let r: Result<Option<Int64>, String> = Err("fail")
        let opt = Result<Option<Int64>, String>.transpose(r)
        @Expect(opt.isSome(), true)
        @Expect(opt.getOrThrow().unwrapErr(), "fail")
    }

    @TestCase
    func flattenOkOk(): Unit {
        let r: Result<Result<Int64, String>, String> = Ok(Ok(42))
        let flat = Result<Result<Int64, String>, String>.flatten(r)
        @Expect(flat.unwrap(), 42)
    }

    @TestCase
    func flattenOkErr(): Unit {
        let r: Result<Result<Int64, String>, String> = Ok(Err("inner"))
        let flat = Result<Result<Int64, String>, String>.flatten(r)
        @Expect(flat.unwrapErr(), "inner")
    }

    @TestCase
    func flattenErr(): Unit {
        let r: Result<Result<Int64, String>, String> = Err("outer")
        let flat = Result<Result<Int64, String>, String>.flatten(r)
        @Expect(flat.unwrapErr(), "outer")
    }
}
