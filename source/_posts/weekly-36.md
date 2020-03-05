---
title: 2019年39周记录
date: 2019-09-26 10:37:52
tags: 移动端H5 js技巧
category: 前端开发
thumbnail: '/images/photo-1499343628900-545067aef5a3.jpeg'
---

## 1. 隐藏移动版 chorme 中 `video`标签的下载按钮

HTML中直接使用video来播放视频，在Chrome浏览器、360浏览器、QQ浏览器（以及其他一些使用Chrome内核Blink）等中都会出现下载按钮，但我们一般又不希望出现下载按钮。

![image-20190926104525464](/images/image-20190926104525464.png)

好像是从Chrome 54版本开发有下载按钮的（从网上看到的，我也不确定），网上有css解决方案，如下：

```css
video::-internal-media-controls-download-button {
    display:none;
}
video::-webkit-media-controls-enclosure {
    overflow:hidden;
}
video::-webkit-media-controls-panel {
    width: calc(100% + 30px);

}
```
笔者试了之后在chrome内核： `56.0.2924.90` 之下确实可以将下载按钮去除，不过看上面的css大致意思就是将控制器的宽度加宽30px，然后通过 `overflow:hidden;` 去除显示，不过感觉好像不是多靠谱，然后接着网上看资料，就看到了`HTMLMediaElement.controlsList`。

### HTMLMediaElement.controlsList

HTMLMediaElement接口的controlsList 属性返回DOMTokenList，帮助用户在显示其自己的控件集时选择要在媒体元素上显示的控件。DOMTokenList可以设置以下三个可能值中的一个或多个：`nodownload`，`nofullscreen`和`noremoteplayback`。

也就是说可以通过设置controlsList属性来控制是否显示下载按钮，如下：

```html
<video controls controlslist="nodownload" id="video" src=""></video>
```


设置 `controlslist="nodownload"` 之后，在我当前使用的Chrome浏览器（69）就不会出现下载按钮。

关于controlsList可以查看https://developer.mozilla.org/zh-CN/docs/Web/API/HTMLMediaElement/controlsList 。

这里是一个关于controlsList使用的[示例](https://googlechrome.github.io/samples/media/controlslist.html) 。

但是我又想兼容例如56版本的Chrome浏览器怎么办呢，我试着加上上述的css解决方案并设置controlslist="nodownload"，在56版本的Chrome浏览器和69版本的谷歌浏览器两个都可以正常显示。

但是我用360浏览器（内核版本63）以及QQ浏览器（内核版本63）如果同时设置以上的两种解决方案是有问题的，会将全屏按钮一并隐藏，所以可能在56版本的Chrome浏览器不支持controlslist="nodownload"就将其忽略，而在69版本的谷歌浏览器上面的css解决方案已经无效了。

所以现在如果要统一解决的话，在低版本54.0-57.0之间使用上面的css解决方案，而在58版本之后使用controlslist="nodownload"解决。
————————————————
转载：原文链接：https://blog.csdn.net/fxss5201/article/details/83513275

> 本次的问题是在移动端安卓版浏览器的webview环境中遇到的，试了加上`controlslist`可以生效，暂且认为其webview环境使用的是固定的浏览器内核版本，所以不再采用上述 CSS 方案做不同版本的兼容。



## 2. webview中遇到的第二个问题： 安卓网页视频不能全屏

症状：视频全屏按钮置灰无法点击，但在浏览器中可以正常使用。

这已经超出了H5和js的讨论范畴，涉及到一些Android开发和配置的知识。在此记录只是为前端同学遇到这个问题顺利甩锅给Native开发提供依据，前人的踩坑记录：

https://blog.csdn.net/lxh327523471/article/details/84742910

