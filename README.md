[TOC]

# shell-scripts

## pure-bash-bible

[pure-bash-bible](https://github.com/dylanaraps/pure-bash-bible)

[bash奇巧淫技(中文版)](https://github.com/A-BenMao/pure-bash-bible-zh_CN)

## 安装使用

完整下载

```shell
curl -s "https://raw.githubusercontent.com/mufool/shell-scripts/master/installer.sh" | bash -s
```

单个下载

```
wget --no-check-certificate https://raw.githubusercontent.com/mufool/shell-scripts/master/scripts/java/show-busy-java-threads
chmod +x show-busy-java-threads
./show-busy-java-threads
```

单个运行

```
curl -sLk 'https://raw.githubusercontent.com/mufool/shell-scripts/master/scripts/java/show-busy-java-threads' | bash
```

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

## Java相关脚本

### show-busy-java-threads

用于快速排查Java的CPU性能问题(top us值过高)，自动查出运行的Java进程中消耗CPU多的线程，并打印出其线程栈，从而确定导致性能问题的方法调用。

平常定位问题主要使用一下步骤：

```
1. `top`命令找出有问题`Java`进程及线程`id`：
    1. 开启线程显示模式
    2. 按`CPU`使用率排序
    3. 记下`Java`进程`id`及其`CPU`高的线程`id`
2. 用进程`id`作为参数，`jstack`有问题的`Java`进程
3. 手动转换线程`id`成十六进制（可以用`printf %x 1234`）
4. 查找十六进制的线程`id`（可以用`grep`）
5. 查看对应的线程栈
```

可能会要多次这样操作以确定问题，整个过程比较麻烦。

#### 用法

```
show-busy-java-threads [Options] [delay [ucount]]
# 从 所有的 Java进程中找出最消耗CPU的线程（缺省5个），打印出其线程栈。

show-busy-java-threads -c <要显示的线程栈数>

show-busy-java-threads -c <要显示的线程栈数> -p <指定的Java Process>

# -F选项：执行jstack命令时加上-F选项（强制jstack），一般情况不需要使用
show-busy-java-threads -p <指定的Java Process> -F

show-busy-java-threads -s <指定jstack命令的全路径>
# 对于sudo方式的运行，JAVA_HOME环境变量不能传递给root，
# 而root用户往往没有配置JAVA_HOME且不方便配置，
# 显式指定jstack命令的路径就反而显得更方便了

show-busy-java-threads -a <输出记录到的文件>

show-busy-java-threads -c <要显示的线程栈数> -p <指定的Java Process> <刷新间隔秒数> <刷新次数>

##############################
# 注意：
##############################
# 如果Java进程的用户 与 执行脚本的当前用户 不同，则jstack不了这个Java进程。
# 为了能切换到Java进程的用户，需要加sudo来执行，即可以解决：
sudo show-busy-java-threads

# 帮助信息
$ show-busy-java-threads -h
Usage: show-busy-java-threads [OPTION] [delay [ucount]]
Find out the highest cpu consumed threads of java, and print the stack of these threads.
Example: show-busy-java-threads -c 10

Options:
    -p, --pid       find out the highest cpu consumed threads from the specifed java process,
                    default from all java process.
    -c, --count     set the thread count to show, default is 5
    -a, --append-file <file>  specify the file to append output as log
    -s, --jstack-path <path>  specify the path of jstack command
    -F, --force               set jstack to force a thread dump(use jstack -F option)
    -S, --jstack-file-dir <path>  specifies the directory for storing jstack output files, and keep files.
                            default store jstack output files at tmp dir, and auto remove after run.
                            use this option to keep files so as to review jstack later.
    -m, --mix-native-frames   set jstack to print both java and native frames (mixed mode).
    -l, --lock-info           set jstack with long listing. Prints additional information about locks.
    -d, --top-delay  <deplay> specifies the delay between top samples, default is 0.5 (second).
                              get thread cpu percentage during this delay interval.
                              more info see top -d option. eg: -d 1 (1 second).
    -P, --use-ps              use ps command to find busy thread(cpu usage) instead of top command,
                              default use top command, because cpu usage of ps command is expressed as
                              the percentage of time spent running during the entire lifetime of a process,
                              this is not ideal.
    -h, --help      display this help and exit
    delay is the delay between updates in seconds. when this is not set, it will output once.
    ucount is the number of updates. when delay is set, ucount is not set, it will output in unstop mode.
```

### show-duplicate-java-classes

找出`Java Lib`（`Java`库，即`Jar`文件）或`Class`目录（类目录）中的重复类。

`Java`开发的一个麻烦的问题是`Jar`冲突（即多个版本的`Jar`），或者说重复类。会出`NoSuchMethod`等的问题，还不见得当时出问题。找出有重复类的`Jar`，可以防患未然。

#### 用法

- 通过脚本参数指定`Libs`目录，查找目录下`Jar`文件，收集`Jar`文件中`Class`文件以分析重复类。可以指定多个`Libs`目录。
    注意，只会查找这个目录下`Jar`文件，不会查找子目录下`Jar`文件。因为`Libs`目录一般不会用子目录再放`Jar`，这样也避免把去查找不期望`Jar`。
- 通过`-c`选项指定`Class`目录，直接收集这个目录下的`Class`文件以分析重复类。可以指定多个`Class`目录。

```bash
# 查找当前目录下所有Jar中的重复类
show-duplicate-java-classes

# 查找多个指定目录下所有Jar中的重复类
show-duplicate-java-classes path/to/lib_dir1 /path/to/lib_dir2

# 查找多个指定Class目录下的重复类。 Class目录 通过 -c 选项指定
show-duplicate-java-classes -c path/to/class_dir1 -c /path/to/class_dir2

# 查找指定Class目录和指定目录下所有Jar中的重复类的Jar
show-duplicate-java-classes path/to/lib_dir1 /path/to/lib_dir2 -c path/to/class_dir1 -c path/to/class_dir2
```

### find-in-jars

在当前目录下所有`jar`文件里，查找类或资源文件。

#### 用法

```bash
# 在当前目录下所有`jar`文件里，查找类或资源文件。
find-in-jars 'log4j\.properties'
find-in-jars 'log4j\.xml$'
find-in-jars log4j\\.xml$ # 和上面命令一样，Shell转义的不同写法而已
find-in-jars 'log4j(\.properties|\.xml)$'

# -d选项 指定 查找目录（覆盖缺省的当前目录）
find-in-jars 'log4j\.properties$' -d /path/to/find/directory
# 支持多个查找目录
find-in-jars 'log4j\.properties' -d /path/to/find/directory1 -d /path/to/find/directory2

# 帮助信息
$ find-in-jars -h
Usage: find-in-jars [OPTION]... PATTERN
Find file in the jar files under specified directory(recursive, include subdirectory).
The pattern default is *extended* regex.

Example:
    find-in-jars.sh 'log4j\.properties'
    find-in-jars.sh '^log4j(\.properties|\.xml)$' # search file log4j.properties/log4j.xml at zip root
    find-in-jars.sh 'log4j\.properties$' -d /path/to/find/directory
    find-in-jars.sh 'log4j\.properties' -d /path/to/find/dir1 -d /path/to/find/dir2

Options:
  -d, --dir              the directory that find jar files, default is current directory.
                         this option can specify multiply times to find in multiply directory.
  -E, --extended-regexp  PATTERN is an extended regular expression (*default*)
  -F, --fixed-strings    PATTERN is a set of newline-separated strings
  -G, --basic-regexp     PATTERN is a basic regular expression
  -P, --perl-regexp      PATTERN is a Perl regular expression
  -h, --help             display this help and exit
```

注意，Pattern缺省是`grep`的 **扩展**正则表达式。

#### 示例

```bash
# 在当前目录下的所有Jar文件中，查找出 log4j.properties文件
$ find-in-jars 'log4j\.properties$'
./hadoop-core-0.20.2-cdh3u3.jar!log4j.properties

# 查找出 以Service结尾的类
$ ./find-in-jars 'Service.class$'
./WEB-INF/libs/spring-2.5.6.SEC03.jar!org/springframework/stereotype/Service.class
./rpc-benchmark-0.0.1-SNAPSHOT.jar!com/taobao/rpc/benchmark/service/HelloService.class
......

# 在指定的多个目录的Jar文件中，查找出 properties文件
$ find-in-jars '\.properties$' -d ../WEB-INF/lib -d ../deploy/lib | grep -v '/pom\.properties$'
../WEB-INF/lib/aspectjtools-1.6.2.jar!org/aspectj/ajdt/ajc/messages.properties
../WEB-INF/lib/aspectjtools-1.6.2.jar!org/aspectj/ajdt/internal/compiler/parser/readableNames.properties
../WEB-INF/lib/aspectjweaver-1.8.8.jar!org/aspectj/weaver/XlintDefault.properties
../WEB-INF/lib/aspectjweaver-1.8.8.jar!org/aspectj/weaver/weaver-messages.properties
../deploy/lib/groovy-all-1.1-rc-1.jar!groovy/ui/InteractiveShell.properties
../deploy/lib/groovy-all-1.1-rc-1.jar!org/codehaus/groovy/tools/shell/CommandAlias.properties
../deploy/lib/httpcore-4.3.3.jar!org/apache/http/version.properties
../deploy/lib/httpmime-4.2.2.jar!org/apache/http/entity/mime/version.properties
../deploy/lib/javax.servlet-api-3.0.1.jar!javax/servlet/LocalStrings_fr.properties
../deploy/lib/javax.servlet-api-3.0.1.jar!javax/servlet/http/LocalStrings_es.properties
......
```

### [housemd](java/bin/housemd)

`housemd [pid] [java_home]`
> 使用housemd对java程序进行运行时跟踪，支持的操作有：
>
> - 查看加载类
> - 跟踪方法
> - 查看环境变量
> - 查看对象属性值
> - 详细信息请参考: https://github.com/CSUG/HouseMD/wiki/UserGuideCN

### [jargrep](java/bin/jargrep)

`jargrep "text" [path or jarfile]`
> 在jar包中查找文本，可查找常量字符串、类引用。

### [jvm](java/bin/jvm)

`jvm [pid]`

> 执行jvm debug工具，包含对java栈、堆、线程、gc等状态的查看，支持的功能有： 

>========线程相关=======
>1 : 查看占用cpu最高的线程情况
>2 : 打印所有线程
>3 : 打印线程数
>4 : 按线程状态统计线程数
>========GC相关=======
>5 : 垃圾收集统计（包含原因）可以指定间隔时间及执行次数，默认1秒, 10次
>6 : 显示堆中各代的空间可以指定间隔时间及执行次数，默认1秒，5次
>7 : 垃圾收集统计。可以指定间隔时间及执行次数，默认1秒, 10次
>8 : 打印perm区内存情况*会使程序暂停响应*
>9 : 查看directbuffer情况
>========堆对象相关=======
>10 : dump heap到文件*会使程序暂停响应*默认保存到`pwd`/dump.bin,可指定其它路径
>11 : 触发full gc。*会使程序暂停响应*
>12 : 打印jvm heap统计*会使程序暂停响应*
>13 : 打印jvm heap中top20的对象。*会使程序暂停响应*参数：1:按实例数量排序,2:按内存占用排序，默认为1
>14 : 触发full gc后打印jvm heap中top20的对象。*会使程序暂停响应*参数：1:按实例数量排序,2:按内存占用排序，默认为1
>15 : 输出所有类装载器在perm里产生的对象。可以指定间隔时间及执行次数
>========其它=======
>16 : 打印finalzer队列情况
>17 : 显示classloader统计
>18 : 显示jit编译统计
>19 : 死锁检测
>20 : 等待X秒，默认为1
>q : exit
></pre>
>进入jvm工具后可以输入序号执行对应命令
>可以一次执行多个命令，用分号";"分隔，如：1;3;4;5;6
>每个命令可以带参数，用冒号":"分隔，同一命令的参数之间用逗号分隔，如：
>Enter command queue:1;5:1000,100;10:/data1/output.bin

### [greys](java/bin/greys)

`greys [pid][@ip:port]`
> 使用greys对java程序进行运行时跟踪(不传参数，需要先`greys -C pid`,再greys)。支持的操作有：
>
> - 查看加载类，方法信息
> - 查看JVM当前基础信息
> - 方法执行监控（调用量，失败率，响应时间等）
> - 方法执行数据观测、记录与回放（参数，返回结果，异常信息等）
> - 方法调用追踪渲染
> - 详细信息请参考: https://github.com/oldmanpushcart/greys-anatomy/wiki

### [sjk](java/bin/sjk)

`sjk [cmd] [arguments]`
`sjk --commands`
`sjk --help [cmd]`
> 使用sjk对Java诊断、性能排查、优化工具
>
> - ttop:监控指定jvm进程的各个线程的cpu使用情况
> - jps: 强化版
> - hh: jmap -histo强化版
> - gc: 实时报告垃圾回收信息
> - mx: 操作MBean
> - 更多信息请参考: https://github.com/aragozin/jvm-tools

### [vjmap](java/bin/vjmap)

`vjmap -all [pid] > /tmp/histo.log`
`vjmap -old [pid] > /tmp/histo-old.lo`
`vjmap -sur [pid] > /tmp/histo-sur.log`
> 使用唯品会的vjmap(思路来自于阿里巴巴的TBJMap)查看堆内存的分代占用信息，加强版jmap

> 注意：vjmap在执行过程中，会完全停止应用一段时间，必须摘流量执行！！！！

> 更多信息请参考: https://github.com/vipshop/vjtools/tree/master/vjmap

### [vjdump](java/bin/vjdump)

`vjdump [pid]`
`vjdump --liveheap [pid]`
> 使用唯品会的vjdump一次性快速dump现场信息，包括：
> - JVM启动参数及命令行参数: jinfo -flags [pid]
> - thread dump数据：jstack -l [pid]
> - sjk ttop JVM概况及繁忙线程：sjk ttop -n 1 -ri 3 -p [pid]
> - jmap histo 堆对象统计数据：jmap -histo [pid] & jmap -histo:live [pid]
> - GC日志(如果JVM有设定GC日志输出)
> - heap dump数据（需指定--liveheap开启）：jmap -dump:live,format=b,file=[DUMP_FILE] [pid]
>
> 更多信息请参考: https://github.com/vipshop/vjtools/tree/master/vjdump

### [vjmxcli](java/bin/vjmxcli)

`vjmxcli - [host:port] java.lang:type=Memory HeapMemoryUsage`

`vjmxcli - [pid] gcutil [interval]`
> 使用唯品会的vjmxcli获取MBean属性值以及在jstat无法使用时模拟jstat -gcutil。开启jmx时可以使用主机:端口号；未开启jmx则使用pid。
>
> 更多信息请参考: https://github.com/vipshop/vjtools/tree/master/vjmxcli

参考：
[awesome-scripts](https://github.com/Suishenyun/awesome-scripts)
