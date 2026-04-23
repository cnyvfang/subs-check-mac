#!/bin/sh
# subs-check macOS 一键安装脚本
# 兼容 bash / sh / zsh
# 用法:
#   curl -fsSL https://raw.githubusercontent.com/beck-8/subs-check/master/install-macos.sh | bash
#   或:
#   wget -qO- https://raw.githubusercontent.com/beck-8/subs-check/master/install-macos.sh | bash
# 加速:
#   bash <(curl -fsSL https://ghfast.top/https://raw.githubusercontent.com/beck-8/subs-check/master/install-macos.sh) https://ghfast.top/

set -e

# ============ 配置 ============
REPO="beck-8/subs-check"
INSTALL_DIR="/usr/local/subs-check"
BINARY_NAME="subs-check"
SERVICE_NAME="subs-check"
PLIST_FILE="/Library/LaunchDaemons/${SERVICE_NAME}.plist"
LEGACY_SERVICE_NAME="com.beck-8.subs-check"
LEGACY_PLIST_FILE="/Library/LaunchDaemons/${LEGACY_SERVICE_NAME}.plist"
GITHUB_API="https://api.github.com/repos/${REPO}/releases/latest"
GITHUB_PROXY="${1:-}"

# ============ 运行状态 ============
IS_UPGRADE=0
DOWNLOADER=""
LATEST_VERSION=""
RELEASE_JSON=""
ARCH=""
ASSET_URL=""
ASSET_NAME=""
TMP_DIR=""

# ============ 颜色输出 ============
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info()  { printf "${BLUE}[INFO]${NC} %s\n" "$1"; }
ok()    { printf "${GREEN}[OK]${NC} %s\n" "$1"; }
warn()  { printf "${YELLOW}[WARN]${NC} %s\n" "$1"; }
error() { printf "${RED}[ERROR]${NC} %s\n" "$1"; exit 1; }

cleanup() {
    if [ -n "$TMP_DIR" ] && [ -d "$TMP_DIR" ]; then
        rm -rf "$TMP_DIR"
    fi
}
trap cleanup EXIT

# ============ 前置检查 ============
check_root() {
    if [ "$(id -u)" -ne 0 ]; then
        error "请使用 root 用户或 sudo 运行此脚本"
    fi
}

check_os() {
    if [ "$(uname -s)" != "Darwin" ]; then
        error "此脚本仅支持 macOS"
    fi
}

check_existing() {
    if [ -f "${INSTALL_DIR}/${BINARY_NAME}" ]; then
        IS_UPGRADE=1
        info "检测到已有安装，将执行升级操作"
    fi
}

check_download_tool() {
    if command -v curl >/dev/null 2>&1; then
        DOWNLOADER="curl"
    elif command -v wget >/dev/null 2>&1; then
        DOWNLOADER="wget"
    else
        error "需要 curl 或 wget，请先安装其中之一"
    fi
}

check_extract_tool() {
    if ! command -v tar >/dev/null 2>&1; then
        error "未找到 tar"
    fi
    if ! command -v unzip >/dev/null 2>&1; then
        warn "未找到 unzip，如 release 提供 zip 包则安装会失败"
    fi
}

# ============ 下载封装 ============
download() {
    url="$1"
    output="$2"
    if [ "$DOWNLOADER" = "curl" ]; then
        curl -fsSL -o "$output" "$url"
    else
        wget -qO "$output" "$url"
    fi
}

fetch_url() {
    url="$1"
    if [ "$DOWNLOADER" = "curl" ]; then
        curl -fsSL "$url"
    else
        wget -qO- "$url"
    fi
}

# ============ 架构检测 ============
detect_arch() {
    arch="$(uname -m)"
    case "$arch" in
        arm64|aarch64)
            ARCH="arm64"
            ;;
        x86_64|amd64)
            ARCH="x86_64"
            ;;
        *)
            error "不支持的架构: $arch"
            ;;
    esac
    ok "检测到系统架构: $ARCH"
}

# ============ 获取 release 信息 ============
get_release_json() {
    info "正在获取最新版本信息..."
    RELEASE_JSON="$(fetch_url "$GITHUB_API")"
    if [ -z "$RELEASE_JSON" ]; then
        error "无法获取 release 信息，请检查网络连接"
    fi

    LATEST_VERSION=$(printf "%s" "$RELEASE_JSON" | grep '"tag_name"' | head -1 | sed 's/.*"tag_name": *"//;s/".*//')
    if [ -z "$LATEST_VERSION" ]; then
        error "无法解析最新版本号"
    fi
    ok "最新版本: $LATEST_VERSION"
}

