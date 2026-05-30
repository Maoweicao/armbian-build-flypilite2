#!/bin/bash
# 编译设备树覆盖文件的脚本
# 用法: ./compile-dtbo.sh [input.dtso] [output.dtbo]

set -e

INPUT_FILE="${1:-}"
OUTPUT_FILE="${2:-}"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查dtc是否安装
check_dtc() {
    if ! command -v dtc &> /dev/null; then
        log_error "未找到设备树编译器(dtc)"
        log_info "请安装dtc:"
        log_info "  Ubuntu/Debian: sudo apt-get install device-tree-compiler"
        log_info "  CentOS/RHEL: sudo yum install dtc"
        log_info "  Arch Linux: sudo pacman -S dtc"
        exit 1
    fi
}

# 编译dtso为dtbo
compile_dtbo() {
    local input="$1"
    local output="$2"
    
    if [ ! -f "$input" ]; then
        log_error "输入文件不存在: $input"
        exit 1
    fi
    
    # 如果未指定输出文件，使用输入文件名，但更改扩展名
    if [ -z "$output" ]; then
        output="${input%.dtso}.dtbo"
    fi
    
    log_info "编译设备树覆盖文件..."
    log_info "输入: $input"
    log_info "输出: $output"
    
    # 使用dtc编译
    # -@: 允许符号引用
    # -I dts: 输入格式为dts源码
    # -O dtb: 输出格式为dtb二进制
    # -o: 输出文件
    dtc -@ -I dts -O dtb -o "$output" "$input"
    
    if [ $? -eq 0 ]; then
        log_info "编译成功!"
        log_info "文件大小: $(ls -lh "$output" | awk '{print $5}')"
    else
        log_error "编译失败"
        exit 1
    fi
}

# 显示帮助
show_help() {
    echo "用法: $0 [选项] <输入文件> [输出文件]"
    echo ""
    echo "选项:"
    echo "  -h, --help     显示此帮助信息"
    echo "  -c, --check    检查dtc是否安装"
    echo "  -a, --all      编译所有dtso文件"
    echo ""
    echo "示例:"
    echo "  $0 input.dtso output.dtbo"
    echo "  $0 input.dtso"
    echo "  $0 -a"
    echo ""
    echo "编译所有H616 TFT覆盖文件:"
    echo "  $0 -a"
}

# 编译所有dtso文件
compile_all() {
    log_info "编译所有设备树覆盖文件..."
    
    local count=0
    local success=0
    
    # 查找所有dtso文件
    for dtso in $(find . -name "*.dtso" -type f); do
        count=$((count + 1))
        dtbo="${dtso%.dtso}.dtbo"
        
        log_info "编译: $dtso -> $dtbo"
        if dtc -@ -I dts -O dtb -o "$dtbo" "$dtso" 2>/dev/null; then
            success=$((success + 1))
            log_info "成功: $dtbo"
        else
            log_warn "失败: $dtso"
        fi
    done
    
    log_info "编译完成: $success/$count 个文件成功"
}

# 主函数
main() {
    case "${1:-}" in
        -h|--help)
            show_help
            exit 0
            ;;
        -c|--check)
            check_dtc
            log_info "dtc已安装: $(dtc --version)"
            exit 0
            ;;
        -a|--all)
            check_dtc
            compile_all
            exit 0
            ;;
        "")
            show_help
            exit 1
            ;;
        *)
            check_dtc
            compile_dtbo "$1" "${2:-}"
            ;;
    esac
}

# 运行主函数
main "$@"