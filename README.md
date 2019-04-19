
# hexo + docker + nginx 简单个人网站部署

环境： linux(centos)
依赖： docker, nginx, NodeJs (hexo的依赖)

## 初始化
```bash
$ npm install
# 或者
$ yarn add
```

## 写作
markdown 格式
> [hexo 文档在这](https://hexo.io/zh-cn/docs/commands)

## 开发预览
```bash
$ npm run publish
$ hexo server

```

## 部署
```bash

$ npm run publish # 生成 publish 发布目录
$ npm start # 启动服务，本地可以访问localhost:4001查看
$ npm stop # 停止服务
$ npm run restart # 重启
```




