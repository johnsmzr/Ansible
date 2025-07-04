#!/bin/bash

# Ansible服务器初始化部署脚本
# 使用方法: ./scripts/deploy.sh [选项]

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

# 默认配置
INVENTORY_FILE="inventory/hosts.yml"
PLAYBOOK="site.yml"
TAGS=""
LIMIT=""
EXTRA_VARS=""
CHECK_MODE=""
VERBOSE=""
ASK_PASS=""
ASK_BECOME_PASS=""

# 显示帮助信息
show_help() {
    echo -e "${BLUE}Ansible服务器初始化部署脚本${NC}"
    echo ""
    echo "使用方法: $0 [选项]"
    echo ""
    echo "选项:"
    echo "  -h, --help              显示此帮助信息"
    echo "  -i, --inventory FILE    指定inventory文件 (默认: $INVENTORY_FILE)"
    echo "  -p, --playbook FILE     指定playbook文件 (默认: $PLAYBOOK)"
    echo "  -t, --tags TAGS         指定要执行的标签"
    echo "  -l, --limit HOSTS       限制执行的主机"
    echo "  -e, --extra-vars VARS   额外变量"
    echo "  -c, --check             检查模式（dry-run）"
    echo "  -v, --verbose           详细输出"
    echo "  --quick                 快速安装（仅安装基础工具）"
    echo "  --security              仅执行安全配置"
      echo "  --syntax-check          语法检查"
  echo "  --list-hosts            列出目标主机"
  echo "  --list-tasks            列出所有任务"
  echo "  --ask-pass              询问SSH密码"
  echo "  --ask-become-pass       询问sudo密码"
    echo ""
    echo "示例:"
    echo "  $0                                    # 完整部署所有主机"
    echo "  $0 -l production                     # 仅部署生产环境"
    echo "  $0 -t packages                       # 仅安装软件包"
    echo "  $0 --quick                           # 快速安装基础工具"
    echo "  $0 --security                        # 仅执行安全配置"
    echo "  $0 -c                                # 检查模式"
    echo "  $0 -l \"prod-server-01,prod-server-02\" # 部署指定主机"
}

# 检查Ansible是否安装
check_ansible() {
    if ! command -v ansible-playbook &> /dev/null; then
        echo -e "${RED}错误: 未找到ansible-playbook命令${NC}"
        echo "请先安装Ansible:"
        echo "  # CentOS/RHEL: yum install ansible"
        echo "  # Ubuntu/Debian: apt install ansible"
        echo "  # pip: pip install ansible"
        exit 1
    fi
}

# 检查inventory文件
check_inventory() {
    if [[ ! -f "$PROJECT_DIR/$INVENTORY_FILE" ]]; then
        echo -e "${RED}错误: inventory文件不存在: $INVENTORY_FILE${NC}"
        echo "请先配置inventory文件"
        exit 1
    fi
}

# 检查playbook文件
check_playbook() {
    local pb_file="$1"
    if [[ ! -f "$PROJECT_DIR/$pb_file" ]]; then
        echo -e "${RED}错误: playbook文件不存在: $pb_file${NC}"
        exit 1
    fi
}

# 语法检查
syntax_check() {
    echo -e "${BLUE}执行语法检查...${NC}"
    cd "$PROJECT_DIR"
    ansible-playbook -i "$INVENTORY_FILE" "$PLAYBOOK" --syntax-check
    echo -e "${GREEN}语法检查通过！${NC}"
}

# 列出主机
list_hosts() {
    echo -e "${BLUE}目标主机列表:${NC}"
    cd "$PROJECT_DIR"
    ansible-playbook -i "$INVENTORY_FILE" "$PLAYBOOK" --list-hosts ${LIMIT:+--limit "$LIMIT"}
}

# 列出任务
list_tasks() {
    echo -e "${BLUE}任务列表:${NC}"
    cd "$PROJECT_DIR"
    ansible-playbook -i "$INVENTORY_FILE" "$PLAYBOOK" --list-tasks ${TAGS:+--tags "$TAGS"} ${LIMIT:+--limit "$LIMIT"}
}

# 执行部署
run_deployment() {
    echo -e "${BLUE}开始执行Ansible部署...${NC}"
    echo "配置信息:"
    echo "  Inventory: $INVENTORY_FILE"
    echo "  Playbook: $PLAYBOOK"
    echo "  Tags: ${TAGS:-all}"
    echo "  Hosts: ${LIMIT:-all}"
    echo "  Check Mode: ${CHECK_MODE:-false}"
    echo ""
    
    cd "$PROJECT_DIR"
    
    # 构建ansible-playbook命令
    local cmd="ansible-playbook -i \"$INVENTORY_FILE\" \"$PLAYBOOK\""
    
    [[ -n "$TAGS" ]] && cmd="$cmd --tags \"$TAGS\""
    [[ -n "$LIMIT" ]] && cmd="$cmd --limit \"$LIMIT\""
    [[ -n "$EXTRA_VARS" ]] && cmd="$cmd --extra-vars \"$EXTRA_VARS\""
    [[ -n "$CHECK_MODE" ]] && cmd="$cmd --check"
    [[ -n "$VERBOSE" ]] && cmd="$cmd -v"
    [[ -n "$ASK_PASS" ]] && cmd="$cmd --ask-pass"
    [[ -n "$ASK_BECOME_PASS" ]] && cmd="$cmd --ask-become-pass"
    
    echo -e "${YELLOW}执行命令: $cmd${NC}"
    echo ""
    
    eval $cmd
    
    if [[ $? -eq 0 ]]; then
        echo -e "${GREEN}部署完成！${NC}"
    else
        echo -e "${RED}部署失败！${NC}"
        exit 1
    fi
}

# 解析命令行参数
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -i|--inventory)
            INVENTORY_FILE="$2"
            shift 2
            ;;
        -p|--playbook)
            PLAYBOOK="$2"
            shift 2
            ;;
        -t|--tags)
            TAGS="$2"
            shift 2
            ;;
        -l|--limit)
            LIMIT="$2"
            shift 2
            ;;
        -e|--extra-vars)
            EXTRA_VARS="$2"
            shift 2
            ;;
        -c|--check)
            CHECK_MODE="--check"
            shift
            ;;
        -v|--verbose)
            VERBOSE="-v"
            shift
            ;;
        --quick)
            PLAYBOOK="playbooks/quick-install.yml"
            shift
            ;;
        --security)
            PLAYBOOK="playbooks/security-only.yml"
            shift
            ;;
        --syntax-check)
            check_ansible
            check_inventory
            check_playbook "$PLAYBOOK"
            syntax_check
            exit 0
            ;;
        --list-hosts)
            check_ansible
            check_inventory
            check_playbook "$PLAYBOOK"
            list_hosts
            exit 0
            ;;
        --list-tasks)
            check_ansible
            check_inventory
            check_playbook "$PLAYBOOK"
            list_tasks
            exit 0
            ;;
        --ask-pass)
            ASK_PASS="--ask-pass"
            shift
            ;;
        --ask-become-pass)
            ASK_BECOME_PASS="--ask-become-pass"
            shift
            ;;
        *)
            echo -e "${RED}未知选项: $1${NC}"
            show_help
            exit 1
            ;;
    esac
done

# 执行前检查
check_ansible
check_inventory
check_playbook "$PLAYBOOK"

# 执行部署
run_deployment 