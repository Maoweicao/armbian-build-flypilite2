#!/bin/bash
# 为FLY H3/H618添加TFT屏幕支持的脚本
# 使用方法: sudo ./add-tft-support.sh [board_type]
# board_type: fly-h3 或 fly-h618 (默认自动检测)

set -e

BOARD_TYPE="${1:-}"
OVERLAY_DIR="/boot/dtb/allwinner/overlay"
ENV_FILE="/boot/armbianEnv.txt"

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

# 检测板子类型
detect_board() {
    if [ -f "/boot/dtb/allwinner/sun8i-h3-fly-h3.dtb" ]; then
        echo "fly-h3"
    elif [ -f "/boot/dtb/allwinner/sun50i-h618-fly-h618.dtb" ]; then
        echo "fly-h618"
    else
        echo "unknown"
    fi
}

# 检查是否为root用户
check_root() {
    if [ "$EUID" -ne 0 ]; then
        log_error "请使用sudo运行此脚本"
        exit 1
    fi
}

# 复制覆盖文件
copy_overlays() {
    local board=$1
    local src_dir=""
    
    case $board in
        fly-h3)
            src_dir="overlay/sun8i-h3"
            # 复制所有FLY TFT覆盖文件
            for dtbo in "$src_dir"/sun8i-h3-FLY-TFT-V1-*.dtbo; do
                if [ -f "$dtbo" ]; then
                    cp -v "$dtbo" "$OVERLAY_DIR/"
                    log_info "已复制: $(basename $dtbo)"
                fi
            done
            ;;
        fly-h618)
            # 对于H618，使用H616的TFT覆盖
            if [ -f "patch/kernel/archive/sunxi-6.18/overlay_64/sun50i-h616-tft35_spi.dtso" ]; then
                # 需要编译dtso为dtbo
                if command -v dtc &> /dev/null; then
                    dtc -@ -I dts -O dtb -o "$OVERLAY_DIR/sun50i-h616-tft35_spi.dtbo" \
                        "patch/kernel/archive/sunxi-6.18/overlay_64/sun50i-h616-tft35_spi.dtso"
                    log_info "已编译并复制: sun50i-h616-tft35_spi.dtbo"
                else
                    log_warn "未找到dtc编译器，请手动编译dtso文件"
                    log_warn "或从编译环境中复制预编译的dtbo文件"
                    return 1
                fi
            else
                log_error "未找到TFT覆盖源文件"
                return 1
            fi
            ;;
        *)
            log_error "不支持的板子类型: $board"
            return 1
            ;;
    esac
}

# 更新armbianEnv.txt
update_env_file() {
    local board=$1
    local overlay_name=""
    
    case $board in
        fly-h3)
            overlay_name="sun8i-h3-FLY-TFT-V1-0"
            ;;
        fly-h618)
            overlay_name="sun50i-h616-tft35_spi"
            ;;
    esac
    
    if [ -z "$overlay_name" ]; then
        log_error "未找到对应的覆盖名称"
        return 1
    fi
    
    # 备份原文件
    if [ -f "$ENV_FILE" ]; then
        cp "$ENV_FILE" "${ENV_FILE}.bak"
        log_info "已备份: ${ENV_FILE}.bak"
    fi
    
    # 检查是否已有overlays配置
    if grep -q "^overlays=" "$ENV_FILE"; then
        # 检查是否已包含该覆盖
        if grep -q "overlays=.*$overlay_name" "$ENV_FILE"; then
            log_info "覆盖 $overlay_name 已存在于配置中"
            return 0
        fi
        
        # 追加到现有overlays
        sed -i "s/^overlays=\(.*\)/overlays=\1 $overlay_name/" "$ENV_FILE"
        log_info "已追加覆盖: $overlay_name"
    else
        # 添加新的overlays配置
        echo "" >> "$ENV_FILE"
        echo "# TFT屏幕支持" >> "$ENV_FILE"
        echo "overlays=$overlay_name" >> "$ENV_FILE"
        log_info "已添加覆盖配置: $overlay_name"
    fi
}

# 主函数
main() {
    log_info "FLY TFT屏幕支持安装脚本"
    log_info "=========================="
    
    # 检查root权限
    check_root
    
    # 检测板子类型
    if [ -z "$BOARD_TYPE" ]; then
        BOARD_TYPE=$(detect_board)
        if [ "$BOARD_TYPE" = "unknown" ]; then
            log_error "无法检测板子类型，请手动指定: fly-h3 或 fly-h618"
            exit 1
        fi
        log_info "检测到板子类型: $BOARD_TYPE"
    fi
    
    # 检查overlay目录
    if [ ! -d "$OVERLAY_DIR" ]; then
        log_error "覆盖目录不存在: $OVERLAY_DIR"
        exit 1
    fi
    
    # 复制覆盖文件
    log_info "正在复制覆盖文件..."
    if ! copy_overlays "$BOARD_TYPE"; then
        log_error "复制覆盖文件失败"
        exit 1
    fi
    
    # 更新配置文件
    log_info "正在更新配置文件..."
    if ! update_env_file "$BOARD_TYPE"; then
        log_error "更新配置文件失败"
        exit 1
    fi
    
    log_info "=========================="
    log_info "安装完成！"
    log_info "请重启系统以启用TFT屏幕支持"
    log_info "重启命令: sudo reboot"
    
    # 显示当前配置
    log_info "当前覆盖配置:"
    grep "^overlays=" "$ENV_FILE" || echo "(未配置)"
}

# 显示帮助
show_help() {
    echo "用法: sudo $0 [板子类型]"
    echo ""
    echo "板子类型:"
    echo "  fly-h3    - FLY H3开发板"
    echo "  fly-h618  - FLY H618开发板"
    echo ""
    echo "示例:"
    echo "  sudo $0 fly-h3"
    echo "  sudo $0 fly-h618"
    echo "  sudo $0  # 自动检测"
}

# 处理参数
case "${1:-}" in
    -h|--help)
        show_help
        exit 0
        ;;
    *)
        main
        ;;
esac