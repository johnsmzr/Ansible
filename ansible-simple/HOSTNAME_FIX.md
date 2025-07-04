# Hostname 重启后复原问题修复指南

## 问题描述
服务器重启后，hostname 自动复原到默认值，无法保持设置的主机名。

## 问题原因
常见原因包括：
1. **云平台重置** - cloud-init 在启动时重新设置 hostname
2. **DHCP 客户端重置** - DHCP 客户端使用服务器提供的 hostname
3. **NetworkManager 管理** - NetworkManager 自动管理 hostname
4. **缺少持久化配置** - 系统缺少适当的持久化机制

## 修复方案

### 方法一：运行完整的服务器配置（推荐）
```bash
# 运行完整的配置，包含hostname修复
ansible-playbook -i inventory.yml server-setup.yml
```

### 方法二：仅运行hostname相关配置
```bash
# 只运行系统相关的任务（包含hostname配置）
ansible-playbook -i inventory.yml server-setup.yml --tags system
```

### 方法三：手动修复（紧急情况）
如果Ansible不可用，可以手动执行以下命令：

```bash
# 1. 设置hostname到配置文件
echo "server01" > /etc/hostname

# 2. 设置运行时hostname
hostnamectl set-hostname server01 --static
hostnamectl set-hostname server01 --transient
hostnamectl set-hostname server01 --pretty

# 3. 更新/etc/hosts
echo "127.0.1.1    server01" >> /etc/hosts

# 4. 禁用cloud-init hostname管理（如果存在）
if [ -f /etc/cloud/cloud.cfg ]; then
    echo "preserve_hostname: true" >> /etc/cloud/cloud.cfg
fi

# 5. 创建systemd服务
cat > /etc/systemd/system/set-hostname.service << EOF
[Unit]
Description=Set Hostname at Boot
After=network.target
Before=network-online.target

[Service]
Type=oneshot
ExecStart=/bin/hostnamectl set-hostname server01
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

# 6. 启用服务
systemctl daemon-reload
systemctl enable set-hostname.service

# 7. 禁用NetworkManager hostname管理（如果存在）
if [ -f /etc/NetworkManager/NetworkManager.conf ]; then
    echo "hostname-mode=none" >> /etc/NetworkManager/NetworkManager.conf
    systemctl restart NetworkManager
fi
```

## 修复内容

本次修复包含以下增强功能：

### 1. 多层次持久化配置
- `/etc/hostname` 文件配置
- `hostnamectl` 静态、瞬态、漂亮名称配置
- systemd 服务强制设置

### 2. 禁用自动重置机制
- 云平台 cloud-init hostname 重置
- NetworkManager 自动 hostname 管理
- DHCP 客户端 hostname 更新

### 3. 启动时强制设置
- 创建专用的 systemd 服务
- 在网络启动后自动执行
- 确保每次启动都设置正确的 hostname

## 验证修复效果

### 运行后验证
```bash
# 检查当前hostname
hostname

# 检查hostnamectl状态
hostnamectl status

# 检查服务状态
systemctl status set-hostname.service

# 检查配置文件
cat /etc/hostname
cat /etc/hosts | grep 127.0.1.1
```

### 重启后验证
```bash
# 重启服务器
sudo reboot

# 重新连接后检查
hostname
hostnamectl status
```

## 注意事项

1. **备份重要文件** - 修复过程会备份相关配置文件
2. **网络服务重启** - 可能会重启 NetworkManager 服务
3. **云平台兼容** - 适用于大多数云平台和物理服务器
4. **权限要求** - 需要 root 权限执行

## 故障排除

### 如果重启后hostname仍然复原
1. 检查是否有其他服务在管理hostname：
   ```bash
   systemctl list-units | grep hostname
   journalctl -u systemd-hostnamed
   ```

2. 检查cloud-init日志（如果是云平台）：
   ```bash
   cat /var/log/cloud-init.log | grep hostname
   ```

3. 检查DHCP客户端日志：
   ```bash
   journalctl | grep dhc
   ```

### 联系支持
如果问题仍然存在，请提供以下信息：
- 操作系统版本：`cat /etc/os-release`
- 云平台信息（如果适用）
- 错误日志：`journalctl -u set-hostname.service` 