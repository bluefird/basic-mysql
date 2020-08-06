#!/bin/bash


###########################user passowrd
USER=root
PASSWORD=123456
FILENAME=`date +%Y%d%H%M`
BACKDIR=/backup/dump/full
LOGDIR=/backup/log/full
PORT=3306
DATANAME=
############################diretory 
if [ -d "${BACKDIR}" ];then
    :
else 
    mkdir ${BACKDIR} -p
fi

if [ -d "${LOGDIR}" ];then
    :
else 
    mkdir ${LOGDIR} -p
fi

##########################mysqldump
##########################完全备份

# --single-transaction 不锁表备份 参数看自己是否需要添加
#备份参数
dump_args='-A -R -E --triggers --master-data=2   --set-gtid-purged=off'
function fulldump() {

    mysqldump  -P ${PORT} -u${USER} -p${PASSWORD} ${dump_args} > ${BACKDIR}/${DATANAME}full_${FILENAME}.sql 2>${LOGDIR}/dump.log
    if [ "$?" == 0 ];then
        echo "full_${FILENAME}.sql backup sucess " >> ${LOGDIR}/backup.log
    else
        echo "full_${FILENAME}.sql backup error  " >> ${LOGDIR}/backup_error.log
        exit 1
    fi
}


##########################单库备份
function main() {
    fulldump
}
main 
exit 0