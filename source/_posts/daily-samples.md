---
title: 日常代码片段记录
tags: 代码片段
toc: true
thumbnail: /images/wpp.jpeg
category: web开发
date: 2019-05-09 10:07:38
thumbnail: /images/thumbnails/codesamples.jpeg
---


## js samples codes

[TOC]

#### midway文档

<https://midwayjs.org/midway/guide.html>



#### 基于Session 的简单用户认证

采用基于session的用户认证策略

##### session 插件配置

使用[egg-session](<https://github.com/eggjs/egg-session>)， egg自带此插件且默认enable

配置：

  ```javascript
    /**
     * @link https://github.com/koajs/session
     * view all configurations
     */
    config.session = {
      key: 'DT-Session',
      maxAge: 86400000 / 12,
      renew: true,
    };
  ```

> 这里不会往session中存大量信息，所以使用把session直接存在客户端cookie中的策略，大致就是把session信息加密后存到客户端cookie，处理请求时可以解密客户端带上来的cookie，以获取当前会话的session信息，上述策略的具体实现不在此研究，直接使用egg-session插件来完成，它默认采用此策略，如果需要把session存到redis，mongo等介质以实现储存较大量数据或在分布式系统共享，可以修改其配置来实现。

##### 配置mongoose

小项目，主要是用户注册登录和表单提交，没有强一致性要求，所以使用mongodb来进行用户信息持久化。

> 我们会采用经典的MVC结构来组织程序，并且将数据层操作抽离出来独立于app实例，通过midway的依赖注入方式使用，这里直接使用官方的mongoose库来完成ODM配置。（egg-mongoose 需要用`this.app.model`的方式调用，把实例挂到app上）。

- 约定

*所有Schema定义在src/mongoose路径下，文件名即为Schema名称*

- 全局初始化connection

  ```javascript
  // src/mongoose/index.ts
  import * as mongoose from 'mongoose';
  import * as fs from 'fs';
  import * as path from 'path';

  const options = {
    useNewUrlParser: true,
    useCreateIndex: true,
    useFindAndModify: false,
    autoIndex: false, // Don't build indexes
    reconnectTries: Number.MAX_VALUE, // Never stop trying to reconnect
    reconnectInterval: 500, // Reconnect every 500ms
    poolSize: 10, // Maintain up to 10 socket connections
    // If not connected, return errors immediately rather than waiting for reconnect
    bufferMaxEntries: 0,
    connectTimeoutMS: 10000, // Give up initial connection after 10 seconds
    socketTimeoutMS: 45000, // Close sockets after 45 seconds of inactivity
    family: 4 // Use IPv4, skip trying IPv6
  };

  mongoose.connect('mongodb://localhost/dtxzsjx', options);

  const db = mongoose.connection;

  db.on('error', (e) => {
    // tslint:disable-next-line:no-console
    console.error('error:', e);
  });

  db.once('open', () => {
    // tslint:disable-next-line:no-console
    console.log('mongo db connected!');
  });

  const models = fs.readdirSync(path.resolve(__dirname, '.'))
    .filter((item) => !item.includes('index'))
    .map((item) => item.split('.')[0]);

  // tslint:disable-next-line:no-console
  console.log('正在装载如下models::', models.join('，'));

  const model = {};
  // 装载mongoose/下的Schema
  models.forEach(m => {
    const schema = require(path.resolve(__dirname, m));
    model[m] = mongoose.model(m, schema.default);
  });

  export default model;
  ```

- app.ts 注册models到IoC容器

  ```javascript
  // src/app.ts
  import model from './mongoose';

  export default (app) => {
    app.applicationContext.registerObject('models', model);
  };
  ```

- 把model注入基础Service类

  ```javascript
  import { inject } from 'midway';

  export class BaseService {

    @inject('models')
    protected models;
  }
  ```

- 使用

  ```javascript
  import { provide } from 'midway';
  import { IUserService, IUserOptions, IUserResult } from '../../interface';
  import { BaseService } from './baseService';

  @provide('userService')
  export class UserService extends BaseService implements IUserService {

    async getUsers(): Promise<IUserResult> {
      const users = await this.models.User.find({
        name: 'wck3',
      });
  		return users;
  }
  ```

- 配置完成

  配置完以上内容，就可以在service方便地使用mongoose了～

  > [mongoose 文档](<https://mongoosejs.com/docs/guides.html>)



#### Midwayjs 框架扩展

和eggjs 一致，放在src/app/extend/*.ts（文档好似有些问题）

```javascript
module.exports = {
  async renderPage(template, data, options) {
    await this.render(template, { ...data, isLogin: !!this.session.user }, options);
  },
};
```



#### 全局错误统一拦截

```javascript
// src/app/middleware/web-intercepter.ts
import * as helper from '../../lib/utils';
module.exports = (options, app) => {
  return async (ctx, next) => {
    try {
      await next();
    } catch (e) {
      const isAdmin = /^\/admin/.test('ctx.request.url');
      if (isAdmin) {
        // cms请求错误，返回json请求体和错误状态码
        await helper.response(ctx, 'bad request', null, 400);
      } else {
        // 非cms请求错误，重定向到404页面
        await ctx.render('tpl/404.ejs');
      }
    }
  };
};

// config.default.ts
config.middleware = [
  'webIntercepter',
];
```



#### OSS STS 文件上传

后端：

```javascript
// eggjs 版本
'use strict';
const { Controller } = require('egg');
const OSS = require('ali-oss');
const nconf = require('nconf');


const sts = new OSS.STS({
  accessKeyId: nconf.get('OSS_AK'),
  accessKeySecret: nconf.get('OSS_SK'),
});

class Sts extends Controller {
  async index() {
    try {
      const data = await sts.assumeRole(
        'acs:ram::1234567898765432:role/bucket-name',
        '',
        '3600',
        this.ctx.session.sessionID || `default-session-${new Date().getTime()}`
      );
      this.ctx.body = data;
    } catch (e) {
      await this.ctx.throwError('获取 OSS 验证信息失败');
    }
  }
}

module.exports = Sts;
```

前端：

- 文件选择

```javascript
function selectFile() {
  return new Promise(function (resolve) {
    var $input = document.createElement('input');
    $input.setAttribute('type', 'file');
    $input.dispatchEvent(new MouseEvent('click'));
    $input.onchange = function () {
      $input = null;
      var file = this.files[0];
      var url = URL.createObjectURL(file);
      resolve({
        file: file,
        local_url: url,
        name: file.name,
        size: file.size,
      });
    }
  });
}
```

- 获取sts credentials

```javascript
const cred = await axios.get('/sts').then(res => res.data.credentials);
```

-  上传

```javascript
function upload(file, key, credentials, progress) {
  var fileSize = file.size;
  var fileName = (key || file.name).split(' ').join('-');
  var filePath = ('yicai-zhidekan/' + fileName).split('//').join('/');
  if (filePath.indexOf('/') === 0) {
    filePath = filePath.substring(1);
  }
  var client = new OSS.Wrapper({
    accessKeyId: credentials.AccessKeyId,
    accessKeySecret: credentials.AccessKeySecret,
    stsToken: credentials.SecurityToken,
    region: 'oss-cn-hangzhou',
    bucket: 'yicai-zhidekan',
    secure: true,
  });
  return client.multipartUpload(filePath, file, {
    progress: function (percentage, cpt) {
      return function (next) {
        console.log(percentage, cpt);
        if (progress) {
          progress(percentage);
        };
        next();
      };
    }}).then(function(res) {
    return {
      file_name: fileName,
      file_path: res.name,
      size: fileSize,
      url: 'https://yicai-zhidekan.oss-cn-hangzhou.aliyuncs.com/' + res.name,
    };
  });
}

// es6 async
{
  async progress(percentage, cpt) {
    checkpoint = cpt;
  },
}
```



#### 基于 Bearer Token 的认证策略

使用jwt生成token

> 使用egg插件 [egg-jwt](<https://github.com/okoala/egg-jwt#readme>)

```javascript
	// config.default.js

	// https://github.com/okoala/egg-jwt#readme
  config.jwt = {
    secret: '@^_Fsa1Ds',
    options: {
      expiresIn: 3600, // expires in 1 hour
    },
    enable: true,
    match: (ctx) => {
      const excludes = ['/admin/login', '/admin/sign_in','/test'];
      if (ctx.request.url.includes('/admin')) {
        return !excludes.includes(ctx.request.url);
      }
      return false;
    },
  };
```

```javascript
// plugin.js
exports.jwt = {
  enable: true,
  package: 'egg-jwt'
}
```

自定义中间件

```javascript
// middleware/admin-auth-handler.ts
module.exports = (option) => async (ctx, next) => {
  try {
    if (/^\/admin/.test(ctx.request.url)) {
      if (!['/admin/login', '/admin/sign_in'].includes(ctx.request.url)) {
        const admin = await ctx.currentAdmin();
        if (!admin) {
          await ctx.respond('登陆失效', null, 401);
        }
      }
    }
    await next();
  } catch (e) {
    if (e.name === 'UnauthorizedError') {
      ctx.status = 401;
      ctx.body = {
        message: e.message || 'invalid token',
      };
    } else {
      throw e; // 给其他中间件继续处理
    }
  }
};
```

```javascript
// app.ts
app.config.middleware.unshift('adminAuthHandler');
```

```javascript
// app/extend/context.ts
module.exports = {
    async currentAdmin() {
    // 获取当前登陆的用户信息
    const data = (this.header.authorization || '').split(' ');
    const token = data[1];
    if (!token) {
      return null;
    }
    // todo: load from cache
    return this.model.Admin.findOne({token});
  },
  async respond(message: string, data: any, status: number = 200) {
    await helper.response(this, message, data, status);
  },
};
```

认证逻辑

```javascript
// service/admin.ts
import { provide, config } from 'midway';
import { IAdminResult, IAdminService } from '../../interface';
import { BaseService } from './base';
import ObjectNotFoundError from '../errors/ObjectNotFoundError';
import AlreadyExistError from '../errors/AlreadyExistError';

@provide('adminService')
export class AdminService extends BaseService implements IAdminService {
  @config('superadmin')
  private superadmin;

  public async signin(name: string, password: string): Promise<IAdminResult> {
    const exist = await this.models.Admin.findOne({name});
    if (exist) {
      throw new AlreadyExistError('账号已存在,请直接登陆');
    }
    const adminSalt = this.helper.randomString(5);
    const encryptedPwd = this.helper.encryptPwd(password, adminSalt);
    const {_id: id, token} = await this.models.Admin.create({
      name,
      password: encryptedPwd,
      salt: adminSalt,
    }, {new: true});
    return {
      id, name, token,
    };
  }

  public async login(
    username: string,
    password: string,
  ): Promise<IAdminResult> {
    const storedUser = await this.models.Admin.findOne({
      name: username,
    });
    if (!storedUser) {
      // 超级管理员登入
      const { name, initial_password } = this.superadmin;
      if (username === name && password === initial_password) {
        const adminSalt = this.helper.randomString(5);
        const result = await this.models.Admin.create({
          name: username,
          password: this.helper.encryptPwd(password, adminSalt),
          salt: adminSalt,
        });
        return {
          id: result._id,
          name: username,
        };
      } else {
        throw new ObjectNotFoundError();
      }
    }
    const { password: correctPwd, salt } = storedUser;
    const encryptedInputPwd = this.helper.encryptPwd(password, salt);
    if (encryptedInputPwd !== correctPwd) {
      throw new Error('bad password error');
    }

    return {
      id: storedUser._id,
      name: username,
    };
  }

  public async refreshToken(id, token) {
    const {
      _id,
      name,
      created_at,
    } = await this.models.Admin.findOneAndUpdate(
      { _id: id },
      { $set: { token } },
      { new: true },
    );
    return { id: _id, name, created_at, token };
  }
}
```

```javascript
import { controller, get, post, inject, provide } from 'midway';
import { IAdminService } from '../../interface';
import BaseController from './base';

@provide()
@controller('/admin')
export class AdminController extends BaseController {

  @inject('adminService')
  private service: IAdminService;

  @post('/signin')
  public async create(ctx): Promise<void> {
    try {
      const { username, password } = ctx.request.body;
      const result = await this.service.signin(username, password);
      const token = ctx.app.jwt.sign(result, ctx.app.config.jwt.secret, ctx.app.config.jwt.options);
      const user = await this.service.refreshToken(result.id, token);
      ctx.body = user;
    } catch (e) {
      if (e.name === 'AlreadyExistError') {
        ctx.respond('用户已存在', null, 403);
      } else {
        throw e;
      }
    }
  }

  @post('/login')
  public async login(ctx) {
    try {
      const { username, password } = ctx.request.body;
      const result = await this.service.login(username, password);
      const token = ctx.app.jwt.sign(result, ctx.app.config.jwt.secret, ctx.app.config.jwt.options);
      const user = await this.service.refreshToken(result.id, token);
      ctx.body = user;
    } catch (e) {
      if (e.name === 'ObjectNotFoundError' || e.name === 'InvalidPwdError') {
        this.helper.response(ctx, '用户名或密码错误', null, 403);
      }
    }
  }

}
```

#### devServer proxy

```javascript
{
    devServer: {
    contentBase: path.join(__dirname, '../dist'),
    compress: true,
    port: 3011,
    quiet: false,
    historyApiFallback: true,
    host: '0.0.0.0',
    proxyTable: {
      '/api': {
        target: 'http://localhost:7001/admin/',
        changeOrigin: true,
        pathRewrite: {
          '^/api': '/'
        }
      }
    },
  },
}
```



#### 为表单增加图形验证码

安装依赖

```bash
$ yarn add svg-captcha
```

Controller

```javascript
// controller/captcha.js
import { controller, get, provide } from 'midway';
import BaseController from './base';
import * as svgCaptcha from 'svg-captcha';

@provide()
@controller('/')
export default class CaptchaController extends BaseController {

  /**
  * 获取验证码图片，meta-type 为svg, 可作为外联svg文件或img的src使用
  */
  @get('/captcha')
  public async getCaptcha(ctx: any): Promise<void> {
    const captcha = svgCaptcha.create();
    ctx.session.captcha = captcha.text;
    ctx.type = 'svg';
    ctx.body = captcha.data;
  }

}
```

##### e.g. 登录时校验二维码

View:

```ejs
<link
  rel="stylesheet"
  href="/public/css/login.css?t=<%= Math.floor(new Date() / (1000 * 60)) %>"
/>
<div class="login-wrapper">
  <form action="/user/login" method="POST">
    <div class="login-form animated flipInY">
      <div class="logo">
        <img src="/public/logo_2.png" />
      </div>
      <div class="form-item">
        <input name="phone" type="text" placeholder="手机号" />
      </div>
      <div class="form-item">
        <input name="password" type="text" placeholder="密码" />
      </div>
      <div class="form-item flex-row">
        <input class="flex-auto" name="captcha" type="text" placeholder="验证码" />
        <img class="captcha" src="/captcha?t=<%= +new Date() %>" height="40px" />
      </div>
      <div class="error-info has-error">
        <%= error %>
      </div>
      <div class="submit-btn">
        <input type="submit" value="登陆" />
      </div>
      <div class="info">
        <a href="/user/register">还没有账号？去<span>注册</span></a>
      </div>
    </div>
  </form>
</div>
```

Controller:

```javascript
// controller/user.js 拦截检查InvalidCaptchaError错误
import { controller, get, post, inject, provide } from 'midway';
import { IUserService } from '../../interface';
import BaseController from './base';
import InvalidCaptchaError from '../../lib/errors/InvalidCaptchaError';

@provide()
@controller('/')
export class UserController extends BaseController {
  @inject('userService')
  service: IUserService;


  @get('/user/login')
  async loginPage(ctx) {
    if (ctx.session.user) {
      await ctx.redirect('/');
    }
    await ctx.renderPage('login.ejs', {error: ''}, {layout: 'tpl/layout.ejs'});
  }

  @post('/user/login')
  async login(ctx): Promise<void> {
    try {
      const { phone, password, captcha = '' } = ctx.request.body;
      if (captcha.toLowerCase() !== `${ctx.session.captcha}`.toLowerCase()) {
        throw new InvalidCaptchaError();
      }
      const result = await this.service.login(phone, password);
      ctx.session.user = result;
      const referUrl = new URL(ctx.request.headers.referer);
      const redirect = referUrl.searchParams.get('redirect') || '/';
      ctx.redirect(decodeURIComponent(redirect));
    } catch (e) {
      if (e.name === 'InvalidPwdError' || e.name === 'ObjectNotFoundError') {
        await ctx.renderPage('login.ejs', {error: '用户名或密码不正确'}, {layout: 'tpl/layout.ejs'});
      } else if (e.name === 'InvalidCaptchaError') {
        await ctx.renderPage('login.ejs', {error: e.message}, {layout: 'tpl/layout.ejs'});
      } else {
        throw e;
      }
    }
  }
}

```



#### 本地环境配置https证书

1. 安装mkcert

```bash
$brew install mkcert
```

2. 初次配置信任信息

```bash
$mkcert -install
```

3. 生成证书文件

```bash
# 支持同时配置多个域名或ip
$mkcert \
  172.16.1.35 \
  flow.cbndata.local
```

> 执行后当前路径会生成两个文件，形如 `localhost.pem` ,  `localhost-key.pem`
>
> flow.cbndata.local是本地ip，为此我写了个自动更新hosts文件的脚本，将本机局域网ip更新到hosts
>
> 维护hosts中如下记录:
>
> 172.16.1.35 flow.cbndata.local

```javascript
// update-ip.js
const fs = require('fs');
function getIPAdress(){
  var interfaces = require('os').networkInterfaces();
  for(var devName in interfaces){
        var iface = interfaces[devName];
        for(var i=0;i<iface.length;i++){
             var alias = iface[i];
             if(alias.family === 'IPv4' && alias.address !== '127.0.0.1' && !alias.internal){
                   return alias.address;
             }
        }
  }
}

function getHosts() {
  try {
    const hosts = fs.readFileSync('/etc/hosts', 'utf-8');
    return hosts.split(/\n/);
  } catch (e) {
    throw new Error(e);
  }
}

function genNewHosts() {
  const hosts = getHosts();
  // 定位标记
  const index = hosts.findIndex(item => /^#one-flow/.test(item));
  const newPair = `${getIPAdress()} flow.cbndata.local`;
  if (index >= 0) {
    hosts[index + 1] = newPair;
  } else {
    hosts.push('#one-flow', newPair);
  }
  fs.writeFileSync('/etc/hosts', hosts.join('\n'), 'utf-8');
}

genNewHosts();
```

使用，重新连接导致内网ip变化时执行：`sudo node path-to/update-ip.js `

4. 配置前端项目

webpack devServer增加https配置：

 ```javascript
// 此处省略了不相关配置
{
  devServer: {
    proxy: {
      '/api': {
        target: 'http://localhost:7001/',
        changeOrigin: true,
        pathRewrite: {
          '^/api': '/admin'
        }
      }
    },
    https: {
      key: fs.readFileSync(path.join(__dirname, '../config/localhost-key.pem')),
      cert: fs.readFileSync(path.join(__dirname, '../config/localhost.pem')),
    },
  },
}
 ```

5. 重启devServer

```bash
$npm run dev
```

完成：

![image-20190417101926454](/Users/wangchengkai/Desktop/技术学习/midway/image-20190417101926454.png)

#### egg 调试

##### 查看插件列表

```javascript
// 自定义中间件
console.log(app.config.middleware);
// 内置中间件
console.log(app.config.coreMiddleware);
```

##### 自定义中间件列表

```javascript
// app.ts
app.config.middleware.unshift('adminAuthHandler');
app.config.middleware.push('adminAuthHandler');
```



#### 去除chrome自动填充黄底样式

```scss
# 色值根据需要自定义
input:-webkit-autofill {
    box-shadow: 0 0 0px 1000px rgba(41,60,86,1) inset !important;
    -webkit-box-shadow: 0 0 0px 1000px rgba(41,60,86,1) inset !important;
    border: 0px solid #CCC!important;
    -webkit-text-fill-color: #FFF;
}
```



#### 开发环境不处理csrf

```javascript
	// onfig.default.ts

	const isLocal = appInfo.env === 'local';

  config.security = {
    csrf: isLocal ? false : {
      enable: true,
      match: '/admin',
    },
  };
```

