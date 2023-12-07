






在 Python 中，记录 cron job 的日志通常涉及使用 `logging` 模块，这是 Python 标准库的一部分。`logging` 模块提供了灵活的日志记录系统，您可以通过它将日志信息输出到不同的目的地，如控制台、文件等。

以下是一个设置日志记录到文件的通用做法：

### 基本的日志设置

首先，您需要导入 `logging` 模块并进行基本的配置。您可以指定日志级别、格式和输出文件：

```python
import logging

# 日志配置
logging.basicConfig(filename='cronjob.log', filemode='a', level=logging.INFO,
                    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s')

# 在您的 cron job 中记录一些信息
logging.info('Cron job started.')
try:
    # Cron job 的主要逻辑
    pass
except Exception as e:
    logging.error('An error occurred: %s', str(e))
finally:
    logging.info('Cron job finished.')
```

在这个示例中：

- `filename`: 指定日志文件的名称。
- `filemode`: 'a' 表示追加模式，即新的日志消息将被添加到文件末尾。如果您希望每次运行时都创建新文件，可以使用 'w'。
- `level`: 设置日志级别。`logging.INFO` 表示记录所有的 INFO 级别及以上（警告、错误、严重错误）的日志。
- `format`: 定义日志的格式。这里包括时间戳、记录器名称、日志级别和消息。

### 进阶配置

如果您需要更高级的配置，例如同时将日志发送到控制台和文件，或者设置不同的日志级别，您可以创建一个更复杂的日志配置：

```python
import logging

# 创建一个日志记录器
logger = logging.getLogger('my_cron_job')
logger.setLevel(logging.INFO)

# 创建一个处理器用于写入日志文件
file_handler = logging.FileHandler('cronjob.log')
file_handler.setLevel(logging.INFO)

# 可选：创建一个处理器用于将日志输出到控制台
console_handler = logging.StreamHandler()
console_handler.setLevel(logging.INFO)

# 设置日志格式
formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
file_handler.setFormatter(formatter)
console_handler.setFormatter(formatter)

# 将处理器添加到日志记录器
logger.addHandler(file_handler)
logger.addHandler(console_handler)

# 使用日志记录器
logger.info('Cron job started.')
try:
    # Cron job 的主要逻辑
    pass
except Exception as e:
    logger.error('An error occurred: %s', str(e))
finally:
    logger.info('Cron job finished.')
```

这种方法提供了更多的灵活性，允许您对日志记录进行精细控制。

### 注意事项

- 确保日志文件的路径可写，特别是当您的 cron job 运行在受限环境中（如服务器或 Docker 容器）时。
- 根据 cron job 的执行频率，日志文件可能会迅速增长。考虑实施某种形式的日志轮转（如使用 `logging.handlers.RotatingFileHandler`）。

通过这些方法，您可以轻松地将 cron job 的运行信息记录到日志文件中，以便于后续的监控和故障排查。






在提供的代码示例中，日志文件不会每次被覆盖。由于使用了 `filemode='a'` 参数，日志消息会被追加到现有文件的末尾。这意味着您的日志文件将包含每次 cron job 运行的记录。

如果您需要实现日志轮转（即在日志文件达到特定大小或年龄时自动创建新文件），您可以使用 `logging` 模块中的 `RotatingFileHandler` 或 `TimedRotatingFileHandler`。

以下是一个使用 `RotatingFileHandler` 的示例，它会在日志文件达到特定大小时创建新文件：

```python
import logging
from logging.handlers import RotatingFileHandler

# 日志配置
log_file = 'cronjob.log'
logger = logging.getLogger('my_cron_job')
logger.setLevel(logging.INFO)

# 创建一个轮转日志处理器（文件大小为 5MB，保留 3 个备份）
handler = RotatingFileHandler(log_file, maxBytes=5*1024*1024, backupCount=3)
handler.setLevel(logging.INFO)

formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
handler.setFormatter(formatter)

logger.addHandler(handler)

# 在您的 cron job 中记录信息
logger.info('Cron job started.')
try:
    # Cron job 的主要逻辑
    pass
except Exception as e:
    logger.error('An error occurred: %s', str(e))
finally:
    logger.info('Cron job finished.')
```

在这个例子中，`RotatingFileHandler` 被配置为在日志文件大小达到 5MB 时创建一个新文件，并且最多保留 3 个旧文件作为备份。

如果您希望基于时间来轮转日志（比如每天或每周），可以使用 `TimedRotatingFileHandler`：

