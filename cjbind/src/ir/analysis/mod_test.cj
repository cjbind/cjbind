package cjbind.ir.analysis

import cjbind.ir.*
import std.collection.{HashMap, HashSet}
import std.unittest.*
import std.unittest.testmacro.*

class PropagationAnalysis <: MonotoneFramework<UIntNative, HashSet<UIntNative>> {
    let facts = HashSet<UIntNative>()

    public func initialWorklist(): Array<UIntNative> {
        return [0, 1, 2, 3]
    }

    public func constrain(node: UIntNative): ConstrainResult {
        let shouldHold = node == 3 || (node < 3 && this.facts.contains(node + 1))
        if (shouldHold && this.facts.add(node)) {
            return ConstrainResult.Changed
        }
        return ConstrainResult.Same
    }

    public func eachDependingOn(node: UIntNative): Array<UIntNative> {
        if (node == 0) {
            return Array<UIntNative>()
        }
        return [node - 1]
    }

    public func finish(): HashSet<UIntNative> {
        return this.facts
    }
}

@Test
public class MonotoneFrameworkTest {
    @TestCase
    func combinesConstraintResultsWithoutLosingChanges(): Unit {
        @Expect(ConstrainResult.Same.join(ConstrainResult.Same) == ConstrainResult.Same, true)
        @Expect(ConstrainResult.Same.join(ConstrainResult.Changed) == ConstrainResult.Changed, true)
        @Expect(ConstrainResult.Changed.join(ConstrainResult.Same) == ConstrainResult.Changed, true)
        @Expect(ConstrainResult.Changed.join(ConstrainResult.Changed) == ConstrainResult.Changed, true)

        var accumulated = ConstrainResult.Same
        accumulated |= ConstrainResult.Same
        @Expect(accumulated == ConstrainResult.Same, true)
        accumulated |= ConstrainResult.Changed
        @Expect(accumulated == ConstrainResult.Changed, true)
        accumulated |= ConstrainResult.Same
        @Expect(accumulated == ConstrainResult.Changed, true)
    }

    @TestCase
    func templateDefinitionChangeRequeuesInstantiationUntilFixedPoint(): Unit {
        let analysis = PropagationAnalysis()
        let facts = analyze<UIntNative, HashSet<UIntNative>>(analysis)

        @Expect(facts.size, 4)
        @Expect(facts.contains(0), true)
        @Expect(facts.contains(1), true)
        @Expect(facts.contains(2), true)
        @Expect(facts.contains(3), true)
    }

}

@Test
public class HasVtableLatticeTest {
    @TestCase
    func joinsTowardBaseVtable(): Unit {
        @Expect(
            HasVtableResult.No.join(HasVtableResult.SelfHasVtable) == HasVtableResult.SelfHasVtable,
            true
        )
        @Expect(
            HasVtableResult.SelfHasVtable.join(HasVtableResult.BaseHasVtable) ==
                HasVtableResult.BaseHasVtable,
            true
        )
        @Expect(
            HasVtableResult.BaseHasVtable.join(HasVtableResult.No) == HasVtableResult.BaseHasVtable,
            true
        )
    }

    @TestCase
    func missingResultMeansNoVtable(): Unit {
        let results = HashMap<ItemId, HasVtableResult>()
        @Expect(analysisHasVtable(results, 10), false)
        @Expect(analysisHasVtablePointer(results, 10), false)
    }
}

@Test
public class SizednessLatticeTest {
    @TestCase
    func joinsTowardKnownNonZeroSize(): Unit {
        @Expect(
            SizednessResult.ZeroSized.join(SizednessResult.DependsOnTypeParam) ==
                SizednessResult.DependsOnTypeParam,
            true
        )
        @Expect(
            SizednessResult.DependsOnTypeParam.join(SizednessResult.NonZeroSized) ==
                SizednessResult.NonZeroSized,
            true
        )
        @Expect(
            SizednessResult.NonZeroSized.join(SizednessResult.ZeroSized) == SizednessResult.NonZeroSized,
            true
        )
    }

    @TestCase
    func missingResultMeansZeroSized(): Unit {
        let results = HashMap<ItemId, SizednessResult>()
        @Expect(analysisIsZeroSized(results, 10), true)
    }
}
