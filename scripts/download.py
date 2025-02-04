import platform
import logging
import shutil
from pathlib import Path
from typing import List, Tuple
from pysmartdl2 import SmartDL
import tempfile
import gzip

LLVM_VERSION = "19.1.7"

# 全局配置常量
URL_TEMPLATES = [
    "https://github.com/cjbind/libclang-static/releases/download/{version}-libclang/libclang-full-{os}-{arch}.a.gz"
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
        """执行下载"""
        dest_file = dest_dir / "libclang-full.a.gz"

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

        Path(target_root).mkdir(parents=True, exist_ok=True)
        target_file = Path(target_root) / "libclang-full.a"

        logger.info("解压缩文件 %s 到 %s", archive_path, target_file)
        with gzip.open(archive_path, "rb") as fin, open(target_file, "wb") as fout:
            shutil.copyfileobj(fin, fout)
        logger.info("解压完成")

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