```python
from logging.handlers import TimedRotatingFileHandler

# 创建一个基于时间轮转的日志处理器（每天轮转一次，保留 7 天的日志）
handler = TimedRotatingFileHandler(log_file, when='D', interval=1, backupCount=7)
```

在这个例子中，日志文件将每天轮转一次，保留最近 7 天的日志文件。

使用日志轮转是管理日志文件大小和数量的有效方式，尤其是在长期运行的应用或定期执行的任务（如 cron jobs）中。










import requests
import json
from datetime import datetime

# 初始化变量
api_url = "http://example.com/api/data"  # 示例 API URL
proxy_address = "http://proxyserver:port"  # 代理地址，如果有
custom_header_name = "X-Custom-Header"  # 示例头部名称
custom_header_value = "ValuePart1 ValuePart2"  # 示例头部值
page_size = 100
total_pages = 10  # 假设有 10 页数据，这个值应根据实际情况获取

# 用于存储所有 endpoints 数据
output = []

# 根据总页数循环获取数据
for page in range(1, total_pages + 1):
    search_from = (page - 1) * page_size
    search_to = page * page_size
    response = requests.post(api_url, 
                             headers={custom_header_name: custom_header_value, "Content-Type": "application/json"},
                             proxies={"http": proxy_address, "https": proxy_address},  # 如果不使用代理，可以去掉这一行
                             json={"request_data": {"search_from": search_from, "search_to": search_to}})

    if response.status_code == 200:
        data = response.json().get('reply', {}).get('endpoints', [])
        output.extend(data)
    else:
        print(f"Error: Response for page {page} is not valid JSON.")

# 获取当前时间戳
timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

# 创建最终的 JSON 对象并保存到文件
final_json = {"timestamp": timestamp, "endpoints": output}
with open('data.json', 'w') as json_file:
    json.dump(final_json, json_file)

print("数据保存到 data.json")





### 第 1 部分：获取数据并分类，并加入时间戳

```python
import requests
import time
import json
from datetime import datetime

# API 地址
API_URL = "http://example.com/api/data"

# 初始化变量
search_from = 0
page_size = 100
total_items = 0
total_pages = 0
output = []

# 首次请求以获取总数
response = requests.post(API_URL, json={"request_data": {"search_from": search_from, "search_to": search_from + page_size}})
total_items = response.json()['reply']['total_count']
total_pages = (total_items + page_size - 1) // page_size

# 根据总页数循环获取数据
for page in range(total_pages):
    search_from = page * page_size
    response = requests.post(API_URL, json={"request_data": {"search_from": search_from, "search_to": search_from + page_size}})
    output.extend(response.json()['reply']['endpoints'])

# 获取当前时间戳
timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

# 分类
class1_endpoints, class2_endpoints, class3_endpoints = [], [], []
CONSTANT1, CONSTANT2, CONSTANT3 = "name1", "name2", "name3"

for endpoint in output:
    endpoint_name = endpoint['endpoint_name']
    endpoint_id = endpoint['endpoint_id']
    if endpoint_name == CONSTANT1:
        class1_endpoints.append(endpoint_id)
    elif endpoint_name == CONSTANT2:
        class2_endpoints.append(endpoint_id)
    elif endpoint_name == CONSTANT3:
        class3_endpoints.append(endpoint_id)

# 保存原始数据到 JSON 文件
with open('original_data.json', 'w') as file:
    json.dump({'timestamp': timestamp, 'endpoints': output}, file)
```

### 第 2 部分：为每个类别调用 POST API 并收集 action_id

```python
def post_api_call(endpoint_ids, url):
    action_ids = []
    for i in range(0, len(endpoint_ids), 100):
        payload = {"endpoint_ids": endpoint_ids[i:i+100]}
        response = requests.post(url, json=payload)
        action_id = response.json().get('action_id')
        if action_id:
            action_ids.append(action_id)
    return action_ids

url = "http://example.com/another-api"
class1_action_ids = post_api_call(class1_endpoints, url)
class2_action_ids = post_api_call(class2_endpoints, url)
class3_action_ids = post_api_call(class3_endpoints, url)

# 等待 5 分钟
time.sleep(300)
```

### 第 3 部分：使用 Action ID 调用另一个 API 并保存结果

