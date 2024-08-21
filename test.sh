#!/bin/bash

# 日志文件路径
log_file="/path/to/script_execution.log"

# 定义日志函数
log() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") - $1" >> "$log_file"
}

# 定义输出目录的基础路径
base_dir="/path/to"

# 检查并压缩删除超过30天的文件夹的函数
cleanup_old_folders() {
    local days=30
    # 查找超过30天的文件夹并压缩删除
    find "$base_dir" -type d -name '*[0-9]*' -mindepth 1 -maxdepth 1 | while read folder; do
        if [[ "$(date +%s -r "$folder")" < "$(( $(date +%s) - days * 86400 ))" ]]; then
            tar -czf "${folder}.tar.gz" "$folder"
            rm -rf "$folder"
            log "超过30天的文件夹 $folder 已被压缩并删除。"
        fi
    done
}

# 定义Python脚本执行和检查的函数
execute_python_script() {
    local script=$1
    local file=$2
    local max_retries=3
    local retries=0

    while [ $retries -lt $max_retries ]; do
        python3 "$script"
        if [ -f "$file" ]; then
            log "脚本 $script 执行成功，文件 $file 已生成。"
            return 0
        else
            log "脚本 $script 执行失败，文件 $file 未生成，正在重试（尝试次数：$retries）。"
            ((retries++))
        fi
    done

    log "脚本 $script 执行失败，重试 $max_retries 次后仍然失败。"
    return 1
}

# 创建今日日期的文件夹并执行Python脚本
folder_name=$(date +%Y%m%d)
output_dir="$base_dir/$folder_name"

mkdir -p "$output_dir" && log "目录 $output_dir 创建成功。"

# 定义Python脚本的路径
test1_script="$base_dir/test1.py"
test2_script="$base_dir/test2.py"
test3_script="$base_dir/test3.py"

# 定义输出文件的路径
file1="$output_dir/file1.json"
file2="$output_dir/file2.json"
file3="$output_dir/file3.json"

# 顺序执行Python脚本并检查输出文件
execute_python_script "$test1_script" "$file1" || exit 1
execute_python_script "$test2_script" "$file2" || exit 1
execute_python_script "$test3_script" "$file3" || exit 1

# 脚本执行完毕后的日志记录
log "所有脚本执行完毕，所有文件已生成。"

# 检查并压缩删除超过30天的文件夹
cleanup_old_folders








# ==========
#!/bin/bash

# 日志文件路径
log_file="/path/to/script_execution.log"

# 定义日志函数
log() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") - $1" >> "$log_file"
}

# 定义今日日期的文件夹名称
folder_name=$(date +%Y%m%d)
output_dir="/path/to/$folder_name"

# 创建今日日期的文件夹
mkdir -p "$output_dir" && log "目录 $output_dir 创建成功。"

# 定义Python脚本的路径
test1_script="/path/to/test1.py"
test2_script="/path/to/test2.py"
test3_script="/path/to/test3.py"

# 定义输出文件的路径
file1="$output_dir/file1.json"
file2="$output_dir/file2.json"
file3="$output_dir/file3.json"

# 函数：调用Python脚本并检查输出文件
call_and_check() {
    local script=$1
    local file=$2
    local max_retries=3
    local retries=0

    while [ $retries -lt $max_retries ]; do
        log "开始执行脚本 $script。"
        python3 "$script"
        if [ -f "$file" ]; then
            log "脚本 $script 执行成功，文件 $file 已生成。"
            return 0
        else
            log "脚本 $script 执行失败，文件 $file 未生成，正在重试（尝试次数：$retries）。"
            ((retries++))
        fi
    done

    log "脚本 $script 执行失败，重试 $max_retries 次后仍然失败。"
    return 1
}

# 调用test1.py并检查file1.json是否存在
if call_and_check "$test1_script" "$file1"; then
    :
else
    log "因test1.py失败，脚本执行终止。"
    exit 1
fi

# 调用test2.py并检查file2.json是否存在
if call_and_check "$test2_script" "$file2"; then
    :
else
    log "因test2.py失败，脚本执行终止。"
    exit 1
fi

# 调用test3.py并检查file3.json是否存在
if call_and_check "$test3_script" "$file3"; then
    log "所有脚本执行完毕，所有文件已生成。"
else
    log "因test3.py失败，脚本执行终止。"
    exit 1
fi