# ============ 选择 macOS 资产 ============
select_asset() {
    info "正在匹配 macOS 安装包..."

    # 从 release JSON 中提取所有 browser_download_url
    URL_LIST=$(printf "%s" "$RELEASE_JSON" | sed 's/,/\n/g' | grep 'browser_download_url' | sed 's/.*"browser_download_url": *"//;s/".*//')

    if [ -z "$URL_LIST" ]; then
        error "release 中未找到可下载资产"
    fi

    # 优先匹配 darwin/macos + arch + tar.gz/zip
    ASSET_URL=$(printf "%s\n" "$URL_LIST" | grep -Ei "(darwin|macos)" | grep -Ei "$ARCH" | grep -Ei '\.tar\.gz$|\.zip$' | head -1 || true)

    # 有些项目可能用 amd64 表示 x86_64
    if [ -z "$ASSET_URL" ] && [ "$ARCH" = "x86_64" ]; then
        ASSET_URL=$(printf "%s\n" "$URL_LIST" | grep -Ei "(darwin|macos)" | grep -Ei "amd64|x86_64" | grep -Ei '\.tar\.gz$|\.zip$' | head -1 || true)
    fi

    # 有些项目可能用 aarch64 表示 arm64
    if [ -z "$ASSET_URL" ] && [ "$ARCH" = "arm64" ]; then
        ASSET_URL=$(printf "%s\n" "$URL_LIST" | grep -Ei "(darwin|macos)" | grep -Ei "arm64|aarch64" | grep -Ei '\.tar\.gz$|\.zip$' | head -1 || true)
    fi

    if [ -z "$ASSET_URL" ]; then
        error "未找到适用于 macOS ${ARCH} 的安装包，请检查 release 资产命名"
    fi

    ASSET_NAME=$(basename "$ASSET_URL")
    ok "已匹配安装包: $ASSET_NAME"

    if [ -n "$GITHUB_PROXY" ]; then
        ASSET_URL="${GITHUB_PROXY}${ASSET_URL}"
        info "已启用 GitHub 代理"
    fi
}

# ============ 停止服务 ============
stop_service_if_running() {
    if launchctl print "system/${SERVICE_NAME}" >/dev/null 2>&1; then
        warn "检测到服务正在运行，正在停止..."
        launchctl bootout system "$PLIST_FILE" >/dev/null 2>&1 || true
    fi
}

cleanup_legacy_service() {
    if [ "$SERVICE_NAME" = "$LEGACY_SERVICE_NAME" ]; then
        return 0
    fi

    if [ -f "$LEGACY_PLIST_FILE" ] || launchctl print "system/${LEGACY_SERVICE_NAME}" >/dev/null 2>&1; then
        warn "检测到旧服务标识 ${LEGACY_SERVICE_NAME}，正在迁移到 ${SERVICE_NAME}..."
        launchctl bootout "system/${LEGACY_SERVICE_NAME}" >/dev/null 2>&1 || true
        launchctl bootout system "$LEGACY_PLIST_FILE" >/dev/null 2>&1 || true
        rm -f "$LEGACY_PLIST_FILE"
        ok "旧服务已清理"
    fi
}

# ============ 解压安装 ============
extract_package() {
    pkg="$1"
    dest="$2"

    case "$pkg" in
        *.tar.gz)
            tar -xzf "$pkg" -C "$dest"
            ;;
        *.zip)
            if ! command -v unzip >/dev/null 2>&1; then
                error "当前安装包为 zip，但系统未安装 unzip"
            fi
            unzip -q "$pkg" -d "$dest"
            ;;
        *)
            error "不支持的压缩格式: $pkg"
            ;;
    esac
}

find_binary_in_dir() {
    search_dir="$1"

    if [ -f "${search_dir}/${BINARY_NAME}" ]; then
        printf "%s" "${search_dir}/${BINARY_NAME}"
        return 0
    fi

    found=$(find "$search_dir" -type f -name "$BINARY_NAME" | head -1 || true)
    if [ -n "$found" ]; then
        printf "%s" "$found"
        return 0
    fi

    return 1
}

install_binary() {
    TMP_DIR=$(mktemp -d)

    info "正在下载 ${ASSET_NAME}..."
    download "$ASSET_URL" "${TMP_DIR}/${ASSET_NAME}"
    ok "下载完成"

    info "正在解压安装包..."
    extract_package "${TMP_DIR}/${ASSET_NAME}" "$TMP_DIR"

    BIN_PATH=$(find_binary_in_dir "$TMP_DIR" || true)
    if [ -z "$BIN_PATH" ]; then
        error "解压后未找到可执行文件 ${BINARY_NAME}"
    fi

    if [ "$IS_UPGRADE" -eq 1 ]; then
        stop_service_if_running
        info "正在升级 ${INSTALL_DIR} 中的程序..."
    else
        info "正在安装到 ${INSTALL_DIR}..."
    fi

    mkdir -p "$INSTALL_DIR"
    cp "$BIN_PATH" "${INSTALL_DIR}/${BINARY_NAME}"
    chmod +x "${INSTALL_DIR}/${BINARY_NAME}"

    if [ "$IS_UPGRADE" -eq 1 ]; then
        ok "升级完成: ${INSTALL_DIR}/${BINARY_NAME}"
    else
        ok "安装完成: ${INSTALL_DIR}/${BINARY_NAME}"
    fi
}

