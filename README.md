# XBoard Node Universal Installer

一个适用于多种 Linux 环境的 XBoard Node 自动安装器。

支持：

- Debian
- Ubuntu
- Alpine Linux
- OpenRC
- systemd
- BusyBox init

支持架构：

- amd64
- arm64
- armv7


---

## Features

### 自动检测

自动识别：

- Linux 发行版
- CPU 架构
- Init 系统
- 虚拟化环境


### 自动安装

自动完成：

1. 下载 xboard-node
2. 安装二进制
3. 创建配置
4. 注册服务
5. 启动节点
6. 健康检查


### 服务支持

|系统|服务|
|-|-|
|Debian|systemd|
|Ubuntu|systemd|
|Alpine|OpenRC|
|BusyBox|后台运行|



---

# Installation


## Interactive Mode

直接运行：

```bash
bash install.sh


输入：
Panel URL:
Node Token:
Machine ID:
Machine Mode
无人值守安装：
bash install.sh \
--mode machine \
--panel "https://example.com" \
--token "TOKEN" \
--machine-id 10
参数说明：
参数	说明
--panel	XBoard Panel 地址
--token	节点 Token
--machine-id	机器 ID

Service Management
systemd
查看状态：
systemctl status xboard-node
启动：
systemctl start xboard-node
停止：
systemctl stop xboard-node
重启：
systemctl restart xboard-node
日志：
journalctl -u xboard-node -f
OpenRC
查看：
rc-service xboard-node status
启动：
rc-service xboard-node start
停止：
rc-service xboard-node stop
重启：
rc-service xboard-node restart
日志：
tail -f /var/log/xboard-node/service.log
Configuration
配置文件：
/etc/xboard-node/config.yml
示例：
panel:
  url: https://example.com

token: your-token

machine_id: 10
Health Check
执行：
bash lib/health.sh
检查：
Binary
Config
Process
Service
Port
Update
更新节点：
bash lib/update.sh
更新流程：
backup old binary

        ↓

download latest

        ↓

replace

        ↓

restart service
Uninstall
卸载：
bash lib/uninstall.sh
卸载内容：
服务
二进制
配置
日志
备份位置：
/var/backups/xboard-node
Directory Structure
xboard-node-installer

├── install.sh

├── lib

│   ├── common.sh

│   ├── detect.sh

│   ├── download.sh

│   ├── config.sh

│   ├── service-systemd.sh

│   ├── service-openrc.sh

│   ├── service-none.sh

│   ├── health.sh

│   ├── update.sh

│   └── uninstall.sh

│

└── templates

    ├── xboard-node.service

    └── xboard-node.init
Tested Environment
已适配：
Debian 13
Alpine Linux 3.22
ARM64
AMD64
OpenRC
systemd
License
MIT
