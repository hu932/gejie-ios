#!/bin/bash
# ═══════════════════════════════════════════════════════
# WSL 一键安装 Theos 开发环境
# 在 WSL (Ubuntu) 终端中执行：bash setup_wsl.sh
# ═══════════════════════════════════════════════════════

set -e
echo ""
echo "╔══════════════════════════════════════╗"
echo "║   Theos iOS 开发环境安装脚本          ║"
echo "╚══════════════════════════════════════╝"
echo ""

# ── Step 1: 系统依赖
echo "[1/5] 安装系统依赖..."
sudo apt-get update -q
sudo apt-get install -y \
    git curl wget \
    build-essential \
    fakeroot \
    libssl-dev \
    python3 python3-pip \
    zip unzip \
    pkg-config \
    libtinfo5 2>/dev/null || true

# ── Step 2: 安装 Theos
echo ""
echo "[2/5] 安装 Theos..."
export THEOS=/opt/theos
if [ ! -d "$THEOS" ]; then
    sudo git clone --recursive https://github.com/theos/theos.git $THEOS
    sudo chown -R $(id -u):$(id -g) $THEOS
else
    echo "  Theos 已存在，跳过克隆"
fi

# ── Step 3: 下载 iOS SDK
echo ""
echo "[3/5] 下载 iOS SDK (iPhoneOS16.5)..."
SDK_URL="https://github.com/theos/sdks/releases/download/2023-10-09/iPhoneOS16.5.sdk.tar.xz"
SDK_DIR="$THEOS/sdks"
mkdir -p "$SDK_DIR"

if [ ! -d "$SDK_DIR/iPhoneOS16.5.sdk" ]; then
    echo "  正在下载 SDK（约 200MB）..."
    wget -q --show-progress "$SDK_URL" -O /tmp/sdk.tar.xz
    tar -xf /tmp/sdk.tar.xz -C "$SDK_DIR"
    rm /tmp/sdk.tar.xz
    echo "  ✅ SDK 安装完成"
else
    echo "  SDK 已存在，跳过"
fi

# ── Step 4: 安装 ldid（代码签名工具）
echo ""
echo "[4/5] 安装 ldid..."
if ! command -v ldid &>/dev/null; then
    LDID_URL="https://github.com/ProcursusTeam/ldid/releases/latest/download/ldid_linux_x86_64"
    sudo wget -q "$LDID_URL" -O /usr/local/bin/ldid
    sudo chmod +x /usr/local/bin/ldid
    echo "  ✅ ldid 安装完成"
else
    echo "  ldid 已存在"
fi

# ── Step 5: 配置环境变量
echo ""
echo "[5/5] 配置环境变量..."
PROFILE_LINE='export THEOS=/opt/theos'
PATH_LINE='export PATH=$THEOS/bin:$PATH'

if ! grep -q "THEOS=/opt/theos" ~/.bashrc; then
    echo "$PROFILE_LINE" >> ~/.bashrc
    echo "$PATH_LINE"    >> ~/.bashrc
fi
if ! grep -q "THEOS=/opt/theos" ~/.zshrc 2>/dev/null; then
    echo "$PROFILE_LINE" >> ~/.zshrc 2>/dev/null || true
    echo "$PATH_LINE"    >> ~/.zshrc 2>/dev/null || true
fi

export THEOS=/opt/theos
export PATH=$THEOS/bin:$PATH

# ── 完成
echo ""
echo "╔══════════════════════════════════════╗"
echo "║   ✅  Theos 安装完成！               ║"
echo "╚══════════════════════════════════════╝"
echo ""
echo "验证安装："
echo "  theos --version"
echo ""
echo "编译 Tweak："
echo "  cd MyTweak && make package"
echo ""
echo "⚠️  请重启终端或执行 source ~/.bashrc 使环境变量生效"
