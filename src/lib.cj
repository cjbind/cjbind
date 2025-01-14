package cjbind

import cjbind.ir.CjbindContext
import cjbind.options.CjbindOptions
import cjbind.clang
import cjbind.ir
import std.collection.*

func parseOne(ctx: CjbindContext, cursor: clang.Cursor, parent: ?ir.ItemId) {
    if (!cursor.isBuiltin()) {
        return
    }


}

func parse(context: CjbindContext) {
    var error: ?String = None

    for (d in context.translationUnit.diags()) {
        let msg = d.toString()
        let isError = d.severity() >= clang.CXDiagnostic_Error

        if (isError) {
            error = match (error) {
                case None => Some(msg + "\n")
                case Some(oldmsg) => oldmsg + msg + "\n"
            }
        } else {
            eprintln("clang diag: ${msg}")
        }
    }

    if (let Some(e) <- error) {
        throw Exception(e)
    }

    let cursor = context.translationUnit.cursor()

    let root = context.rootModule
    context.withModule(root) {
        ctx => cursor.visit() {
            child => parseOne(ctx, child, None)
        }
    }
}

func generate(opts: CjbindOptions): String {
    let ctx = CjbindContext(opts)

    parse(ctx)

    return ""
}
