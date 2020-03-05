---
title: 利用 Docker 多阶段搞定前端构建和部署
date: 2020-03-05 22:26:10
tags: 前端工程化
category: 前端工程化
thumbnail: /images/docker.jpeg
---

多阶段构建是 Docker 17.05开始加入的一个新特性，它是一个很有用的功能，特别适合那些有强迫症，希望更加极致地提高项目的可读性和可维护性的人。

### 背景

过大的image占用更多的磁盘空间，push或者pull操作时占用更多的网络带宽，花费更长的时间。大规模的部署过程可能需要数个小时，大部分时间浪费在image的push与pull操作中，甚至因为短时间内流量的爆发而引起网络问题，最终导致部署失败。因此，我们应该尽量构建更小尺寸的image。

Iamge的构建过程写在Dockerfile文件中，文件中的每一条指令都会叠加一个新的层。相应地，缩小image的方法有两个，一个是尽量减少Dockerfile中指令的条数，指令条数越少，image中的层数就越少。另一个是精简每层的内容，使之只包含必要的东西。

为此在写Dockerfile时往往会利用SHELL脚本技巧，将多条命令连接成一条命令，并在其中加入一些逻辑。另外，可以将同一个image的Dockerfile分成两份，一个Dockerfile供开发者使用，里边包含开发套件、各种工具、运行时环境等一切构建、运行所需要的东西。另一个Dockerfile供部署人员使用，里边只包含开发者构建好的成果物及运行时环境，删除了开发套件、工具等开发人员才需要的东西，称之为建造者模式(builder pattern)。

### 构建者模式(builder pattern)

一个建造者模式的例子，首先有两份image构建文件，名称分别为`Dockerfile.build`、`Dockerfile`。

Dockerfile.build内容如下：

```dockerfile
FROM golang:1.7.3
WORKDIR /go/src/github.com/alexellis/href-counter/
COPY app.go .
RUN go get -d -v golang.org/x/net/html \
  && CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o app .
```


上边文件中使用的基础镜像是golang:1.7.3，它包含goland语言完整的编译、调试、及运行环境，尺寸较大。这个文件供开发者使用，每次修改完app.go中的代码以后，用这个文件build镜像，然后交互式运行，进去运行、调试代码。

Dockerfile文件内容如下：

```dockerfile
FROM alpine:latest  
RUN apk --no-cache add ca-certificates
WORKDIR /root/
COPY app .
CMD ["./app"]  
```


使用的基础镜像为alpine:latest，它只包含运行golang可执行程序的运行时环境，尺寸较小。另外，它需要使用Dockerfile.build中编译好的golang可执行文件app，整个过程可通过一个shell脚本build.sh实现，脚本内容如下：

```shell
#!/bin/sh
echo Building alexellis2/href-counter:build
 
# 通过Dockerfile.build文件构建image，image名称为alexellis2/href-counter:build
docker build --build-arg https_proxy=$https_proxy --build-arg http_proxy=$http_proxy \  
    -t alexellis2/href-counter:build . -f Dockerfile.build
 
# 为上一步中构建好的镜像alexellis2/href-counter:build创建container，名称为extract
docker container create --name extract alexellis2/href-counter:build  
# 将extract中的app文件复制到当前目录
docker container cp extract:/go/src/github.com/alexellis/href-counter/app ./app
# 删除extract容器  
docker container rm -f extract
 
echo Building alexellis2/href-counter:latest
# 用Dockerfile文件构建镜像，它会使用刚才复制到当前目录的app文件
docker build --no-cache -t alexellis2/href-counter:latest .
# 删除当前目录中的app文件
rm ./app
```

这样，通过build.sh脚本构建出的image尺寸会较小，然后可将此image push到镜像创建中供部署人员使用。

可以看到为了缩小image的尺寸，上述构建过程有点小复杂。涉及三个文件Dockerfile.build、Dockerfile、build.sh，增加了管理的难度。为了减少Dockerfile中指令的数量，使用了shell中的&&命令连接符，降低了可读性。

### 多阶构建(multstage build)

我们当然希望最好只需要一个Dockerfile文件，并且文件中的指令简单明了，就能达成上述三个文件才能完成的目标。于是从Docker17.0.5版本开始，引入了"多阶构建(multstage build)"的功能。以上述构建过程为例，只需要一个Dockerfile文件，并且不需要额外的脚本，Dockerfile文件内容如下：

