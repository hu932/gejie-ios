#!/bin/bash
# 格界 - WSL 一键编译脚本
# 在 WSL Ubuntu 中运行: bash /mnt/c/Users/Administrator/Desktop/ios/格界/build_in_wsl.sh

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

PROJECT_DIR="/mnt/c/Users/Administrator/Desktop/ios/格界"

echo -e "${CYAN}=====================================${NC}"
echo -e "${CYAN}  格界 deb 编译工具${NC}"
echo -e "${CYAN}=====================================${NC}"
echo ""

# 安装基础依赖
echo -e "${YELLOW}[1/5] 安装系统依赖...${NC}"
sudo apt-get update -qq
sudo apt-get install -y -qq \
    curl git perl make findutils rsync \
    libplist-utils zip unzip fakeroot \
    clang lld 2>/dev/null || true
echo -e "${GREEN}  ✓ 依赖安装完成${NC}"

# 安装 Theos
if [ ! -d "/opt/theos" ]; then
    echo -e "${YELLOW}[2/5] 安装 Theos（首次安装约需 3-5 分钟）...${NC}"
    sudo mkdir -p /opt/theos
    sudo chown $(whoami) /opt/theos
    
    export THEOS=/opt/theos
    bash -c "$(curl -fsSL https://raw.githubusercontent.com/theos/theos/master/bin/install-theos)"
    echo -e "${GREEN}  ✓ Theos 安装完成${NC}"
else
    echo -e "${GREEN}[2/5] ✓ Theos 已安装${NC}"
fi

export THEOS=/opt/theos

# 下载 iOS SDK（如果没有）
SDK_DIR="$THEOS/sdks"
if [ ! -d "$SDK_DIR/iPhoneOS14.5.sdk" ] && [ ! -d "$SDK_DIR/iPhoneOS15.0.sdk" ] && [ ! -d "$SDK_DIR/iPhoneOS16.0.sdk" ]; then
    echo -e "${YELLOW}[3/5] 下载 iOS SDK...${NC}"
    mkdir -p "$SDK_DIR"
    cd "$SDK_DIR"
    
    # 使用轻量级 SDK
    SDK_URL="https://github.com/theos/sdks/releases/download/2022-07-13/iPhoneOS15.5.sdk.tar.xz"
    echo "  下载 iOS 15.5 SDK..."
    curl -L "$SDK_URL" -o ios_sdk.tar.xz --progress-bar
    tar -xf ios_sdk.tar.xz
    rm ios_sdk.tar.xz
    echo -e "${GREEN}  ✓ SDK 下载完成${NC}"
else
    echo -e "${GREEN}[3/5] ✓ iOS SDK 已存在${NC}"
fi

# 编译
echo -e "${YELLOW}[4/5] 开始编译格界...${NC}"
cd "$PROJECT_DIR"

# 清理旧的构建文件
make clean 2>/dev/null || true

# 编译打包
make package FINALPACKAGE=1 THEOS=/opt/theos 2>&1

echo ""
echo -e "${YELLOW}[5/5] 查找输出文件...${NC}"

DEB_FILE=$(find "$PROJECT_DIR/packages" -name "*.deb" | sort | tail -1)

if [ -n "$DEB_FILE" ]; then
    SIZE=$(du -h "$DEB_FILE" | cut -f1)
    echo ""
    echo -e "${GREEN}=====================================${NC}"
    echo -e "${GREEN}  编译成功！${NC}"
    echo -e "${GREEN}=====================================${NC}"
    echo -e "  文件: ${CYAN}$DEB_FILE${NC}"
    echo -e "  大小: ${CYAN}$SIZE${NC}"
    echo ""
    echo -e "${YELLOW}安装到越狱手机：${NC}"
    echo "  方式1 (SSH): scp '$DEB_FILE' root@手机IP:/var/root/"
    echo "              ssh root@手机IP dpkg -i /var/root/$(basename $DEB_FILE)"
    echo "  方式2 (文件管理器): 用 Filza 传入手机点击安装"
    echo ""
    
    # 复制到桌面方便找
    WIN_DEST="/mnt/c/Users/Administrator/Desktop/$(basename $DEB_FILE)"
    cp "$DEB_FILE" "$WIN_DEST"
    echo -e "${GREEN}  已复制到 Windows 桌面: $(basename $DEB_FILE)${NC}"
else
    echo -e "${RED}未找到 deb 文件，编译可能失败，请查看上方错误信息。${NC}"
    exit 1
fi
