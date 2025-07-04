# Ansible 简单服务器配置

这是一个简化的 Ansible Playbook，用于快速初始化和配置 Linux 服务器。

## 🚀 快速开始

### 1. 准备工作

确保已安装 Ansible：
```bash
pip install ansible
```

### 2. 配置SSH公钥（重要！）

**⚠️ 在运行playbook之前，请务必配置SSH公钥，否则可能被锁在服务器外面！**

编辑 `server-setup.yml`，在 `ssh_public_keys` 部分添加你的公钥：

```yaml
ssh_public_keys:
  - "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC... 你的公钥内容"
  - "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI... 另一个公钥（可选）"
```

**获取你的公钥：**
```bash
# 查看现有公钥
cat ~/.ssh/id_rsa.pub
# 或
cat ~/.ssh/id_ed25519.pub

# 如果没有公钥，先生成一个
ssh-keygen -t ed25519 -C "your_email@example.com"
```

### 3. 配置目标服务器

编辑 `inventory.yml`：
```yaml
all:
  hosts:
    server01:
      ansible_host: 192.168.100.110  # 修改为你的服务器IP
      ansible_user: root              # 修改为你的用户名
```

### 4. 运行配置

```bash
# 测试连接
ansible all -m ping

# 完整配置
ansible-playbook server-setup.yml

# 只运行特定部分
ansible-playbook server-setup.yml --tags system    # 系统配置
ansible-playbook server-setup.yml --tags packages  # 软件包安装
ansible-playbook server-setup.yml --tags security  # 安全配置
```

## 📋 功能特性

### ✅ 系统基础配置
- 更新软件包缓存
- 设置时区（默认：Asia/Shanghai）
- 配置主机名
- 更新 /etc/hosts

### ✅ 软件包管理
- 安装常用工具：vim, curl, wget, htop, git, unzip, tree, screen, tmux
- 安装 Python3 和 pip

### ✅ 用户和SSH安全
- 管理员用户配置
- SSH公钥部署
- SSH安全加固：
  - 禁用密码认证
  - 启用公钥认证
  - 限制登录尝试次数
  - 禁止root密码登录

### ✅ 系统优化
- 配置文件描述符限制
- 调优网络参数

### ✅ 便利功能
- 创建常用命令别名
- 验证配置状态
- 详细的完成报告

## 🔧 高级配置

### 自定义变量

在 `server-setup.yml` 中可以修改以下变量：

```yaml
vars:
  server_timezone: "Asia/Shanghai"      # 时区
  ssh_public_keys:                      # SSH公钥列表
    - "你的公钥内容"
  admin_users:                          # 管理员用户
    - name: "用户名"
      groups: ["sudo"]
      shell: "/bin/bash"
  install_packages:                     # 要安装的软件包
    - vim
    - curl
    # ... 更多包
```

### 标签说明

| 标签 | 功能 |
|------|------|
| `system` | 系统基础配置（时区、主机名等） |
| `packages` | 软件包安装 |
| `users` | 用户管理 |
| `security` | SSH和安全配置 |
| `optimize` | 系统优化 |
| `config` | 配置文件和别名 |
| `verify` | 验证配置 |
| `info` | 显示信息 |

## ⚠️ 安全注意事项

1. **必须配置SSH公钥**：在启用SSH安全配置前，确保已正确配置SSH公钥
2. **备份重要文件**：Playbook会自动备份重要配置文件
3. **测试连接**：在禁用密码认证前，确保可以使用公钥登录
4. **保留访问方式**：建议在配置前保持一个可用的SSH连接

## 🐛 故障排除

### 被锁在服务器外面？

如果意外被锁在外面：
1. 通过控制台/KVM等物理方式登录
2. 检查 `/etc/ssh/sshd_config` 配置
3. 临时启用密码认证：`PasswordAuthentication yes`
4. 重启SSH服务：`systemctl restart ssh`

### 包安装失败？

如果遇到404错误：
```bash
# 先更新缓存
ansible-playbook server-setup.yml --tags "system,packages"
```

### 验证配置

```bash
# 检查SSH配置
ansible all -m command -a "sshd -T | grep -E 'passwordauthentication|pubkeyauthentication'"

# 检查时区
ansible all -m command -a "timedatectl"

# 检查主机名
ansible all -m command -a "hostname"
```

## 📝 更新日志

- v2.0: 添加SSH公钥管理和安全配置
- v1.1: 修复主机名和时区重启后丢失问题
- v1.0: 基础服务器配置功能 