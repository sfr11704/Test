# Test
import json

def process_value(key, value):
    # 如果值是列表，取第一个非空字符串
    if isinstance(value, list):
        for item in value:
            if item:  # 确保非空
                return item
    # 如果值是形如 "[\"value\"]" 的字符串，尝试解析为实际的列表
    elif isinstance(value, str) and value.startswith('[') and value.endswith(']'):
        try:
            # 尝试解析字符串为JSON
            parsed_value = json.loads(value)
            if parsed_value:  # 确保解析后的列表非空
                return parsed_value[0] if isinstance(parsed_value, list) else parsed_value
        except json.JSONDecodeError:
            pass  # 解析失败，返回原始值
    elif key.endswith('AntivirussignatureAge') and isinstance(value, str) and value.isdigit():
        # 将AntivirussignatureAge的值从字符串转换为整数
        return int(value)
    return value

def process_endpoint_data(endpoint_data):
    processed_data = {}
    for key in endpoint_data:
        # 去掉以下划线开始的键名中的下划线
        clean_key = key.lstrip('_')
        # 处理值
        processed_data[clean_key] = process_value(clean_key, endpoint_data[key])
    return processed_data

# 原始JSON数据
json_data = [
    # ... 您提供的原始JSON对象列表 ...
]

# 处理JSON对象列表
processed_json_data = [process_endpoint_data(endpoint) for endpoint in json_data]

# 打印处理后的JSON数据
print(json.dumps(processed_json_data, indent=4))
