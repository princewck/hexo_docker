---
title: 《Nginx Cookbook》中文版
date: 2020-03-16 01:18:05
category: 运维技术
tags: Nginx
description: 《Nginx Cookbook》中文版
toc: true
thumbnail: /images/nginx.jpg
---

### 一. 基础

[链接：NGINX Cookbook英文原本官方下载](https://www.nginx.com/resources/library/complete-nginx-cookbook/?utm_source=nginxorg&utm_medium=homepagebanner&utm_campaign=complete_cookbook&_ga=2.145469041.478574807.1582991384-151531481.1582597691)

Nginx 分为开源版本和商业版本Plus

相关推荐：[What’s the Difference between NGINX Open Source and NGINX Plus?](https://www.nginx.com/blog/whats-difference-nginx-foss-nginx-plus/)，我们这里主要摘录了部分开源版本的一些相关使用。

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



### 五. 身份认证(Authentication)

使用Nginx可以对客户端进行访问认证，使用Nginx对客户端进行认证减少了开发的负担，并且可以在请求到达业务服务之前对请求进行认证。NGINX开源版本可用的模块中包含了Basic Authentication 和 Authentication subrequests，商业版还提供了支持JWT的认证模块。

#### HTTP Basic Authentication

如何使用 Nginx 进行基本的 http 用户访问认证呢？

首先按照下面形式创建一个文件，其中密码部分按照后面方式加密：

```nginx
# comment
name1:password1
name2:password2:comment
name3:password3
```

第一个字段是用户名，第二个字段是密码，第三个是备注，备注是可选字段，字段之间用冒号分隔。NGINX可以识别多种不同形式的密码，其中一种是C语言中的 `crypt()`方法的调用结果，这个方法可以通过命令行`openssl passwd` 来进行调用，我们可以像下面这样创建一个密码。

```nginx
$ openssl passwd mypassword1234
```

编写完配置我们可以使用NGINX提供的 `auth_basic` 额 `auth_basic_user_file`来进行请求认证：

```nginx
location / {
  auth_basic "private site";
  auth_basic_user_file ./passwd;
}
```

`auth_basic`  可以使用在 HTTP , location 上下文中，`auth_basic` 接受一个字符串作为参数，当一个用户没用认证时，浏览器会在popup弹窗中显示该文字，`auth_basic_user_file` 指定了一个配置文件的路径。

> 除了上面的 openssl 工具，还可以使用 Apache 的 htpasswd命令来生成密码

在浏览器中用户输入用户名和密码后，浏览器仅仅是对输入内容进行了base64编码，然后以`Authorization: Base [encodedSTRING]`这样的形式提交给服务器进行校验，所以使用basic authentication 时建议使用HTTPS以防止敏感信息的泄漏。

#### Authentication Subrequests

> nginx向第三方认证服务发送子请求进行认证后决定是否提供访问

使用 `http_auth_request_module` 可以在提供服务前，项指定认证服务发送请求获取认证结果。示例：

```nginx
location /private/ {
  auth_request /auth;
  auth_request_set $auth_status $upstream_status;
}

location /auth {
  internal;
  proxy_pass http://auth-server;
  proxy_pass_request_body off;
  proxy_set_header: Content-Length "";
  proxy_set_header: X-Origin-URI $requet_uri;
}
```

`auth_request`指令的参数必须是一个本地的内部请求地址，通过`auth_request_set`指令可以设置一些变量。

自请求返回的状态码将会作为客户端是否具有访问权限的依据，如果状态码为 200 代表认证成功，请求将被正常继续，如果状态码返回 `401`或者`401`，NGINX将会直接把该状态码发回给原始请求。

如果认证服务不需要接受请求体，可以通过上面例子一样使用`proxy_pass_request_body`指令在子请求认证时丢弃请求体，这样可以减小请求大小并缩短响应时间，在丢弃请求体的同时，我们要将`Content-Length`的值设置为空。如果我们的认证服务想要知道原始请求的更多信息，可以通过`auth_request_set`指令设置额外Headers带一些变量传递给子请求。



Nginx商业版还支持其他认证方式，如 JWT等，这里不做介绍。



### 六. 安全控制

安全在访问的不同层级都需要被考虑，一个坚实的安全模型必须建立在多层次的安全控制之上。这个部分我们将介绍一些NGINX中提供的可以帮助提高应用安全性的特性。

#### 基于IP地址的访问控制

```nginx
location /admin/ {
  deny 10.0.0.1;
  allow 10.0.0.0/20;
  allow 2001:0db8::/32;
  deny: all;
}
```

上面的配置允许 IPv4 地址 `10.0.0.0/20` 访问，并排出`10.0.0.1`，允许 IPV6 `2001:0db8::/32` 子网下的IPv6地址访问，对其他IP地址则会返回 `403`状态码。

`allow`和 `deny`指令可以在 HTTP ， server， location 上下文中使用，设定的多条规则将会从上到下依次匹配，直到找到匹配的项。

通常情况下，当我们需要保护一个资源禁止其被外部访问时，我们可以在一组 `allow` 中配置允许的内部 IP 地址，然后在后面加上 `deny: all`；

#### 允许 CORS访问

> 缩写CORS代表的是：Cross-Origin Resource Sharing 跨域资源共享

由于浏览器的同源限制，网站一般是不允许直接访问其他域名下的资源的，允许跨域资源访问，可以解除这个限制，让不同域名的网站访问我们的资源。

下面的配置，根据不同的请求方法来返回不同的请求头来支持 CORS：

```nginx
map $request_method $cors_method {
  OPTIONS 11;
  GET 1;
  default 0;
}

server {
  #...

  location / {
    if ($cors_method ~ '1') {
      add_header 'Access-Control-Allow-Methods' 'GET,POST,OPTIONS';
      add_header 'Access-Control-Allow-Origin' '*.example.com';
      add_header 'Access-Control-Allow-Headers'
        				 'DNT,Keep-Alive,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type';
    }
    if ($cors_method = '11') {
      add_header 'Access-Control-Max-Age' 1728000;
      add_header 'Content-Type' 'text/plain; charset=UTF-8';
      add_header 'Content-Length' 0;
      return 204;
    }
  }
}
```

上面配置中配置了`Access-Control-Max-Age`设置预检OPTIONS请求的最大缓存时间为 1728000 秒，也就是20天，在此期间默认允许某个客户端进行跨域请求而不重新发送OPTIONS请求。

> 如果一个请求是 `GET`，`HEAD`或`POST`请求，我们称之为简单请求，对于简单请求且没有包含一些额外的Headers，将不会发送 `OPTIONS`请求而直接检查 Origin，其他情况下浏览器将会在首次请求跨域资源时预先发送一个 OPTIONS请求来检查服务端对跨域访问的支持情况。



#### 客户端加密

利用SSL模块我们可以对访问进行加密，常见的SSL模块有 `ngx_http_ssl_module`，`ngx_stream_ssl_module`等。

```nginx
http { # All directives used below are also valid in stream
  server {
    listen 8443 ssl;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_certificate /etc/nginx/ssl/example.pem;
    ssl_certificate_key /etc/nginx/ssl/example.key;
    ssl_certificate /etc/nginx/ssl/example.ecdsa.crt;
    ssl_certificate_key /etc/nginx/ssl/example.ecdsa.key;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;
  }
}
```

上面配置设置了一个监听 8443端口通过SSL加密的服务器。`ssl_protocols TLSv1.2 TLSv1.3;`代表加密协议使用的版本。

目前 SSL 已经被认为是不安全的来，TLS 协议是更推荐的选择。NGINX 使我们的服务和最终客户之间的传输变得更加安全。关于客户端加密的更多细节，在这里不做更多的深入，有兴趣可以找一些深入的资料来单独研究。

> [Test Your SSL Configuration with SSL Labs SSL Test](https://www.ssllabs.com/ssltest/)
>
> [https://ssl-config.mozilla.org/](https://ssl-config.mozilla.org/)

#### 和上游服务器间的加密

当我们需要和我们上游的服务提供者之间进行加密通信时，我们可以使用 proxy 模块的一些ssl相关指令来配置SSL规则：

```nginx
location / {
  proxy_pass https://upstream.example.com;
  proxy_ssl_verify on;
  proxy_ssl_verify_depth 2;
  proxy_ssl_protocols TLSv1.2;
}
```

> 这一块笔者没有实践过，就不多介绍了，后面再做补充



#### HTTPS Redirects

把所有http请求重定向到 HTTPS：

```nginx
server {
  listen 80 default_server;
  listen [::]:80 default_server;
  server_name _;
  return 301 https://$host$request_uri;
}
```

正确配置 http 到 https的重定向是非常必要的，我们不需要重定向所有的请求，但是一些含有敏感信息的请求则必须做这样的重定向才能保证数据传输的安全性，例如登录接口`/login`等。



#### HTTP Strict Transport Security

通过设置请求头告诉浏览器，"永远不要使用HTTP发送请求"。

```nginx
add_header Strict-Transport-Security max-age=31536000;
```

通过设置 请求头`Strict-Transport-Security`可以告知浏览器，在给定的时间里不能使用 HTTP 发送请求，这样我们可以进一步增强网站的安全性。



#### 设置可选择的多种访问获取方式

>Satisfying Any Number of Security Methods

直接看例子：

```nginx
location / {
  satisfy any;
  allow 192.168.1.0/24;
  deny all;
  auth_basic "closed site";
  auth_basic_user_file conf/htpasswd;
}
```

这里介绍的是 `satisfy`这个指令，`satisfy any`告诉NGINX，只要满足下面提供的任意一种情况，就可以正常请求资源。比如上面例子中只要满足 IP 符合 `192.168.1.0/24`或者提供指定的 basic auth 用户名密码就可以正常请求location为 `/` 开头的资源。

类似地，设置 `satisfy: all`，则代表必须同时满足后面的所有条件才可以获得资源的访问权限。



### 七. HTTP/2

HTTP/2是对HTTP协议的主要修订。这个版本大部分的工作是集中在传输层,如使完整的请求和响应在一个TCP连接多路复用。通过HTTP报头的压缩性能获得了很大提升,并增加了请求优先级的定义。HTTP/2新增的另一个大的特性是支持服务端向客户端推送消息。下面会介绍一些基本的配置方法，例如如何用 NGINX 支持 HTTP/2和gRPC和消息推送的配置。

#### 基本设置：让服务器支持 HTTP/2

```nginx
server {
	listen 443 ssl http2 default_server;
	ssl_certificate server.crt;
	ssl_certificate_key server.key;
}
```

只需要在 listen 指令添加 `http2`参数就可以开启 http2了，值得一提的是，虽然协议没有规定使用HTTP/2必须使用HTTPS，但是一些客户端实现仅支持在HTTPS网站中使用HTTP/2。另一个问题是，HTTP/2规范将部分 `TLS 1.2`列入了黑名单，如果使用了这些加密方式请求就会握手失败，Nginx 使用的默认加密方案不在黑名单中。配置完后如果想检查配置是否正确，可以在Chrome中安装一些可以提示当前网站是否使用HTTP/2的插件，或者使用命令行工具 `nghttp`进行测试。

> [HTTP/2 RFC Blacklisted Ciphers](https://tools.ietf.org/html/rfc7540#appendix-A)
>
> [Chrome HTTP2 and SPDY Indicator Plugin](https://chrome.google.com/webstore/detail/http2-and-spdy-indicator/mpbpobfflnpcgagjijhmgnchggcjblin)
>
> [Firefox HTTP2 Indicator Add-on](https://addons.mozilla.org/en-US/firefox/addon/http2-indicator/)



#### HTTP/2 服务端消息推送

服务器主动推送消息给客户端

```nginx
server {
  listen 443 ssl http2 default_server;
  ssl_certificate server.crt;
  ssl_certificate_key server.key;
  root /usr/share/nginx/html;

  location = /demo.html {
    http2_push /style.css;
    http2_push /image1.jpg;
  }
}
```

### 八. 容器化和微服务

容器化技术在应用层实现了一种抽象，把应用依赖和环境的安装从部署阶段转移到了构建阶段。这是一种重要的技术革命，它可以让工程师们不再需要考虑程序运行的环境，以一种统一的方式去部署程序。NGINX 对容器化提供了跟好的支持。

#### 使用官方 NGINX 镜像

我么可以从 Docker Hub 上获取到 NGINX 官方镜像，快速地获得 NGINX 提供的服务。

官方镜像包含了一些默认配置，想要修改这些配置有两种方法：

- 使用volume 将本地自定义的配置文件路径挂载到容器中
- 创建一个 Dockerfile 用 `ADD` 将本地配置文件添加到自定义的镜像中

```bash
$ docker run --name my-nginx -p 80:80 \
	-v /path/to/content:/usr/share/nginx/html:ro -d nginx
```

上面命令将本地路径`/path/to/content`作为volume 挂载到容器中 `/user/share/nginx/html`并设置为只读（`ro`） ，只需一行命令就可以在容器中启动并运行一个 Nginx 服务器。



#### 创建NGINX Dockerfile

使用任何提供商的docker镜像，使用 `RUN` 命令安装 NGINX，使用 `ADD ` 命令添加 NGINX 配置文件，使用 `EXPOSE` 命令暴露指定的端口到容器外，使用 `CMD` 命令启动 NGINX。我们需要在前台运行NGINX，为了做到这一点我们可以在命令行添加 -g "daemon off;" 或者 在配置文件中添加 `daemon off` 配置。

```dockerfile
FROM centos:7

# Install epel repo to get nginx and install nginx
RUN yum -y install epel-release && \
yum -y install nginx

# add local configuration files into the image
ADD /nginx-conf /etc/nginx

EXPOSE 80 443

CMD ["nginx"]
```

文件结构如下：

```shell
.
├── Dockerfile
└── nginx-conf
├── conf.d
│ └── default.conf # 配置文件中已经添加了 daemon off 配置
├── fastcgi.conf
├── fastcgi_params
├── koi-utf
├── koi-win
├── mime.types
├── nginx.conf
├── scgi_params
├── uwsgi_params
└── win-utf
```

#### 使用环境变量

在NGINX配置文件中引入环境变量，这样我们就可以在不同环境中使用同一个镜像了。

我们可以通过 `ngx_http_perl_module` 模块来在 NGINX 中使用环境变量来设置自定义变量：

```nginx
daemon off;
env APP_DNS;

include /usr/share/nginx/modules/*.conf;
#...
http {
  perl_set $upstream_app 'sub { return $ENV{"APP_DNS"}; }';
  server {
    ...
    location / {
      proxy_pass https://$upstream_app;
    }
  }
}
```

> 安装 `ngx_http_perl_module`模块后才可以使用 `perl_set` 指令，可以使用时额外安装该模块或者从源代码构建并包含该模块

下面例子我们系统的使用包管理工具动态安装了`ngx_http_perl_module`模块，我们安装的模块在 CentOS 系统下会被放置在 `/usr/lib64/nginx/modules/`路径下

```dockerfile
FROM centos:7

# Install epel repo to get nginx and install nginx
RUN yum -y install epel-release && \
	yum -y install nginx nginx-mod-http-perl

# add local configuration files into the image
ADD /nginx-conf /etc/nginx

EXPOSE 80 443

CMD ["nginx"]
```

####  Kubernetes Ingress Controller

> 暂时不熟，后面补充



### 九. 日志

#### 配置Access Log

设置 access_log 的格式：

```nginx
http {
  log_format geoproxy
  '[$time_local] $remote_addr '
  '$realip_remote_addr $remote_user '
  '$request_method $server_protocol '
  '$scheme $server_name $uri $status '
  '$request_time $body_bytes_sent '
  '$geoip_city_country_code3 $geoip_region '
  '"$geoip_city" $http_x_forwarded_for '
  '$upstream_status $upstream_response_time '
  '"$http_referer" "$http_user_agent"';
	#...
}
```

这个日志格式被命名为 geoproxy ，它使用了许多内置的变量来展示NGINX的日志能力。

- $time_local：请求时的服务器时间
- $remote_addr：使用连接的IP地址
- $realip_remote_addr：客户端的 IP ， geoip_proxy 或 realip_header 指令识别的 IP
- $remote_user： Basic auth 的用户名
- $request_method： 请求方法
- $request_method：使用的协议，如 HTTP/1.1
- $scheme : HTTP 或 HTTPS
- $request_time： 请求处理时间（毫秒）
-  $body_bytes_sent：发送给客户端的响应体大小
-  $http_x_forwarded_for：请求是否是由其他代理转发过来的
- $upstream_status：返回的状态码

`log_format` 指令只能在 HTTP 上下文中使用，上面的日志格式打印出的日志会像下面的形式：

```bash
[25/Nov/2016:16:20:42 +0000] 10.0.1.16 192.168.0.122 Derek
GET HTTP/1.1 http www.example.com / 200 0.001 370 USA MI
"Ann Arbor" - 200 0.001 "-" "curl/7.47.0"
```

我们可以使用 `access_log` 来使用上面定义的日志格式：

```nginx
server {
	access_log /var/log/nginx/access.log geoproxy;
}
```

#### 错误日志

使用 `error_log` 指令可以定义日志路径和日志等级：

```nginx
error_log /var/log/nginx/error.log warn;
```

上面的 warn 代表日志的等级，是一个可选参数。这个指令可以在所有除了 `if` 语句的上下文中使用。

> 可用的日志等级有：`debug`， `info`，`notice`， `warn`，`error`， `crit`，`alert`，`emerg`。
>
> 其中 debug 级别的日志只有在运行时添加 `--with-debug` 这个 flag 时才可以使用。
