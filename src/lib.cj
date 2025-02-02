package cjbind

import std.collection.*

import cjbind.ir.CjbindContext
import cjbind.options.CjbindOptions
import cjbind.clang
import cjbind.codegen
import cjbind.ir.*

func parseOne(ctx: CjbindContext, cursor: clang.Cursor, parent: ?ItemId): Unit {
    if (cursor.isBuiltin() || cursor.isInSystemHeader()) {
        return
    }

    match (Item.parse(cursor, parent, ctx)) {
        case Ok(_) => ()
        case Err(ParseError.Continue) => ()
        case Err(ParseError.Recurse) => 
            cursor.visitContinue {
                child => parseOne(ctx, child, parent)
            }
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
        ctx => cursor.visitContinue {
            child => parseOne(ctx, child, None)
        }
    }
}

public func generate(opts: CjbindOptions): String {
    let headerOpts = ArrayList<String>()
    for ((i, h) in opts.headers.iterator().enumerate()) {
        if (i != opts.headers.size - 1) {
            headerOpts.add("-include")
        }
        headerOpts.add(h)
    }
    opts.clangArgs.add(all: headerOpts)

    let ctx = CjbindContext(opts)

    parse(ctx)

    let module = match (codegen.codegen(ctx)) {
        case Ok(v) => v
        case Err(e) => throw Exception("Failed to generate code")
    }

    return module.toString()
}
