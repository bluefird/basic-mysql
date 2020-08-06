#!/bin/bash
#完全备份目录
BACKDIR=/backup/innodb
OLDFILE=${BACKDIR}/olddir.txt
file_check() {
    cat ${OLDFILE}
    OLDDIR=`cat ${OLDFILE}`
    if [[ -f "${OLDFILE}"  && -w "${OLDFILE}" && -n "${OLDFILE}" ]];then
         :
    else 
        echo "文件不存在，无法找到上次备份点"
        exit 3
    fi 
}
file_check