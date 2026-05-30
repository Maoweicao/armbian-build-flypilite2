# FLY开发板TFT屏幕支持配置指南

## 概述
本指南说明如何在已编译的Armbian镜像中为FLY H3和FLY H618开发板添加TFT屏幕支持。

## 支持情况
| 开发板 | HDMI | TFT屏幕 | 默认启用 |
|--------|------|---------|----------|
| FLY H3 | ❌ | ✅ | ✅ (已配置) |
| FLY H618 | ✅ | ✅ | ✅ (已配置) |

## 方法一：使用自动脚本（推荐）

### 1. 下载脚本
```bash
wget https://raw.githubusercontent.com/Maoweicao/armbian-build-flypilite2/main/add-tft-support.sh
chmod +x add-tft-support.sh
```

### 2. 运行安装脚本
```bash
# 自动检测板子类型
sudo ./add-tft-support.sh

# 或手动指定板子类型
sudo ./add-tft-support.sh fly-h3
sudo ./add-tft-support.sh fly-h618
```

### 3. 重启系统
```bash
sudo reboot
```

## 方法二：手动配置

### FLY H3 TFT配置

#### 1. 复制设备树覆盖文件
```bash
# 下载覆盖文件
wget https://raw.githubusercontent.com/Maoweicao/armbian-build-flypilite2/main/overlay/sun8i-h3/sun8i-h3-FLY-TFT-V1-0.dtbo

# 复制到系统目录
sudo cp sun8i-h3-FLY-TFT-V1-0.dtbo /boot/dtb/allwinner/overlay/
```

#### 2. 编辑配置文件
```bash
sudo nano /boot/armbianEnv.txt
```

在文件末尾添加或修改：
```
overlays=usbhost2 usbhost3 sun8i-h3-FLY-TFT-V1-0
```

#### 3. 重启系统
```bash
sudo reboot
```

### FLY H618 TFT配置

#### 1. 编译覆盖文件（需要dtc编译器）
```bash
# 安装设备树编译器
sudo apt-get install device-tree-compiler

# 下载源文件
wget https://raw.githubusercontent.com/Maoweicao/armbian-build-flypilite2/main/patch/kernel/archive/sunxi-6.18/overlay_64/sun50i-h616-tft35_spi.dtso

# 编译为dtbo
dtc -@ -I dts -O dtb -o sun50i-h616-tft35_spi.dtbo sun50i-h616-tft35_spi.dtso

# 复制到系统目录
sudo cp sun50i-h616-tft35_spi.dtbo /boot/dtb/allwinner/overlay/
```

**或者使用编译脚本**：
```bash
# 下载编译脚本
wget https://raw.githubusercontent.com/Maoweicao/armbian-build-flypilite2/main/compile-dtbo.sh
chmod +x compile-dtbo.sh

# 编译单个文件
./compile-dtbo.sh patch/kernel/archive/sunxi-6.18/overlay_64/sun50i-h616-tft35_spi.dtso

# 编译所有dtso文件
./compile-dtbo.sh -a
```

#### 2. 编辑配置文件
```bash
sudo nano /boot/armbianEnv.txt
```

在文件末尾添加或修改：
```
overlays=sun50i-h616-tft35_spi
```

#### 3. 重启系统
```bash
sudo reboot
```

## 方法三：从编译环境复制

如果您有编译环境，可以直接复制预编译的覆盖文件：

```bash
# FLY H3
cp overlay/sun8i-h3/sun8i-h3-FLY-TFT-V1-*.dtbo /path/to/image/boot/dtb/allwinner/overlay/

# FLY H618
cp output/debs/armbian-firmware*/lib/firmware/device-tree/allwinner/overlay/sun50i-h616-tft35_spi.dtbo /path/to/image/boot/dtb/allwinner/overlay/
```

## TFT屏幕旋转

FLY H3支持多种旋转角度的覆盖文件：

| 覆盖文件 | 旋转角度 |
|----------|----------|
| `sun8i-h3-FLY-TFT-V1-0.dtbo` | 0° (默认) |
| `sun8i-h3-FLY-TFT-V1-90.dtbo` | 90° |
| `sun8i-h3-FLY-TFT-V1-180.dtbo` | 180° |
| `sun8i-h3-FLY-TFT-V1-270.dtbo` | 270° |

选择对应的覆盖文件即可调整显示方向。

## 故障排除

### 1. 检查覆盖文件是否加载
```bash
ls -la /boot/dtb/allwinner/overlay/
cat /boot/armbianEnv.txt
```

### 2. 检查设备树是否生效
```bash
sudo dtc -I fs /sys/firmware/devicetree/base
```

### 3. 检查SPI设备
```bash
ls /dev/spidev*
dmesg | grep -i spi
```

### 4. 检查显示设备
```bash
ls /dev/fb*
dmesg | grep -i drm
```

## 相关文件位置

- 设备树覆盖: `/boot/dtb/allwinner/overlay/`
- 启动配置: `/boot/armbianEnv.txt`
- 内核日志: `dmesg`

## 注意事项

1. **备份重要数据**：修改系统配置前请备份重要数据
2. **正确卸载**：修改SD卡镜像时，请先卸载再拔出
3. **电源供应**：确保TFT屏幕有稳定的电源供应
4. **连接检查**：检查TFT屏幕的排线连接是否正确

## 技术支持

如有问题，请访问：
- GitHub Issues: https://github.com/Maoweicao/armbian-build-flypilite2/issues
- 论坛讨论: https://forum.armbian.com

## 快速参考

### 脚本文件
| 脚本 | 用途 | 平台 |
|------|------|------|
| `add-tft-support.sh` | Linux/Mac自动安装脚本 | Linux/Mac |
| `add-tft-support.bat` | Windows自动安装脚本 | Windows |
| `compile-dtbo.sh` | 编译设备树覆盖文件 | Linux/Mac |

### 覆盖文件位置
| 板子 | 覆盖文件 | 来源 |
|------|----------|------|
| FLY H3 | `sun8i-h3-FLY-TFT-V1-*.dtbo` | `overlay/sun8i-h3/` |
| FLY H618 | `sun50i-h616-tft35_spi.dtbo` | 需要编译 |

### 配置示例
```bash
# FLY H3 (0度旋转)
overlays=usbhost2 usbhost3 sun8i-h3-FLY-TFT-V1-0

# FLY H3 (90度旋转)
overlays=usbhost2 usbhost3 sun8i-h3-FLY-TFT-V1-90

# FLY H618
overlays=sun50i-h616-tft35_spi
```

### 常用命令
```bash
# 检查覆盖文件
ls -la /boot/dtb/allwinner/overlay/

# 查看当前配置
cat /boot/armbianEnv.txt

# 查看内核日志
dmesg | grep -i spi
dmesg | grep -i drm

# 检查SPI设备
ls /dev/spidev*
```

## 更新日志

- 2026-05-30: 初始版本，支持FLY H3和FLY H618的TFT屏幕配置
- 2026-05-30: 添加自动安装脚本和编译脚本
- 2026-05-30: 添加快速参考和故障排除指南