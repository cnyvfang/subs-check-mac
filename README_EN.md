# subs-check-mac 🍎

> One-click macOS installer for `subs-check`, managed with `launchd`.

🌐 Language: [简体中文](./README.md) | **English**

Core repository: [`beck-8/subs-check`](https://github.com/beck-8/subs-check) 🔗

## 🚀 Quick Start

Default install:

```bash
curl -fsSL https://raw.githubusercontent.com/cnyvfang/subs-check-mac/main/install.sh | sudo bash
```

Using a GitHub proxy:

```bash
curl -fsSL https://raw.githubusercontent.com/cnyvfang/subs-check-mac/main/install.sh | sudo bash -s -- https://ghfast.top/
```

## ⚙️ What The Script Does

| Step | Description |
| --- | --- |
| Environment check | Supports macOS only and must be run with `root` or `sudo` |
| Downloader check | Uses `curl` first, falls back to `wget` if needed |
| Architecture detection | Supports `x86_64` and `arm64` |
| Version lookup | Fetches the latest release from `beck-8/subs-check` |
| Package selection | Automatically matches the macOS package, supports `.tar.gz` / `.zip`, and requires `unzip` for `.zip` assets |
| Installation | Installs the binary to `/usr/local/subs-check` |
| Service setup | Creates the `launchd` plist at `/Library/LaunchDaemons/subs-check.plist` |
| Auto-start option | Prompts whether to enable launch at boot |
| Service start | Prompts whether to start immediately; if an existing install is detected, it follows the upgrade flow and can restart the service |

## 🛠️ Service Management

```bash
# Load the service for the first time
sudo launchctl bootstrap system /Library/LaunchDaemons/subs-check.plist

# Stop and unload the service
sudo launchctl bootout system /Library/LaunchDaemons/subs-check.plist

# Start or restart the service
sudo launchctl kickstart -k system/subs-check

# Enable / disable auto-start at boot
sudo launchctl enable system/subs-check
sudo launchctl disable system/subs-check

# Check service status
sudo launchctl print system/subs-check

# View logs
tail -f /usr/local/subs-check/subs-check.log
tail -f /usr/local/subs-check/subs-check.err.log

# Reload the service after modifying the plist
sudo launchctl bootout system /Library/LaunchDaemons/subs-check.plist
sudo launchctl bootstrap system /Library/LaunchDaemons/subs-check.plist
sudo launchctl kickstart -k system/subs-check
```

## 📁 Paths

| Item | Path |
| --- | --- |
| Install directory | `/usr/local/subs-check` |
| Service plist | `/Library/LaunchDaemons/subs-check.plist` |
| Config file | `/usr/local/subs-check/config/config.yaml` |
| Runtime log | `/usr/local/subs-check/subs-check.log` |
| Error log | `/usr/local/subs-check/subs-check.err.log` |

## 🗑️ Uninstall

```bash
sudo launchctl bootout system /Library/LaunchDaemons/subs-check.plist
sudo rm -rf /usr/local/subs-check /Library/LaunchDaemons/subs-check.plist
```

## ⚠️ Disclaimer

This repository only provides the macOS installation and service-management script for `subs-check`. It does not contain the core implementation. For features, source code, issues, and releases, refer to the upstream repository [`beck-8/subs-check`](https://github.com/beck-8/subs-check).

This tool is intended for learning and research purposes only. You are responsible for your own usage and should ensure it complies with local laws, regulations, and the terms of the target services.
