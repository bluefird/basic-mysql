#!/bin/bash
#
#
#
###################### basic env 
mkdir -p  /app/mysql /data/330{6,7,8}
tar xvf mysql-5.7.30-linux-glibc2.12-x86_64.tar.gz -C /app/
ln -s mysql-5.7.30-linux-glibc2.12-x86_64/ mysql


###################### 权限
useradd  -M -s /sbin/nologin mysql
chown mysql.mysql /app/mysql
chown mysql.mysql /data/ -R

###################### system bin
cat >/etc/profile.d/mysqld.sh<<EOF 
#mysqld bin path
pathmunge /app/mysql/bin
EOF
source /etc/profile

##################### data init 数据库安全初始化 
#注意mysql密码
mysqld --initialize  --user=mysql --basedir=/app/mysql --datadir=/data/3306
# mysqld --initialize  --user=mysql --basedir=/app/mysql --datadir=/data/3307
# mysqld --initialize  --user=mysql --basedir=/app/mysql --datadir=/data/3308