```python
result_api_url = "http://example.com/result-api"

def fetch_and_save_results(action_ids, filename):
    all_results = []
    for action_id in action_ids:
        response = requests.post(result_api_url, json={"action_id": action_id})
        all_results.extend(response.json().get('endpoints', []))
    
    with open(filename, 'w') as file:
        json.dump(all_results, file)

fetch_and_save_results(class1_action_ids, 'result_class1.json')
fetch_and_save_results(class2_action_ids, 'result_class2.json')
fetch_and_save_results(class3_action_ids, 'result_class3.json')
```

### 综合说明

- 在第 1 部分中，我添加了时间戳并将初始数据保存到了 `original_data.json`。
- 在第 2 部分中，脚本调用 API 并收集每个分类的 `action_id`。
- 在第 3 部分中，对于每个 `action_id` 调用结果 API 并将结果合并，然后根据分类保存到不同的文件中。

请确保在运行这个脚本之前安装了 `requests` 库。您可以根据实际的 API 结构和响应格式调整脚本的具体细节。




将这个 Bash 脚本翻译成 Python 3 非常直接。Python 脚本可以使用 `sys.argv` 来访问命令行参数。以下是相应的 Python 实现：

```python
import sys

# 设置默认 API URL 为生产环境
API_URL = "http://prod.example.com/api"

# 检查命令行参数数量
if len(sys.argv) > 1:
    # 根据传入的第一个参数切换 API URL
    if sys.argv[1] == "dev":
        API_URL = "http://dev.example.com/api"
    elif sys.argv[1] == "test":
        API_URL = "http://test.example.com/api"

print("使用的 API URL: {}".format(API_URL))

# 脚本的其他部分...
```

在这个 Python 脚本中：

- `sys.argv` 是一个包含命令行参数的列表，其中 `sys.argv[0]` 是脚本名称，`sys.argv[1]` 是传递给脚本的第一个参数。
- 脚本首先检查是否有至少一个传递的参数（`len(sys.argv) > 1`），然后根据这个参数的值来设置 `API_URL`。
- 如果没有提供参数或者参数不是 "dev" 或 "test"，它将使用默认的生产环境 URL。

您可以通过在命令行中传递 "dev" 或 "test" 来测试不同的环境 URL。例如：

```bash
python script.py dev
```

或者

```bash
python script.py test
```

如果没有传递任何参数，将使用默认的生产环境 URL。

由于我的执行环境没有外部网络连接，所以无法直接访问网络 API。但是，我可以提供一个 Python 脚本的示例，展示如何实现这个 API 调用。

在这个脚本中，我们使用 Python 的 `requests` 库来发出 HTTP 请求。我假设您已经知道如何获取必要的 API 密钥或其他身份验证信息，以便成功调用 Palo Alto Networks Cortex XDR API。以下是脚本的示例：

```python
import requests
import json

def get_all_endpoints(api_url, api_key):
    headers = {
        'x-xdr-auth-id': api_key,
        'Content-Type': 'application/json'
    }

    # 在实际场景中，可能需要根据 API 的要求调整请求体
    payload = json.dumps({
        "request_data": {
            # 您可能需要根据实际情况设置这里的请求参数
        }
    })

    response = requests.post(api_url, headers=headers, data=payload)

    if response.status_code == 200:
        return response.json()
    else:
        print("Failed to fetch data: HTTP ", response.status_code)
        return None

# 示例用的 API URL 和密钥（需要替换为实际的值）
API_URL = "https://api-example.paloaltonetworks.com/endpoints"
API_KEY = "your_api_key_here"

endpoints_data = get_all_endpoints(API_URL, API_KEY)

if endpoints_data:
    print("获取到的端点数据: ", endpoints_data)
```

在这个脚本中：

1. 定义了一个函数 `get_all_endpoints` 来执行 API 请求。
2. 使用 `requests.post` 来发送 POST 请求到 API。
3. 通过 `headers` 传递 API 密钥。
4. 解析并返回响应数据。

确保在运行此脚本之前已安装了 `requests` 库（可以通过 `pip install requests` 安装）。同时，您需要将 `API_URL` 和 `API_KEY` 替换为实际的 API 端点和您的 API 密钥。根据实际 API 文档，您可能还需要调整请求体的内容。


根据您提供的链接到 Palo Alto Networks Cortex XDR 的 "Run Script" REST API 文档，如果您需要将 `endpoint_ids` 数组放入到 `payload` 的 `filters` 字段中，Python 脚本将类似于下面的实现：

