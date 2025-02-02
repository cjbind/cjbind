package cjbind.build

import cjbind.build.macros.exec

public const VERSION = "0.1.0"
public const COMMIT_HASH = @exec("git rev-parse HEAD")
public const COMMIT_DATE = @exec("git log -1 --format=%ci HEAD")

public const BRANCH = @exec("git branch --show-current")
public const TAG = @exec("git tag --points-at HEAD")

public const GIT_CLEAN_FILES = @exec("git status --porcelain")