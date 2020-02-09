---
title: 理解React 技术栈
tags: 前端开发
category: 前端开发
date: 2020-02-08 20:51:56
thumbnail: /images/redux/thumb.jpeg
---

**React的哲学**：在 React 中一切皆组件，根据单一职责原则划分组件的功能范围，一个组件只负责一个功能。组件也是状态机，维护了自身的状态，组件内的 state 常用于保存交互中随时间频繁变化的状态。

父组件通过props向子组件传递数据，单项数据流的思想贯穿 React 组件模块化设计，这条原则让组件之间的关系变得简单且可预测，易于快速开发和调试。

**单向数据流**：React 中的数据流是单向的，并顺着组件层级从上往下传递。子组件想要向父组件传送数据必须通过回调的方式把数据给父组件，让父组件决定如何使用这些数据去产生一些副作用。



### 生命周期及其管理艺术

![](/images/redux/react_lifecycle.png)

> 无状态组件没有生命周期方法，该类组件每次更新都会重新渲染

生命周期可以分为两类

1. 挂载和卸载阶段
2. 更新阶段

#### 挂载和卸载

- `constructor`
- `componentWillMount `废弃
- `componentDidMount`

- `componentWillUnmount`

#### 更新过程

- `componentWillReceiveProps`
- `shouldComponentUpdate`
- `componentWillUpdate`
- `componentDidUpdate`

新增的生命周期

- `static getDerivedStateFromProps()` 

```javascript
/**
* componentWillReceiveProps 的替代方案
* 在 render方法之前被调用
* 因为是静态方法，所以无法获得组件作用域 this
*/
static getDerivedStateFromProps(props, state) {
  if (props.currentRow !== state.lastRow) {
    return {
      isScrollingDown: props.currentRow > state.lastRow,
      lastRow: props.currentRow,
    };
  }
  // Return null to indicate no change to state.
  return null;
}
```

- `getSnapshotBeforeUpdate(prevProps, prevState)`

在改动被提交到 DOM 树前调用，可以用来做一些快照，比如记录滚动位置，返回值会被作为`componentDidUpdate`的第三个参数。



##### 捕获错误

- `static getDerivedStateFromError(error)` 捕获后代组件抛出的错误，并更新state，显示 fallback UI
- `componentDidCatch(error, info)`  

##### （即将）废弃的 生命周期

- `UNSAFE_componentWillMount`

- `UNSAFE_componentWillReceiveProps`

- `UNSAFE_componentWillUpdate`

  

### Hooks 

react@^16.8.0 支持



### 组件间通信



### 表单

受控和非受控

#### 高阶组件

告诫组件是一个函数，传入一个组件，返回一个增强的 React 组件。让我们的代码更有复用性、逻辑性和抽象性。它可以劫持 render 方法，控制 props 和 state;

高阶组件实现中可能会用到的技巧：

- 属性代理
- 反向继承

#### pureComponent

PureComponent通过prop和state的浅比较来实现shouldComponentUpdate，某些情况下可以用PureComponent提升性能。

### Virtual DOM

React 中的虚拟DOM好比是一个虚拟空间，它是位于内存中的。React 设计了一整套的虚拟DOM标签，有一套可以映射到真实DOM的虚拟标签建立和增删API。我们常用的 `createElement`方法，其实是在虚拟DOM中进行的虚拟元素创建操作。

### setState机制

 队列机制

React通过**状态队列**的机制实现了`setState`的异步更新，setState的状态会在合并后放入状态队列，状态队列合并后批量更新。

>  在 `shouldComponentUpdate ` 和 `componentWillUpdate`中调用 setState，有可能会造成循环调用。

### diff算法

diff 算法可以帮我们计算出 VirtualDOM中真正变化的部分，并只针对该部分进行原生 DOM 操作，而不是重新渲染整个页面，这也是VirtualDOM 高效的原因。

