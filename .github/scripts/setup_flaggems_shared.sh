#!/usr/bin/env bash
#
# 初始化 FlagGems 共享存储目录结构
# 需要在 CI 机器上手动执行一次
#

set -euo pipefail

FLAGGEMS_ROOT="/mnt/airs-business/cicd/flaggems"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=========================================="
echo "初始化 FlagGems 共享存储"
echo "根目录: ${FLAGGEMS_ROOT}"
echo "=========================================="

# 创建目录结构
echo "创建目录结构..."
mkdir -p "${FLAGGEMS_ROOT}/nvidia/FlagGems"
mkdir -p "${FLAGGEMS_ROOT}/nvidia/config"
mkdir -p "${FLAGGEMS_ROOT}/enflame/FlagGems"
mkdir -p "${FLAGGEMS_ROOT}/enflame/config"
mkdir -p "${FLAGGEMS_ROOT}/mthreads/FlagGems"
mkdir -p "${FLAGGEMS_ROOT}/mthreads/config"
mkdir -p "${FLAGGEMS_ROOT}/scripts"

# 复制脚本
echo "复制脚本文件..."
cp "${SCRIPT_DIR}/parse_operators.py" "${FLAGGEMS_ROOT}/scripts/"
cp "${SCRIPT_DIR}/run_flaggems_test.sh" "${FLAGGEMS_ROOT}/scripts/"
chmod +x "${FLAGGEMS_ROOT}/scripts/"*.sh
chmod +x "${FLAGGEMS_ROOT}/scripts/"*.py

# 创建 ignore_list.txt (如果不存在)
for backend in nvidia enflame mthreads; do
    IGNORE_FILE="${FLAGGEMS_ROOT}/${backend}/config/ignore_list.txt"
    if [ ! -f "$IGNORE_FILE" ]; then
        echo "创建 ${backend} 的 ignore_list.txt..."
        cat > "$IGNORE_FILE" << 'EOF'
# FlagGems 忽略列表
# 每行一个测试文件名 (相对于 tests/ 目录)
# 以 # 开头的行为注释，空行会被跳过

EOF
    fi
done

echo ""
echo "=========================================="
echo "目录结构初始化完成!"
echo ""
echo "后续步骤:"
echo "1. 克隆 FlagGems 到各后端目录:"
echo "   cd ${FLAGGEMS_ROOT}/nvidia/FlagGems"
echo "   git clone https://github.com/flagos-ai/FlagGems.git ."
echo ""
echo "2. 编辑忽略列表 (如有需要):"
echo "   vim ${FLAGGEMS_ROOT}/nvidia/config/ignore_list.txt"
echo ""
echo "3. 测试脚本:"
echo "   ${FLAGGEMS_ROOT}/scripts/run_flaggems_test.sh --backend nvidia"
echo "=========================================="
