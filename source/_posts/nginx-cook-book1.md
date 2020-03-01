---
title: 《Nginx Cookbook》读书笔记(上)
date: 2020-03-01 11:12:05
category: 运维技术
tags: Nginx
description: 《Nginx Cookbook》中文版
toc: true
thumbnail: /images/nginx.jpg
---

## web读书笔记：《 NGINX Cookbook》

### 一. 基础

[链接：NGINX Cookbook英文原本官方下载](https://www.nginx.com/resources/library/complete-nginx-cookbook/?utm_source=nginxorg&utm_medium=homepagebanner&utm_campaign=complete_cookbook&_ga=2.145469041.478574807.1582991384-151531481.1582597691)

Nginx 分为开源版本和商业版本Plus

相关推荐：[What’s the Difference between NGINX Open Source and NGINX Plus?](https://www.nginx.com/blog/whats-difference-nginx-foss-nginx-plus/)，我们这里主要记录开源版本的一些相关使用。

#### 安装：

##### RedHat / CentOS

创建文件 `/etc/yum.repos.d/nginx.repo`

```shell
[nginx]
name=nginx repo
baseurl=http://nginx.org/packages/mainline/OS/OSRELEASE/$basearch/
gpgcheck=0
enabled=1
```

> - 根据你的系统用rhel 或 centos替换上面链接中的 `OS`
> - 把`OSRELEASE`替换成需要安装的版本号 比如 6 或 7

然后运行下面命令：

```shell
yum -y install nginx
systemctl enable nginx
systemctl start nginx
firewall-cmd --permanent --zone=public --add-port=80/tcp
firewall-cmd --reload
```

上面命令从nginx官方源安装 nginx ，并且使用 systemd 设置了启动后自动开启 nginx 服务，然后立即手动启动了Nginx服务。`firewall`命令打开了TCP 协议 的80端口，这是 HTTP 的默认端口，最后一行命令reload了firewall 以使新配置生效。

##### 确认安装成功

```shell
$ nginx -v
```

查看 Nginx 进程，确定服务是否被启动

```bash
$ ps -ef | grep nginx
root 1738 1 0 19:54 ? 00:00:00 nginx: master process
nginx 1739 1738 0 19:54 ? 00:00:00 nginx: worker process
```

打开浏览器或者使用`curl`，访问localhost，可以看到 NGINX 的欢迎页面

```bash
$ curl localhost
```

#### 关键文件，命令和目录

###### 配置文件

- `/etc/nginx`： 默认的服务器配置路径

- `/etc/nginx/nginx.conf`： 默认的配置文件入口，这里设置了一些全局配置例如工作进程数，日志，动态加载的模块，也可以指定引用其他子配置文件。这个文件中包含了一个顶层的 `http` 模块，所有其他配置都将被包含在其中。

- `/etc/nginx/conf.d`：包含了默认的 http  服务器配置文件，这个路径下以 `.conf`结尾的文件都会被 include 进`nginx.conf`主入口文件中。我们进行服务器配置时，最佳实践是把配置按一定的规则（比如按域名或业务）拆分后放在此目录中管理，而不应该直接把 server配置全写到 `nginx.conf`这样做可以使配置更简洁清晰。

- `/var/log/nginx/`：默认的日志存储路径

> Mac OS 系统的配置路径是：`/usr/local/etc/nginx`，默认的`conf.d`路径也被`servers`替代。

###### 常用命令

```bash
$ nginx -h  # 显示帮助菜单
$ nginx -v  # 显示版本
$ nginx -V  # 显示版本信息，构建信息和配置信息，可以显示构建中包含了哪些模块
$ nginx -t  # 测试配置文件
$ nginx -T  # 测试配置并把通过校验的配置打印出来
$ nginx -s  # 给master进程发送信号，如： stop, quit, reload, reopen
```

> nginx -s stop 立即停止nginx 进程，quit 则是等当前处理中的请求结束后结束进程。

#### 静态资源服务

```nginx
server {
listen 80 default_server;
server_name www.example.com;
  location / { # / 表示匹配所有请求
  root /usr/share/nginx/html;
  # alias /usr/share/nginx/html;
  index index.html index.htm;
  }
}
```

`default_server` 指定该服务为 80 端口的默认服务，如果没有这个指令，那表明请求的 host 必须匹配 server_name 的域名才会被分发到此服务。

#### 优雅地重启服务

如何重新载入更新后的配置文件而不中断正在进行中的服务，避免丢包等情况呢？

答案是 使用 reload 方法：

```bash
$ nginx -s reload
```



### 二. 负载均衡 Load Balancing

> 负载均衡，服务集群，水平扩展（horizontal scaling），基础设施（infrastructure）

如今的互联网产品的用户体验依赖与产品的可用时间和服务性能。为实现这些目标，多个相同服务被部署在物理设备上构建称服务集群，并使用负载均衡实现请求分发；随着负载的增加，新的服务会被部署到到集群中；这种技术称之为**水平扩展**。

NGINX提供了**多种协议的负载均衡解决方案**如：HTTP、TCP 和 UDP 负载均衡。

常用的**负载均衡算法**如：轮询，最少连接数，最短响应时间，IP 哈希和普通哈希。这些负载均衡算法有助于您在项目中选择行之有效的请求分配策略。



- HTTP 负载均衡

> 使用 NGINX 的 HTTP 模块，将请求分发到有 upstream 块级指令代理的 HTTP服务器集群，实现负载均衡

```nginx
upstream backend {
  server 10.10.12.45:80 weight=1;
  server app.example.com:80 weight=2;
}
server {
  location / {
    proxy_pass http://backend;
  }
}
```

HTTP 模块的 upstream 用于设置被代理的 HTTP 服务器实现负载均衡。模块内定义一个目标服务器连接池，它可以是 UNIX 套接字、IP 地址、DNS 记录或它们的混合使用配置；此外 upstream 还可以通过 weight 参数配置，如何分发请求到应用服务器。

> - 所有 HTTP 服务器在 upstream 块级指令中由 server 指令配置完成
> - 可选参数能够精细化控制请求分发。它们包括
>   -  weight 参数：用于负载均衡算法；
>   -  max_fails 指令和 fail_timeout：判断目标服务器是否可用，及如何判断服务器可用性。
>   - NGINX Plus 版本提供了许多其他方便的参数，比如服务器的连接限制、高级DNS解析控制，以及在服务器启动后缓慢地连接到服务器的能力。



- TCP 负载均衡

> 在 NGINX 的 stream 模块内使用 upstream 块级指令实现多台 TCP 服务器负载均衡：

```nginx
stream {
  upstream mysql_read {
    server read1.example.com:3306 weight=5;
    server read2.example.com:3306;
    server 10.10.12.34:3306 backup;
  }
  server {
    listen 3306;
    proxy_pass mysql_read;
  }
}
```

`stream`模块和`http`模块类似，允许你定义一个服务的连接池，并配置其中监听的服务器。

- UDP 负载均衡

```nginx
stream {
  upstream ntp {
    server ntp1.example.com:123 weight=2;
    server ntp2.example.com:123;
  }
  server {
  	listen 123 udp;
	  proxy_pass ntp;
  }
}
```



##### 负载均衡算法

对于负载压力不均匀的应用服务器或服务器连接池，轮询(round-robin)负载均衡算法无法满足业务需求。

解决办法是使用 NGINX 提供的其它负载均衡算法，如：最少连接数(least connections)、最短响应时间(leaest time)、通用散列算法(generic hash)或 IP 散列算法(IP hash)：

```nginx
upstream backend {
  least_conn;
  server backend.example.com;
  server backend1.example.com;
}
```

>  如上面示例，所有负载均衡算法指令，除了通用算法指令外，都是一个普通指令，需要单独占一行配置。

在负载均衡中，并非所有的请求和数据包请求都具有相同的权重。有鉴于此，如上例所示的轮询或带有权重的轮询负载均衡算法，可能并不能满足我们的应用或负载需求。NGINX 提供了一系列的负载均衡算法，以满足不同的运用场景。所有提供的负载均衡算法都可以针对业务场景随意选择和配置，并且都可以应用于 upstream 块级指令中的 HTTP、TCP 和 UDP 负载均衡服务器连接池。

- **轮询负载均衡算法(Round robin)**： 没有明确指定负载均衡算法时作为 nginx 默认的负载均衡算法，可以为服务器指定分发权重。
- **最少连接数负载均衡算法(Least connections)**：它会将访问请求分发到upstream 所代理的应用服务器中，当前打开连接数最少的应用服务器实现负载均衡。指令：`least_conn`

- **最短响应时间负载均衡算法(least time)**：将请求分发给平均响应时间更短的应用服务器。。它是负载均衡算法最复杂的算法之一，能够适用于需要高性能的 Web 服务器负载均衡的业务场景。该算法是对最少连接数负载均衡算法的优化实现，因为最少的访问连接并非意味着更快的响应。指令：`least_time`
- **通用散列负载均衡算法(Generic hash)**：服务器管理员依据请求或运行时提供的文本、变量或文本和变量的组合来生成散列值。通过生成的散列值决定使用哪一台被代理的应用服务器，并将请求分发给它。在需要对访问请求进行负载可控，或将访问请求负载到已经有数据缓存的应用服务器的业务场景下，该算法会非常有用。指令：`hash`
- **IP 散列负载均衡算法(IP hash)**：该算法仅支持 HTTP 协议，它通过计算客户端的 IP 地址来生成散列值。这对需要存储使用会话，而又没有使用共享内存存储会话的应用服务来说，能够保证同一个客户端请求，在应用服务可用的情况下，永远被负载到同一台应用服务器上。该指令同样提供了权重参数选项。该指令的配置名称是 `ip_hash`。
- **随机数算法**：指定随机选择一台服务器，指令是`random`。还可以使用可选配置 `two [method]`，其中 method默认是 `least_conn`，这个配置表明需要随机选择两台服务器，并在这两台中再使用 method指定的lb算法。

##### Sticky Cookie

问题：集群模式下如何使下游的客户端固定访问同一台服务呢（NGINX Plus版本）？

解决办法是使用 `sticky cookie`配置：

```nginx
upstream backend {
  server backend1.example.com;
  server backend2.example.com;
  sticky cookie
  affinity
  expires=1h
  domain=.example.com
  httponly
  secure
  path=/;
}
```

上面配置通过创建一个名为`affinity`的配置并跟踪它来实现将同一台客户机的请求始终路由到集群中同一服务上的功能，上面其他配置制定了 cookie 的一些属性， `secure`表示只在 https 下使用。配置完后，客户端在第一次请求时会创建一个包含上有具体服务标识的 cookie，使用它将后续请求路由到同一服务。

>  关于NGINX Plus版本的配置不再继续展开

对于开源版本如果想用sticky实现会话保持，可以自己定制化编译，加入nginx-sticky-module模块。

> 相关推荐： [nginx会话保持之sticky模块](https://www.cnblogs.com/tssc/p/7481885.html)

##### Passive Health Checks 被动健康检查

**健康检查**：保证只有正常工作的 upstream servers 才会被使用

开源版本只支持被动的，主动（active）健康检查在商业版中支持。

被动健康检查是在错误出现后请求先抵达出错的服务器，再转发给其他正常服务器。而主动则是nginx主动去ping后端服务器，发现错误主动将其从集群中移除。

>  主动和被动的区别：https://www.cnblogs.com/linyouyi/p/11502282.html

```nginx
upstream backend {
  server backend1.example.com:1234 max_fails=3 fail_timeout=3s;
  server backend2.example.com:1234 max_fails=3 fail_timeout=3s;
}
```

上面配置可以被动地监控 upstream中服务器的健康状况。在以3s为周期的时间内，同一服务器出现三次请求错误则标记为不可用，本周期内不再接受新的请求，本周期结束后重复上述过程。

>  被动检查默认处于开启状态，默认：fail_timeout为10s, max_fails为1次。

#####  Active Health Checks 主动健康检查

开源版没有集成该功能，商业版配置示例：

```nginx
http {
	server {
		...
    location / {
      proxy_pass http://backend;
      health_check interval=2s
      fails=2
      passes=5
      uri=/
      match=welcome;
    }
  }
  # status is 200, content type is "text/html",
  # and body contains "Welcome to nginx!"
  match welcome {
    status 200;
    header Content-Type = text/html;
    body ~ "Welcome to nginx!";
  }
}
```

开源版本可以安装第三方模块来实现：

[Nginx 增加主动检查健康机制](https://help.finereport.com/doc-view-2911.html)

##### Slow Start

`server`指令的`slow_start`参数可以达到逐渐增加某个服务的连接数的功能，一般用在从故障恢复或新添加进upstream连接池的服务，`Slow start`让应用可以缓慢预热，有机会迁移缓存，初始化数据库等，防止其被突然增加的大量连接压垮。



### 三. 流量管理

> A/B Test ，灰度，连接数限制，请求频率限制，带宽限制，地域限制

Nginx 也是一个web流量控制工具。你可以使用Nginx提供的一些属性去智能地路由和控制流量的分发。这个部分会涉及如何按百分比分割流量，使用客户端的地理位置并按比例去控制流量、连接数和带宽。使用这些特性可以给你的服务带来更多可能。

#### A/B Testing&灰度发布

使用`split_client`模块可以把请求按比例分割：

```nginx
split_clients "${remote_addr}AAA" $variant {
  20.0% "backendv2";
  50.0% "backendv3";
  * "backendv1";
}
```

解释：IP地址加上AAA字符串会使用MurmurHash2转换成数字。得出的数字在前20%，那么$variant值为backendv2，相应的在20.0 - 50%区间的值为backendv3，剩下的为 backendv1。

> backendv1, backendv2, backendv3 代表三个不同的upstream pool

我们可以在将其作为 `proxy_pass`指令的值：

```nginx
location / {
	proxy_pass http://$variant;
}
```

> [文档：Module ngx_http_split_clients_module](http://nginx.org/en/docs/http/ngx_http_split_clients_module.html)
>
> [nginx实现A/B测试](http://www.ttlsa.com/nginx/nginx-ngx_http_split_clients_module/)
>
> [nginx实现简单的A-B测试（灰度发布）](https://blog.csdn.net/iteye_19607/article/details/82672330)

#### GeoIP 模块

记录或者规定客户端的地理位置。

> 再此不做详细展开：https://www.jianshu.com/p/97cc453e61ab



#### 根据国家限制访问

```nginx
load_module "/usr/lib64/nginx/modules/ngx_http_geoip_module.so";

http {
  map $geoip_country_code $country_access {
    "US" 0;
    "RU" 0;
    default 1;
  }
}

server {
  if ($country_access = '1') {
	  return 403;
  }
}

```

> [NGINX的ngx_http_geoip2模块以精准禁止特定国家或者地区IP访问](https://www.cnblogs.com/nsh123/p/11626651.html)



#### 连接数限制

> [ngx_http_limit_conn_module](http://nginx.org/en/docs/http/ngx_http_limit_conn_module.html)

```nginx
http {
  limit_conn_zone $binary_remote_addr zone=limitbyaddr:10m;
  limit_conn_status 429;
  ...
  server {
    ...
    limit_conn limitbyaddr 40;
    ...
  }
}
```

[nginx配置limit_conn_zone来限制并发连接数以及下载带宽](https://blog.csdn.net/plunger2011/article/details/37812843)

#### 请求频率限制

根据某个key（比如客户端的ip）来限制其请求的频率

```nginx
http {
limit_req_zone $binary_remote_addr zone=limitbyaddr:10m rate=1r/s;
limit_req_status 429;
...
  server {
    ...
    limit_req zone=limitbyaddr burst=10 nodelay;
    ...
  }
}
```

上面例子创建一个大小为10兆名为limitbyaddr的共享内存空间，以二进制ip为key。limit_req指令第一个参数为zone为必须参数，burst 和 nodelay为可选，burst默认值为 0。

limit_req_status 默认值为 503

limit_req_zone 只能放在 http 模块下，limit_req 可以在 http , server , location 模块下使用。

> [nginx的limit_req_zone使用](https://blog.csdn.net/shuixiou1/article/details/80165525)

使用适当的请求频率限制可以防止客户端恶意频繁请求，保护服务稳定运行。

#### 限制带宽

使用 `limit_rate` 和 `limit_rate_after`可以限制某个客户端的下载带宽。

```nginx
location /download/ {
  limit_rate_after 10m;
  limit_rate 1m;
}
```

上面例子将前缀为`/download`的请求进行限速，当传输超过 10 M 以后以 1M/s对该连接限速。因为限速是针对连接的，所以要做进一步限制的话可以加上连接数限制一起使用。



### 四. 内容缓存

> 缓存，内容分发网络，CDN，前端缓存，绕过缓存，缓存清理，缓存文件分割

缓存就是通过储存请求结果以供后续再次使用的技术，它提高了内容分发的速度。它减轻了上游服务的负载，只需要给客户端返回缓存的完整请求结果而不用再发请求通过计算获取结果。根据策略在特定的地域部署缓存服务器对用户端的访问体验有着极大的提升。使用离用户最近的服务器给客户提供内容是一种对性能的优化，这种模式成为内容分发网络（CDN）。使用 Nginx 你可以在任何你能够架设服务器的地方缓存资源，构建属于你自己的内容分发网络。

#### 缓存空间

问题：怎么控制缓存内容和指定内容缓存的位置呢？

解决：使用`proxy_cache_path`指令指定一块共享的空间存储缓存内容：

```nginx
proxy_cache_path /var/nginx/cache
keys_zone=CACHE:60m
levels=1:2
inactive=3h
max_size=20g;
proxy_cache CACHE;
```

以上配置创建了一个目录放置缓存的请求结果，并且在内存中开辟了一块名为 CACHE的缓存区域。这个例子设置了缓存的路径结构，定义了缓存3小时未被使用则自动释放掉，并且定义了缓存文件最大为 20GB。`proxy_cache` 定义指定的上下文使用缓存空间。

> proxy_cache_path 可以在 HTTP 模块使用
>
> proxy_cache 可以在 HTTP , server 和 location 模块中使用



#### 缓存的 key

`proxy_cache_key`指定一个key来决定如何判断是否命中缓存，以及控制请求如何被缓存：

```nginx
proxy_cache_key "$host$request_uri $cookie_user";
```

> $cookie_user 中的user是指 cookie 中含有一个名为 user 的cookie，使用它做 key
>
> https://blog.csdn.net/jelope/article/details/12885707

`proxy_cache_key`的默认值是`$scheme$proxy_host$request_uri`，这个key 包含了协议（HTTP/HTTPS）、代理host，请求地址等信息对于大部分用户来说都是适用的。

选择一个合适的key规则很重要，我们可以根据具体的应用来定制化。对于静态资源，一般比较直接使用host和URI做key即可，对于动态资源，我们需要考虑更多，我们可以使用例如请求参数，headers，session 标识等等来制定特殊的key ，因为处于安全考虑我们可能不希望不同用户共享同一份缓存内容。

> proxy_cache_key 可以在 HTTP, server 和 location 模块使用

> [http://nginx.org/en/docs/varindex.html](http://nginx.org/en/docs/varindex.html)

####  Cache Bypass 绕过缓存

我们可以设置指定的请求不使用缓存规则，这个指令就是 `proxy_cache_bypass`

绕过请求的方法是给这个指令传递非 0 值，它的一种使用方法是在不想使用缓存的 location 模块使用这个指令并将它的值设置为 1，也可以通过在特定上下文使用 `proxy_cache off;`彻底关闭缓存功能；

```nginx
proxy_cache_bypass $http_cache_bypass;
```

上面的设置代表 Nginx 会判断 Http Header 中名为 cache_bypass 的值，如果值不是 0 则绕过缓存。

#### 提高缓存性能

这里主要指如何在客户端设置缓存机制来提高性能。

``` nginx
location ~* \.(css|js)$ {
  expires 1y;
  add_header Cache-Control "public";
}
```

这里主要指给响应添加缓存相关的 Headers ，参考我们熟悉的 HTTP 缓存机制，这里不再赘述，不清楚的朋友可以google 一下。

####  缓存清除

这里书中列举了商业版的例子，开源版可以通过安装第三方模块来实现

[nginx安装第三方ngx_cache_purge模块，purge命令清除静态缓存](https://blog.csdn.net/lzxlfly/article/details/77885302)

#### 缓存文件分割

```nginx
proxy_cache_path /tmp/mycache keys_zone=mycache:10m;
server {
  ...
  proxy_cache mycache;
  slice 1m;
  proxy_cache_key $host$uri$is_args$args$slice_range;
  proxy_set_header Range $slice_range;
  proxy_http_version 1.1;
  proxy_cache_valid 200 206 1h;
  location / {
  	proxy_pass http://origin:80;
  }
}
```

将缓存文件分割为 1M 大小的片段中，分割是根据 `proxy_cache_key`来进行的，Cache Slice 功能是为 H5 video 而设计的，前端视频加载时会使用`byte-range`流式地请求资源（状态码 206）。

>  [Smart and Efficient Byte-Range Caching with NGINX & NGINX Plus](https://www.nginx.com/blog/smart-efficient-byte-range-caching-nginx/)
