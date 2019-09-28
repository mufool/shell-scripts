# shell-scripts

## pure-bash-bible

[pure-bash-bible](https://github.com/dylanaraps/pure-bash-bible)

[bash奇巧淫技(中文版)](https://github.com/A-BenMao/pure-bash-bible-zh_CN)

## scripts

### colines

彩色`cat`出文件行，方便人眼区分不同的行。

```
# echo 'test123' | colines
test123 # 带颜色

# cat test_file | colines
colorful lines
```

### a2l

按行彩色输出参数，方便人眼查看。命令名a2l意思是Arguments to(2) Lines。

```
#a2l *.java
```

### ap and rp

批量转换文件路径为绝对路径/相对路径，会自动跟踪链接并规范化路径。

命令名ap意思是Absolute Path，rp是Relative Path。

```
# ap缺省打印当前路径的绝对路径
$ ap
/home/admin/useful-scripts/test
$ ap ..
/home/admin/useful-scripts
# 支持多个参数
$ ap .. ../.. /etc /etc/../etc
/home/admin/useful-scripts
/home/admin
/etc
/etc

# rp当一个参数时，打印相对于当前路径的相对路径
$ rp /home
../..
# 多于一个参数时，打印相对于最后一个参数的相对路径
$ rp /home /etc/../etc /home/admin
..
```

### tcp-connection-state-counter

统计各个TCP连接状态的个数。

```
$ tcp-connection-state-counter.sh
ESTABLISHED  290
TIME_WAIT    212
SYN_SENT     17
```

