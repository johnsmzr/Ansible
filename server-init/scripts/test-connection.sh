#!/bin/bash

# 测试Ansible连接脚本
# 使用方法: ./scripts/test-connection.sh

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 脚本目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo -e "${BLUE}Ansible连接测试${NC}"
echo "项目目录: $PROJECT_DIR"
echo ""

# 切换到项目目录
cd "$PROJECT_DIR"

# 检查inventory文件
if [[ ! -f "inventory/hosts.yml" ]]; then
    echo -e "${RED}错误: inventory文件不存在${NC}"
    exit 1
fi

echo -e "${YELLOW}1. 检查inventory配置...${NC}"
ansible-inventory -i inventory/hosts.yml --list

echo ""
echo -e "${YELLOW}2. 测试连接所有主机...${NC}"
ansible all -i inventory/hosts.yml -m ping

echo ""
echo -e "${YELLOW}3. 收集基本信息...${NC}"
ansible all -i inventory/hosts.yml -m setup -a "filter=ansible_distribution*"

echo ""
echo -e "${GREEN}连接测试完成！${NC}"
echo ""
echo "下一步操作:"
echo "  # 快速安装基础工具"
echo "  ./scripts/deploy.sh --quick"
echo ""
echo "  # 完整部署"
echo "  ./scripts/deploy.sh" 