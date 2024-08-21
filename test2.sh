#!/bin/bash

# 日志文件路径
log_file="/path/to/your/logfile.log"

# 定义日志函数
log() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") - $1" >> "$log_file"
}

# 确保日志文件存在
touch "$log_file"

# 定义Python脚本执行的函数，并将print输出重定向到日志文件
execute_python_script() {
    local script=$1
    shift # 移除第一个参数，剩余的是文件参数
    local files=("$@") # 剩余参数作为数组
    local max_retries=3
    local retries=0
    local all_files_exist=true

    # 执行Python脚本，并捕获其标准输出和标准错误，同时检查输出文件是否存在
    while [ $retries -lt $max_retries ]; do
        {
            # 执行Python脚本，将输出和错误重定向到日志文件
            python3 "$script"
        } >> "$log_file" 2>&1

        # 检查所有文件是否存在
        all_files_exist=true
        for file in "${files[@]}"; do
            if [ ! -f "$file" ]; then
                all_files_exist=false
                break
            fi
        done

        if [ "$all_files_exist" = true ]; then
            log "Script $script executed successfully, all files have been generated."
            return 0
        else
            log "Script $script failed to generate all required files, retrying (Attempt $retries)."
            ((retries++))
        fi
    done

    log "Script $script failed after $max_retries attempts."
    # 执行失败后的清理操作
    cleanup_folder "$output_dir"
    return 1
}

# 其余函数定义（cleanup_old_folders, cleanup_folder等）...

# 脚本主体逻辑
# ...

# 顺序执行Python脚本并检查输出文件
execute_python_script "$test1_script" "$file1" || exit 1
execute_python_script "$test2_script" "${files2[@]}" || exit 1
execute_python_script "$test3_script" "$file3" || exit 1

# 脚本执行完毕后的日志记录
log "All scripts have been executed, and the process has concluded."

# 执行日志归档和删除操作
# ...

# 检查并压缩删除超过30天的文件夹
# ...

# 脚本结束
log "Script execution finished."



#####===========
#!/bin/bash

# ... （其他函数定义保持不变） ...

# 定义Python脚本执行和检查输出文件的函数，现在包含失败后的清理逻辑
execute_python_script() {
    local script=$1
    shift # 移除第一个参数，剩余的是文件参数
    local files=("$@") # 剩余参数作为数组
    local max_retries=3
    local retries=0
    local all_files_exist=true

    while [ $retries -lt $max_retries ]; do
        python3 "$script"
        # 检查所有文件是否存在
        all_files_exist=true
        for file in "${files[@]}"; do
            if [ ! -f "$file" ]; then
                all_files_exist=false
                break
            fi
        done

        if [ "$all_files_exist" = true ]; then
            log "Script $script executed successfully, all files have been generated."
            return 0
        else
            log "Script $script failed to generate all files, retrying (Attempt $retries)."
            ((retries++))
        fi
    done

    log "Script $script failed after $max_retries attempts."
    # 执行失败后的清理操作
    cleanup_folder "$output_dir"
    return 1
}

# 定义清理文件夹的函数
cleanup_folder() {
    local folder=$1
    if [ -d "$folder" ]; then
        log "Cleaning up folder $folder."
        rm -rf "$folder"
    fi
}

# ... （主脚本逻辑，包括日志、归档、清理旧文件夹等） ...

# 顺序执行Python脚本并检查输出文件
execute_python_script "$test1_script" "$file1" || exit 1
execute_python_script "$test2_script" "${files2[@]}" || exit 1
execute_python_script "$test3_script" "$file3" || exit 1

# ... （脚本执行完毕后的日志记录、日志归档、旧文件夹清理等） ...

# 脚本结束
log "Script execution finished."



####============
#!/bin/bash

# Log file path
log_file="/path/to/script_execution.log"

# Define the log function
log() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") - $1" | tee -a "$log_file"
}

# Ensure the log file exists
touch "$log_file"

# Define the function to clean up old folders
cleanup_old_folders() {
    local days=30
    log "Searching for folders older than $days days to clean up."
    local old_folders=$(find "$base_dir" -type d -mtime +$days -mindepth 1 -maxdepth 1)
    for folder in $old_folders; do
        tar -czf "${folder}.tar.gz" "$folder" && rm -rf "$folder"
        log "Folder $folder older than 30 days has been archived and removed."
    done
}

# Define the function to execute Python scripts and check the output files
execute_python_script() {
    local script=$1
    shift # Remove the first argument, remaining are file arguments
    local files=("$@") # Remaining arguments as an array
    local max_retries=3
    local retries=0
    local all_files_exist=true

    while [ $retries -lt $max_retries ]; do
        python3 "$script"
        # Check if all files exist
        all_files_exist=true
        for file in "${files[@]}"; do
            if [ ! -f "$file" ]; then
                all_files_exist=false
                break
            fi
        done

        if [ "$all_files_exist" = true ]; then
            log "Script $script executed successfully, all files have been generated."
            return 0
        else
            log "Script $script failed to generate all files, retrying (Attempt $retries)."
            ((retries++))
        fi
    done

    log "Script $script failed after $max_retries attempts."
    return 1
}

# Define the function to rotate and archive logs
log_rotate_and_archive() {
    local archive_dir="/var/log/archives"
    local today=$(date +%Y%m%d)
    local archive_name="script_execution_${today}.tar.gz"
    local max_archives=30

    # Ensure the archive directory exists
    mkdir -p "$archive_dir"

    # Archive the log file
    tar -czf "${archive_dir}/${archive_name}" "$log_file"

    # Keep the latest archives, delete old ones
    local old_archives=$(ls -t "$archive_dir"/*.tar.gz | tail -n +$((max_archives + 1)))
    for old_archive in $old_archives; do
        rm -f "$old_archive"
        log "Old archive $old_archive has been deleted."
    done

    # Delete the original log file
    rm -f "$log_file"
    log "Log file has been archived and deleted."
}

# Main script logic
base_dir="/path/to"
output_dir="$base_dir/$(date +%Y%m%d)"
mkdir -p "$output_dir" && log "Directory $output_dir created successfully."

test1_script="$base_dir/test1.py"
test2_script="$base_dir/test2.py"
test3_script="$base_dir/test3.py"

file1="$output_dir/file1.json"
files2=( "$output_dir/file2_1.json" "$output_dir/file2_2.json" "$output_dir/file2_3.json" "$output_dir/file2_4.json" "$output_dir/file2_5.json" )
file3="$output_dir/file3.json"

# Execute Python scripts in order and check output files
execute_python_script "$test1_script" "$file1" || exit 1
execute_python_script "$test2_script" "${files2[@]}" || exit 1
execute_python_script "$test3_script" "$file3" || exit 1

# Log after all scripts have been executed
log "All scripts have been executed successfully, all files have been generated."

# Perform log rotation and archiving
log_rotate_and_archive

# Clean up old folders
cleanup_old_folders

# Script finished
log "Script execution finished."
