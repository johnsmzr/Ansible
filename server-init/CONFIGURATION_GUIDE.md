# 📖 Ansible服务器初始化配置指南

## 🎯 当前配置状态

您的服务器已经配置为：
- **主机地址**: 192.168.100.110
- **登录用户**: root  
- **认证方式**: 密码认证 (password)

## 📋 配置位置总览

### 1. 主机配置 (inventory/hosts.yml)
```yaml
production:
  hosts:
    prod-server-01:
      ansible_host: 192.168.100.110      # 服务器IP地址
      ansible_user: root                 # 登录用户名
      ansible_ssh_pass: password         # SSH登录密码
      ansible_become_pass: password      # sudo密码
```

### 2. 全局配置 (group_vars/all.yml)
- 时区设置、系统优化参数
- 要安装的软件包列表
- 安全配置选项

### 3. 环境特定配置
- `group_vars/production.yml` - 生产环境配置
- `group_vars/development.yml` - 开发环境配置

## 🔧 常见配置场景

### 场景1: 添加更多服务器
在 `inventory/hosts.yml` 中添加：
```yaml
production:
  hosts:
    prod-server-01:
      ansible_host: 192.168.100.110
      ansible_user: root
      ansible_ssh_pass: password
    prod-server-02:                      # 新增服务器
      ansible_host: 192.168.100.111      # 新服务器IP
      ansible_user: root
      ansible_ssh_pass: password
```

### 场景2: 使用不同的用户名和密码
```yaml
prod-server-01:
  ansible_host: 192.168.100.110
  ansible_user: ubuntu                   # 改为ubuntu用户
  ansible_ssh_pass: your_password        # 实际密码
  ansible_become: yes                    # 需要sudo
  ansible_become_pass: sudo_password     # sudo密码
```

### 场景3: 自定义SSH端口
```yaml
prod-server-01:
  ansible_host: 192.168.100.110
  ansible_port: 2222                     # 自定义SSH端口
  ansible_user: root
  ansible_ssh_pass: password
```

### 场景4: 使用SSH密钥（推荐）
```yaml
prod-server-01:
  ansible_host: 192.168.100.110
  ansible_user: root
  ansible_ssh_private_key_file: ~/.ssh/id_rsa  # 私钥路径
  # 移除 ansible_ssh_pass 行
```

## 🚀 快速开始步骤

### 第一步：验证当前配置
```bash
cd server-init

# 测试连接
./scripts/test-connection.sh
```

### 第二步：快速安装（推荐首次使用）
```bash
# 仅安装基础工具，不修改系统配置
./scripts/deploy.sh --quick
```

### 第三步：完整部署
```bash
# 完整的服务器初始化
./scripts/deploy.sh
```

## 🛠️ 配置自定义选项

### 修改要安装的软件包
编辑 `roles/basic-tools/tasks/main.yml`，在对应的操作系统部分添加软件包：

```yaml
# Ubuntu/Debian
- name: "安装基础开发工具包 (Ubuntu/Debian)"
  package:
    name:
      - vim
      - curl
      - your-package-here    # 添加您需要的软件包
```

### 修改系统配置
编辑 `group_vars/all.yml`：
```yaml
# 时区设置
server_timezone: "Asia/Shanghai"

# 禁用不需要的服务
disable_unnecessary_services: true

# 安全配置
configure_ssh: true
install_fail2ban: true
```

### 配置管理员用户
编辑 `group_vars/all.yml`，取消注释并修改：
```yaml
admin_users:
  - name: admin
    groups: ["wheel"]
    shell: /bin/bash
    ssh_key: "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAB... your-public-key"
```

## 🔒 安全配置

### 当前安全级别：开发/测试
- 密码明文存储在inventory文件中
- 适合快速测试和开发环境

### 提升到生产级别安全
1. **使用SSH密钥**：
   ```bash
   # 生成密钥对
   ssh-keygen -t rsa -b 4096
   
   # 复制公钥到服务器
   ssh-copy-id root@192.168.100.110
   ```

2. **使用ansible-vault加密密码**：
   ```bash
   # 创建加密文件
   ansible-vault create group_vars/production/vault.yml
   ```

3. **限制文件权限**：
   ```bash
   chmod 600 inventory/hosts.yml
   ```

## 🎛️ 运行选项

### 基本运行
```bash
./scripts/deploy.sh                    # 完整部署
./scripts/deploy.sh --quick           # 快速安装
./scripts/deploy.sh --security        # 仅安全配置
```

### 高级选项
```bash
./scripts/deploy.sh -c                # 检查模式（不实际执行）
./scripts/deploy.sh -v                # 详细输出
./scripts/deploy.sh -l production     # 仅部署生产环境
./scripts/deploy.sh -t packages       # 仅安装软件包
```

### 密码相关选项
```bash
./scripts/deploy.sh --ask-pass        # 运行时询问SSH密码
./scripts/deploy.sh --ask-become-pass # 运行时询问sudo密码
```

## 🐛 常见问题解决

### 1. 连接被拒绝
```bash
# 检查SSH服务是否运行
ssh root@192.168.100.110

# 如果SSH端口不是22
ssh -p 2222 root@192.168.100.110
```

### 2. 主机密钥验证失败
```bash
# 临时解决
export ANSIBLE_HOST_KEY_CHECKING=False
./scripts/deploy.sh --quick
```

### 3. 权限不足
确保用户有sudo权限，或者在inventory中添加：
```yaml
ansible_become: yes
ansible_become_pass: sudo_password
```

### 4. Python未找到
在inventory中指定Python路径：
```yaml
ansible_python_interpreter: /usr/bin/python3
```

## 📚 进一步学习

- 查看 `docs/password-config.md` 了解密码配置详情
- 查看 `examples/` 目录中的配置示例
- 阅读各个角色的 `tasks/main.yml` 了解具体执行的任务

## 📞 获取帮助

```bash
# 查看脚本帮助
./scripts/deploy.sh -h

# 测试连接
./scripts/test-connection.sh

# 检查配置语法
./scripts/deploy.sh --syntax-check
``` 