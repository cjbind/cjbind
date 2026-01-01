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
			if argsToUse[i] == "-passes=default<O2>" {
				argsToUse[i] = "-passes=__PASSES_PLACEHOLDER__"
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
