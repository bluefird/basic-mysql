#!/bin/bash
# mysql 5.7 xtrabackup 版本24 备份
# xtrabackup 实现
# 目的： mysql 实现 全备 、增量备份
# 日期： 2020-08-06
# 作者： github bluefird
# 版本: v1 
# commands:xtraback.sh
# 添加执行权限： chmod +x xtraback.sh
# 使用方式 :sh xtraback.sh A/I或者 xtraback.sh A/I
###########################user passowrd

#必须：数据库用户 
USER=root
#必须：数据库用户密码
PASSWORD=123456
#必需：mysql 环境中的sock
SOCKET=/tmp/mysql.sock

#备份目录
BACKDIR=/backup/innodb
#目录名称
DIRNAME=`date +%Y%m%d%H%S`
#完全备份目录
FULLDIR=${BACKDIR}/full/${DIRNAME}
#增量备份目录
INCDIR=${BACKDIR}/INC/${DIRNAME}
#上次备份目录存储文件
OLDFILE=${BACKDIR}/olddir.txt
#备份list名单
BACKLIST=${BACKDIR}/backlist.txt
#日志备份目录
LOGDIR=${BACKDIR}/logs
INNOBACK_LOG=${LOGDIR}/xtraback.log
ERROR_LOG=${LOGDIR}/xtraback_error.log
SUCCESS_LOG=${LOGDIR}/xtraback_success.log
##################################log dir
logdir_check() {
    if [ ! -d "${LOGDIR}" ];then 
        mkdir -p  ${LOGDIR}
    else 
        :
    fi
}
##################################mysql check 
mysql_check() {
#不输出任何信息
#    mysqladmin --socket=${SOCKET} -u${USER} -p${PASSWORD} ping  &>/dev/null
#输出 mysql is alive
    mysqladmin -P${PORT} -u${USER} -p${PASSWORD} ping  2>/dev/null
    if  [ "$?" -eq 0 ];then
        :
    else 
        echo -e "MYSQL is error....."
        echo -e "USER or PASSWORD or PORT is error....."
        exit 1
    fi
}

##################################上次目录查看
file_check() {

    if [[ -f "${OLDFILE}"  && -w "${OLDFILE}" && -n "${OLDFILE}" ]]
    then
         :
    else 
        echo "文件不存在，无法找到上次备份点"
        exit 3
    fi 
}
##################################增量备份
incback() { 

    #上次备份目录
    OLDDIR=`cat ${OLDFILE}`
    innobackupex --user=${USER} --password=${PASSWORD} --no-timestamp --socket=${SOCKET}  --incremental --incremental-dir=${OLDDIR} ${INCDIR} >> ${INNOBACK_LOG}
    if [ "$?" -eq 0 ];then
        echo "INC ${INCDIR} backup sucess " >> ${SUCCESS_LOG}
    #记录备份点
        echo "${INCDIR}" > ${OLDFILE}
    #累计备份点
        echo "${INCDIR} increment" >> ${BACKLIST}
        exit 0
    else 
        echo "INC ${INCDIR} backup error " >> ${ERROR_LOG}
        exit 4
    fi
}

###################################完全备份
fullback() {
    innobackupex --user=${USER} --password=${PASSWORD} --no-timestamp --socket=${SOCKET} ${FULLDIR} > ${INNOBACK_LOG}
    if [ "$?" -eq 0 ];then
        echo "full ${FULLDIR} backup sucess " >> ${SUCCESS_LOG}
    #记录备份点
        echo "${FULLDIR}" > ${OLDFILE}
    #累计备份次数
        echo "${FULLDIR} FULLDIR" >> ${BACKLIST}
        exit 0
    else 
        echo "full ${FULLDIR} backup error " >> ${ERROR_LOG}
        exit 5
    fi
}

main () {
    mysql_check
    logdir_check
    case $1 in
    A) 
        fullback
        ;;
    I)
        file_check
        incback
        ;;
    *)
        echo "Usage: xtraback.sh A or xtraback.sh I"
        exit 1
        ;;
    esac
}
main $1