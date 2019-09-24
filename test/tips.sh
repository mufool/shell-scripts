#!/bin/bash

# 遇到不存在的变量,终止脚本的执行
set -o nounset

# 遇到执行出错, 终止脚本的执行
set -o errexit

# 函数封装
log() { 
	local prefix=[$(date +%Y/%m/%d\ %H:%M:%S)]
}

# readonly定义只读变量
readyonly DEFAULT_VAL=${DEFAULT_VAL:-7}

# local定义局部变量保证安全

myfunc(){
	local some_var=${DEFAULT_VAL}
}

# $()代替``

# [[]]代替[]

# 调试方法
echo "log..."
bash -n my.sh # 检查语法错误
base -v my.sh # 跟踪脚本中命令的执行
base -x my.sh # 跟踪脚本里的每个命令的执行，并附加扩充信息
set -o verbose # 永久输出调试信息
set -o xtrace # 永久输出调试信息

