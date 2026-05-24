# Build Record - Armbian for FLY H618 / FLY H3

## Boards

| Board | SoC | Kernel | Ethernet | WiFi/BT | Status |
|-------|-----|--------|----------|---------|--------|
| fly-h618 | Allwinner H618 | edge (6.18) | AC200 EPHY (PWM5) | UWE5622 | Boot OK, Net OK |
| fly-h618 | Allwinner H618 | current (6.12) | AC200 EPHY (PWM5) | UWE5622 | PWM5 clock broken (#pwm-cells missing) |
| fly-h3 | Allwinner H3 | current + edge | - | RTL8723BU | TBD |

## Fly-H618 Edge (6.18) - Working

### Boot
- SD card detected (MMC0, cd-gpios PF6 GPIO_ACTIVE_LOW)
- `no-1-8-v` disables UHS voltage switching
- Boots to login prompt

### Ethernet (AC200 Internal EPHY)
- **AC200 on I2C3** (PA10/PA11), clocked by **PWM5** (PA12) at 2MHz
- `ac200_pwm_clk` provides pwm-clock → AC200 MFD driver gets clock → EPHY registered → PHY detected by sunxi-gmac
- EMAC1 RMII mode with rx-delay=3100ps, tx-delay=700ps
- Kernel configs needed: `CONFIG_PWM_SUNXI_ENHANCE=m`, `CONFIG_COMMON_CLK_PWM=y`

### DTS Files
- `patch/kernel/archive/sunxi-6.18/dt_64/sun50i-h618-fly-h618.dts`
- PWM nodes added via `arm64-dts-sun50i-h616-add-pwm-nodes-support.patch`
- EMAC driver: `driver-allwinner-h618-emac.patch` (uses `phy_drivers_register(driver, 1, THIS_MODULE)`)

## Fly-H618 Current (6.12) - Broken

### Issue
```
OF: /ac200_clk: could not get #pwm-cells for /soc/pwm5@0300a000
pwm-clock ac200_clk: probe with driver pwm-clock failed with error -22
```
- `pwm5` device lacks `#pwm-cells` property, pwm-clock cannot bind
- Added `#pwm-cells = <3>` to pwm5 node (untested after fix)
- `&pwm` label does not exist in 6.12 sun50i-h616.dtsi → use `&pwm5` instead

### DTS Files
- `patch/kernel/archive/sunxi-6.12/dt/sun50i-h618-fly-h618.dts`
- pwm5 created directly in DTS (`/ { soc { pwm5 { ... }; }; };`)
- pwm5_pin from `arm64-dts-sun50i-h616-Add-i2c3-pa-pwm-pins.patch`
- PWM driver: `drivers-pwm-Add-pwm-sunxi-enhance-driver-for-h616.patch`

## Key Commits

| Commit | Description |
|--------|-------------|
| `017280086` | Rewrite fly-h618.csc with FlyOS-extracted info |
| `90a4ca9e6` | Add DTS sources + edge kernel config |
| `dad38dd5a` | Add PWM nodes patch (later removed) |
| `03fc019b6` | Fix MMC0 cd-gpios polarity LOW, add pinctrl |
| `532369d8f` | Enable PWM driver + fix 6.12 DTS |
| `678fce5df` | Fix phy_driver_register → phy_drivers_register for 6.18 |
| `4e6a7b77b` | Add PWM5 clock to 6.12 DTS |
| `fb3d213e5` | Fix &pwm→&pwm5 in 6.12; add count arg to phy_drivers_register |

## CI Matrix (May 2026)

| Board | Branch | Variant | Release |
|-------|--------|---------|---------|
| fly-h3 | current (6.12) | wizard | trixie |
| fly-h3 | current (6.12) | preset | trixie |
| fly-h3 | edge (6.18) | wizard | trixie |
| fly-h3 | edge (6.18) | preset | trixie |
| fly-h618 | edge (6.18) | wizard | trixie |
| fly-h618 | edge (6.18) | preset | trixie |

### Variants
- **wizard**: Normal first-boot interactive setup (set password, user, network, locale)
- **preset**: Pre-configured out-of-box - skips wizard (root:mellow, user:mellow:mellow, Ethernet DHCP, Asia/Shanghai)

On push success → creates a GitHub pre-release with all images attached.

## WiFi (UWE5622)

- Module confirmed from FlyOS extraction (not RTL8821CS)
- Driver: `uwe5622-allwinner` extension
- SDIO on MMC1, PG18 reset via mmc-pwrseq-simple

## Boot Configuration

- U-Boot: `orangepi_zero3_defconfig`
- Board family: `sun50iw9`
- Console: UART0 PH0/PH1 (ttyS0, 115200n8)
- Verbosity: 1 (reduced from 7)
- No systemd debug args
- SD card CD: PF6, GPIO_ACTIVE_LOW
