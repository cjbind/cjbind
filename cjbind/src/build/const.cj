package cjbind.build

import cjbind.build.macros.{env, exec}

public const VERSION: String = @env("CJBIND_VERSION")
public const COMMIT_HASH: String = @exec("git rev-parse HEAD")
public const COMMIT_DATE: String = @exec("git log -1 --format=%ci HEAD")

public const TAG: String = @exec("git tag --points-at HEAD")

public const GIT_CLEAN_FILES: String = @exec("git status --porcelain")