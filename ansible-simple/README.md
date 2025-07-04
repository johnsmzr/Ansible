# Ansible 简化学习版本

## 📁 文件结构
```
ansible-simple/
├── inventory.yml       # 主机清单
├── server-setup.yml    # 主要配置playbook
├── ansible.cfg         # ansible配置
└── README.md          # 说明文档
```

## 🚀 快速开始

### 1. 修改主机信息
编辑 `inventory.yml`，修改服务器IP和用户：
```yaml
all:
  hosts:
    server01:
      ansible_host: 你的服务器IP
      ansible_user: root
```

### 2. 测试连接
```bash
ansible all -m ping
```

### 3. 运行完整配置
```bash
ansible-playbook server-setup.yml
```

### 4. 只运行特定部分
```bash
# 只安装软件包
ansible-playbook server-setup.yml --tags packages

# 只做系统配置
ansible-playbook server-setup.yml --tags system

# 只做安全配置
ansible-playbook server-setup.yml --tags security
```

## 🔧 功能说明

这个简化版本包含：
- ✅ 系统基础配置（时区、主机名）
- ✅ 软件包安装（vim, git, htop等）
- ✅ 系统优化（limits, 网络参数）
- ✅ 基础安全配置（SSH）
- ✅ 实用别名配置

## 📚 学习要点

1. **inventory.yml** - 定义要管理的服务器
2. **server-setup.yml** - 主要的配置任务
3. **tags** - 用于选择性执行任务
4. **vars** - 变量定义，便于修改
5. **handlers** - 处理服务重启等操作

这个版本去掉了复杂的roles结构，所有配置都在一个文件中，更容易理解和学习！ 