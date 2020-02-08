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

## 同构原理

ReactDOMServer

… 待补充



# 