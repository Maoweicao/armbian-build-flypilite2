@echo off
REM FLY TFT屏幕支持安装脚本 (Windows版本)
REM 使用方法: add-tft-support.bat [drive_letter] [board_type]
REM 例如: add-tft-support.bat E fly-h3

setlocal enabledelayedexpansion

set "DRIVE_LETTER=%~1"
set "BOARD_TYPE=%~2"

if "%DRIVE_LETTER%"=="" (
    echo 错误: 请指定SD卡驱动器盘符
    echo 用法: %0 [驱动器盘符] [板子类型]
    echo 示例: %0 E fly-h3
    echo 示例: %0 F fly-h618
    exit /b 1
)

if "%BOARD_TYPE%"=="" (
    echo 警告: 未指定板子类型，将尝试自动检测
    set "BOARD_TYPE=auto"
)

echo FLY TFT屏幕支持安装脚本
echo ========================
echo 驱动器: %DRIVE_LETTER%:
echo 板子类型: %BOARD_TYPE%
echo.

REM 检查驱动器是否存在
if not exist "%DRIVE_LETTER%:\" (
    echo 错误: 驱动器 %DRIVE_LETTER%: 不存在
    exit /b 1
)

REM 检查是否为Armbian系统
if not exist "%DRIVE_LETTER%:\boot\armbianEnv.txt" (
    echo 错误: 未在 %DRIVE_LETTER%:\boot\armbianEnv.txt 找到Armbian配置
    echo 请确认SD卡已正确烧录Armbian镜像
    exit /b 1
)

REM 自动检测板子类型
if "%BOARD_TYPE%"=="auto" (
    if exist "%DRIVE_LETTER%:\boot\dtb\allwinner\sun8i-h3-fly-h3.dtb" (
        set "BOARD_TYPE=fly-h3"
        echo 检测到板子类型: FLY H3
    ) else if exist "%DRIVE_LETTER%:\boot\dtb\allwinner\sun50i-h618-fly-h618.dtb" (
        set "BOARD_TYPE=fly-h618"
        echo 检测到板子类型: FLY H618
    ) else (
        echo 错误: 无法自动检测板子类型
        echo 请手动指定: fly-h3 或 fly-h618
        exit /b 1
    )
)

REM 检查覆盖目录
if not exist "%DRIVE_LETTER%:\boot\dtb\allwinner\overlay" (
    echo 创建覆盖目录...
    mkdir "%DRIVE_LETTER%:\boot\dtb\allwinner\overlay"
)

REM 复制覆盖文件
echo.
echo 正在复制覆盖文件...

