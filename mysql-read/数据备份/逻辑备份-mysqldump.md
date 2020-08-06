## 备份工具-mysqldump

mysqldump (逻辑备份的客户端工具)

### 客户端通用参数：-u  -p   -S   -h  -P    

本地备份:mysqldump -uroot -p  -S /tmp/mysql.sock

远程备份:mysqldump -uroot -p  -h 10.0.0.51 -P3306

备份专用基本参数

#### -A   全备参数

#例子1： 

\# 1.常规备份是要加 --set-gtid-purged=OFF,解决备份时的警告 (脚本备份时注意)
\# [root@db01 ~]# mysqldump -uroot -p123 -A  --set-gtid-purged=OFF  >/backup/full.sql
\# 2.构建主从时,做的备份,不需要加这个参数
\# [root@db01 ~]# mysqldump -uroot -p123 -A    --set-gtid-purged=ON >/backup/full.sql

#### -B db1  db2  db3  备份多个单库

说明：生产中需要备份，生产相关的库和MySQL库

例子2 :mysqldump -B mysql gtid --set-gtid-purged=OFF >/data/backup/b.sql 

备份单个或多个表

例子3 world数据库下的city,country表

mysqldump -uroot -p world city country >/backup/bak1.sql
以上备份恢复时:必须库事先存在,并且ues才能source恢复

### 高级参数应用

### 特殊参数1使用（必须要加）

-R            备份存储过程及函数
--triggers  备份触发器
-E             备份事件

例子4:

[root@db01 backup]# mysqldump -uroot -p -A -R -E --triggers >/data/backup/full.sql

##### -F  在备份开始时,刷新一个新binlog日志

例子5:

mysqldump -uroot -p  -A  -R --triggers -F >/bak/full.sql

### --master-data=2 : 特别重要

以注释的形式,保存备份开始时间点的binlog的状态信息： 以供还原时操作

```sh
mysqldump -uroot -p  -A  -R --triggers --master-data=2   >/back/world.sql
grep 'CHANGE' /backup/world.sql 
```

 功能：

（1）在备份时，会自动记录，二进制日志文件名和位置号
			0 默认值
			1  以change master to命令形式，可以用作主从复制
			2  以注释的形式记录，备份时刻的文件名+postion号
（2） 自动锁表
（3）如果配合--single-transaction，只对非InnoDB表进行锁表备份，InnoDB表进行“热“”备，实际上是实现快照备份。

​           innodb 存储引擎开启热备(快照备份)功能       

master-data可以自动加锁

（1）在不加--single-transaction ，启动所有表的温备份，所有表都锁定

（1）加上--single-transaction ,对innodb进行快照备份,对非innodb表可以实现自动锁表功能

例子6: 备份必加参数

mysqldump -uroot -p -A -R -E --triggers --master-data=2  --single-transaction --set-gtid-purged=OFF >/data/backup/full.sql

### --set-gtid-purged=auto

​       auto , on,off 
使用场景:

1. --set-gtid-purged=OFF,可以使用在日常备份参数中.

   1. ```shell
      mysqldump -uroot -p -A -R -E --triggers --master-data=2  --single-transaction --set-gtid-purged=OFF >/data/backup/full.sql 
      ```

2.  auto , on:在构建主从复制环境时需要的参数配置

   1. ```shell
      mysqldump -uroot -p -A -R -E --triggers --master-data=2  --single-transaction --set-gtid-purged=ON >/data/backup/full.sql
      ```

### --max-allowed-packet=#

​       The maximum packet length to send to or receive from server.

```shell
mysqldump -uroot -p -A -R -E --triggers --master-data=2  --single-transaction --set-gtid-purged=OFF --max-allowed-packet=256M >/data/backup/full.sql 
```