React 将VirtualDOM 树转换成 actual DOM 树的最少操作过程称为`调和（Reconciliation）`。

##### diff 策略

1. DOM 节点跨层级移动很少 ， 所以diff 算法只会对同一层级的元素进行比较
2. 相同类的组件生成相似的结构，不同类的组件生成不同的结构
   - 如果是同一类型组件，按原策略比较 Virtual DOM 
   - 不是的话，替换整个组件和子组件
   - 借助`shouldComponentUpdate`判断需不需要 diff 检测变化

## Redux 

redux 是 flux 的一种第三方实现

### Flux 架构

基于 dispatcher 的前端应用架构模式。

“`ADSV`”： Action Dispatcher Store View

定义了一种单项数据流的方式实现 View 和 Model 层间的数据流动

概念：

- Store 存储状态
- Dispatcher 分发器，负责接收 Action
- Action 

### Redux 三大原则

1. 单一数据源
2. 状态只读
3. 状态修改由纯函数完成

### 主要概念

- dispatch
- action
- reducer(state => new Store)
- view

### 核心 API

`createStore(reducers)`

```javascript
import { createStore } from 'redux';
const store = createStore(reducers);
```

store是一个对象，包含如下方法

`getState()`

`dispatch(action)`

`subscribe(listener)`

`replaceReducer(nextReducer)`

```javascript
import { createStore } from 'redux';
console.log(createStore);

function counter(state, action) {
  switch(action.type) {
    case 'INCREMENT':
      return {
        ...state,
        count: Number(state.count || 0) + 1
      };
    case 'DECREMENT':
      return {
        ...state,
        count: Number(state.count || 0) - 1
      };
    default:
      return state;
  }
}
const initialState = { name: 'wck' };
let store = createStore(counter, initialState);

store.subscribe(() => console.log(store.getState()));

store.dispatch({ type: 'INCREMENT' });
store.dispatch({ type: 'DECREMENT'});
```



### 异步

> Flux 一个很大的不足之处在于定义的模式太过松散，这导致许多采用了  Flux 模式的开发者在实际开发过程中遇到一个很纠结的问题：在哪里发请求，如何处理异步流？在Redux 中，这种异步 action 的请求可以通过 Redux 原生的 middleware 设计来实现。
>
> ——  《深入 react 技术栈》

![image-20200208171411072](/images/redux/image-20200208171411072.png)

#### Middleware

redux 提供了middleware，它实现了一种可组合的、自由插拔的插件机制。借鉴了 Koa 的思想。

```javascript
const logger = store => next => action => {
  console.log('dispatch', action);
  store.dispatch(action);
  console.log('finish', action);
}
```

![image-20200208172927889](/images/redux/image-20200208172927889.png)

redux 使用 `applyMiddleware()`方法加载 middleware

```javascript
import compose from './compose';
export default function applyMiddleware(...middlewares) {
  return (next) => (reducer, initialState) => {
    let store = next(reducer, initialState);
    let dispatch = store.dispatch;
    let chain = [];
    
    var middlewareAPI = {
      getState: store.getState,
      dispatch: (action) => dispatch(action),
    };
    chain = middlewares.map(middleware => middleware(middlewareAPI));
    // chain: [(next) => action => void, ...]
    // next 做的事和 store.dispatch 类似，但它是微观的，把 action 从外向内传
    // 它又和 store.dispatch 不同，next是传递过程中的一环，store.dispatch则是从最外层
    // 往里传（直到原生dispatch）的整个过程。这里说的 store.dispatch 是被层层包裹增强后的dispatch
    dispatch = compose(...chain)(store.dispatch);
    return {
      ...store,
      dispatch,
    }
  }
}
```

结合下面的`logger middleware` 实现：

```javascript
export default store => next => action => {
  console.log('dispatch', action);
  next(action);
  console.log('finish', action);
}
```

> middleware 的设计使用了函数式编程中的 柯里化 (curring)，

curring 结构中间件的好处：

