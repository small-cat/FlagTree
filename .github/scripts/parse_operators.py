#!/usr/bin/env python3
"""
解析 FlagGems/conf/operators.yaml 文件，提取算子名称并生成 pytest -m 参数
"""

import yaml
import sys
from pathlib import Path


def parse_operators(yaml_file: str) -> list:
    """
    解析 operators.yaml 文件，提取所有算子名称

    Args:
        yaml_file: operators.yaml 文件路径

    Returns:
        算子名称列表
    """
    with open(yaml_file, 'r', encoding='utf-8') as f:
        data = yaml.safe_load(f)

    operators = []
    if 'ops' in data:
        for op in data['ops']:
            if 'id' in op:
                operators.append(op['id'])

    return operators


def generate_pytest_marks(operators: list) -> str:
    """
    将算子列表转换为 pytest -m 参数格式

    Args:
        operators: 算子名称列表

    Returns:
        pytest -m 参数字符串，格式为 "op1 or op2 or op3"
    """
    if not operators:
        raise ValueError("算子列表为空")

    return " or ".join(operators)


def main():
    if len(sys.argv) != 2:
        print(f"用法: {sys.argv[0]} <operators.yaml 路径>", file=sys.stderr)
        sys.exit(1)

    yaml_file = sys.argv[1]

    if not Path(yaml_file).exists():
        print(f"错误: 文件不存在: {yaml_file}", file=sys.stderr)
        sys.exit(1)

    try:
        operators = parse_operators(yaml_file)
        marks = generate_pytest_marks(operators)
        print(marks)
        # 输出统计信息到 stderr
        print(f"共解析 {len(operators)} 个算子", file=sys.stderr)
    except Exception as e:
        print(f"错误: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
