---
title: React TransitionGroup的使用
date: 2019-07-04 10:19:20
tags: 周报 前端开发
thumbnail: /images/animate.gif
---

## React TransitionGroup和React-Router v4结合实现转场动画

### 基本使用



```jsx
  <CSSTransition
        in={this.state.show} // 如果this.state.show从false变为true，则动画入场，反之out出场
        timeout={1000} //动画执行1秒
        classNames='fade' //自定义的class名
        unMountOnExit //可选，当动画出场后在页面上移除包裹的dom节点
        onEntered={(el) => {
              el.style.color='blue'   //可选，动画入场之后的回调，el指被包裹的dom，让div内的字体颜色等于蓝色
        }}
        onExited={() => {
              xxxxx   //同理，动画出场之后的回调，也可以在这里来个setState啥的操作
        }}

  >
      <div>hello</div>
  </CSSTransition>
```

### 问题：

最近在使用React做路由切换动画时，希望实现的是「新路由推入，旧路由推出」无缝衔接的一个效果
![demo](/images/animate.gif)
> 在线Demo : https://q7715.codesandbox.io/#/route/c

在两个div之间做这样的切换，实现代码如下：

```jsx
import React, { Component } from "react";
import { CSSTransition } from "react-transition-group";
import "./routeC.scss";

export default class RouteC extends Component {
  state = {
    tab: 0
  };

  toggleTab = () => {
    this.setState({
      tab: (this.state.tab + 1) % 2
    });
  };

  render() {
    return (
      <div>
        <button onClick={this.toggleTab}>切换tab</button>
        <CSSTransition
          unmountOnExit={true}
          in={this.state.tab === 0}
          classNames="slide"
          timeout={500}
        >
          <div className="tab-item tab-item-1">tab1</div>
        </CSSTransition>
        <CSSTransition
          unmountOnExit={true}
          in={this.state.tab === 1}
          classNames="slide"
          timeout={500}
        >
          <div className="tab-item tab-item-2">tab2</div>
        </CSSTransition>
      </div>
    );
  }
}
```

```scss
.tab-item {
  width: 500px;
  height: 300px;
  border: 1px solid #ddd;
  transition: all .5s ease;
  &-1 {
    background: #ddd;
  }
  &-2 {
    background: #666;
    color: #fff;
  }
}

.slide-enter {
  transform: translateX(-100%);
  position: absolute;
  transition: all .5s ease;

  &-active {
  	transform: translateX(0);
	}
}
.slide-exit {
  transition: all .5s ease;
  position: absolute;
  transform: translateX(0);

  &-active {
  	transform: translateX(100%);
	}
}
```



>  但是如何把上述动画和react-router路由结合起来，实现上图的路由切换的效果呢？

观察上面的动画我们可以发现，在路由切换动画过程中，两个div是有一段时间共存的，即那个即将离开的div实际上并未在新div进入时立刻消失，而是在动画"表演"结束后才被删除。

回到我们的路由，我们知道React-Router在切换到新路由时是即时发生的，也就是说按常规的用法，切换到新路由时，原来的路由会立刻从dom树中移除，它也就没有了"表演" `exit`动画的机会，这样我们的转场动画只剩下入场效果，出场的那部分就缺失了。

如何弥补这个缺失呢？好在官方社区给了我们[解决方案](https://reactcommunity.org/react-transition-group/with-react-router), 我们在定义路由时可以换一种方式，如下：

```jsx
<Route key={path} exact path={path}>
  {({ match }) => (
    <CSSTransition
      in={match != null}
      timeout={300}
      classNames="page"
      unmountOnExit
      >
      <div className="page">
        <Component />
      </div>
    </CSSTransition>
  )}
</Route>
```

根据文档，Route 可以接受一个方法作为他的chindren，这个方法在路由切换时必然会被执行，而路由是否匹配我们可以根据该方法的 match 参数来推断。

利用这个特性，我们可以借助这个match 参数将路由视图组件的创建和销毁的任务转交给`CSSTransition`来完成，将入场（也即组件创建）交给 in 来判断。in 判断结果为 false时，CSSTransition可以按自己的逻辑添加出场 exit class 来完成出场动画，当动画完成后 `unmountOnExit `告诉`CSSTransition`表演结束了，可以销毁组件了。

经过以上分析，问题也就解决了，代码如下：

```jsx
import React from "react";
import ReactDOM from "react-dom";
import {
  HashRouter as Router,
  Switch,
  Route,
  Redirect
} from "react-router-dom";
import { TransitionGroup, CSSTransition } from "react-transition-group";
import RouteA from "./routeA";
import RouteB from "./routeB";
import "./styles.scss";

const routes = [
  {
    path: "/route/a",
    component: RouteA
  },
  {
    path: "/route/b",
    component: RouteB
  },
];

function App() {
  return (
    <div className="App">
      <h3>路由切换</h3>
      <Router>
        <Switch>
          <TransitionGroup>
            {routes.map(item => {
              return (
                <Route path={item.path}>
                  {({ match }) => {
                    return (
                      <CSSTransition
                        in={match}
                        classNames="slide"
                        timeout={500}
                        unmountOnExit={true}
                      >
                        {React.createElement(item.component, null, null)}
                      </CSSTransition>
                    );
                  }}
                </Route>
              );
            })}
          </TransitionGroup>
          <Redirect to="/route/a" />
        </Switch>
      </Router>
    </div>
  );
}

const rootElement = document.getElementById("root");
ReactDOM.render(<App />, rootElement);
```

>  在线演示demo：https://q7715.codesandbox.io/#/route/a

