---
title: iOS下使用iframe嵌套页面的bug
date: 2019-09-04 10:22:24
category: 前端开发
tags: js技巧 移动端H5
thumbnail: /images/thumbnails/ios-bug.jpeg
---

### 问题
ios竖屏下iframe设置宽度100%，实际测试发现真机上并不生效，似乎`width`有参数无法被覆盖，iframe的宽度会根据内容宽度被撑开，按照iframe里面页面元素的全尺寸来调整iframe的大小：

![](/qrcodes/iso-iframe-bug1.png)

> 以上问题在有轮播图的页面尤为明显，上面的例子中页面被撑到大的不行，整个iframe区域只能显示轮播图的一小块区域。



### 解决方案

- 给iframe设置一个容器，样式如下

```css
 .scroll-wrapper {
   -webkit-overflow-scrolling: touch;
   overflow: auto;
   position: fixed;
   right: 0;
   left: 0;
   top: 0;
   bottom: 0;
   width: 100%;
 }
```

> 这里的关键是 `   -webkit-overflow-scrolling: touch;overflow: auto;` 这两条，其他可以根据需求调整

- 在iframe 上设置以下样式：

```css
iframe {
  width: 1px;
  min-width: 100%;
  *width: 100%;
  min-height: 100vh; /** 根据需求调整 **/
}
```

- 同时设置 `scrolling` 属性为 `no`

```html
<div id="wrapper" class="scroll-wrapper">
	<iframe height="950" width="100%" scrolling="no" src="Content.html"></iframe>
</div>
```

完成以上设置，再看看我们的页面：

![](/qrcodes/iso-iframe-bug2.png)

似乎是解决了问题，如果是逻辑简单的页面确实是解决了，但是有交互的H5就不一定了。

> 几点说明：
>
> - 上面我们说ios上iframe的宽度会自适应内部页面，这里高度也是这样自动会被撑开，所以iframe我们不设置固定高度，但可以 加个最小高度 `min-height`（小心会截断iframe内部页面显示）
> - 另外`scrolling="no"`也限制了iframe内部内容的滚动。
> - 基于以上特性，我们iframe嵌套页面的滚动其实是变成了iframe所在容器的滚动。

### 新的问题

#### 1. 安卓不能滚动了

由于上面加了`scrolling="no"`，我们打开安卓机可能会发现页面无法滚动了

这个问题我们可以通过判断UA来解决，如果不是ios，则不加`scrolling="no"`。

```javascript
  var u = navigator.userAgent;
    var isiOS = /iPad|iPhone|iPod/.test(navigator.userAgent) && !window.MSStream;
    var wrapper = document.getElementById('wrapper');
    if (isiOS) {
      wrapper.innerHTML = '<iframe id="iframe" scrolling="no" src="http://absovalue.cbndata.com/bestpay/staging/stock-knowledge" />';
    } else {
      wrapper.innerHTML = '<iframe id="iframe" src="http://absovalue.cbndata.com/bestpay/staging/stock-knowledge" />';
    }
```

> 注意这里需要用js 动态生成整个iframe的dom对象，而预先放置iframe，然后通过setAttribute的方式经测试是不行的。

#### 2. iframe 内部无法滚动，内部页基于滚动的交互失效了

典型的例子是常见的两种H5列表页交互：

- 滚动到底部加载下一条
- 下拉刷新。

这种情况我们可以hack一下，使用 [`window.postMessage`](https://developer.mozilla.org/zh-CN/docs/Web/API/Window/postMessage) ，在iframe所在页面检测相关的滚动事件，并在合适的时机给内部的iframe发消息告知其需要执行的动作。

> 这种解决方案需要开发者有直接干涉内部页面代码的权限，或者至少能够和内部页面开发者联调。

### 完成后的页面

![](/qrcodes/iso-iframe-bug3.png)
