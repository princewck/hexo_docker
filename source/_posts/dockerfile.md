---
title: Dockerfile reference 笔记
date: 2019-03-26 17:04:32
tags: Docker
category: 工程化和运维
toc: true
thumbnail: /images/wpp3.jpeg
---

### dockerfile reference 笔记

[TOC]

> 以下要点记录提取自[官方文档](https://docs.docker.com/engine/reference/builder/)

1. build工作是docker 守护进程执行的，而不是cli工具。
2. build默认会以dockerfile文件所在目录为上下文，并上下文目录传入守护进程中，因此最好将dockerfile在空目录中,使构建过程仅添加需要用到的东西
3. 如果需要使用build context中的文件，使用指令来添加他们，例如`COPY`
4. 如果要忽略context中的文件来提高构建镜像的性能，可以[添加`.dockerignore`文件](https://docs.docker.com/engine/reference/builder/#dockerignore-file)
5. 默认情况下把配置文件命名为`Dockerfile`并放在context路径下，但可以通过-f 参数来自定义
>```bash
> $docker build -f /path/to/a/Dockerfile .
>```
6. 使用`-t`指定仓库名和版本号
>```bash
> $docker build -t shykes/myapp .
>
> # 同时build为多个名字也是支持的
> $docker build -t shykes/myapp:1.0.2 -t shykes/myapp:latest .
>
>```
7. 在执行dockerfile中的指令前，会先做语法检查。
8. docker守护进程会一行一行地执行Dockerfile中的指令，每一行commit为一个新的image。
9. 守护进程会在build完成过自动清理传入的context内容。
10. Docker会优先复用在之前构建过程中缓存的中间镜像，以此加速构建过程。（命令行会有`Using cache`提示）
11. 一下为Dockerfile 指令的一般格式：
>```bash
># Comment
>INSTRUCTION arguments
>```
12. 指令不区分大小写，但是国际惯例是全部大写，这样更容易把指令和参数做区分。
13. 符号`#`有两种作用，一种是[`Parser directives`](https://docs.docker.com/engine/reference/builder/#parser-directives) 格式如`# directive=value`, 除此用法外均作为注释使用。
14. 对于Parser directives, 一行只会生效一次，惯例全部小写。
15. 一旦有注释、空行或指令被处理，Docker不会再寻找parser directives， 所以directives需要放在首行，也不能使用`\`符号折行书写。
>```bash
># direc \
>tive=value
># 以上写法错误
>```
```
16. 环境变量可以用`ENV`指令来引入，有两种方法引用：
​```bash
$variable_name or ${variable_name}
```
17. 环境变量可以在一下指令中使用：
- `ADD`
- `COPY`
- `ENV`
- `EXPOSE`
- `FROM`
- `LABEL`
- `STOPSIGNAL`
- `USER`
- `VOLUME`
- `WORKDIR`
- `ONBUILD`(1.4版本以上)
18. 关于环境变量，环境变量的值在一条指令中会始终使用同一个，看例子：
```
ENV abc=hello
ENV abc=bye def=$abc
ENV ghi=$abc
```
结果： def=hello ghi=bye

#### From
19. 合法的Dockerfile必须以`FROM`指令开始，[唯一可以用在`FROM`前面的指令是`ARG`](https://docs.docker.com/engine/reference/builder/#understand-how-arg-and-from-interact)

```dockerfile
FROM <image> [AS <name>]

FROM <image>[:<tag>] [AS <name>]

FROM <image>[@<digest>] [AS <name>]
```
- `FROM`在一个Dockerfile文件中可以出现多次
- `AS`可以为构建阶段命名，以便其他构建过程引用：`COPY --from=<name|index>`
- `tag` 和 `digest`是可选的，默认tag是latest

### ARG

20. 定义在`FROM`前面的`AGR`是在构建过程以外的，所以除了`FROM`以外的其他指令无法使用这些参数。如果需要在构建时使用`ARG`定义的值，可以在`FROM`后面加上没有值的`ARG`指令：

```dockerfile
ARG VERSION=latest
FROM busybox:$VERSION
ARG VERSION
RUN echo $VERSION > image_version
```

### RUN

21. `RUN`有两种使用形式：

- `RUN <command>`  shell形式，会被作为/bin/sh -c 的参数值执行
- `RUN ["executable", "param1", "param2"]` exec形式，这种模式可以让没有包含指定shell的基础镜像也能运行给定的脚本，参数会当作JSON数组来处理，所以必须使用双引号，并且包含`\`时需要转译。

22. 每一个`RUN`会生成一个新的镜像层供后续构建过程使用。

23. shell模式的命令，可以使用`\`来折行：

    ```dockerfile
    RUN /bin/bash -c 'source $HOME/.bashrc; \
    echo $HOME'

    # 等价
    RUN /bin/bash -c 'source $HOME/.bashrc; echo $HOME'
    ```

24. exec模式下指定shell可以这样写：`RUN ["/bin/bash", "-c", "echo hello"]`

### CMD

25. `CMD`有三种形式：

- `CMD ["executable","param1","param2"]` (推荐形式)
- `CMD ["param1","param2"]` ( 会作为`ENTRYPOINT`的默认参数 )
- `CMD command param1 param2`  shell形式

26. 一个Dockerfile中只能由一个`CMD`指令，如果有多条，只有最后一条会生效。
27. 如果`CMD`是作为`ENTRYPOINT`的默认参数使用，两者需要使用JSON数组格式

### Label

28. `Label`指令用来给镜像添加一些元信息，用键值对的形式表示，如果包含空格和换行可以使用引号和`\`。
29. 一个镜像可以包含多个`Label`， 也可以在一行包含多个label定义，空格分隔即可。
30. 使用命令行`docker inspect <image name>`可以查看镜像的Label等metadata信息。

### EXPOSE

```dockerfile
EXPOSE 80/tcp
EXPOSE 80/udp
```

31. `EXPOSE`可以指定容器运行时监听的（宿主机）网络端口，默认是TCP协议，也支持UDP。
32. `EXPOSE`作为镜像创建者和使用者之间沟通的一个文档，并没有真实生效。在容器启动时，如希望使用`EXPOSE`中定义的端口映射，需要制定 `-p`（指定部分）或`-P`（映射所有端口）参数。

```bash
$docker run -p 80:80/tcp -p 80:80/udp ...
# 可以用-p参数覆盖dockerfile中的EXPOSE定义，自定义部分端口
```

### ENV

```dockerfile
ENV <key> <value>
ENV <key>=<value> ...
```

33. 第一种形式，一行只能设置一个变量，空格后面的值会被当作value，第二种形式可以在一行定义多个环境变量值。

```dockerfile
ENV myName="John Doe" myDog=Rex\ The\ Dog \
    myCat=fluffy

ENV myName John Doe
ENV myDog Rex The Dog
ENV myCat fluffy

# 结果一样
```

### ADD

```dockerfile
ADD [--chown=<user>:<group>] <src>... <dest>
ADD [--chown=<user>:<group>] ["<src>",... "<dest>"]
```

34. `—chown`只在linux机器支持，不被windows支持
35. `ADD`会从`<src>`复制新文件、目录、或远程文件，将其作为容器中的`<dest>`路径。
36. 支持通配符：

```dockerfile
ADD hom* /mydir/        # adds all files starting with "hom"
ADD hom?.txt /mydir/    # ? is replaced with any single character, e.g., "home.txt"
```

37. `<dest>`是绝对路径或对`WORKDIR`的相对路径。
38. 只能`ADD`包含在context目录下的资源，因为build的第一步是传入context到守护行程中。
39. 如果src是个URL并且dest不是以`/`结尾的，下载后的文件会被存为dest
40. 如果src是个URL并且dest是以`/`结尾的，下载后的文件会被存为dest/[filename]；

41. 如果src是多个文件或目录，包括通配符匹配结果，那dest必须是路径，以`/`结尾。

42. 如果没有指定dest，会根据src路径创建。
43. src的路径如果是目录，所有目录内容会被复制，但不包含目录自身。

### COPY

```dockerfile
COPY [--chown=<user>:<group>] <src>... <dest>
COPY [--chown=<user>:<group>] ["<src>",... "<dest>"]
```

> 使用注意类比`ADD`

44. 和`ADD`的区别是，`ADD`支持从远程读取并复制资源，并且更加擅长读取本地tar文件并解压缩。

45. 事实上，当要读取URL远程资源的时候，并不推荐使用ADD指令，而是建议使用RUN指令，在RUN指令中执行wget或curl命令。

```dockerfile
RUN mkdir -p /usr/src/things \
    && curl -SL http://example.com/big.tar.xz \
    | tar -xJC /usr/src/things \
    && make -C /usr/src/things all
```

### ENTRYPOINT

```dockerfile
ENTRYPOINT ["executable", "param1", "param2"]
ENTRYPOINT command param1 param2
```

配置容器，让其执行一些可执行文件。

46. shell形式的用法时，CMD和命令行参数都会无效，并且命令会作为`/bin/sh -c`的子命令执行。这意味着你的可执行任务不会是pid=1的进程，容器stop时不会检测到`SIGTERM`信号。

### VOLUME

```dockerfile
VOLUME ["/data"]
VOLUME /var/log
```

[添加外部挂载点。](https://docs.docker.com/storage/volumes/)

47. 不能指定挂载点对应的路径，这样做为了保证可移植性

### WORKDIR

```dockerfile
WORKDIR /path/to/workdir
```

为`RUN`,`CMD`,`ENTRYPOINT`,`COPY`,`ADD`等指令设置工作路径

48. 如果指定的`WORKDIR`不存在，他会被创建，即使它在后续的指令中并未使用过。
49. `WORKDIR`可以多次使用，如果指定相对路径，则它是相对于前一个`WORKDIR`的路径。

### ARG

50. 使用build时使用命令行参数传入`--build-arg <varname>=<value>`的参数，支持多次使用。

```dockerfile
# 使用传入的参数
FROM busybox
ARG user1
ARG buildno
...
```

51. 不建议将敏感信息如github keys , secret keys等用此方法(`—-build-arg`)传递，因为这对于人和使用`docker history`命令的人都是可见的。

52. 可以为`ARG`指定默认值：

```dockerfile
FROM busybox
# 当构建时没有传入user1时默认为someuser
ARG user1=someuser
ARG buildno=1
...
```

53. `同名的ENV`始终会覆盖`ARG`的值

54. 内置的`ARG`，可以传入build-arg直接使用：

- HTTP_PROXY
- http_proxy
- HTTPS_PROXY
- https_proxy
- FTP_PROXY
- ftp_proxy
- NO_PROXY
- no_proxy

e.g.

```dockerfile
--build-arg HTTP_PROXY=http://user:pass@proxy.lon.example.com
```