```dockerfile

FROM golang:1.7.3
WORKDIR /go/src/github.com/alexellis/href-counter/
RUN go get -d -v golang.org/x/net/html  
COPY app.go .
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o app .
 
FROM alpine:latest  
RUN apk --no-cache add ca-certificates
WORKDIR /root/
COPY --from=0 /go/src/github.com/alexellis/href-counter/app .
CMD ["./app"]  
```

在同一个Dockerfile文件中，包含两条FROM指令，分别引用两个不同的基础image，本质上包含了两个image的构建过程，代表了上述方法中两个不同的阶段，所以是多阶构建。另外，后者可以直接引用前者的中间产物，在本例中，后者直接COPY前者生成的/go/src/github.com/alexellis/href-counter/app文件。

然后运行如下命令：

```shell
docker build.
#　或者
docker build -t alexellis2/href-counter:latest .
```

最终生成的镜像是以alpine:latest为基础的镜像，小尺寸的供部署人员使用。第一个阶段以golang:1.7.3为基础镜像的构建过程不会生成最终结果，它相当于整个构建过程中的准备阶段。

如果只想要第一阶段构建的image以供开发人员调试，怎么办呢？通过给每个阶段加上名字，构建时指定阶段名就可以得到相应的结果，如下：

```dockerfile
FROM golang:1.7.3 as builder
WORKDIR /go/src/github.com/alexellis/href-counter/
RUN go get -d -v golang.org/x/net/html  
COPY app.go    .
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o app .
 
FROM alpine:latest  
RUN apk --no-cache add ca-certificates
WORKDIR /root/
COPY --from=builder /go/src/github.com/alexellis/href-counter/app .
CMD ["./app"] 
```

第一阶段被命名为builder，执行如下命令：

```bash
$ docker build --target builder -t alexellis2/href-counter:latest .
```

注意其中的参数--target builder，此命令完成第一阶段的构建后就结束，最终结果是第一阶段构建的image。如果不加--target builder，两个构建过程都会执行，并且最终结果是第二阶段的构建结果。相比于建造者模式，多阶构建简洁、灵活得多，并且不需要SHELL脚本技巧。
> 版权声明：以上内容为引用CSDN博主「五星上炕」的原创文章，遵循 CC 4.0 BY-SA 版权协议，转载请附上原文出处链接及本声明。
> 原文链接：https://blog.csdn.net/dkfajsldfsdfsd/article/details/88781816

### 前端应用

对于当下的前端开发来说，我们至少会接触两套环境：**构建环境** & **运行环境**。有了多阶段构建这个特性，我们可以在一个 Dockerfile 中定义两个环境中要做的事情，最终得到我们需要最终部署到服务器的镜像。这里我们假设我们的前端项目构建结果为一个 `dist` 目录，我们最终部署时只需要 `NGINX` 和这个 `dist`目录即可（实际项目可能更加复杂）。

我们可以像下面这样写我们的 `Dockerfile`：

```dockerfile
#################################
# Build the support container v4
#################################
FROM node:10 as build

WORKDIR /

# some config files
ADD ./.babelrc ./.babelrc
ADD ./tsconfig.json ./tsconfig.json
ADD ./tslint.json ./tslint.json
ADD ./build ./build
ADD ./index.d.ts  ./index.d.ts

# package
ADD ./package.json ./package.json
RUN npm install

# source code
ADD ./src ./src

RUN npm run build

#################################
# Build the Application container
#################################

FROM nginx:stable-alpine

RUN echo "http://mirrors.aliyun.com/alpine/v3.7/main/" | tee /etc/apk/repositories && \
  rm -f /etc/nginx/conf.d/default.conf

COPY --from=build /dist /app/current
ADD ./nginx/nginx.conf /etc/nginx/nginx.conf
ADD ./nginx/conf.d /etc/nginx/conf.d
```

我们的 Nginx配置：

```nginx
server {
        listen 3000;
        server_name default;

        location / {
                root /app/current;
                try_files $uri /index.html;
        }

        location = /index.html {
                root /app/current;
                add_header Cache-Control no-cache;
        }
}
```

最后我们只要使用这个 Dockerfile 构建镜像便可以得到干净的只包含 nginx 和 `dist `前端构建结果的自定义镜像了，使用这个轻巧的镜像创建运行时容器是不是很清爽，整个构建过程也很清晰，容易管理和维护。