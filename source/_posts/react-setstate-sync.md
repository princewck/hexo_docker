---
title: React中setState是同步还是异步？
date: 2020-02-11 20:49:47
tags: 前端开发
thumbnail: /images/setstate.png
---
我们通常认为`setState`是异步的，它通过一个队列机制实现 state 更新。当执行 setState 时，会将需要更新的 state 合并后放入状态队列，而不会立即更新 `this.state`，利用队列机制可以高效地批量更新 state。

不仔细查看文档，我们可能不会注意到，`setState `其实在某些情况下，会表现为同步更新状态，下面是官网的说明：

> ### When is `setState` asynchronous?
>
> Currently, `setState` is asynchronous inside event handlers.
>
> This ensures, for example, that if both `Parent` and `Child` call `setState` during a click event, `Child` isn’t re-rendered twice. Instead, React “flushes” the state updates at the end of the browser event. This results in significant performance improvements in larger apps.
>
> This is an implementation detail so avoid relying on it directly. In the future versions, React will batch updates by default in more cases.

从说明中我们发现，文档只是明确指出了在事件回调（准确地说是React 封装的时间绑定回调，区别于原生的回调事件）中，setState是异步调用的。那么在什么情况下`setState`会表现为同步执行呢？观察下面代码的执行结果进行分析：

https://codesandbox.io/s/frosty-fog-b9zfp

```javascript
import React from "react";
import "./styles.css";

export default class App extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      counter: 1
    };
    this.updateState = this.updateState.bind(this);
  }

  componentDidMount() {
    setInterval(this.updateState, 3000);

    window.addEventListener("mousedown", this.updateState);
  }

  updateState(event) {
    console.log("= = = = = = = = = = = =");
    console.log("EVENT:", event ? event.type : "timer");
    console.log("Pre-setState:", this.state.counter);

    this.setState({
      counter: this.state.counter + 1
    });
    console.log("Post-setState:", this.state.counter);
  }

  render() {
    return (
      <div>
        <h1>{this.state.counter}</h1>
        <button onClick={this.updateState}>button</button>
      </div>
    );
  }
}
```

经过测试，我们会得到如下的结果：

![setState(/Users/wangchengkai/learn/notebook/source/images/setstate.png) timing in ReactJS may update state synchronously or asynchronously.](/images/setstate.png)

可以看到，只有在 React 的 `onClick` 回调中执行的`setState`表现为异步更新state的值，从官方文档中了解到，这种异步机制可以防止子组件多次触发 state 更新而导致多次渲染，从而防止性能问题。

#### setState 调用栈(React@~15)

再观察下面代码：

```javascript
import React from "react";
import "./styles.css";

export default class App extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      val: 0
    };
  }

  componentDidMount() {
    this.setState({ val: this.state.val + 1 });
    console.log(this.state.val);

    this.setState({ val: this.state.val + 1 });
    console.log(this.state.val);

    setTimeout(() => {
      this.setState({ val: this.state.val + 1 });
      console.log(this.state.val);

      this.setState({ val: this.state.val + 1 });
      console.log(this.state.val);
    }, 0);
  }

  render() {
    return null;
  }
}
```

执行打印的结果是： 0 、 0 、 2、 3，如果和你想的不一样你是否会好奇为什么会这样呢？

下图是一个简化的 `setState` 调用栈：

![image-20200211221026422](/images/image-20200211221026422.png)

我们注意到 `enqueueUpdate` 方法，它的代码如下：

```javascript
function enqueueUpdate(component) {
  ensureInjected();

  // 如果不处于批量更新模式
  if (!batchingStrategy.isBatchingUpdates) {
    batchingStrategy.batchedUpdates(enqueueUpdate, component);
    return;
  }
  // 如果处于批量更新模式，则将该组件保存在 dirtyComponents 中
  dirtyComponents.push(component);
}
```

`batchingStrategy`其实是一个简单对象，定义了布尔值`isBatchingUpdates`和`batchedUpdates`方法：

```javascript
var ReactDefaultBatchingStrategy = {
  isBatchingUpdates: false,
  batchedUpdates: function(callback, a, b, c, d, e) {
    var alreadyBatchingUpdates = ReactDefaultBatchingStrategy.isBatchingUpdates;
    ReactDefaultBatchingStrategy.isBatchingUpdates = true;
    if (alreadyBatchingUpdates) {
      callback(a, b, c, d, e);
    } else {
      transaction.perform(callback, null, a, b, c, d, e);
    }
  }
}
```

值得注意的是，`batchedUpdates` 方法中有一个 `transaction.perform`方法，这里使用了`React` 中事务的机制，简单说这里的事务就是将要执行的方法用 `wrapper`包起来， 再通过`perform` 方法执行，多个 `wrapper` 可以叠加。

![image-20200211223131041](/images/image-20200211223131041.png)

> 更多关于事务的介绍： https://www.mattgreer.org/articles/react-internals-part-five-transactions/

所以简单分析上面执行结果： 我们首先把4次 `setState `进行简单归类，前两次属于第一类，因为他们在同一次调用栈中执行，`setTimeout` 中的两次 `setState` 属于另一类。

在 `componentDidMount`中直接调用的两次 `setState`，其调用栈更复杂；而 `setTimeout` 中的两次调用栈则简单很多。我们发现第一类的 `setState` 其实是调用了 `batchedUpdates`  方法的，原来早在 `setState`调用前，已经处于 `batchedUpdates`执行的事务中了。其实，整个将 React 组件渲染到 DOM 中的过程就处于一个大的事务中。总结来说，在 `componentDidMount` 中调用 `setState` 时，`BatchingStrategy.isBatchingUpdates`就已经是 `true`了，所以两次 `setState`的结果并没有立即生效，而是被放进了 `dirtyComponents` 中，这也是为什么两次打印都是 0 的原因，如果没有后面的 setTimeout 的代码，前面这两次`setState`其实会合并，最终`val`的值是 1。

再反观 `setTimeout` 中的两次 setState ，首先它处于 setTimeout 中，所以它是在后续的事件循环过程中被执行，所以拿到的 val 初始状态 应该是上面两次的结果也就是 1。因为 `setTimeout` 中的 `setState` 执行时没有前置的 `batchedUpdate`调用，所以`BatchingStrategy.isBatchingUpdates`是 `false`，也就导致了新的 state 马上生效，所以打印结果为更新后的 2，第二次的同理。

> 以上过程针对 React 15 ，16版本可能会有所不同



#### 小结：

通过上面的例子和分析，我们知道了 **<u>setState 可能是异步的也有可能是同步的</u>**，所以我们最好假设这是个模糊的性质，不要在使用 state 的时候依赖某种你预期的同步或异步的性质。即便你非常清楚它的工作机制，也无法确保它的异步更新策略和实现方式再未来不会做调整。

> 本文参考 ，侵删 😄
>
> - https://www.bennadel.com/blog/2893-setstate-state-mutation-operation-may-be-synchronous-in-reactjs.htm
> - https://reactjs.org/docs/faq-state.html#when-is-setstate-asynchronous
> - 《深入React 技术栈》

