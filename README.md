# subs-check-mac 🍎

> `subs-check` 的 macOS 一键安装脚本，使用 `launchd` 管理服务。

🌐 语言：**简体中文** | [English](./README_EN.md)

核心仓库：[`beck-8/subs-check`](https://github.com/beck-8/subs-check) 🔗

具体使用方法请参照 `subs-check` 原仓库说明。

## 🚀 快速开始

默认安装：

```bash
curl -fsSL https://raw.githubusercontent.com/cnyvfang/subs-check-mac/main/install.sh | sudo bash
```

使用 GitHub 代理：

```bash
curl -fsSL https://raw.githubusercontent.com/cnyvfang/subs-check-mac/main/install.sh | sudo bash -s -- https://ghfast.top/
```

## ⚙️ 脚本行为

| 步骤 | 说明 |
| --- | --- |
| 环境检查 | 仅支持 macOS，要求使用 `root` 或 `sudo` 运行 |
| 下载工具检查 | 优先使用 `curl`，若不存在则回退到 `wget` |
| 架构检测 | 当前支持 `x86_64` 和 `arm64` |
| 版本获取 | 从 `beck-8/subs-check` 的 GitHub Releases 获取最新版本 |
| 安装包匹配 | 自动匹配 macOS 安装包，支持 `.tar.gz` / `.zip`，若为 `.zip` 则需要 `unzip` |
| 程序安装 | 将二进制程序安装到 `/usr/local/subs-check` |
| 服务配置 | 生成 `launchd` 服务文件 `/Library/LaunchDaemons/subs-check.plist` |
| 自启动设置 | 交互式选择是否开启开机自启动 |
| 服务启动 | 交互式选择是否立即启动；若检测到已有安装，则按升级流程执行并可选择重启 |

## 🛠️ 服务管理

```bash
# 首次加载服务
sudo launchctl bootstrap system /Library/LaunchDaemons/subs-check.plist

# 停止并卸载服务
sudo launchctl bootout system /Library/LaunchDaemons/subs-check.plist

# 启动或重启服务
sudo launchctl kickstart -k system/subs-check

# 开启 / 关闭开机自启动
sudo launchctl enable system/subs-check
sudo launchctl disable system/subs-check

# 查看服务状态
sudo launchctl print system/subs-check

# 查看日志
tail -f /usr/local/subs-check/subs-check.log
tail -f /usr/local/subs-check/subs-check.err.log

# 修改 plist 后重新加载服务
sudo launchctl bootout system /Library/LaunchDaemons/subs-check.plist
sudo launchctl bootstrap system /Library/LaunchDaemons/subs-check.plist
sudo launchctl kickstart -k system/subs-check
```

## 🌐 访问地址

默认会暴露两个端口：

- `8199`：管理面板和本地文件订阅
- `8299`：内置 `Sub-Store` 转换订阅

### 管理面板与本地文件订阅

| 类型 | 地址 | 说明 |
| --- | --- | --- |
| 管理面板 | `http://127.0.0.1:8199/admin` | Web 管理面板 |
| Clash YAML | `http://127.0.0.1:8199/sub/all.yaml` | `subs-check` 直接生成 |
| Mihomo YAML | `http://127.0.0.1:8199/sub/mihomo.yaml` | 带分流规则的 Mihomo/Clash 订阅 |
| Base64 | `http://127.0.0.1:8199/sub/base64.txt` | Base64 格式订阅 |

### `Sub-Store` 转换订阅

以下链接参照上游 [`beck-8/subs-check`](https://github.com/beck-8/subs-check) README 中的“订阅使用方法”补充：

| 类型 | 地址 |
| --- | --- |
| 通用订阅 | `http://127.0.0.1:8299/download/sub` |
| URI | `http://127.0.0.1:8299/download/sub?target=URI` |
| Mihomo / ClashMeta | `http://127.0.0.1:8299/download/sub?target=ClashMeta` |
| Clash | `http://127.0.0.1:8299/download/sub?target=Clash` |
| V2Ray | `http://127.0.0.1:8299/download/sub?target=V2Ray` |
| ShadowRocket | `http://127.0.0.1:8299/download/sub?target=ShadowRocket` |
| Quantumult X | `http://127.0.0.1:8299/download/sub?target=QX` |
| Sing-Box | `http://127.0.0.1:8299/download/sub?target=sing-box` |
| Surge | `http://127.0.0.1:8299/download/sub?target=Surge` |
| Surfboard | `http://127.0.0.1:8299/download/sub?target=Surfboard` |
| 带规则 Mihomo / Clash | `http://127.0.0.1:8299/api/file/mihomo` |

`带规则 Mihomo / Clash` 订阅默认使用 `https://raw.githubusercontent.com/beck-8/override-hub/refs/heads/main/yaml/ACL4SSR_Online_Full.yaml` 覆写，可在配置中通过 `mihomo-overwrite-url` 修改。

## 📝 使用前配置

使用管理面板前，请先在配置文件中设置 `api-key`，或通过环境变量设置 `API_KEY`。

完成 API 配置后，再打开管理面板 `http://127.0.0.1:8199/admin` 配置订阅信息。

需要重点检查并修改以下内容：

1. 在配置文件中设置 `api-key`，或通过环境变量设置 `API_KEY`。
2. 将 `sub-urls-remote` 设置为你自己的远程订阅清单地址。
3. 将 `sub-urls` 设置为你自己的订阅地址。
4. 将模板中不需要的订阅地址注释掉或删除，避免混用示例订阅。

配置完成后重启服务使其生效：

```bash
sudo launchctl kickstart -k system/subs-check
```

## 📁 路径说明

| 项目 | 路径 |
| --- | --- |
| 安装目录 | `/usr/local/subs-check` |
| 服务文件 | `/Library/LaunchDaemons/subs-check.plist` |
| 配置文件 | `/usr/local/subs-check/config/config.yaml` |
| 运行日志 | `/usr/local/subs-check/subs-check.log` |
| 错误日志 | `/usr/local/subs-check/subs-check.err.log` |

## 🗑️ 卸载

```bash
sudo launchctl bootout system /Library/LaunchDaemons/subs-check.plist
sudo rm -rf /usr/local/subs-check /Library/LaunchDaemons/subs-check.plist
```

## ⚠️ 免责声明

本仓库仅提供 `subs-check` 的 macOS 安装与服务管理脚本，不包含核心功能实现。核心功能、源码、Issue 和 Release 请以上游仓库 [`beck-8/subs-check`](https://github.com/beck-8/subs-check) 为准。本工具仅供学习和研究使用，使用者应自行承担风险，并确保自己的使用方式符合当地法律法规与目标服务的相关条款。
