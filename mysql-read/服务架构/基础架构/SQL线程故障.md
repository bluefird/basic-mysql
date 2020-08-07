## SQL线程功能：

(1)读写relay-log.info 
(2)relay-log损坏,断节,找不到
(3)接收到的SQL无法执行

### 导致SQL线程故障原因分析：

1. 版本差异，参数设定不同
2. 比如：数据类型的差异，SQL_MODE影响
3. 要创建的数据库对象,已经存在 
4. 要删除或修改的对象不存在  
5. DML语句不符合表定义及约束时.  
6. 归根揭底的原因都是由于从库发生了写入操作.

```mysql
Last_SQL_Error: Error 'Can't create database 'db'; database exists' on query. Default database: 'db'. Query: 'create database db'
```

### 处理方法(以从库为核心的处理方案)：

 方法一：#将同步指针向下移动一个，如果多次不同步，可以重复操作。

```mysql
stop slave; 
set global sql_slave_skip_counter = 1;
start slave;
```

方法二：常见错误代码:    1007:对象已存在   1032:无法执行DML  1062:主键冲突,或约束冲突

```shell
vim my.cnf
slave-skip-errors = 1032,1062,1007
```

但是，以上操作有时是有风险的，最安全的做法就是重新构建主从。把握一个原则,一切以主库为主.

## 最佳的方法:

(1) 可以设置从库只读.: 从库操作

```shell
vim my.cnf
read_only=on       #普通用户限制
super_read_only=on #超级用户限制
```

```mysql
db01 [(none)]>show variables like '%read_only%';
```

注意：只会影响到普通用户，对管理员用户无效。
(2)加中间件
读写分离。