package cjbind.build

import cjbind.build.macros.{exec, env}

public const VERSION = "0.1.1"
public const COMMIT_HASH: String = @exec("git rev-parse HEAD")
public const COMMIT_DATE: String = @exec("git log -1 --format=%ci HEAD")

public const BRANCH: String = @env("GITHUB_REF_NAME")
public const TAG: String = @exec("git tag --points-at HEAD")

public const GIT_CLEAN_FILES: String = @exec("git status --porcelain")