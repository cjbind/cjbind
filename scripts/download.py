import os
import platform
import shutil
import sys
from pathlib import Path
from tempfile import mkdtemp
from typing import Optional

import requests
import py7zr
from py7zr.callbacks import ExtractCallback
from tqdm import tqdm


class LibClangInstaller:
    """用于自动下载和安装 libclang 的安装器"""

    URL_MAP = {
        "windows": "https://download.qt.io/development_releases/prebuilt/libclang/qt/libclang-llvmorg-19.1.7-windows11-llvm-mingw_64.7z",
        "macos": "https://download.qt.io/development_releases/prebuilt/libclang/qt/libclang-llvmorg-19.1.7-macos-universal.7z",
        "linux-x86_64": "https://download.qt.io/development_releases/prebuilt/libclang/qt/libclang-llvmorg-19.1.7-linux-Ubuntu22.04-gcc11.2-x86_64.7z",
        "linux-arm64": "https://download.qt.io/development_releases/prebuilt/libclang/qt/libclang-llvmorg-19.1.7-linux-Ubuntu24.04-gcc11.2-arm64.7z",
    }

    def __init__(self):
        self.system_key = self._detect_system()
        self.download_url = self._get_download_url()
        self.base_dir = Path(__file__).parent.resolve()
        self.temp_archive = self.base_dir / "temp_libclang.7z"
        self.target_dir = self.base_dir.parent / "lib"
        self.extract_dir: Optional[Path] = None

    def _detect_system(self) -> str:
        """检测操作系统和架构"""
        system = platform.system().lower()
        machine = platform.machine().lower()

        if system == "windows":
            return "windows"
        if system == "darwin":
            return "macos"
        if system == "linux":
            return "linux-arm64" if machine in ("arm64", "aarch64") else "linux-x86_64"
        raise RuntimeError(f"Unsupported system: {system}/{machine}")

    def _get_download_url(self) -> str:
        """获取对应系统的下载地址"""
        url = self.URL_MAP.get(self.system_key)
        if not url:
            raise RuntimeError(f"No download URL configured for {self.system_key}")
        return url

    def _download_file(self) -> None:
        """下载压缩文件并显示进度条"""
        print(f"Downloading libclang for {self.system_key}...")

        try:
            with requests.get(self.download_url, stream=True, timeout=30) as response:
                response.raise_for_status()
                total_size = int(response.headers.get('content-length', 0))

                with tqdm(
                    total=total_size,
                    unit='B',
                    unit_scale=True,
                    desc="Downloading",
                ) as pbar:
                    with open(self.temp_archive, 'wb') as f:
                        for chunk in response.iter_content(chunk_size=8192):
                            f.write(chunk)
                            pbar.update(len(chunk))
        except Exception as e:
            self._cleanup()
            raise RuntimeError(f"Download failed: {str(e)}")

    def _extract_archive(self) -> None:
        """解压下载的文件"""
        try:
            self.extract_dir = Path(mkdtemp())
            with py7zr.SevenZipFile(self.temp_archive, 'r') as archive:
                class TqdmExtractCallback(ExtractCallback):
                        def __init__(self):
                            super().__init__()

                            info = archive.archiveinfo().uncompressed

                            self.pendingSize = None
                            self.pbar = tqdm(
                                total=info,
                                unit='B',
                                unit_scale=True,
                                miniters=1,
                                desc="Extracting",
                            )

                        def report_start(self, processing_file_path, processing_bytes):
                            pass

                        def report_update(self, decompressed_bytes):
                            self.pbar.update(int(decompressed_bytes))

                        def report_end(self, processing_file_path, wrote_bytes):
                            pass

                        def report_start_preparation(self):
                            pass

                        def report_warning(self, message):
                            print(f"Warning: {message}")

                        def report_postprocess(self):
                            pass
                        
                cb = TqdmExtractCallback()
                archive.extractall(path=self.extract_dir, callback=cb)
                    
        except Exception as e:
            self._cleanup()
            raise RuntimeError(f"Extraction failed: {str(e)}")

    def _find_libclang_dir(self) -> Path:
        """查找解压后的 libclang 目录"""
        if not self.extract_dir:
            raise RuntimeError("No extraction directory found")

        for path in self.extract_dir.rglob("libclang"):
            if path.is_dir():
                return path
        raise FileNotFoundError("libclang directory not found in the archive")

    def _install_files(self) -> None:
        """移动文件到目标目录"""
        libclang_src = self._find_libclang_dir()
        libclang_dest = self.target_dir / "libclang"

        if libclang_dest.exists():
            shutil.rmtree(libclang_dest)

        shutil.move(str(libclang_src), str(libclang_dest))
        print(f"\nSuccessfully installed to: {libclang_dest}")

    def _cleanup(self) -> None:
        """清理临时文件"""
        self.temp_archive.unlink(missing_ok=True)
        if self.extract_dir and self.extract_dir.exists():
            shutil.rmtree(self.extract_dir, ignore_errors=True)

    def run(self) -> None:
        """执行安装流程"""
        try:
            self.target_dir.mkdir(parents=True, exist_ok=True)
            self._download_file()
            self._extract_archive()
            self._install_files()
        finally:
            self._cleanup()


if __name__ == "__main__":
    try:
        installer = LibClangInstaller()
        installer.run()
    except Exception as e:
        print(f"\nError: {str(e)}")
        sys.exit(1)
