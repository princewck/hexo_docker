---
title: 2019年第35周
date: 2019-09-01 17:54:07
tags: 前端开发
thumbnail: /images/thumbnails/week35.jpeg
---

## 2019年8月

### 问题：webpack 升级babel7 后不能正确引入umd模块文件
报错内容： `exports`为undefined或者类似的空指针属性引用问题。
原因是 Babel 默认按照ES Modules方式来解析文件，他会在文件中混入`import`代码，如果引入的是 `CommonJs`或者 `UMD` 文件，可能会出现这个问题，解决办法是在babel配置中加上`sourceType`配置
```
{
  "sourceType": "unambiguous",
}
```
他会根据文件内是否含有 `import/export`语句来判定模块类型。
> https://github.com/babel/babel/issues/8900
> https://babeljs.io/docs/en/options#sourcetype


### happypack 作者不再维护，推荐大家使用 thread-loader
HappyPack https://github.com/amireh/happypack
可以使用多进程来执行我们的loader处理文件，加速构建。
随着webpack的性能不断优化，happyPack的性能提升变得不那么明显了，我们可以用 [thread-loader](https://github.com/webpack-contrib/thread-loader) 作为当下的替代品。

### 给webpack加上自定义进度条
```javascript
const chalk = require('chalk');
const ProgressBarPlugin = require('progress-bar-webpack-plugin');

{

  plugins: [
    new ProgressBarPlugin({
      format: `☕️ 请稍后 :bar ${chalk.green.bold(':percent')} (用时:elapsed秒)`,
      complete: chalk.green('▇'),
      incomplete: chalk.white('▇'),
    }),
    //...
  ]
}

```