# ============ 配置 launchd ============
setup_launchd() {
    info "正在配置 launchd 服务..."

    mkdir -p /Library/LaunchDaemons

    cat > "$PLIST_FILE" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "https://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>${SERVICE_NAME}</string>

    <key>ProgramArguments</key>
    <array>
        <string>${INSTALL_DIR}/${BINARY_NAME}</string>
    </array>

    <key>WorkingDirectory</key>
    <string>${INSTALL_DIR}</string>

    <key>RunAtLoad</key>
    <true/>

    <key>KeepAlive</key>
    <true/>

    <key>StandardOutPath</key>
    <string>${INSTALL_DIR}/subs-check.log</string>

    <key>StandardErrorPath</key>
    <string>${INSTALL_DIR}/subs-check.err.log</string>
</dict>
</plist>
EOF

    chmod 644 "$PLIST_FILE"
    chown root:wheel "$PLIST_FILE"
    ok "launchd 服务配置完成"
}

enable_service() {
    if launchctl print "system/${SERVICE_NAME}" >/dev/null 2>&1; then
        launchctl bootout system "$PLIST_FILE" >/dev/null 2>&1 || true
    fi

    launchctl bootstrap system "$PLIST_FILE"
    launchctl enable "system/${SERVICE_NAME}" || true
}

start_service() {
    launchctl kickstart -k "system/${SERVICE_NAME}"
}

# ============ 交互式选择 ============
ask_enable() {
    printf "${YELLOW}是否设置开机自启动？[Y/n]: ${NC}"
    read -r answer < /dev/tty
    case "$answer" in
        [nN]|[nN][oO])
            info "已跳过开机自启动配置"
            ;;
        *)
            enable_service
            ok "已设置开机自启动"
            ;;
    esac
}

ask_start() {
    printf "${YELLOW}是否立即启动服务？[Y/n]: ${NC}"
    read -r answer < /dev/tty
    case "$answer" in
        [nN]|[nN][oO])
            info "已跳过启动服务"
            ;;
        *)
            start_service
            ok "服务已启动"
            ;;
    esac
}

ask_restart_upgrade() {
    printf "${YELLOW}是否重新启动服务？[Y/n]: ${NC}"
    read -r answer < /dev/tty
    case "$answer" in
        [nN]|[nN][oO])
            info "已跳过启动服务"
            ;;
        *)
            enable_service
            start_service
            ok "服务已重新启动"
            ;;
    esac
}

# ============ 打印信息 ============
print_info() {
    printf "\n"
    printf "${GREEN}========================================${NC}\n"
    if [ "$IS_UPGRADE" -eq 1 ]; then
        printf "${GREEN} subs-check 升级成功！${NC}\n"
    else
        printf "${GREEN} subs-check 安装成功！${NC}\n"
    fi
    printf "${GREEN}========================================${NC}\n"
    printf "\n"
    printf "  版本:       %s\n" "$LATEST_VERSION"
    printf "  安装目录:   %s\n" "$INSTALL_DIR"
    printf "  配置文件:   %s/config/config.yaml\n" "$INSTALL_DIR"
    printf "  服务文件:   %s\n" "$PLIST_FILE"
    printf "\n"
    printf "  服务管理:\n"
    printf "    加载:     launchctl bootstrap system %s\n" "$PLIST_FILE"
    printf "    卸载:     launchctl bootout system %s\n" "$PLIST_FILE"
    printf "    启动:     launchctl kickstart -k system/%s\n" "$SERVICE_NAME"
    printf "    状态:     launchctl print system/%s\n" "$SERVICE_NAME"
    printf "    日志:     tail -f %s/subs-check.log\n" "$INSTALL_DIR"
    printf "    错误日志: tail -f %s/subs-check.err.log\n" "$INSTALL_DIR"
    printf "\n"
    printf "  卸载方法:\n"
    printf "    launchctl bootout system %s\n" "$PLIST_FILE"
    printf "    rm -rf %s %s\n" "$INSTALL_DIR" "$PLIST_FILE"
    printf "\n"
    printf "${YELLOW}  如需修改参数，请编辑配置文件：${NC}\n"
    printf "    %s/config/config.yaml\n" "$INSTALL_DIR"
    printf "  修改后重启服务：launchctl kickstart -k system/%s\n" "$SERVICE_NAME"
    printf "\n"
}

# ============ 主流程 ============
main() {
    printf "\n"
    printf "${GREEN}========================================${NC}\n"
    printf "${GREEN} subs-check macOS 一键安装脚本${NC}\n"
    printf "${GREEN}========================================${NC}\n"
    printf "\n"

    check_root
    check_os
    check_existing
    check_download_tool
    check_extract_tool
    detect_arch
    get_release_json
    select_asset
    install_binary
    cleanup_legacy_service
    setup_launchd

    if [ "$IS_UPGRADE" -eq 1 ]; then
        ask_enable
        ask_restart_upgrade
    else
        ask_enable
        ask_start
    fi

    print_info
}

main
