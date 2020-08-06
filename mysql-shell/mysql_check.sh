#!/bin/bash
# mysql 5.7 数据库备份
# mysqldump 实现
# 日期： 2020-08-06
# 作者： github bluefird
# commands:mysql_check
# 添加执行权限： chmod +x mysql_check.sh
# 使用方式 :sh mysql_check.sh 或者 mysql_check.sh
###########################user passowrd
#用户 必须
USER=root
#密码 必须
PASSWORD=123456
#端口 必须
PORT=3306

mysql_check () {
#不输出任何信息
#    mysqladmin -P${PORT} -u${USER} -p${PASSWORD} ping  &>/dev/null
#输出 mysql is alive
    mysqladmin -P${PORT} -u${USER} -p${PASSWORD} ping  2>/dev/null
    if  [ "$?" -eq 0 ];then
        exit 0
    else 
        echo -e "MYSQL is error....."
        echo -e "USER or PASSWORD or PORT is error....."
        exit 1
    fi
}
main () {
    mysql_check
}
main