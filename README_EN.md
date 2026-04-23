# subs-check-mac 🍎

> One-click macOS installer for `subs-check`, managed with `launchd`.

🌐 Language: [简体中文](./README.md) | **English**

Core repository: [`beck-8/subs-check`](https://github.com/beck-8/subs-check) 🔗

For detailed usage, refer to the upstream `subs-check` repository.

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

## 🌐 Endpoints

Two ports are exposed by default:

- `8199`: admin panel and locally served subscription files
- `8299`: built-in `Sub-Store` conversion endpoints

### Admin Panel And Local Subscription Files

| Type | URL | Notes |
| --- | --- | --- |
| Admin panel | `http://127.0.0.1:8199/admin` | Web management UI |
| Clash YAML | `http://127.0.0.1:8199/sub/all.yaml` | Generated directly by `subs-check` |
| Mihomo YAML | `http://127.0.0.1:8199/sub/mihomo.yaml` | Mihomo/Clash subscription with rules |
| Base64 | `http://127.0.0.1:8199/sub/base64.txt` | Base64 subscription |

### `Sub-Store` Conversion Endpoints

The links below are added based on the "Subscription Usage" section in the upstream [`beck-8/subs-check`](https://github.com/beck-8/subs-check) README:

| Type | URL |
| --- | --- |
| Generic subscription | `http://127.0.0.1:8299/download/sub` |
| URI | `http://127.0.0.1:8299/download/sub?target=URI` |
| Mihomo / ClashMeta | `http://127.0.0.1:8299/download/sub?target=ClashMeta` |
| Clash | `http://127.0.0.1:8299/download/sub?target=Clash` |
| V2Ray | `http://127.0.0.1:8299/download/sub?target=V2Ray` |
| ShadowRocket | `http://127.0.0.1:8299/download/sub?target=ShadowRocket` |
| Quantumult X | `http://127.0.0.1:8299/download/sub?target=QX` |
| Sing-Box | `http://127.0.0.1:8299/download/sub?target=sing-box` |
| Surge | `http://127.0.0.1:8299/download/sub?target=Surge` |
| Surfboard | `http://127.0.0.1:8299/download/sub?target=Surfboard` |
| Mihomo / Clash with rules | `http://127.0.0.1:8299/api/file/mihomo` |

The `Mihomo / Clash with rules` endpoint uses `https://raw.githubusercontent.com/beck-8/override-hub/refs/heads/main/yaml/ACL4SSR_Online_Full.yaml` as the default overwrite file. You can change it with `mihomo-overwrite-url` in the config.

## 📝 Before Use

Before using the admin panel, set `api-key` in the config file or provide `API_KEY` as an environment variable.

After the API key is configured, open the admin panel at `http://127.0.0.1:8199/admin` and configure your subscription sources.

Make sure to update the following:

1. Set `api-key` in the config file or provide `API_KEY` as an environment variable.
2. Set `sub-urls-remote` to your own remote subscription list URL.
3. Set `sub-urls` to your own subscription URLs.
4. Comment out or remove any template subscription URLs you do not need.

Restart the service after saving the configuration:

```bash
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
