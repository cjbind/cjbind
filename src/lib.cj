package cjbind

import cjbind.ir.CjbindContext
import cjbind.options.CjbindOptions
import cjbind.clang
import std.collection.*

func parse(context: CjbindContext) {
    var error: ?String = None

    for (d in context.translation_unit.diags()) {
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

    let cursor = context.translation_unit.cursor()
}

func generate(opts: CjbindOptions): String {
    let ctx = CjbindContext(opts)

    parse(ctx)

    return ""
}
