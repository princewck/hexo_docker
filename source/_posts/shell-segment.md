---
title: Shell脚本：删除所有Docker中间镜像
date: 2020-03-06 22:50:59
tags: Docker Shell
category: 工程化和运维
thumbnail: /images/linux.jpeg
---

本脚本的功能是删除当前机器上所有`REPOSITORY`列为`<none>`的镜像，一般这种是我们构建镜像时留下的中间镜像，日积月累以后这些镜像会占据大量的磁盘空间，我们可以用此脚本一键清理：

> rm_all_blank_docker_images.sh
```shell
#!/usr/bin/env sh
a=0
docker images | awk '$1 == "<none>"{ print $3 }' | while read line
do
echo "准备删除：${line}"
docker rmi ${line}
let a=a+1
done
```
使用：`sh ./rm_all_blank_docker_images.sh`

这里主要需要了解`awk`的使用，以及逐行遍历的写法。
