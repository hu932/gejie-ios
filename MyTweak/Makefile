# ─────────────────────────────────────────────
# Theos Makefile
# ─────────────────────────────────────────────

# Theos 路径（WSL 下默认安装位置）
export THEOS ?= /opt/theos

# 目标 iOS 最低版本
export TARGET := iphone:clang:latest:14.0

# 架构：arm64 适配 iPhone 5s 及以上
export ARCHS = arm64

# 如果要直接安装到设备，设置设备 IP
# export THEOS_DEVICE_IP = 192.168.1.100
# export THEOS_DEVICE_PORT = 22

# ─────────────────────────────────────────────
# 引入 Theos 初始化
# ─────────────────────────────────────────────
include $(THEOS)/makefiles/common.mk

# ─────────────────────────────────────────────
# Tweak 配置
# ─────────────────────────────────────────────
TWEAK_NAME = MyTweak

# 源文件（支持多文件用空格分隔）
MyTweak_FILES = Tweak.x

# 注入目标进程（多个进程用空格分隔）
# springboard     = 注入桌面
# com.apple.xxx   = 注入系统 App
# com.tencent.xin = 注入微信
MyTweak_FILTER = com.apple.springboard

# 编译选项
MyTweak_CFLAGS = -fobjc-arc
MyTweak_FRAMEWORKS = UIKit Foundation CoreGraphics

# 链接 CydiaSubstrate（必须）
MyTweak_LIBRARIES = substrate

# ─────────────────────────────────────────────
include $(THEOS)/makefiles/tweak.mk

# 安装后重启 SpringBoard
after-install::
	install.exec "killall -9 SpringBoard"
