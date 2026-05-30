# FLY TFT屏幕支持工具包

## 文件清单

### 脚本文件
| 文件 | 用途 | 平台 |
|------|------|------|
| `add-tft-support.sh` | 自动安装TFT支持 | Linux/Mac |
| `add-tft-support.bat` | 自动安装TFT支持 | Windows |
| `compile-dtbo.sh` | 编译设备树覆盖文件 | Linux/Mac |

### 文档文件
| 文件 | 说明 |
|------|------|
| `TFT-SCREEN-SETUP.md` | 完整配置指南 |
| `TFT-SETUP-README.md` | 快速入门指南 |
| `README-TFT.md` | 本文件 |

### 覆盖文件
| 板子 | 文件 | 状态 |
|------|------|------|
| FLY H3 | `sun8i-h3-FLY-TFT-V1-*.dtbo` | ✅ 预编译 |
| FLY H618 | `sun50i-h616-tft35_spi.dtbo` | ⚠️ 需要编译 |

## 快速开始

### 1. 自动安装（推荐）

#### Linux/Mac:
```bash
# 下载脚本
wget https://raw.githubusercontent.com/Maoweicao/armbian-build-flypilite2/main/add-tft-support.sh
chmod +x add-tft-support.sh

# 运行安装
sudo ./add-tft-support.sh
```

#### Windows:
1. 下载 `add-tft-support.bat`
2. 以管理员身份运行
3. 按照提示操作

### 2. 手动安装

#### FLY H3:
```bash
# 复制覆盖文件
sudo cp overlay/sun8i-h3/sun8i-h3-FLY-TFT-V1-0.dtbo /boot/dtb/allwinner/overlay/

# 编辑配置
sudo nano /boot/armbianEnv.txt
# 添加: overlays=usbhost2 usbhost3 sun8i-h3-FLY-TFT-V1-0

# 重启
sudo reboot
```

#### FLY H618:
```bash
# 编译覆盖文件
./compile-dtbo.sh patch/kernel/archive/sunxi-6.18/overlay_64/sun50i-h616-tft35_spi.dtso

# 复制覆盖文件
sudo cp sun50i-h616-tft35_spi.dtbo /boot/dtb/allwinner/overlay/

# 编辑配置
sudo nano /boot/armbianEnv.txt
# 添加: overlays=sun50i-h616-tft35_spi

# 重启
sudo reboot
```

## 编译覆盖文件

### 方法1: 使用编译脚本
```bash
# 编译单个文件
./compile-dtbo.sh input.dtso output.dtbo

# 编译所有dtso文件
./compile-dtbo.sh -a
```

### 方法2: 手动编译
```bash
# 安装设备树编译器
sudo apt-get install device-tree-compiler

# 编译
dtc -@ -I dts -O dtb -o output.dtbo input.dtso
```

### 方法3: 使用Docker
```bash
# 使用Docker编译
docker run --rm -v $(pwd):/work -w /work ubuntu:20.04 bash -c \
  "apt-get update && apt-get install -y device-tree-compiler && \
   dtc -@ -I dts -O dtb -o sun50i-h616-tft35_spi.dtbo \
   patch/kernel/archive/sunxi-6.18/overlay_64/sun50i-h616-tft35_spi.dtso"
```

## 支持的屏幕

### FLY H3 TFT屏幕
- 支持旋转角度: 0°, 90°, 180°, 270°
- 接口: SPI
- 驱动: 内核内置

### FLY H618 TFT屏幕
- 支持3.5寸SPI TFT屏幕
- 接口: SPI1
- 触摸: 支持（需要I2C配置）

## 故障排除

### 检查安装
```bash
# 检查覆盖文件
ls -la /boot/dtb/allwinner/overlay/

# 检查配置
cat /boot/armbianEnv.txt

# 检查内核日志
dmesg | grep -i spi
dmesg | grep -i drm
```

### 常见问题
1. **屏幕无显示**: 检查SPI连接和电源
2. **触摸不工作**: 检查I2C配置
3. **显示方向错误**: 使用对应的旋转覆盖文件

## 相关链接

- GitHub仓库: https://github.com/Maoweicao/armbian-build-flypilite2
- 问题反馈: https://github.com/Maoweicao/armbian-build-flypilite2/issues
- Armbian论坛: https://forum.armbian.com

## 更新日志

### 2026-05-30
- 创建TFT屏幕支持工具包
- 添加自动安装脚本
- 添加编译脚本
- 添加完整文档

## 许可证

本项目基于GPL-2.0许可证开源。