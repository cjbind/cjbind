import os
import sys
import shutil
import subprocess
import platform
import sys

if sys.platform.startswith('win'):
    try:
        sys.stdout.reconfigure(encoding='utf-8')
        sys.stderr.reconfigure(encoding='utf-8')
    except AttributeError:
        import io
        sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')

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
    
    # 编译 opt.go
    current_dir = os.path.dirname(os.path.abspath(__file__))
    opt_go_path = os.path.join(current_dir, 'opt.go')
    
    if not os.path.exists(opt_go_path):
        print(f"错误: 找不到 {opt_go_path}")
        sys.exit(1)
    
    print(f"编译 {opt_go_path} 到 {opt_path}")
    try:
        # 使用 go build 编译
        build_cmd = ['go', 'build', '-o', opt_path, opt_go_path]
        subprocess.run(build_cmd, check=True)
        print("编译成功")
    except subprocess.CalledProcessError as e:
        print(f"编译失败: {e}")
        sys.exit(1)

if __name__ == "__main__":
    patch()