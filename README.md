# subs-check-mac 🍎

> `subs-check` 的 macOS 一键安装脚本，使用 `launchd` 管理服务。

🌐 语言：**简体中文** | [English](./README_EN.md)

核心仓库：[`beck-8/subs-check`](https://github.com/beck-8/subs-check) 🔗

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
