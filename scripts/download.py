import platform
import logging
import shutil
from pathlib import Path
from typing import List, Tuple
from pysmartdl2 import SmartDL
import py7zr
import tempfile

LLVM_VERSION = "19.1.7"

# 全局配置常量
URL_TEMPLATES = [
    "https://github.com/cjbind/libclang-static/releases/download/{version}/{os}-{arch}.7z"
]

# 日志配置
logging.basicConfig(
    level=logging.INFO,
    format="[%(asctime)s] [%(levelname)s] %(message)s",
    handlers=[logging.StreamHandler()]
)
logger = logging.getLogger(__name__)


class SystemInfo:
    """系统信息检测类"""
    OS_MAPPING = {
        "Windows": "windows",
        "Darwin": "macos",
        "Linux": "linux"
    }

    ARCH_MAPPING = {
        "x86_64": "x64",
        "amd64": "x64",
        "aarch64": "arm64",
        "arm64": "arm64"
    }

    @classmethod
    def detect_platform(cls) -> Tuple[str, str]:
        """检测并返回标准化系统信息"""
        system = platform.system()
        arch = platform.machine().lower()

        os_name = cls.OS_MAPPING.get(system)
        arch_name = cls.ARCH_MAPPING.get(arch, arch)

        if not os_name:
            raise ValueError(f"不支持的操作系统: {system}")
        if arch_name not in ("x64", "arm64"):
            raise ValueError(f"不支持的处理器架构: {arch}")

        if os_name == "macos":
            arch_name = "universal"

        return os_name, arch_name


class DownloadManager:
    """下载管理类"""

    def __init__(self):
        self.url_templates = URL_TEMPLATES
        self.download_config = {
            "timeout": 30,
            "connections": 5,
            "progress_bar": True
        }

    def generate_urls(self, os_name: str, arch: str) -> List[str]:
        """生成实际下载URL列表"""
        return [
            template.format(os=os_name, arch=arch, version=LLVM_VERSION)
            for template in self.url_templates
        ]

    def download(self, urls: List[str], dest_dir: Path) -> Path:
        """执行多源下载"""
        dest_file = dest_dir / "lib.7z"

        logger.info("启动下载任务")
        logger.debug("下载参数: %s", self.download_config)
        logger.debug("目标路径: %s", dest_file)

        try:
            downloader = SmartDL(
                urls,
                dest=str(dest_file),
                progress_bar=self.download_config["progress_bar"],
                timeout=self.download_config["timeout"],
                threads=self.download_config["connections"]
            )
            downloader.start(blocking=True)
        except Exception as e:
            raise RuntimeError(f"下载失败: {str(e)}") from e

        if not downloader.isSuccessful:
            errors = "\n".join(str(e) for e in downloader.get_errors())
            raise RuntimeError(f"下载错误:\n{errors}")

        logger.info("文件下载完成: %s", dest_file)
        return dest_file


class ArchiveHandler:
    """压缩包处理类"""
    @staticmethod
    def process_archive(archive_path: Path, target_root: Path) -> None:
        """处理整个解压流程"""
        logger.info("开始处理压缩包")

        with tempfile.TemporaryDirectory() as temp_dir:
            # 解压阶段
            extracted_dir = ArchiveHandler._extract_archive(
                archive_path, Path(temp_dir))

            # 复制阶段
            ArchiveHandler._copy_files(
                source_dir=extracted_dir,
                target_dir=target_root
            )

    @staticmethod
    def _extract_archive(archive_path: Path, dest_dir: Path) -> Path:
        """解压7z文件到临时目录"""
        try:
            with py7zr.SevenZipFile(archive_path, mode='r') as z:
                z.extractall(dest_dir)
        except Exception as e:
            raise RuntimeError(f"解压失败: {str(e)}") from e

        lib_dir = dest_dir / "lib"
        if not lib_dir.exists():
            raise FileNotFoundError("压缩包中缺少lib目录")

        return lib_dir

    @staticmethod
    def _copy_files(source_dir: Path, target_dir: Path) -> None:
        """递归复制文件并跳过已存在文件"""
        target_dir.mkdir(parents=True, exist_ok=True)

        for src_path in source_dir.glob("**/*"):
            if src_path.is_dir():
                continue

            relative_path = src_path.relative_to(source_dir)
            dest_path = target_dir / relative_path

            if dest_path.exists():
                logger.debug("跳过已存在文件: %s", dest_path)
                continue

            dest_path.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(src_path, dest_path)
            logger.debug("已复制文件: %s -> %s", src_path.name, dest_path)


def main():
    try:
        # 获取系统信息
        os_name, arch = SystemInfo.detect_platform()
        logger.info("检测到系统环境: %s-%s", os_name, arch)

        # 初始化下载管理器
        downloader = DownloadManager()
        urls = downloader.generate_urls(os_name, arch)
        logger.info("生成的下载地址: %s", urls[0])

        # 执行下载
        with tempfile.TemporaryDirectory() as tmp_dir:
            archive_path = downloader.download(urls, Path(tmp_dir))

            # 处理压缩包
            script_dir = Path(__file__).parent.resolve()
            target_dir = script_dir.parent / "lib"
            ArchiveHandler.process_archive(archive_path, target_dir)

        logger.info("操作成功完成")

    except Exception as e:
        logger.error("程序执行失败: %s", str(e), exc_info=True)
        raise


if __name__ == "__main__":
    main()
