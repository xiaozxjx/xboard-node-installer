# XBoard Node Universal Installer

使用方法：

```bash
curl -fsSL https://raw.githubusercontent.com/xiaozxjx/xboard-node-installer/main/install-online.sh | sh
```

一个仅适用于Alpine环境的 XBoard Node 自动安装器。

支持架构：

- amd64
- arm64


---

## Features

### 自动检测

自动识别：

- CPU 架构


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
|Alpine|OpenRC|

License
MIT
