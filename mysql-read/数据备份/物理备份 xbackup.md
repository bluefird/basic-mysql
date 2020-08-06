 MySQL物理备份工具-xtrabackup(XBK、Xbackup)

安装依赖包： yum -y install perl perl-devel libaio libaio-devel perl-Time-HiRes perl-DBD-MySQL libev

RPM地址：版本需求      https://www.percona.com/downloads/XtraBackup/Percona-XtraBackup-2.4.12/binary/redhat/7/x86_64/percona-xtrabackup-24-2.4.12-1.el7.x86_64.rpm

备份命令介绍:

- xtrabackup
- innobackupex

​       备份方式——物理备份

- 对于非Innodb表（比如 myisam）是，锁表cp数据文件，属于一种温备份。
- 对于Innodb的表（支持事务的），不锁表，拷贝数据页，最终以数据文件的方式保存下来，把一部分redo和undo一并备走，属于热备方式

##            innobackupex使用

```shell
[root@db01 backup]# innobackupex --user=root --password=123  /data/backup 
#全备
[root@db01 backup]# innobackupex --user=root --password=123 --no-timestamp /data/backup/full 
#自定义备份路径
```

文件记录：

### 备份集中多出来的文件：

```shell
-rw-r----- 1 root root       24 Jun 29 09:59 xtrabackup_binlog_info
-rw-r----- 1 root root      119 Jun 29 09:59 xtrabackup_checkpoints
-rw-r----- 1 root root      489 Jun 29 09:59 xtrabackup_info
-rw-r----- 1 root root     2560 Jun 29 09:59 xtrabackup_logfile
```

xtrabackup_binlog_info ：（备份时刻的binlog位置）
记录的是备份时刻，binlog的文件名字和当时的结束的position，可以用来作为截取binlog时的起点。

xtrabackup_checkpoints ：
backup_type = full-backuped
from_lsn = 0            上次所到达的LSN号(对于全备就是从0开始,对于增量有别的显示方法)
to_lsn = 160683027      备份开始时间(ckpt)点数据页的LSN    
last_lsn = 160683036    备份结束后，redo日志最终的LSN
compact = 0
recover_binlog_info = 0
（1）备份时刻，立即将已经commit过的，内存中的数据页刷新到磁盘(CKPT).开始备份数据，数据文件的LSN会停留在to_lsn位置。
（2）备份时刻有可能会有其他的数据写入，已备走的数据文件就不会再发生变化了。
（3）在备份过程中，备份软件会一直监控着redo的undo，如果一旦有变化会将日志也一并备走，并记录LSN到last_lsn。
从to_lsn  ----》last_lsn 就是，备份过程中产生的数据变化.

## 全备恢复

### 准备备份（Prepared）


将redo进行重做，已提交的写到数据文件，未提交的使用undo回滚掉。模拟了CSR的过程

```shell
[root@db01 ~]# innobackupex --apply-log  /backup/full
```

### 恢复备份

前提：  1、被恢复的目录是空

​			 2、被恢复的数据库的实例是关闭

```shell
mkdir /data/mysql1
chown -R mysql.mysql /data/mysql1
cp -a /backup/full/* /data/mysql1/
```

### 启动数据库

```shell
vim /etc/my.cnf
datadir=/data/mysql
[root@db01 mysql1]# chown -R mysql.mysql /data/mysql
systemctl start mysqld`
```

## 增量备份(incremental)

```markdown
（1）增量备份的方式，是基于上一次备份进行增量。
（2）增量备份无法单独恢复。必须基于全备进行恢复。
（3）所有增量必须要按顺序合并到全备中。
```

### 增量备份命令

```shell
#上次全备（周日）
[root@db01 backup]# innobackupex --user=root --password --no-timestamp /backup/full >&/tmp/xbk_full.log
#数据变化（周一）
db01 [(none)]>create database cs charset utf8;
db01 [(none)]>use cs
db01 [cs]>create table t1 (id int);
db01 [cs]>insert into t1 values(1),(2),(3);
db01 [cs]>commit;
#第一次增量备份（周一）
innobackupex --user=root --password=123 --no-timestamp --incremental --incremental-basedir=/backup/full  /backup/inc1 &>/tmp/inc1.log
#模拟周二数据
db01 [cs]>create table t2 (id int);
db01 [cs]>insert into t2 values(1),(2),(3);
db01 [cs]>commit;
#周二增量
innobackupex --user=root --password=123 --no-timestamp --incremental --incremental-basedir=/backup/inc1  /backup/inc2  &>/tmp/inc2.log
#模拟周三数据变化
db01 [cs]>create table t3 (id int);
db01 [cs]>insert into t3 values(1),(2),(3);
db01 [cs]>commit;
db01 [cs]>drop database cs;
```

### 恢复到周三误drop之前的数据状态

1. 恢复思路
2. 挂出维护页，停止当天的自动备份脚本
3. 检查备份：周日full+周一inc1+周二inc2，周三的完整二进制日志
4. 进行备份整理（细节），截取关键的二进制日志（从备份——误删除之前）
5. 测试库进行备份恢复及日志恢复
6. 应用进行测试无误，开启业务
7. 此次工作的总结

### 恢复过程

```shell
#1. 检查备份(先备份 备份的数据，避免误操作 损失 备份数据)
cp -rp /backup /newdata
1afe8136-601d-11e9-9022-000c2928f5dd:7-9
#2. 备份整理（apply-log）+合并备份（full+inc1+inc2）
#(1) 全备的整理
[root@db01 one]# innobackupex --apply-log --redo-only /data/backup/full
#(2) 合并inc1到full中
[root@db01 one]# innobackupex --apply-log --redo-only --incremental-dir=/data/backup/inc1 /data/backup/full
#(3) 合并inc2到full中
[root@db01 one]# innobackupex --apply-log  --incremental-dir=/data/backup/inc2 /data/backup/full
#(4) 最后一次整理全备
[root@db01 backup]#  innobackupex --apply-log  /data/backup/full
#3. 截取周二 23:00 到drop 之前的 binlog 
[root@db01 inc2]# mysqlbinlog --skip-gtids --include-gtids='1afe8136-601d-11e9-9022-000c2928f5dd:7-9' /data/binlog/mysql-bin.000009 >/data/backup/binlog.sql
#4. 进行恢复
[root@db01 backup]# mkdir /data/mysql/data2 -p
[root@db01 full]# cp -a * /data/mysql/data2
[root@db01 backup]# chown -R mysql.  /data/*
[root@db01 backup]# systemctl stop mysqld
vim /etc/my.cnf
datadir=/data/mysql/data2
systemctl start mysqld
Master [(none)]>set sql_log_bin=0;
Master [(none)]>source /data/backup/binlog.sql
```

