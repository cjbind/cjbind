import os
import sys
import shutil
import subprocess
import platform
import tempfile

if sys.platform.startswith('win'):
    try:
        sys.stdout.reconfigure(encoding='utf-8')
        sys.stderr.reconfigure(encoding='utf-8')
    except AttributeError:
        import io
        sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')


PASSES_TO_REMOVE = {
    'BitcodeWriterPass',
    'cangjie-ir-verifier',  # 此 pass 有 bug，需要移除
}


def parse_top_level_passes(passes):
    result = []
    current = []
    depth = 0

    for char in passes:
        if char == ',' and depth == 0:
            if current:
                result.append(''.join(current))
                current = []
        else:
            current.append(char)
            if char in '(<':
                depth += 1
            elif char in ')>':
                depth -= 1

    if current:
        result.append(''.join(current))

    return result


def get_pass_name(pass_str):
    for i, char in enumerate(pass_str):
        if char in '(<':
            return pass_str[:i]
    return pass_str


def filter_passes(passes):
    top_level = parse_top_level_passes(passes)
    filtered = [p for p in top_level if get_pass_name(p) not in PASSES_TO_REMOVE]
    return ','.join(filtered)


def get_passes(opt_path):
    with tempfile.NamedTemporaryFile(suffix='.bc', delete=False) as temp_file:
        temp_path = temp_file.name

    try:
        result = subprocess.check_output(
            [
                opt_path,
                "--print-pipeline-passes",
                "--cangjie-pipeline",
                "-passes=default<O2>",
                "--only-verify-out",
                temp_path,
            ],
            stderr=subprocess.STDOUT,
            text=True,
        )
        passes = result.strip()
        passes = filter_passes(passes)
        return passes
    finally:
        if os.path.exists(temp_path):
            os.remove(temp_path)


def cache_dir():
    return os.path.dirname(os.path.abspath(__file__))


def cache_path():
    return os.path.join(cache_dir(), '.passes_cache')


def read_cached_passes():
    path = cache_path()
    if os.path.exists(path):
        with open(path, 'r', encoding='utf-8') as f:
            return f.read().strip()
    return None


def write_cached_passes(passes):
    path = cache_path()
    with open(path, 'w', encoding='utf-8') as f:
        f.write(passes)
    print(f"缓存 passes 到 {path}")


def patch():
    # 获取 CANGJIE_HOME 环境变量
    cangjie_home = os.environ.get('CANGJIE_HOME')
    if not cangjie_home:
        print("错误: CANGJIE_HOME 环境变量未设置")
        sys.exit(1)

    # 确定目标文件路径
    is_windows = platform.system() == 'Windows'
    opt_suffix = '.exe' if is_windows else ''

    opt_path = os.path.join(cangjie_home, 'third_party', 'llvm', 'bin', f'opt{opt_suffix}')
    opt_old_path = os.path.join(cangjie_home, 'third_party', 'llvm', 'bin', f'opt.old{opt_suffix}')

    # 检查目标文件是否存在
    if not os.path.exists(opt_path):
        print(f"错误: 找不到 {opt_path}")
        sys.exit(1)

    # 如果 opt.old 不存在，则重命名
    if not os.path.exists(opt_old_path):
        print(f"将 {opt_path} 重命名为 {opt_old_path}")
        shutil.move(opt_path, opt_old_path)
    else:
        print(f"{opt_old_path} 已经存在，跳过重命名")

    # 检查缓存
    cached = read_cached_passes()
    if cached:
        print(f"使用缓存的 passes: {cached[:80]}...")
        passes = cached
    else:
        print(f"从 {opt_old_path} 获取最新 passes...")
        try:
            passes = get_passes(opt_old_path)
            print(f"获取到 passes: {passes[:80]}...")
            write_cached_passes(passes)
        except subprocess.CalledProcessError as e:
            print(f"获取 passes 失败: {e}")
            sys.exit(1)

    opt_go_path = os.path.join(cache_dir(), 'opt.go')

    if not os.path.exists(opt_go_path):
        print(f"错误: 找不到 {opt_go_path}")
        sys.exit(1)

    print(f"编译 {opt_go_path} 到 {opt_path}")
    try:
        build_cmd = ['go', 'build', '-o', opt_path, opt_go_path]
        subprocess.run(build_cmd, check=True)
        print("编译成功")
    except subprocess.CalledProcessError as e:
        print(f"编译失败: {e}")
        sys.exit(1)

if __name__ == "__main__":
    patch()
