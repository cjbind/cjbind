package cjbind.codegen

import cjbind.ir.*
import cjbind.ir.analysis.AnalysisResults
import cjbind.options.CjbindOptions
import std.collection.{ArrayList, HashMap}
import std.env.getTempDirectory
import std.fs.{Directory, File, remove}
import std.process.executeWithOutput
import std.unittest.*
import std.unittest.testmacro.*

func addObjcRuntimeTestType(ctx: CjbindContext, name: String, kind: TypeKind, layout: ?Layout): TypeId {
    let id = ctx.nextItemId()
    ctx.addItem(
        Item(id, None, ctx.rootModule, ItemKind.KindType(Type(Some(name), layout, kind, false)), None),
        None,
        None
    )
    return id
}

@Test
public class ObjCRuntimeNullabilityTest {
    @TestCase
    func compilesNullableObjectPointerStringAndCallbackCarriers(): Unit {
        let directory = Directory.createTemp(getTempDirectory())
        try {
            let header = directory.join("empty.h")
            File.writeTo(header, "".toArray())
            let options = CjbindOptions()
            options.autoCString = true
            options.clangArgs.add(all: ["-x", "c", header.toString()])
            let ctx = CjbindContext(options)
            try {
                let pointerLayout = Layout(ctx.pointerWidth(), ctx.pointerWidth())
                let unit = addObjcRuntimeTestType(ctx, "Void", TypeKind.TypeKindVoid, None)
                let byte = addObjcRuntimeTestType(ctx, "Char", TypeKind.TypeKindInt(IntKindChar(true)), Some(Layout(1, 1)))
                let objectType = addObjcRuntimeTestType(
                    ctx, "Peer", TypeKind.TypeKindObjCInterface(ObjCInterface("Peer")), Some(pointerLayout)
                )
                let objectRef = addObjcRuntimeTestType(
                    ctx, "PeerRef", TypeKind.ResolvedTypeRef(objectType), Some(pointerLayout)
                )
                let pointer = addObjcRuntimeTestType(ctx, "Pointer", TypeKind.TypeKindPointer(unit), Some(pointerLayout))
                let string = addObjcRuntimeTestType(ctx, "Text", TypeKind.TypeKindPointer(byte), Some(pointerLayout))
                let callbackSig = FunctionSig(
                    "callback", unit, Array<(?String, TypeId)>(), false, ClangAbi.Known(Abi.C)
                )
                let callbackType = addObjcRuntimeTestType(ctx, "CallbackFunction", TypeKind.TypeKindFunction(callbackSig), None)
                let callback = addObjcRuntimeTestType(
                    ctx, "Callback", TypeKind.TypeKindPointer(callbackType), Some(pointerLayout)
                )
                ctx.installAnalysisResults(AnalysisResults(HashMap<ItemId, ItemSet>()))

                let members = StringBuilder()
                for ((name, ty) in [("Object", objectRef), ("Pointer", pointer), ("Text", string), ("Callback", callback)]) {
                    let signature = FunctionSig(
                        "roundTrip${name}", ty, [(Some("_cjbindResult"), ty)], false, ClangAbi.Known(Abi.C)
                    )
                    let method = ObjCMethod(
                        "roundTrip${name}", "roundTrip${name}:", signature,
                        returnsNullable: true, nullableParams: ArrayList<Bool>([true])
                    )
                    members.append(genRuntimeMethod(ctx, method, "Probe", false).toString())
                    members.append("\n")
                    let property = ObjCProperty(
                        "property${name}", ty, "property${name}",
                        setterName: Some("setProperty${name}:"), isClassProperty: true, isNullable: true
                    )
                    members.append(genRuntimeProperty(ctx, property, "Probe").toString())
                    members.append("\n")
                }
                let rendered = "package objc_runtime_probe\n" + genRuntimeDecls().toString() + "\n" +
                    "public class Peer { public let id: CPointer<Unit>\n" +
                    "public init(id: CPointer<Unit>) { this.id = id } }\n" +
                    "public class Probe { public let id: CPointer<Unit>\n" +
                    "public init(id: CPointer<Unit>) { this.id = id }\n" + members.toString() + "}\n"
                @Expect(rendered.contains("CPointer<Unit>(_cjbindResult).isNull()"), true)
                @Expect(rendered.contains("zeroValue<CString>()"), true)
                @Expect(rendered.contains("zeroValue<CFunc<"), true)
                let generated = directory.join("nullable.cj")
                File.writeTo(generated, rendered.toArray())
                let (exitCode, _, stderr) = executeWithOutput("cjc", [
                    generated.toString(), "--output-type=staticlib", "-Woff", "unused",
                    "-o", directory.join("nullable.a").toString()
                ])
                if (exitCode != 0) {
                    throw Exception("Nullable ObjC binding compilation failed: ${String.fromUtf8(stderr)}")
                }
            } finally {
                ctx.close()
            }
        } finally {
            remove(directory, recursive: true)
        }
    }
}
