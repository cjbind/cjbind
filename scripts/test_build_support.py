# /// script
# requires-python = ">=3.13"
# dependencies = ["requests", "tqdm"]
# ///
"""Exercise library selection and failed dependency upgrades without networking."""

from __future__ import annotations

import os
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

import cjpm
import download


class LibClangSearchTest(unittest.TestCase):
    def setUp(self) -> None:
        self.temp = tempfile.TemporaryDirectory(prefix="cjbind-libclang-search-")
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.custom = self.root / "custom"
        self.system = self.root / "system"
        self.custom.mkdir()
        self.system.mkdir()
        self.enterContext(patch.object(cjpm.sys, "platform", "linux"))
        self.enterContext(patch.dict(cjpm.LIBCLANG_SEARCH_DIRS, {"linux": [str(self.system)]}))

    def find(self, *directories: Path):
        with patch.dict(os.environ, {"LIBCLANG_PATH": os.pathsep.join(map(str, directories))}):
            return cjpm.find_libclang()

    def test_explicit_unversioned_library_wins_over_system_version(self) -> None:
        (self.custom / "libclang.so").touch()
        (self.system / "libclang-23.so").touch()
        self.assertEqual(self.find(self.custom), (self.custom, "libclang.so", True))

    def test_explicit_runtime_library_wins_over_system_development_library(self) -> None:
        (self.custom / "libclang.so.17").touch()
        (self.system / "libclang-23.so").touch()
        self.assertEqual(self.find(self.custom), (self.custom, "libclang.so.17", False))

    def test_explicit_search_directories_keep_their_order(self) -> None:
        (self.custom / "libclang-17.so").touch()
        (self.system / "libclang-23.so").touch()
        self.assertEqual(self.find(self.custom, self.system), (self.custom, "libclang-17.so", True))

    def test_empty_explicit_directory_falls_back_to_system(self) -> None:
        (self.system / "libclang-23.so").touch()
        self.assertEqual(self.find(self.custom), (self.system, "libclang-23.so", True))


class LibClangInstallTest(unittest.TestCase):
    def setUp(self) -> None:
        self.temp = tempfile.TemporaryDirectory(prefix="cjbind-libclang-install-")
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        # Do not construct a network/platform-specific installer for these tests.
        self.installer = download.LibClangInstaller.__new__(download.LibClangInstaller)
        self.installer.target_dir = self.root / "lib"
        self.installer.temp_dir = self.root / "download"
        self.installer.extract_dir = self.root / "extract"
        self.installer.temp_dir.mkdir()
        self.installer.extract_dir.mkdir()
        self.existing = self.installer.target_dir / "libclang"
        self.existing.mkdir(parents=True)
        (self.existing / "old.a").write_bytes(b"working old library")
        self.source = self.installer.extract_dir / "libclang"
        self.source.mkdir()
        (self.source / "new.a").write_bytes(b"replacement library")

    def assert_old_installation(self) -> None:
        self.assertEqual((self.existing / "old.a").read_bytes(), b"working old library")
        self.assertFalse((self.existing / "new.a").exists())

    def test_download_failure_preserves_installation(self) -> None:
        with patch.object(self.installer, "_download_file", side_effect=RuntimeError("offline")):
            with self.assertRaisesRegex(RuntimeError, "offline"):
                self.installer.run()
        self.assert_old_installation()

    def test_extraction_failure_preserves_installation(self) -> None:
        with patch.object(self.installer, "_download_file"), patch.object(
            self.installer, "_extract_archive", side_effect=RuntimeError("invalid archive")
        ):
            with self.assertRaisesRegex(RuntimeError, "invalid archive"):
                self.installer.run()
        self.assert_old_installation()

    def test_missing_library_directory_preserves_installation(self) -> None:
        with patch.object(self.installer, "_find_libclang_dir", side_effect=FileNotFoundError("libclang")):
            with self.assertRaises(FileNotFoundError):
                self.installer._install_files()
        self.assert_old_installation()

    def test_staging_copy_failure_preserves_installation(self) -> None:
        with patch.object(download.shutil, "move", side_effect=OSError("disk full")):
            with self.assertRaisesRegex(OSError, "disk full"):
                self.installer._install_files()
        self.assert_old_installation()

    def test_failed_final_rename_restores_installation(self) -> None:
        original_rename = Path.rename

        def fail_new(source: Path, target: Path):
            if source.name == "new":
                raise OSError("replacement denied")
            return original_rename(source, target)

        with patch.object(Path, "rename", fail_new):
            with self.assertRaisesRegex(OSError, "replacement denied"):
                self.installer._install_files()
        self.assert_old_installation()
        self.assertEqual(list(self.installer.target_dir.glob(".libclang-stage-*")), [])

    def test_failed_rollback_retains_recoverable_backup(self) -> None:
        original_rename = Path.rename

        def fail_new_and_restore(source: Path, target: Path):
            if source.name in ("new", "previous"):
                raise OSError("rename denied")
            return original_rename(source, target)

        with patch.object(Path, "rename", fail_new_and_restore):
            with self.assertRaisesRegex(RuntimeError, "previous libclang is preserved at"):
                self.installer._install_files()
        backups = list(self.installer.target_dir.glob(".libclang-stage-*/previous/old.a"))
        self.assertEqual(len(backups), 1)
        self.assertEqual(backups[0].read_bytes(), b"working old library")

    def test_interrupted_replacement_restores_installation(self) -> None:
        original_rename = Path.rename

        def interrupt_new(source: Path, target: Path):
            if source.name == "new":
                raise KeyboardInterrupt()
            return original_rename(source, target)

        with patch.object(Path, "rename", interrupt_new):
            with self.assertRaises(KeyboardInterrupt):
                self.installer._install_files()
        self.assert_old_installation()

    def test_success_replaces_without_retaining_stale_libraries(self) -> None:
        self.installer._install_files()
        self.assertFalse((self.existing / "old.a").exists())
        self.assertEqual((self.existing / "new.a").read_bytes(), b"replacement library")
        self.assertEqual(list(self.installer.target_dir.glob(".libclang-stage-*")), [])


if __name__ == "__main__":
    unittest.main()
