#!/bin/bash
# mysql 5.7 数据库备份
# mysqldump 实现
# 日期： 2020-08-06
# 作者： github bluefird
# commands: mysqldump
# dump_args='-R -E --triggers --master-data=2   --set-gtid-purged=off'
# 添加执行权限： chmod +x mysqldump.sh 
# 使用方式 : mysqldump.sh all / mysqldump base 
###########################user passowrd
#用户
USER=root
#用户密码
PASSWORD=123456
#以时间为备份名
DATENAME=`date +%Y%d%H%M`
#默认 3306
PORT=3306
#单库备份需要，自己填写需要备份的库，空格隔开,结尾不留空格
DATANAME="world mysql employees sakila"
#全局备份参数,可以自己添加
dump_args='-R -E --triggers --master-data=2   --set-gtid-purged=off'
###################backup dir
#全库备份目录
FULLDIR=/backup/dump/full
#单库备份目录
DATADIR=/backup/dump/base
####################log dir
# 日志输出目录
LOGDIR=/backup/log
# 全备 日志
full_success_log=${LOGDIR}/full_sucess.log
full_error_log=${LOGDIR}/full_error.log
# 单库备份日志
base_sucess_log=${LOGDIR}/base_sucess.log
base_error_log=${LOGDIR}/base_error.log
# mysqldump 错误警告备份信息日志
dump_log=${LOGDIR}/dump.log
############################dir test 
if [ -d "${FULLDIR}" ];then
    :
else 
    mkdir ${FULLDIR} -p
fi
if [ -d "${DATADIR}" ];then
    :
else 
    mkdir ${DATADIR} -p
fi

if [ -d "${LOGDIR}" ];then
    :
else 
    mkdir ${LOGDIR} -p
fi

##########################mysqldump  #########################################

##########################完全备份

# --single-transaction 不锁表备份 参数看自己是否需要添加

ALLDUMP() {
    DATANAME=
#添加 -A参数 -P参数
    mysqldump  -P ${PORT} -A -u${USER} -p${PASSWORD} ${dump_args} > ${FULLDIR}/${DATANAME}full_${DATENAME}.sql 2>${dump_log}
    if [ "$?" == 0 ];then
        echo "full_${DATENAME}.sql backup sucess " >> ${full_success_log}
    else
        echo "full_${DATENAME}.sql backup error  " >> ${full_error_log}
        exit 1
    fi
}


##########################单库备份

datadump() {
    if [ -n "${DATANAME}"  ];then
        for DB in ${DATANAME}
        do
#####################添加 -B参数 -P参数
            mysqldump  -P ${PORT} -u${USER} -p${PASSWORD} ${dump_args} -B ${DB} > ${DATADIR}/${DB}_${DATENAME}.sql 2>${dump_log}
            if [ "$?" == 0 ];then
                echo "${DB}_${DATENAME}.sql backup sucess " >> ${base_sucess_log}
            else
                echo "${DB}_${DATENAME}.sql backup error  " >> ${base_sucess_log}
            fi
        done
    else 
        echo "base backup error" >>${dump_log}
        exit 1
    fi
}

##########################main 函数 主要运行
main() {
    case $1 in 
        all)
            ALLDUMP
            ;;
        base)
            datadump
            ;;
        *)
            echo "usage:command all / base...."
            ;;
    esac
}
main $1
exit 0