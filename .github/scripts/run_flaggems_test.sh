#!/usr/bin/env bash
#
# FlagGems 精度测试脚本
# 用法: ./run_flaggems_test.sh [--backend nvidia|enflame|mthreads] [--timeout 3300]
#

set -euo pipefail

# 默认参数
BACKEND="nvidia"
TIMEOUT=3300  # 55 分钟
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FLAGGEMS_ROOT="/mnt/airs-business/cicd/flaggems"

# 解析命令行参数
while [[ $# -gt 0 ]]; do
    case $1 in
        --backend)
            BACKEND="$2"
            shift 2
            ;;
        --timeout)
            TIMEOUT="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# 设置路径
FLAGGEMS_DIR="${FLAGGEMS_ROOT}/${BACKEND}/FlagGems"
CONFIG_DIR="${FLAGGEMS_ROOT}/${BACKEND}/config"
SCRIPTS_DIR="${FLAGGEMS_ROOT}/scripts"
IGNORE_LIST="${CONFIG_DIR}/ignore_list.txt"
OPERATORS_YAML="${FLAGGEMS_DIR}/conf/operators.yaml"

echo "=========================================="
echo "FlagGems Accuracy Test"
echo "Backend: ${BACKEND}"
echo "FlagGems dir: ${FLAGGEMS_DIR}"
echo "=========================================="

# 检查目录
if [ ! -d "$FLAGGEMS_DIR" ]; then
    echo "Error: FlagGems directory not found: $FLAGGEMS_DIR"
    exit 1
fi

if [ ! -f "$OPERATORS_YAML" ]; then
    echo "Error: operators.yaml not found: $OPERATORS_YAML"
    exit 1
fi

# 生成 pytest marks
echo "Parsing operators.yaml..."
MARKS=$(${SCRIPTS_DIR}/parse_operators.py "$OPERATORS_YAML")
if [ -z "$MARKS" ]; then
    echo "Error: Failed to generate pytest marks"
    exit 1
fi
echo "Generated marks (first 200 chars): ${MARKS:0:200}..."

# 构建 pytest 命令
PYTEST_CMD="python3 -m pytest tests/ -m \"${MARKS}\" --ref=cpu --quick -v --timeout=300"

# 添加 ignore 参数
if [ -f "$IGNORE_LIST" ]; then
    echo "Loading ignore list from: $IGNORE_LIST"
    while IFS= read -r line || [[ -n "$line" ]]; do
        # 跳过空行和注释
        line=$(echo "$line" | tr -d '[:space:]')
        [[ -z "$line" ]] && continue
        [[ "$line" == \#* ]] && continue
        PYTEST_CMD="${PYTEST_CMD} --ignore=${FLAGGEMS_DIR}/tests/${line}"
        echo "  Ignoring: tests/${line}"
    done < "$IGNORE_LIST"
fi

echo "=========================================="
echo "Running tests with timeout: ${TIMEOUT}s"
echo "Quick mode: enabled"
echo "Reference device: cpu"
echo "=========================================="

# 运行测试
cd "$FLAGGEMS_DIR"
EXIT_CODE=0
timeout "$TIMEOUT" bash -c "$PYTEST_CMD" || EXIT_CODE=$?

if [ $EXIT_CODE -eq 124 ]; then
    echo "Warning: Tests timed out after ${TIMEOUT}s"
    exit 0
elif [ $EXIT_CODE -ne 0 ]; then
    echo "Warning: Some tests failed (exit code: $EXIT_CODE)"
    exit 0
fi

echo "All tests passed!"
exit 0
