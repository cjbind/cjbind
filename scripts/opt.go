package main

import (
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"runtime"
	"strings"
	"syscall"
)

func GetExePath(exeName string) string {
	dir, err := filepath.Abs(filepath.Dir(os.Args[0]))
	if err != nil {
		fmt.Fprintf(os.Stderr, "获取当前目录失败: %v\n", err)
		os.Exit(1)
	}

	if runtime.GOOS == "windows" {
		exeName = exeName + ".exe"
	}

	return filepath.Join(dir, exeName)
}

func ExecuteWithArgs(exeName string, args []string) (int, error) {
	exePath := GetExePath(exeName)

	cmd := exec.Command(exePath, args...)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	cmd.Stdin = os.Stdin

	err := cmd.Run()

	exitCode := 0
	if err != nil {
		if exitError, ok := err.(*exec.ExitError); ok {
			if status, ok := exitError.Sys().(syscall.WaitStatus); ok {
				exitCode = status.ExitStatus()
			} else {
				if status, ok := exitError.Sys().(uint32); ok {
					exitCode = int(status)
				} else {
					exitCode = 1
				}
			}
		}
	}

	return exitCode, err
}

func OverrideArgs(exeName string) (int, error) {
	argsToUse := os.Args[1:]

	filename := argsToUse[0]
	if strings.HasSuffix(filename, "cjbind.clang.bc") {
		for i := range len(argsToUse) {
			if argsToUse[i] == "--only-verify-out" {
				argsToUse = append(argsToUse[:i], argsToUse[i+1:]...)
				break
			}
		}

		for i := range len(argsToUse) {
			if argsToUse[i] == "--cangjie-pipeline" {
				argsToUse = append(argsToUse[:i], argsToUse[i+1:]...)
				break
			}
		}

		for i := range len(argsToUse) {
			if argsToUse[i] == "-passes=default<O2>" {
				// function(insert-cj-tbaa),fill-klass-gv,cj-runtime-lowering,cj-early-opt,annotation2metadata,forceattrs,inferattrs,coro-early,function<eager-inv>(loop(loop-simplifycfg),lower-expect,simplifycfg<bonus-inst-threshold=1;no-forward-switch-cond;no-switch-range-to-icmp;no-switch-to-lookup;keep-loops;no-hoist-common-insts;no-sink-common-insts>,sroa,early-cse<>),openmp-opt,ipsccp,called-value-propagation,globalopt,function(mem2reg),deadargelim,function<eager-inv>(instcombine,simplifycfg<bonus-inst-threshold=1;no-forward-switch-cond;switch-range-to-icmp;no-switch-to-lookup;keep-loops;no-hoist-common-insts;no-sink-common-insts>),require<globals-aa>,function(invalidate<aa>),require<profile-summary>,cgscc(devirt<4>(inline<only-mandatory>,inline,function-attrs,openmp-opt-cgscc,cj-devirtual-opt,function(cj-barrier-split),function(simplifycfg<bonus-inst-threshold=1;no-forward-switch-cond;switch-range-to-icmp;no-switch-to-lookup;keep-loops;no-hoist-common-insts;no-sink-common-insts>),function(instcombine),function(sccp),PEA,function(simplifycfg<bonus-inst-threshold=1;no-forward-switch-cond;switch-range-to-icmp;no-switch-to-lookup;keep-loops;no-hoist-common-insts;no-sink-common-insts>),PartialEscapeAnalysis,function<eager-inv>(cj-late-opt,sroa,early-cse<memssa>,speculative-execution,jump-threading,correlated-propagation,cj-generic-intrinsic-opt,cj-simple-range-analysis,simplifycfg<bonus-inst-threshold=1;no-forward-switch-cond;switch-range-to-icmp;no-switch-to-lookup;keep-loops;no-hoist-common-insts;no-sink-common-insts>,instcombine,libcalls-shrinkwrap,tailcallelim,simplifycfg<bonus-inst-threshold=1;no-forward-switch-cond;switch-range-to-icmp;no-switch-to-lookup;keep-loops;no-hoist-common-insts;no-sink-common-insts>,reassociate,instcombine,require<opt-remark-emit>,loop-mssa(licm<no-allowspeculation>,loop-rotate,indvars,loop-deletion,loop-instsimplify,loop-simplifycfg,licm<no-allowspeculation>,loop-rotate,licm<allowspeculation>,simple-loop-unswitch<no-nontrivial;trivial>),simplifycfg<bonus-inst-threshold=1;no-forward-switch-cond;switch-range-to-icmp;no-switch-to-lookup;keep-loops;no-hoist-common-insts;no-sink-common-insts>,instcombine,cj-loop-float-opt,loop(loop-idiom,indvars,loop-deletion,loop-unroll-full),sroa,mldst-motion<no-split-footer-bb>,gvn<>,sccp,bdce,instcombine,jump-threading,correlated-propagation,adce,memcpyopt,cj-rssce,dse,loop-mssa(licm<allowspeculation>),coro-elide,simplifycfg<bonus-inst-threshold=1;no-forward-switch-cond;switch-range-to-icmp;no-switch-to-lookup;keep-loops;hoist-common-insts;sink-common-insts>,instcombine),coro-split)),coro-cleanup,globalopt,globaldce,rpo-function-attrs,recompute-globalsaa,cgscc(function-attrs),function<eager-inv>(irce,simplifycfg<bonus-inst-threshold=1;no-forward-switch-cond;switch-range-to-icmp;no-switch-to-lookup;keep-loops;no-hoist-common-insts;no-sink-common-insts>,loop(simple-loop-unswitch<no-nontrivial;trivial>),loop-mssa(licm<allowspeculation>),gvn<>,memcpyopt,cj-rssce,dse,mldst-motion<no-split-footer-bb>),function<eager-inv>(float2int,lower-constant-intrinsics,loop(loop-rotate,loop-deletion),loop-distribute,inject-tli-mappings,loop-vectorize<no-interleave-forced-only;no-vectorize-forced-only;>,loop-load-elim,instcombine,simplifycfg<bonus-inst-threshold=1;forward-switch-cond;switch-range-to-icmp;switch-to-lookup;no-keep-loops;hoist-common-insts;sink-common-insts>,slp-vectorizer,vector-combine,instcombine,loop-unroll<O2>,transform-warning,instcombine,require<opt-remark-emit>,loop-mssa(licm<allowspeculation>),alignment-from-assumptions,loop(indvars),early-cse<>,loop-sink,instsimplify,div-rem-pairs,tailcallelim,simplifycfg<bonus-inst-threshold=1;no-forward-switch-cond;switch-range-to-icmp;no-switch-to-lookup;keep-loops;no-hoist-common-insts;no-sink-common-insts>),elim-avail-extern,globaldce,constmerge,cg-profile,rel-lookup-table-converter,function(annotation-remarks),cangjie-specific-opt,place-safepoints,cj-barrier-opt,rewrite-statepoints-for-cangjie-gc,BitcodeWriterPass

				argsToUse[i] = "-passes=function(insert-cj-tbaa),fill-klass-gv,cj-runtime-lowering,cj-early-opt,annotation2metadata,forceattrs,inferattrs,coro-early,function<eager-inv>(loop(loop-simplifycfg),lower-expect,simplifycfg<bonus-inst-threshold=1;no-forward-switch-cond;no-switch-range-to-icmp;no-switch-to-lookup;keep-loops;no-hoist-common-insts;no-sink-common-insts>,sroa,early-cse<>),openmp-opt,ipsccp,called-value-propagation,globalopt,function(mem2reg),deadargelim,function<eager-inv>(instcombine,simplifycfg<bonus-inst-threshold=1;no-forward-switch-cond;switch-range-to-icmp;no-switch-to-lookup;keep-loops;no-hoist-common-insts;no-sink-common-insts>),require<globals-aa>,function(invalidate<aa>),require<profile-summary>,cgscc(devirt<4>(inline<only-mandatory>,inline,function-attrs,openmp-opt-cgscc,cj-devirtual-opt,function(cj-barrier-split),function(simplifycfg<bonus-inst-threshold=1;no-forward-switch-cond;switch-range-to-icmp;no-switch-to-lookup;keep-loops;no-hoist-common-insts;no-sink-common-insts>),function(instcombine),function(sccp),PEA,function(simplifycfg<bonus-inst-threshold=1;no-forward-switch-cond;switch-range-to-icmp;no-switch-to-lookup;keep-loops;no-hoist-common-insts;no-sink-common-insts>),PartialEscapeAnalysis,function<eager-inv>(cj-late-opt,sroa,early-cse<memssa>,speculative-execution,jump-threading,correlated-propagation,cj-generic-intrinsic-opt,cj-simple-range-analysis,simplifycfg<bonus-inst-threshold=1;no-forward-switch-cond;switch-range-to-icmp;no-switch-to-lookup;keep-loops;no-hoist-common-insts;no-sink-common-insts>,instcombine,libcalls-shrinkwrap,tailcallelim,simplifycfg<bonus-inst-threshold=1;no-forward-switch-cond;switch-range-to-icmp;no-switch-to-lookup;keep-loops;no-hoist-common-insts;no-sink-common-insts>,reassociate,instcombine,require<opt-remark-emit>,loop-mssa(licm<no-allowspeculation>,loop-rotate,indvars,loop-deletion,loop-instsimplify,loop-simplifycfg,licm<no-allowspeculation>,loop-rotate,licm<allowspeculation>,simple-loop-unswitch<no-nontrivial;trivial>),simplifycfg<bonus-inst-threshold=1;no-forward-switch-cond;switch-range-to-icmp;no-switch-to-lookup;keep-loops;no-hoist-common-insts;no-sink-common-insts>,instcombine,cj-loop-float-opt,loop(loop-idiom,indvars,loop-deletion,loop-unroll-full),sroa,mldst-motion<no-split-footer-bb>,gvn<>,sccp,bdce,instcombine,jump-threading,correlated-propagation,adce,memcpyopt,cj-rssce,dse,loop-mssa(licm<allowspeculation>),coro-elide,simplifycfg<bonus-inst-threshold=1;no-forward-switch-cond;switch-range-to-icmp;no-switch-to-lookup;keep-loops;hoist-common-insts;sink-common-insts>,instcombine),coro-split)),coro-cleanup,globalopt,globaldce,rpo-function-attrs,recompute-globalsaa,cgscc(function-attrs),function<eager-inv>(irce,simplifycfg<bonus-inst-threshold=1;no-forward-switch-cond;switch-range-to-icmp;no-switch-to-lookup;keep-loops;no-hoist-common-insts;no-sink-common-insts>,loop(simple-loop-unswitch<no-nontrivial;trivial>),loop-mssa(licm<allowspeculation>),gvn<>,memcpyopt,cj-rssce,dse,mldst-motion<no-split-footer-bb>),function<eager-inv>(float2int,lower-constant-intrinsics,loop(loop-rotate,loop-deletion),loop-distribute,inject-tli-mappings,loop-vectorize<no-interleave-forced-only;no-vectorize-forced-only;>,loop-load-elim,instcombine,simplifycfg<bonus-inst-threshold=1;forward-switch-cond;switch-range-to-icmp;switch-to-lookup;no-keep-loops;hoist-common-insts;sink-common-insts>,slp-vectorizer,vector-combine,instcombine,loop-unroll<O2>,transform-warning,instcombine,require<opt-remark-emit>,loop-mssa(licm<allowspeculation>),alignment-from-assumptions,loop(indvars),early-cse<>,loop-sink,instsimplify,div-rem-pairs,tailcallelim,simplifycfg<bonus-inst-threshold=1;no-forward-switch-cond;switch-range-to-icmp;no-switch-to-lookup;keep-loops;no-hoist-common-insts;no-sink-common-insts>),elim-avail-extern,globaldce,constmerge,cg-profile,rel-lookup-table-converter,function(annotation-remarks),cangjie-specific-opt,place-safepoints,cj-barrier-opt,rewrite-statepoints-for-cangjie-gc"
				break
			}
		}

		fmt.Println("重写为：", argsToUse)
	}

	return ExecuteWithArgs(exeName, argsToUse)
}

func main() {
	exitCode, err := OverrideArgs("opt.old")
	if err != nil {
		fmt.Fprintf(os.Stderr, "执行失败: %v\n", err)
	}

	os.Exit(exitCode)
}