if "%BOARD_TYPE%"=="fly-h3" (
    REM 复制FLY H3 TFT覆盖文件
    for %%f in (overlay\sun8i-h3\sun8i-h3-FLY-TFT-V1-*.dtbo) do (
        if exist "%%f" (
            copy "%%f" "%DRIVE_LETTER%:\boot\dtb\allwinner\overlay\" >nul
            if !errorlevel! equ 0 (
                echo 已复制: %%~nxf
            ) else (
                echo 错误: 复制 %%~nxf 失败
            )
        )
    )
    
    REM 更新配置文件
    echo.
    echo 正在更新配置文件...
    
    REM 备份原文件
    if exist "%DRIVE_LETTER%:\boot\armbianEnv.txt" (
        copy "%DRIVE_LETTER%:\boot\armbianEnv.txt" "%DRIVE_LETTER%:\boot\armbianEnv.txt.bak" >nul
        echo 已备份: armbianEnv.txt.bak
    )
    
    REM 检查是否已有overlays配置
    findstr /b "overlays=" "%DRIVE_LETTER%:\boot\armbianEnv.txt" >nul
    if !errorlevel! equ 0 (
        REM 检查是否已包含TFT覆盖
        findstr "sun8i-h3-FLY-TFT-V1-0" "%DRIVE_LETTER%:\boot\armbianEnv.txt" >nul
        if !errorlevel! equ 0 (
            echo TFT覆盖已存在于配置中
        ) else (
            REM 追加到现有overlays
            powershell -Command "(Get-Content '%DRIVE_LETTER%:\boot\armbianEnv.txt') -replace '^(overlays=.*)', '$1 sun8i-h3-FLY-TFT-V1-0' | Set-Content '%DRIVE_LETTER%:\boot\armbianEnv.txt'"
            echo 已追加TFT覆盖到现有配置
        )
    ) else (
        REM 添加新的overlays配置
        echo. >> "%DRIVE_LETTER%:\boot\armbianEnv.txt"
        echo # TFT屏幕支持 >> "%DRIVE_LETTER%:\boot\armbianEnv.txt"
        echo overlays=sun8i-h3-FLY-TFT-V1-0 >> "%DRIVE_LETTER%:\boot\armbianEnv.txt"
        echo 已添加TFT覆盖配置
    )
    
) else if "%BOARD_TYPE%"=="fly-h618" (
    REM 对于H618，需要检查是否有预编译的覆盖文件
    if exist "patch\kernel\archive\sunxi-6.18\overlay_64\sun50i-h616-tft35_spi.dtbo" (
        copy "patch\kernel\archive\sunxi-6.18\overlay_64\sun50i-h616-tft35_spi.dtbo" "%DRIVE_LETTER%:\boot\dtb\allwinner\overlay\" >nul
        if !errorlevel! equ 0 (
            echo 已复制: sun50i-h616-tft35_spi.dtbo
        ) else (
            echo 错误: 复制覆盖文件失败
            exit /b 1
        )
    ) else (
        echo 警告: 未找到预编译的TFT覆盖文件
        echo 请手动编译sun50i-h616-tft35_spi.dtso文件
        echo 或从编译环境中获取预编译的dtbo文件
        exit /b 1
    )
    
    REM 更新配置文件
    echo.
    echo 正在更新配置文件...
    
    REM 备份原文件
    if exist "%DRIVE_LETTER%:\boot\armbianEnv.txt" (
        copy "%DRIVE_LETTER%:\boot\armbianEnv.txt" "%DRIVE_LETTER%:\boot\armbianEnv.txt.bak" >nul
        echo 已备份: armbianEnv.txt.bak
    )
    
    REM 检查是否已有overlays配置
    findstr /b "overlays=" "%DRIVE_LETTER%:\boot\armbianEnv.txt" >nul
    if !errorlevel! equ 0 (
        REM 检查是否已包含TFT覆盖
        findstr "sun50i-h616-tft35_spi" "%DRIVE_LETTER%:\boot\armbianEnv.txt" >nul
        if !errorlevel! equ 0 (
            echo TFT覆盖已存在于配置中
        ) else (
            REM 追加到现有overlays
            powershell -Command "(Get-Content '%DRIVE_LETTER%:\boot\armbianEnv.txt') -replace '^(overlays=.*)', '$1 sun50i-h616-tft35_spi' | Set-Content '%DRIVE_LETTER%:\boot\armbianEnv.txt'"
            echo 已追加TFT覆盖到现有配置
        )
    ) else (
        REM 添加新的overlays配置
        echo. >> "%DRIVE_LETTER%:\boot\armbianEnv.txt"
        echo # TFT屏幕支持 >> "%DRIVE_LETTER%:\boot\armbianEnv.txt"
        echo overlays=sun50i-h616-tft35_spi >> "%DRIVE_LETTER%:\boot\armbianEnv.txt"
        echo 已添加TFT覆盖配置
    )
    
) else (
    echo 错误: 不支持的板子类型: %BOARD_TYPE%
    echo 支持的类型: fly-h3, fly-h618
    exit /b 1
)

echo.
echo ========================
echo 安装完成！
echo.
echo 请将SD卡插入开发板并启动系统
echo TFT屏幕支持将在启动时自动启用
echo.
echo 注意事项:
echo 1. 确保TFT屏幕正确连接到SPI接口
echo 2. 检查电源供应是否稳定
echo 3. 首次启动可能需要额外配置
echo.
echo 如需帮助，请查看TFT-SCREEN-SETUP.md文档
pause