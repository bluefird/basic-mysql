
# 二进制安装 #

    新特性重要说明:
    5.7开始,MySQL加入了全新的 密码的安全机制:
    1.初始化完成后,会生成临时密码(显示到屏幕上,并且会往日志中记一份)
    2.密码复杂度:长度:超过12位? 复杂度:字符混乱组合
    3.密码过期时间180天
---

## 目录规划 ##

    1.basedir
    2.datadirdir
    3.logdiir
---

---

## 基础配置 ##

    3.1 创建mysql
    `mkdir -p  /app/mysql /data/330{6,7,8}`
    `tar xvf mysql-5.7.30-linux-glibc2.12-x86_64.tar.gz -C /app/`
    `ln -s mysql-5.7.30-linux-glibc2.12-x86_64/ mysql`
    3.2 目录权限权限
    `useradd  -M -s /sbin/nologin mysql`
    `chown mysql.mysql /app/mysql`
    `chown mysql.mysql /data/ -R`
    3.3 系统环境参数
    `touch /etc/profile.d/mysqld.sh`
    `vim /etc/profile.d/mysqld.sh`

# mysqld bin path #

    `pathmunge /app/mysql/bin`
    3.3 数据库初始化
        方法一: 安全初始化
            `mysqld --initialize  --user=mysql --basedir=/app/mysql --datadir=/data/3306/data`
                多实例
            `mysqld --initialize  --user=mysql --basedir=/app/mysql --datadir=/data/3307/data`
            `mysqld --initialize  --user=mysql --basedir=/app/mysql --datadir=/data/3308/data`
        方法二: 空密码初始化
            `mysqld --initialize-insecure --user=mysql --basedir=/app/mysql --datadir=/data/3306/data`
                多实例
            `mysqld --initialize-insecure --user=mysql --basedir=/app/mysql --datadir=/data/3307/data`
            `mysqld --initialize-insecure --user=mysql --basedir=/app/mysql --datadir=/data/3308/data`
    3.4 mysql、systemd配置文件(看需求自己配置参数)
        conf目录下
