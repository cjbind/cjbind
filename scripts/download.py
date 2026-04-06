# /// script
# requires-python = ">=3.13"
# dependencies = [
#     "requests",
#     "tqdm",
# ]
# ///

import json
import platform
import shutil
import subprocess
import sys
from pathlib import Path
from tempfile import mkdtemp
from typing import Optional

import requests
from tqdm import tqdm


class LibClangInstaller:
    """用于自动下载和安装 libclang 的安装器"""

    def __init__(self):
        self.base_dir = Path(__file__).parent.resolve()
        self.url_map = self._load_url_map()
        self.system_key = self._detect_system()
        self.download_url = self._get_download_url()
        self.temp_dir = Path(mkdtemp(prefix="libclang_"))
        self.temp_archive = self.temp_dir / "libclang.7z"
        self.target_dir = self.base_dir.parent / "lib"
        self.extract_dir: Optional[Path] = None

    def _load_url_map(self) -> dict[str, str]:
        """从 libclang.json 加载下载地址"""
        json_path = self.base_dir / "libclang.json"
        with open(json_path, "r", encoding="utf-8") as f:
            data = json.load(f)
        return data["urls"]

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
        url = self.url_map.get(self.system_key)
        if not url:
            raise RuntimeError(
                f"No download URL configured for {self.system_key}")
        return url

    @staticmethod
    def _find_7z() -> str:
        """查找 7z 可执行文件"""
        candidates = ["7z"]
        if sys.platform == "win32":
            candidates.extend([
                r"C:\Program Files\7-Zip\7z.exe",
                r"C:\Program Files (x86)\7-Zip\7z.exe",
            ])
        for candidate in candidates:
            if shutil.which(candidate):
                return candidate
        # Check Windows paths directly
        for candidate in candidates[1:]:
            if Path(candidate).is_file():
                return candidate
        raise RuntimeError(
            "7z not found. Please install 7-Zip: https://7-zip.org/")

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
        """使用系统 7z 命令解压（py7zr 不支持 BCJ2 过滤器）"""
        self.extract_dir = Path(mkdtemp(prefix="libclang_extract_"))
        seven_z = self._find_7z()

        print("Extracting...")
        result = subprocess.run(
            [seven_z, "x", str(self.temp_archive), f"-o{self.extract_dir}", "-y"],
            capture_output=True,
            text=True,
        )
        if result.returncode != 0:
            self._cleanup()
            raise RuntimeError(f"Extraction failed: {result.stderr}")

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
        print(f"Successfully installed to: {libclang_dest}")

    def _cleanup(self) -> None:
        """清理临时文件"""
        if self.temp_dir.exists():
            shutil.rmtree(self.temp_dir, ignore_errors=True)
        if self.extract_dir and self.extract_dir.exists():
            shutil.rmtree(self.extract_dir, ignore_errors=True)

    def _remove_old_libclang(self) -> None:
        """清除旧的 libclang 目录，确保不会残留不兼容的文件"""
        libclang_dest = self.target_dir / "libclang"
        if libclang_dest.exists():
            print(f"Removing old libclang: {libclang_dest}")
            shutil.rmtree(libclang_dest)

    def run(self) -> None:
        """执行安装流程"""
        try:
            self.target_dir.mkdir(parents=True, exist_ok=True)
            self._remove_old_libclang()
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
