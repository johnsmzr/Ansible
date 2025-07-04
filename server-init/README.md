# Ansible服务器初始化工具集

这是一个完整的Ansible配置集，用于自动化新服务器的初始化过程，包括安装必要工具、系统配置、安全加固等。

## 🚀 功能特性

### 核心功能
- ✅ **基础工具安装**: vim, curl, htop, git, wget, unzip, tree, nano等
- ✅ **系统优化配置**: 内核参数调优、文件描述符限制、时区设置
- ✅ **安全加固**: SSH配置、fail2ban、防火墙规则、时间同步
- ✅ **用户管理**: 创建管理员用户、SSH密钥配置、sudo权限
- ✅ **环境区分**: 支持生产、测试、开发环境的差异化配置

### 支持的操作系统
- CentOS 7/8/9, RHEL 7/8/9, Rocky Linux
- Ubuntu 18.04/20.04/22.04
- Debian 10/11

## 📋 安装要求

### 控制节点（运行Ansible的机器）
```bash
# CentOS/RHEL
sudo yum install python3 python3-pip
pip3 install -r requirements.txt

# Ubuntu/Debian  
sudo apt install python3 python3-pip
pip3 install -r requirements.txt

# 或者直接安装Ansible
sudo yum install ansible  # CentOS/RHEL
sudo apt install ansible  # Ubuntu/Debian
```

### 目标服务器
- SSH访问权限（密钥或密码认证）
- Python 3.x（大多数现代Linux发行版默认安装）
- sudo或root权限

## 🛠️ 快速开始

### 1. 配置主机清单
编辑 `inventory/hosts.yml` 文件，添加你的服务器信息：

```yaml
all:
  children:
    production:
      hosts:
        prod-server-01:
          ansible_host: 192.168.1.10
          ansible_user: root
        prod-server-02:
          ansible_host: 192.168.1.11
          ansible_user: root
```

### 2. 配置变量（可选）
在 `group_vars/all.yml` 中配置全局变量，或在对应环境的变量文件中配置特定环境的变量。

### 3. 执行部署

#### 使用部署脚本（推荐）
```bash
# 完整初始化所有主机
./scripts/deploy.sh

# 仅部署生产环境
./scripts/deploy.sh -l production

# 快速安装基础工具
./scripts/deploy.sh --quick

# 仅执行安全配置
./scripts/deploy.sh --security

# 检查模式（不实际执行）
./scripts/deploy.sh -c

# 查看帮助
./scripts/deploy.sh -h
```

#### 直接使用Ansible命令
```bash
# 完整部署
ansible-playbook -i inventory/hosts.yml site.yml

# 仅安装软件包
ansible-playbook -i inventory/hosts.yml site.yml --tags packages

# 部署特定主机
ansible-playbook -i inventory/hosts.yml site.yml --limit prod-server-01
```

## 📁 项目结构

```
server-init/
├── ansible.cfg              # Ansible配置文件
├── site.yml                 # 主playbook文件
├── requirements.txt          # Python依赖
├── inventory/
│   └── hosts.yml            # 主机清单
├── group_vars/
│   ├── all.yml              # 全局变量
│   ├── production.yml       # 生产环境变量
│   └── development.yml      # 开发环境变量
├── roles/
│   ├── basic-tools/         # 基础工具安装角色
│   ├── system-init/         # 系统初始化角色
│   ├── security-basic/      # 基础安全配置角色
│   └── user-management/     # 用户管理角色
├── playbooks/
│   ├── quick-install.yml    # 快速安装playbook
│   └── security-only.yml    # 仅安全配置playbook
└── scripts/
    └── deploy.sh            # 部署脚本
```

## 🔧 配置说明

### 主要变量配置

在 `group_vars/all.yml` 中可以配置以下变量：

```yaml
# 系统配置
server_timezone: "Asia/Shanghai"
set_hostname: true

# 安全配置
configure_ssh: true
install_fail2ban: true
configure_firewall: false

# 管理员用户配置
admin_users:
  - name: admin
    groups: ["wheel"]
    shell: /bin/bash
    ssh_key: "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAB... admin@example.com"
```

### 环境特定配置

- `group_vars/production.yml`: 生产环境配置（更严格的安全设置）
- `group_vars/development.yml`: 开发环境配置（相对宽松的设置）

## 📝 使用示例

### 示例1: 初始化生产服务器
```bash
# 1. 配置inventory
vim inventory/hosts.yml

# 2. 配置生产环境变量
vim group_vars/production.yml

# 3. 执行部署
./scripts/deploy.sh -l production
```

### 示例2: 快速安装开发工具
```bash
# 仅安装基础工具，不做系统配置
./scripts/deploy.sh --quick -l development
```

### 示例3: 安全加固现有服务器
```bash
# 仅执行安全配置
./scripts/deploy.sh --security
```

## 🔒 安全注意事项

1. **SSH配置**: 默认会禁用密码认证，启用密钥认证
2. **防火墙**: 生产环境默认启用UFW防火墙
3. **用户权限**: 会锁定不必要的系统用户
4. **时间同步**: 配置chrony进行时间同步
5. **日志审计**: 配置系统审计日志

## 🎯 标签使用

可以使用标签来执行特定的任务：

```bash
# 仅安装软件包
ansible-playbook -i inventory/hosts.yml site.yml --tags packages

# 仅执行安全配置
ansible-playbook -i inventory/hosts.yml site.yml --tags security

# 仅配置用户
ansible-playbook -i inventory/hosts.yml site.yml --tags users

# 仅系统配置
ansible-playbook -i inventory/hosts.yml site.yml --tags system
```

## 🐛 故障排除

### 常见问题

1. **SSH连接失败**
   ```bash
   # 检查SSH连接
   ansible all -i inventory/hosts.yml -m ping
   ```

2. **权限不足**
   ```bash
   # 使用sudo
   ansible-playbook -i inventory/hosts.yml site.yml --become --ask-become-pass
   ```

3. **Python路径问题**
   - 在inventory中设置正确的Python路径：
   ```yaml
   ansible_python_interpreter: /usr/bin/python3
   ```

### 日志查看
```bash
# 详细输出
./scripts/deploy.sh -v

# 检查模式
./scripts/deploy.sh -c
```

## 📚 扩展功能

### 添加自定义角色
1. 在 `roles/` 目录下创建新角色
2. 在 `site.yml` 中引用新角色
3. 在相应的变量文件中添加配置

### 添加新的目标主机
1. 在 `inventory/hosts.yml` 中添加主机信息
2. 根据需要创建主机特定的变量文件 `host_vars/hostname.yml`

## 🤝 贡献

欢迎提交issue和pull request来改进这个项目！

## 📄 许可证

MIT License