- 易串联
- 共享 store 

另外，我们发现 applyMiddleware 结构也是一个多层 curring 函数。借助 compose， applyMiddleware 可以用来和其他插件增强 createStore 函数：

```javascript
import { createStore, applyMiddleware, compose } from 'redux';
import rootReducer from '../reducers';
import DevTools from '../containers/DevTools';

const finalCreateStore = compose(
  // (next) => (reducer, initialState) => {store: ReduxStore, dispatch: Function}
	applyMiddleware(d1, d2, d3), 
  DevTools.instrument()
)(createStore);
// createStore 会被作为初始参数依次传给 compose中的各参数，也就是作为上面的 next 参数，最后返回一个增强后的方法，签名和createStore一样： (reducer, initialState) => {store, dispatch}

```

串联middleware，`compose`的实现：

```javascript
function compose(...funcs) {
  return args => funcs.reduceRight((composed, f) => f(composed), arg);
}
```



![img](/images/redux/u=1587617603,2906342683&fm=26&gp=0.png)

##### Redux Thunk

```javascript
const thunk = store => next => action => typeof action === 'function' ? action(store.dispatch, store.getState) : next(action);
```

使用这个中间件来进行异步操作

```javascript
const getThenShow = (dispatch, getState) => {
  const url = 'http://xxx.json';
  fetch(url).then(response => {
    dispatch({
      type: 'SHOW_MESSAGE_FOR_ME',
      message: response.json(),
    });
  }).catch(() => {
    dispatch({
      type: 'FETCH_DATA_FAIL',
      message: 'error',
    });
  })
}

store.dispatch(getThenShow);
```

> thunk 函数实现上就是针对多参数的柯里化以实现对函数的惰性求值。

##### redux-thunk 源码

```javascript
function createThunkMiddleware(extraArgument) {
  return ({ dispatch, getState }) => (next) => (action) => {
    if (typeof action === 'function') {
      return action(dispatch, getState, extraArgument);
    }

    return next(action);
  };
}

const thunk = createThunkMiddleware();
thunk.withExtraArgument = createThunkMiddleware;

export default thunk;
```

使用：

```javascript
const INCREMENT_COUNTER = 'INCREMENT_COUNTER';

function increment() {
  return {
    type: INCREMENT_COUNTER,
  };
}

function incrementAsync() {
  return (dispatch) => {
    setTimeout(() => {
      // Yay! Can invoke sync or async actions with `dispatch`
      dispatch(increment());
    }, 1000);
  };
}
```



##### redux-promise

> The default export is a middleware function. If it receives a promise, it will dispatch the resolved value of the promise. It will not dispatch anything if the promise rejects.
>
> If it receives an Flux Standard Action whose `payload` is a promise, it will either
>
> - dispatch a copy of the action with the resolved value of the promise, and set `status` to `success`.
> - dispatch a copy of the action with the rejected value of the promise, and set `status` to `error`.
>
> The middleware returns a promise to the caller so that it can wait for the operation to finish before continuing. This is especially useful for server-side rendering. If you find that a promise is not being returned, ensure that all middleware before it in the chain is also returning its `next()` call to the caller.
>
> —— https://github.com/redux-utilities/redux-promise

```javascript
import { isFSA } from 'flux-standard-action';

function isPromise(obj) {
  return !!obj && (typeof obj === 'object' || typeof obj === 'function') && typeof obj.then === 'function';
}

export default function promiseMiddleware({ dispatch }) {
  return next => action => {
    if (!isFSA(action)) {
      return isPromise(action) ? action.then(dispatch) : next(action);
    }

    return isPromise(action.payload)
      ? action.payload
          .then(result => dispatch({ ...action, payload: result }))
          .catch(error => {
            dispatch({ ...action, payload: error, error: true });
            return Promise.reject(error);
          })
      : next(action);
  };
}
```

使用：

```javascript
createAction('FETCH_THING', async id => {
  const result = await somePromise;
  return result.someValue;
});
```