首先，您需要构建相应的请求体，将 `endpoint_ids` 数组作为过滤条件的一部分。然后，您可以使用 Python 的 `requests` 库发送 POST 请求。

以下是构建和发送请求的示例代码：

```python
import requests
import json

def run_script(api_url, api_key, endpoint_ids, script_name):
    headers = {
        'x-xdr-auth-id': api_key,
        'Content-Type': 'application/json'
    }

    payload = {
        "request_data": {
            "script_name": script_name,
            "filters": [{
                "field": "endpoint_id",
                "operator": "in",
                "value": endpoint_ids
            }],
            # 其他可能的参数...
        }
    }

    response = requests.post(api_url, headers=headers, json=payload)

    if response.status_code == 200:
        return response.json()
    else:
        print("Failed to execute script: HTTP ", response.status_code)
        return None

# 示例用的 API URL 和密钥（需要替换为实际的值）
API_URL = "https://api-example.paloaltonetworks.com/public_api/v1/scripts/run_script"
API_KEY = "your_api_key_here"
ENDPOINT_IDS = ["endpoint_id1", "endpoint_id2", "endpoint_id3"]  # 示例 endpoint IDs
SCRIPT_NAME = "Your_Script_Name"  # 替换为要运行的脚本名称

response_data = run_script(API_URL, API_KEY, ENDPOINT_IDS, SCRIPT_NAME)

if response_data:
    print("响应数据: ", response_data)
```

在这个脚本中：

1. 定义了一个 `run_script` 函数来构建和发送请求。
2. `endpoint_ids` 作为过滤条件传入，指定哪些 endpoint 应该运行脚本。
3. 通过 `headers` 传递 API 密钥和内容类型。
4. 解析并返回响应数据。

请确保替换 `API_URL`、`API_KEY`、`ENDPOINT_IDS` 和 `SCRIPT_NAME` 为实际的值。根据您的具体需求，您可能还需要调整其他参数。

在运行此脚本之前，请确认已安装了 `requests` 库。如果还没有安装，您可以通过运行 `pip install requests` 来安装。


要实现使用每个 action ID 查询脚本执行状态，并在所有任务完成后继续处理，您可以利用 Palo Alto Networks Cortex XDR 的 "Get Script Execution Status" API 来定期检查每个 action ID 的状态。以下是一个 Python 示例脚本，展示如何实现这个过程：

### 第 1 部分：定义检查脚本执行状态的函数

```python
import requests
import time

def check_script_status(api_url, api_key, action_id):
    headers = {
        'x-xdr-auth-id': api_key,
        'Content-Type': 'application/json'
    }

    payload = {
        "request_data": {
            "action_id": action_id
        }
    }

    response = requests.post(api_url, headers=headers, json=payload)

    if response.status_code == 200:
        return response.json()
    else:
        print(f"Failed to check script status for action ID {action_id}: HTTP", response.status_code)
        return None

def all_scripts_completed(api_url, api_key, action_ids):
    while True:
        all_done = True
        for action_id in action_ids:
            status = check_script_status(api_url, api_key, action_id)
            # 根据实际API响应调整下一行
            if status['reply']['status'] != 'completed':
                all_done = False
                break
        if all_done:
            return True
        time.sleep(5)  # 等待5秒后再次检查
```

### 第 2 部分：使用 Action IDs 检查状态

在您执行了脚本并获取了 action IDs 后，可以使用这些 ID 来检查所有脚本的执行状态。

```python
API_URL_STATUS = "https://api-example.paloaltonetworks.com/public_api/v1/scripts/get_script_execution_status"
API_KEY = "your_api_key_here"
ACTION_IDS = ["action_id1", "action_id2", "action_id3"]  # 示例 action IDs

# 检查所有脚本是否执行完成
if all_scripts_completed(API_URL_STATUS, API_KEY, ACTION_IDS):
    print("所有脚本执行完成")
    # 在此处进行后续处理...
```

在这个脚本中：

- `check_script_status` 函数用于检查给定 action ID 的脚本执行状态。
- `all_scripts_completed` 函数循环检查所有 action ID 的状态，直到所有脚本执行完成。在此期间，每 5 秒检查一次状态。

请根据您的实际 API 响应结构调整 `check_script_status` 函数中的逻辑，特别是如何从响应中提取状态信息。

在运行此脚本之前，请确认已安装了 `requests` 库。如果还没有安装，您可以通过运行 `pip install requests` 来安装。同时，请将 `API_URL_STATUS`、`API_KEY` 和 `ACTION_IDS` 替换为您实际的 API URL、API 密钥和 action ID 列表。

