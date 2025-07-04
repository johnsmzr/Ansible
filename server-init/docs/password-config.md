# 服务器密码配置指南

在Ansible中配置服务器登录密码有多种方式，根据安全级别和使用场景选择合适的方法。

## 🔐 配置方式对比

| 方式 | 安全性 | 适用场景 | 复杂度 |
|------|--------|----------|--------|
| inventory明文 | ❌ 低 | 测试环境 | ⭐ 简单 |
| 环境变量 | ⚠️ 中 | 开发/测试 | ⭐⭐ 中等 |
| ansible-vault | ✅ 高 | 生产环境 | ⭐⭐⭐ 较复杂 |
| SSH密钥 | ✅ 最高 | 生产环境 | ⭐⭐⭐ 较复杂 |

## 方法1: 在inventory中直接配置（当前配置）

### 配置位置
编辑 `inventory/hosts.yml`：

```yaml
production:
  hosts:
    prod-server-01:
      ansible_host: 192.168.100.110
      ansible_user: root
      ansible_ssh_pass: password        # SSH登录密码
      ansible_become_pass: password     # sudo密码（如果需要）
```

### 优缺点
- ✅ 配置简单，立即可用
- ❌ 密码明文存储，安全性低
- ❌ 不适合版本控制

## 方法2: 使用环境变量

### 配置步骤
1. 在inventory中使用变量引用：
```yaml
production:
  hosts:
    prod-server-01:
      ansible_host: 192.168.100.110
      ansible_user: root
      ansible_ssh_pass: "{{ server_password }}"
      ansible_become_pass: "{{ server_password }}"
```

2. 运行时设置环境变量：
```bash
export ANSIBLE_SSH_PASS="password"
./scripts/deploy.sh -e "server_password=$ANSIBLE_SSH_PASS"
```

## 方法3: 使用ansible-vault加密（推荐生产环境）

### 配置步骤

1. 创建加密的密码文件：
```bash
ansible-vault create group_vars/production/vault.yml
```

2. 在vault.yml中添加密码：
```yaml
vault_ansible_ssh_pass: password
vault_ansible_become_pass: password
```

3. 在group_vars/production.yml中引用：
```yaml
ansible_ssh_pass: "{{ vault_ansible_ssh_pass }}"
ansible_become_pass: "{{ vault_ansible_become_pass }}"
```

4. 运行时提供vault密码：
```bash
./scripts/deploy.sh --ask-vault-pass
# 或者使用密码文件
echo "vault_password" > .vault_pass
./scripts/deploy.sh --vault-password-file .vault_pass
```

## 方法4: 使用SSH密钥（最推荐）

### 配置步骤

1. 生成SSH密钥对：
```bash
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
```

2. 将公钥复制到服务器：
```bash
ssh-copy-id root@192.168.100.110
```

3. 在inventory中配置：
```yaml
production:
  hosts:
    prod-server-01:
      ansible_host: 192.168.100.110
      ansible_user: root
      ansible_ssh_private_key_file: ~/.ssh/id_rsa
```

## 🛠️ 实际使用示例

### 当前配置测试
使用当前的密码配置测试连接：

```bash
# 测试连接
cd server-init
ansible all -i inventory/hosts.yml -m ping

# 执行快速安装
./scripts/deploy.sh --quick

# 完整部署
./scripts/deploy.sh
```

### 如果遇到SSH问题

1. **首次连接主机密钥确认**：
```bash
# 临时禁用主机密钥检查
export ANSIBLE_HOST_KEY_CHECKING=False
```

2. **SSH端口不是22**：
```yaml
prod-server-01:
  ansible_host: 192.168.100.110
  ansible_port: 2222  # 自定义SSH端口
  ansible_user: root
  ansible_ssh_pass: password
```

3. **需要sudo密码**：
```yaml
prod-server-01:
  ansible_host: 192.168.100.110
  ansible_user: username  # 非root用户
  ansible_ssh_pass: password
  ansible_become: yes
  ansible_become_pass: password  # sudo密码
```

## 🔒 安全建议

1. **测试环境**: 可以使用明文密码快速开始
2. **生产环境**: 强烈建议使用SSH密钥或ansible-vault
3. **密码复杂度**: 使用强密码，包含大小写字母、数字和特殊字符
4. **定期更换**: 定期更换服务器密码
5. **权限控制**: 限制inventory文件的访问权限 `chmod 600 inventory/hosts.yml`

## 🎯 推荐配置流程

### 快速测试（当前配置）
1. 使用当前的明文密码配置
2. 测试连接和基本功能
3. 验证脚本正常工作

### 生产部署
1. 切换到SSH密钥认证
2. 禁用密码登录
3. 使用ansible-vault加密敏感信息

### 权限设置
```bash
# 限制inventory文件权限
chmod 600 server-init/inventory/hosts.yml

# 如果使用vault文件
chmod 600 server-init/group_vars/production/vault.yml
``` 