##### redux-saga

用 generator 替代了 promise，是一个优雅的解决方案，它有强大而灵活的 协程机制，可以解决任何复杂的异步交互。





> Redux 常用工具
>
> redux-actions https://redux-actions.js.org/
>
> 

## React 服务端渲染

服务端渲染(SSR for Server Side Render)是一种流行的同构方案，前端代码可以在服务端做渲染，前端在请求 HTML 时，直接返回渲染好的页面

##### 优点：

- 利于SEO
- 加速首屏渲染速度

##### API：

- `React.renderToString`
- `React.renderToStaticMarkup`

##### 提出问题

假如你从未接触过服务器渲染，但是又有基本的React和后端以及NodeJS知识，你可能有以下疑问？

> 1. 既然是同构，我们怎么在 NodeJS 环境运行 使用 ES6 modules 或 AMD等浏览器环境模块化技术编写的文件？
> 2. 怎么把开发的东西变成服务器和客户端是两套运行时代码，并且让他们和谐地协同工作？
> 3. 后端路由怎么认前端路由，根据对应路由渲染对应页面组件呢？
> 4. 请求数据是在哪里？哪些数据请求在服务器做，哪些延迟到客户端浏览器里异步 fetch 呢？
> 5. 浏览器和 Nodejs 的全局环境不太一样，会有哪些问题？
> 6. 服务器渲染的过程中 React 的生命周期会有什么影响吗？服务器上和浏览器中是不是不一样？
> 7. 首屏的数据服务器上已经渲染好了，只需要加一些事件绑定，那怎么让浏览器知道这个事实，跳过不必要的客户端渲染呢？
> 8. 状态管理工具，比如 Redux 怎么集成到服务端渲染过程中呢？

##### 感性认识

为了有一个感性认识，了解如何使用 NodeJS 和 ReactDOMServer API 实现一个基础的服务端渲染项目，笔者在此提供一个简单的项目示例，通过比较少的配置实现一个基本的前后端同构的 React 程序。

https://gitee.com/tricklew/react-ssr-from-scrach

> 喜欢视频教程的同学可以观看这个视频寻找思路：
>
> https://www.youtube.com/watch?v=82tZAPMHfT4

并下面针对此项目做一个渐进式的说明：

###### 项目结构

 我们的项目结构是这样的：

![image-20200209141517966](/images/redux/image-20200209141517966.png)

-  `public`是我们的前端浏览器访问的内容，在我们服务的根路径可以访问其中的文件，比如 `localhost:3008/facts.json`，我们使用express 的 `express.static`来实现这个静态文件服务。

- `server` 是我们最终编译打包的所有 Node 环境所需的运行时代码。
- `src` 和 跟路径下的 `index.js` 是我们开发时需要编写的内容

>  我们在构建过程中还会用到  babel 和 webpack

###### 配置过程

首先我们先创建前端代码，`src`路径下的三个文件是我们需要用到的，其中 `index.js`是整个前端应用的入口，在 `webpack.config.js`中，我们进行如下配置，另外别忘了跟路径的 babel 配置 `.babelrc`：

```javascript
// webpack.config.js
module.exports = {
  entry: './src/index.js',
  output: {
    filename: 'bundle.js',
    path: __dirname + '/public',
  },
  module: {
    loaders: [
      { test: /\.js$/, loader: 'babel-loader', exclude: /node_module/ },
      { test: /\.jsx$/, loader: 'babel-loader', exclude: /node_module/ },
    ]
  },
};
```

```javascript
// .babelrc
{
  "presets": [
    "es2015",
    "react"
  ]
}
```

然后在 `package.json`中添加 scripts：

```json
{
  "buildClient": "node_modules/.bin/webpack"
}
```

