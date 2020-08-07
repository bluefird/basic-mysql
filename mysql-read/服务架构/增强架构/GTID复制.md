###  GTID介绍

```markdown
GTID(Global Transaction ID)是对于一个已提交事务的唯一编号，并且是一个全局(主从复制)唯一的编号。
它的官方定义如下：
GTID = source_id ：transaction_id
7E11FA47-31CA-19E1-9E56-C43AA21293967:29
什么是sever_uuid，和Server-id 区别？
核心特性: 全局唯一,具备幂等性
```

### GTID核心参数： 主从库都得配置

```shell
vim my.cnf
gtid-mode=on                        --启用gtid类型，否则就是普通的复制架构
enforce-gtid-consistency=true               --强制GTID的一致性
log-slave-updates=1                 --slave 更新是否记入日志
```

### 从库配置命令：

```mysql
mysql> change master to 
master_host='hostip',
master_user='repl',
master_password='密码' ,
MASTER_AUTO_POSITION=1;
start slave;
```

### 普通复制和GTID复制区别

```markdwon
（0）在主从复制环境中，主库发生过的事务，在全局都是由唯一GTID记录的，更方便Failover
（1）额外功能参数（3个）
（2）change master to 的时候不再需要binlog 文件名和position号,MASTER_AUTO_POSITION=1;
（3）在复制过程中，从库不再依赖master.info文件，而是直接读取最后一个relaylog的 GTID号
（4）mysqldump备份时，默认会将备份中包含的事务操作，以以下方式
    SET @@GLOBAL.GTID_PURGED='8c49d7ec-7e78-11e8-9638-000c29ca725d:1';
    告诉从库，我的备份中已经有以上事务，你就不用运行了，直接从下一个GTID开始请求binlog就行。
```

### GTID 从库误写入操作处理 

避免方法： 关闭从库写权限

```mysql
#查看监控信息:
Last_SQL_Error: Error 'Can't create database 'oldboy'; database exists' on query. Default database: 'oldboy'. Query: 'create database oldboy''
Retrieved_Gtid_Set: 71bfa52e-4aae-11e9-ab8c-000c293b577e:1-3
Executed_Gtid_Set:  71bfa52e-4aae-11e9-ab8c-000c293b577e:1-2,
7ca4a2b7-4aae-11e9-859d-000c298720f6:1
# 注入空事物的方法：
stop slave;
set gtid_next='99279e1e-61b7-11e9-a9fc-000c2928f5dd:3';
begin;commit;
set gtid_next='AUTOMATIC';   
#这里的xxxxx:N 也就是你的slave sql thread报错的GTID，或者说是你想要跳过的GTID。
#最好的解决方案：重新构建主从环境
```