根据您提供的链接和需求，我将提供 Python 脚本的第三部分，用于调用 Palo Alto Networks Cortex XDR 的 "Get Script Execution Results" API，并将结果保存到文件中。这个 API 用于获取先前运行的脚本的执行结果。

### 第三部分：使用 Action ID 获取脚本执行结果并保存到文件

```python
def get_script_results(api_url, api_key, action_id):
    headers = {
        'x-xdr-auth-id': api_key,
        'Content-Type': 'application/json'
    }

    payload = {
        "request_data": {
            "action_id": action_id
        }
    }

    response = requests.post(api_url, headers=headers, json=payload)

    if response.status_code == 200:
        return response.json()
    else:
        print(f"Failed to get script results for action ID {action_id}: HTTP", response.status_code)
        return None

def save_results_to_file(api_url, api_key, action_ids, filename_prefix):
    all_results = []
    for action_id in action_ids:
        result = get_script_results(api_url, api_key, action_id)
        if result:
            all_results.extend(result.get('reply', {}).get('data', []))  # 根据实际API结构调整
    with open(f'{filename_prefix}_{action_id}.json', 'w') as file:
        json.dump(all_results, file)

# API URL 和 API 密钥
API_URL_RESULTS = "https://api-example.paloaltonetworks.com/public_api/v1/scripts/get_script_execution_results"
API_KEY = "your_api_key_here"

# 之前获得的 Action IDs
ACTION_IDS = ["action_id1", "action_id2", "action_id3"]

# 保存结果到文件
save_results_to_file(API_URL_RESULTS, API_KEY, ACTION_IDS, "script_results")
```

在这个脚本中：

1. 定义了 `get_script_results` 函数来发送请求并获取脚本执行的结果。
2. 定义了 `save_results_to_file` 函数，用于保存所有 action ID 对应的结果到一个 JSON 文件。文件名由前缀和 action ID 构成。
3. 需要调整 `all_results.extend(...)` 中的逻辑以匹配实际的 API 响应结构。

请确保将 `API_URL_RESULTS`、`API_KEY` 和 `ACTION_IDS` 替换为实际的值。根据您的具体需求，可能需要调整保存文件的逻辑，以及如何处理和组织获得的结果数据。

在运行此脚本之前，请确认已安装了 `requests` 库。如果还没有安装，您可以通过运行 `pip install requests` 来安装。

根据您提供的链接，为了使用 Palo Alto Networks Cortex XDR 的 "Get Endpoint" API 获取所有 endpoints 的信息，您需要构造一个合适的请求。这个 API 允许您获取与特定条件匹配的 endpoint 信息。下面的 Python 脚本展示了如何实现这一点：

### Python 脚本：使用 "Get Endpoint" API

```python
import requests
import json

def get_endpoints(api_url, api_key):
    headers = {
        'x-xdr-auth-id': api_key,
        'Content-Type': 'application/json'
    }

    # 请求体可能需要根据 API 的要求进行调整
    payload = {
        "request_data": {
            "filters": [],  # 可以添加过滤条件
            "search_from": 0,  # 根据需要调整
            "search_to": 100   # 根据需要调整
        }
    }

    response = requests.post(api_url, headers=headers, json=payload)

    if response.status_code == 200:
        return response.json()
    else:
        print("Failed to fetch endpoints: HTTP ", response.status_code)
        return None

# 示例用的 API URL 和密钥（需要替换为实际的值）
API_URL = "https://api-example.paloaltonetworks.com/public_api/v1/endpoints/get_endpoints"
API_KEY = "your_api_key_here"

endpoints_data = get_endpoints(API_URL, API_KEY)

if endpoints_data:
    print("获取到的端点数据: ", endpoints_data)
```

在这个脚本中：

1. 定义了 `get_endpoints` 函数来发送 API 请求。
2. 设置了请求头，包括 API 密钥。
3. 构造了请求体，其中可以包括过滤条件、搜索范围等。
4. 使用 `requests.post` 方法发送请求，并处理响应。

请确保将 `API_URL` 和 `API_KEY` 替换为实际的 API URL 和您的 API 密钥。根据实际 API 文档，您可能需要调整请求体的内容，例如添加特定的过滤条件或调整搜索范围。

在运行此脚本之前，请确认已安装了 `requests` 库。如果还没有安装，您可以通过运行 `pip install requests` 来安装。






