---
title: SSH 使用技巧
date: 2020-04-11 10:51:40
tags: 技术见闻
thumbnail: /images/symmetric-encryption-ssh-tutorial.jpg
---

一些使用的 ssh 使用技巧：

### 使用ssh config 文件快速连接远程系统

如果你经常使用 ssh 连接不同远程系统，记住所有的IP地址和用户名密码基本是不可能的，你可能把它们记录在你的备忘录中，每次使用时去 Ctrl + C => Ctrl + V 。我们可以在 bash 配置里设置 alias 来简化操作 ，但是还有更优雅更简单的方式来解决这个问题，通过 ssh config 文件来存储和使用我们的账号。

> 这里假设使用的是 linux 或 MacOS 系统

ssh config 文件的路径是 `~/.ssh/config`，默认情况下它可能不存在，不存在就创建一个

```bash
$ mkdir -p ~/.ssh && chmod 700 ~/.ssh
$ touch ~/.ssh/config
```

我们需要设置配置不能被其他用户组读取

```bash
$ chmod 600 ~/.ssh/config
```

然后把我们的配置按照如下格式设置到config文件中并保存：

```bash
Host hostname1
    SSH_OPTION value
    SSH_OPTION value

Host hostname2
    SSH_OPTION value

Host *
    SSH_OPTION value
```

> 这里的缩进只是为了美观，并不是必须的
>
> 最后的通配符 * 表示对所有 Host 使用该配置

下面是配置用户名密码的例子：

```bash
Host server1
    HostName        101.200.152.168
    Port            22
    User            root
    #IdentityFile    密钥文件的路径
Host server2
		HostName 				101.200.152.168
		Port 22
		User root
```

 `server 2` 我们没有设置认证方式，默认会通过 key 来认证，只需要把我们本机的公钥加入到远程系统的authorized_keys中，例如我们连接的是一个 CentOS 实例，把本机的 `~/.ssh/id_rsa.pub`内容保存在服务端`~/.ssh/authorized_keys`文件中，没有设置key的服务会需要提供username和password。

> 没有设置IdentityFile时，默认会从以下这些位置读取： *~/.ssh/id_dsa*, *~/.ssh/id_ecdsa*, *~/.ssh/id_ecdsa_sk*, *~/.ssh/id_ed25519*, *~/.ssh/id_ed25519_sk* and *~/.ssh/id_rsa*. 

配置完成后，我们可以像下面这样快速连接：

```bash
$ ssh server2
```

最后所有可用的 ssh config 可以[在这里查看](https://man.openbsd.org/OpenBSD-current/man5/ssh_config.5)

### 

###ssh连接超时

一段时间没有操作时，ssh连接会超时并报` Broken pipe`，主要有以下三种方法来解决：

1. 修改server的/etc/ssh/sshd_config，添加下面两个选项：
   ClientAliveInterval 60 //server每隔60秒发送一次请求给client，然后client响应，从而保持连接
   ClientAliveCountMax 3 //server发出请求后，client没有响应次数达到3，就自动断开连接，一般client会响应。

2. 修改client的/etc/ssh/ssh_config，添加下面两个选项：
   ServerAliveInterval 60 //client每隔60秒发送一次请求给server
   ServerAliveCountMax 3 //client发出请求后，server没有响应次数达到3，就自动断开连接，一般server会响应。

3. 在连接时加上下面参数：
   在命令参数里ssh -o ServerAliveInterval=60 这样会在连接中保持持久连接。



### 连接并执行脚本

常用在 shell 脚本中，比如我们需要ssh连接到远程机器并执行指定命令后回到本机执行其他指令，直接把要执行的命令当参数传给 ssh命令:
```bash
$ssh server1 "df -hl" | awk '$1=="/dev/vda1" { print $0 }'
#结果： /dev/vda1        40G   12G   26G   31% /
```

> 引号里可以执行多条命令，如：`ssh chongchong "uptime && df -h"`



更多技巧待后续补充...



#### 参考

>https://blog.csdn.net/yunlilang/java/article/details/82735582
>
>https://linuxize.com/post/using-the-ssh-config-file/
>
>https://baijiahao.baidu.com/s?id=1653420739012462627&wfr=spider&for=pc