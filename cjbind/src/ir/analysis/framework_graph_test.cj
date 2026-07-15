package cjbind.ir.analysis

import cjbind.ir.*
import std.collection.{ArrayList, HashMap, HashSet}
import std.unittest.*
import std.unittest.testmacro.*

class ReachabilityGraphAnalysis <:
    MonotoneFramework<UIntNative, HashMap<UIntNative, HashSet<UIntNative>>> {
    let graph: HashMap<UIntNative, Array<UIntNative>>
    let reverse: HashMap<UIntNative, ArrayList<UIntNative>> = HashMap()
    let reachable: HashMap<UIntNative, HashSet<UIntNative>> = HashMap()

    init(graph: HashMap<UIntNative, Array<UIntNative>>) {
        this.graph = graph
        for ((node, successors) in graph) {
            this.reachable.add(node, HashSet<UIntNative>())
            if (!this.reverse.contains(node)) {
                this.reverse.add(node, ArrayList<UIntNative>())
            }
            for (successor in successors) {
                if (!this.reverse.contains(successor)) {
                    this.reverse.add(successor, ArrayList<UIntNative>())
                }
                this.reverse.get(successor).getOrThrow().add(node)
            }
        }
    }

    public func initialWorklist(): Array<UIntNative> {
        let nodes = ArrayList<UIntNative>()
        for ((node, _) in this.graph) {
            nodes.add(node)
        }
        return nodes.toArray()
    }

    public func constrain(node: UIntNative): ConstrainResult {
        let target = this.reachable.get(node).getOrThrow()
        let originalSize = target.size
        for (successor in this.graph.get(node).getOrThrow()) {
            target.add(successor)
            let transitive = ArrayList<UIntNative>()
            for (value in this.reachable.get(successor).getOrThrow()) {
                transitive.add(value)
            }
            for (value in transitive) {
                target.add(value)
            }
        }
        if (target.size != originalSize) {
            return ConstrainResult.Changed
        }
        return ConstrainResult.Same
    }

    public func eachDependingOn(node: UIntNative): Array<UIntNative> {
        return this.reverse.get(node).getOrThrow().toArray()
    }

    public func finish(): HashMap<UIntNative, HashSet<UIntNative>> {
        return this.reachable
    }
}

func reachabilityGraph(): HashMap<UIntNative, Array<UIntNative>> {
    let graph = HashMap<UIntNative, Array<UIntNative>>()
    graph.add(1, [3])
    graph.add(2, [2])
    graph.add(3, [4, 5])
    graph.add(4, [7])
    graph.add(5, [6, 7])
    graph.add(6, [8])
    graph.add(7, [3])
    graph.add(8, Array<UIntNative>())
    return graph
}

func expectReachable(
    reachable: HashMap<UIntNative, HashSet<UIntNative>>,
    node: UIntNative,
    expected: Array<UIntNative>
): Unit {
    let actual = reachable.get(node).getOrThrow()
    @Expect(actual.size, expected.size)
    for (value in expected) {
        @Expect(actual.contains(value), true)
    }
}

@Test
public class MonotoneFrameworkGraphTest {
    @TestCase
    func computesCyclesSelfLoopsAndDisconnectedNodesToFixedPoint(): Unit {
        let analysis = ReachabilityGraphAnalysis(reachabilityGraph())
        let reachable = analyze<UIntNative, HashMap<UIntNative, HashSet<UIntNative>>>(analysis)

        expectReachable(reachable, 1, [3, 4, 5, 6, 7, 8])
        expectReachable(reachable, 2, [2])
        expectReachable(reachable, 3, [3, 4, 5, 6, 7, 8])
        expectReachable(reachable, 4, [3, 4, 5, 6, 7, 8])
        expectReachable(reachable, 5, [3, 4, 5, 6, 7, 8])
        expectReachable(reachable, 6, [8])
        expectReachable(reachable, 7, [3, 4, 5, 6, 7, 8])
        expectReachable(reachable, 8, Array<UIntNative>())
    }
}