`npm install`安装整个项目的依赖后，运行 `npm run buildClient`，这样我们得到了一个`public/bundle.js`，这是我们需要在浏览器中使用的文件，在`public`中添加一个 `index.html`并引入该`js`:

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta http-equiv="X-UA-Compatible" content="ie=edge">
  <title>服务端渲染示例</title>
</head>
<body>
  <div id="root"></div>
  <script type="text/javascript" src="bundle.js"></script>
</body>
</html>
```

这样，`public`路径下我们得到了一个我们熟悉的静态网站，我们可以运行 `npx serve ./public`测试一下。既然是服务端渲染，我们下一步一定是构建服务端代码，我们在跟路径创建服务端的入口文件，我们使用 ES Modules 的方式来编写，这样我们就可以用我们熟悉的方式引入前端组件了：

```javascript
import React from 'react';
import { renderToString } from 'react-dom/server';
import App from './src/App';
import getFacts from './src/facts';
import express from 'express';

console.log('express', express);

const app = express();
const port = 3008;

app.use('/static', express.static('public'));

app.get('*', (req, res) => {
  getFacts().then(facts => {
    const html = renderToString(<App facts={ facts } />);
    res.set('Cache-Control', 'publicm max-age=600, s-maxage=1200');
    res.send(html);
  })
});

app.listen(port, () => {
  console.log('ssrApp start listening on port '+ port + ' !');
});
```

接着，我们添加如下 `npm script`：

```json
"buildServer": "babel src -d server/src && babel index.js -d server"
```

试着运行它:

```bash
$npm run buildServer
```

检查一下，我们可以看到我们的前端组件和刚才试用 `ES Module`编写的文件被编译成了可以在 node 环境运行的 `CommonJS`形式，试着让它run起来：

```bash
$node ./server
```

访问 `localhost: 3008`我们发现我们的代码跑起来了，`option + command + U` 查看 html 源文件，我们可以看到页面到达浏览器时已经被服务器渲染好了。

细心你的可能发现了，我们目前这样渲染出来的页面只有组件部分，没有`<html>`、`<body>`这些包裹，我们做一些小改造：

- 把 index.html 复制到 `server`下，做少许改动

```html
// index.html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta http-equiv="X-UA-Compatible" content="ie=edge">
  <title>服务端渲染示例</title>
</head>
<body>
  <div id="root">
  <!-- SSR_APP -->
  </div>
  <script type="text/javascript" src="bundle.js"></script>
</body>
</html>
```

```javascript
import React from 'react';
import { renderToString } from 'react-dom/server';
import App from './src/App';
import getFacts from './src/facts';
import express from 'express';
import * as fs from 'fs';
import * as path from 'path';

const app = express();
const port = 3008;

const portal = fs.readFileSync('./index.html', 'utf-8');


app.use('/static', express.static(path.resolve(__dirname, '../public')));

app.get('*', (req, res) => {
  getFacts().then(facts => {
    const html = renderToString(<App facts={ facts } />);
    const finalHTML = portal.replace('<!-- SSR_APP -->', html);
    res.set('Cache-Control', 'publicm max-age=600, s-maxage=1200');
    res.send(finalHTML);
  })
});

app.listen(port, () => {
  console.log('ssrApp start listening on port '+ port + ' !');
});
```

重新构建，然后启动：

```bash
$npm run buildServer
$cd server
$node .  # 或者有supervisor之类的工具也可以 e.g.  supervisor .
```

这时候再查看  html  源码，得到我们最终需要的 dom 结构：

![image-20200209223452221](/images/redux/image-20200209223452221.png)

我们刚才说  server 应当是包含完整的服务端部署，所以我们给他添加单独的 `package.json`，把服务端运行代码需要的依赖添加进去，`webpack`之类的前端构建依赖不用添加。

到此为止，我们已经有了一个服务端渲染的基本骨架。只是目前只有一个页面，我们还需要研究如何配置多页面路由，如何处理数据等问题。

> 💡 上面「提出问题」列表中第1、2两个问题，我们已经初步有了答案。

… // 未完待续