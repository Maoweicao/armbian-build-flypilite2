# FLY TFT屏幕支持 - 快速入门

## 快速开始

### 方法1: 使用自动脚本（推荐）

#### Linux/Mac用户:
```bash
# 下载并运行脚本
wget https://raw.githubusercontent.com/Maoweicao/armbian-build-flypilite2/main/add-tft-support.sh
chmod +x add-tft-support.sh
sudo ./add-tft-support.sh
```

#### Windows用户:
1. 下载 `add-tft-support.bat`
2. 以管理员身份运行
3. 按照提示操作

### 方法2: 手动配置

#### FLY H3:
```bash
# 1. 复制覆盖文件
sudo cp overlay/sun8i-h3/sun8i-h3-FLY-TFT-V1-0.dtbo /boot/dtb/allwinner/overlay/

# 2. 编辑配置
echo "overlays=usbhost2 usbhost3 sun8i-h3-FLY-TFT-V1-0" | sudo tee -a /boot/armbianEnv.txt

# 3. 重启
sudo reboot
```

#### FLY H618:
```bash
# 1. 编译覆盖文件
./compile-dtbo.sh patch/kernel/archive/sunxi-6.18/overlay_64/sun50i-h616-tft35_spi.dtso

# 2. 复制覆盖文件
sudo cp sun50i-h616-tft35_spi.dtbo /boot/dtb/allwinner/overlay/

# 3. 编辑配置
echo "overlays=sun50i-h616-tft35_spi" | sudo tee -a /boot/armbianEnv.txt

# 4. 重启
sudo reboot
```

## 文件说明

### 脚本文件
| 文件 | 说明 | 使用场景 |
|------|------|----------|
| `add-tft-support.sh` | Linux/Mac自动安装脚本 | 在Linux系统中直接安装 |
| `add-tft-support.bat` | Windows自动安装脚本 | 在Windows中烧录SD卡后安装 |
| `compile-dtbo.sh` | 编译设备树覆盖文件 | 需要编译dtso文件时 |

### 文档文件
| 文件 | 说明 |
|------|------|
| `TFT-SCREEN-SETUP.md` | 完整配置指南 |
| `TFT-SETUP-README.md` | 本快速入门指南 |

### 覆盖文件
| 板子 | 文件 | 位置 |
|------|------|------|
| FLY H3 | `sun8i-h3-FLY-TFT-V1-*.dtbo` | `overlay/sun8i-h3/` |
| FLY H618 | `sun50i-h616-tft35_spi.dtbo` | 需要编译 |

## 常见问题

### Q: 如何选择TFT屏幕旋转角度？
A: FLY H3支持多种旋转角度：
- `sun8i-h3-FLY-TFT-V1-0.dtbo` - 0度（默认）
- `sun8i-h3-FLY-TFT-V1-90.dtbo` - 90度
- `sun8i-h3-FLY-TFT-V1-180.dtbo` - 180度
- `sun8i-h3-FLY-TFT-V1-270.dtbo` - 270度

### Q: 如何检查TFT屏幕是否工作？
A: 运行以下命令：
```bash
# 检查SPI设备
ls /dev/spidev*

# 检查显示设备
ls /dev/fb*

# 查看内核日志
dmesg | grep -i spi
dmesg | grep -i drm
```

### Q: 编译dtbo文件失败怎么办？
A: 确保安装了设备树编译器：
```bash
# Ubuntu/Debian
sudo apt-get install device-tree-compiler

# CentOS/RHEL
sudo yum install dtc

# Arch Linux
sudo pacman -S dtc
```

### Q: Windows下如何编译dtbo文件？
A: 使用以下方法之一：
1. 在WSL（Windows Subsystem for Linux）中编译
2. 使用虚拟机中的Linux系统
3. 使用Docker容器

## 技术支持

- 完整文档：`TFT-SCREEN-SETUP.md`
- GitHub Issues: https://github.com/Maoweicao/armbian-build-flypilite2/issues
- Armbian论坛: https://forum.armbian.com

## 注意事项

1. **备份数据**：修改前备份重要数据
2. **正确卸载**：修改SD卡后先卸载再拔出
3. **电源稳定**：确保TFT屏幕电源稳定
4. **连接检查**：检查排线连接是否正确

## 更新日志

- 2026-05-30: 创建快速入门指南
- 2026-05-30: 添加自动安装脚本
- 2026-05-30: 添加编译脚本文档