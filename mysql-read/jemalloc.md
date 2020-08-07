5.7.30 配置

```shell
# 安装jemalloc
yum install jemalloc jemalloc-devel
echo "LD_PRELOAD=/usr/lib64/libjemalloc.so" >> /etc/sysconfig/mysql
sysyemd 中添加
mysqld.service 
EnvironmentFile=-/etc/sysconfig/mysql
# 验证 jemalloc 是否被使用
lsof -p `pidof mysqld`|grep -i jemalloc
```



```shell
mysqld.service
[Unit]
Description=MySQL Server
Documentation=man:mysqld(8)
Documentation=http://dev.mysql.com/doc/refman/en/using-systemd.html
After=network.target
After=syslog.target
[Install]
WantedBy=multi-user.target
[Service]
User=mysql
Group=mysql
# 添加 jemalloc 参数
EnvironmentFile=-/etc/sysconfig/mysql
ExecStart=/app/mysql/bin/mysqld --defaults-file=/data/mysql/3306/my.cnf
LimitNOFILE = 5000
```

mysql 优化
https://www.jianshu.com/p/9599562b9437