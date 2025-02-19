package cjbind

import std.collection.*
import cjbind.options.CjbindOptions
import cjbind.clang
import cjbind.codegen
import cjbind.ir.*

func parseOne(ctx: CjbindContext, cursor: clang.Cursor, parent: ?ItemId): Unit {
    let builtin = cursor.isBuiltin() || cursor.isInSystemHeader()
    if (builtin && !ctx.options.builtins) {
        return
    }

    match (Item.parse(cursor, parent, ctx)) {
        case Ok(_) => ()
        case Err(ParseError.Continue) => ()
        case Err(ParseError.Recurse) => cursor.visitContinue {
            child => parseOne(ctx, child, parent)
        }
    }
}

func parse(context: CjbindContext) {
    var error: ?String = None

    for (d in context.translationUnit.diags()) {
        let msg = d.toString()
        let isError = d.severity() >= clang.CXDiagnosticSeverity_CXDiagnostic_Error

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

func detectIncludePaths(options: CjbindOptions) {
    if (options.noDetectIncludePath) {
        return
    }

    let clangArgsForClang = {
        =>
        let lastWasIncludePrefix = Box(false)
        options
            .clangArgs
            .iterator()
            .filter {
                arg =>
                if (lastWasIncludePrefix.value) {
                    lastWasIncludePrefix.value = false
                    return false
                }

                if (arg == "-I" || arg == "--include-directory") {
                    lastWasIncludePrefix.value = true
                    return false
                }

                if (arg.startsWith("-I") || arg.startsWith("--include-directory=")) {
                    return false
                }

                return true
            } |> collectArrayList
    }().toArray()

    let searchPaths = clang.getClangSearchPaths(clangArgsForClang)

    if (let Some(ps) <- searchPaths) {
        for (p in ps) {
            options.clangArgs.add("-isystem")
            options.clangArgs.add(p)
        }
    }
}

public func generate(opts: CjbindOptions): String {
    detectIncludePaths(opts)

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
