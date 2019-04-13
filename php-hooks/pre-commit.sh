#!/bin/bash

# 每次commit时强制diff文件
git diff --cached

while read st file
do
    # 文件末为不是 .php 时输出文件，并跳出本次循环
    if [[ ! "${file}"  =~ (\.php$) ]]
    then
        echo $file
        continue
    fi

    # 语义检查
    PHP_LINT=`php -l ${file}`
    if [ 0 -ne $? ]
    then
        echo -e "\033[31m 语法错误：${PHP_LINT} \033[0m"
        exit 1
    fi

    # 断点检查
    PHP_DEBUG=$(grep -Ewrn 'die|exit' ${file})
    if [[ ${PHP_DEBUG} ]]
    then
	echo -e "\033[31m 存在调试断点，无法commit，请先修改以下代码：\n${PHP_DEBUG} \033[0m"
        exit 1
    fi

done <<EOF
`git diff --cached --name-status`
EOF

exit 0