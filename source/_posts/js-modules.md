---
title: Javascript模块化技术摘要
date: 2019-07-30 14:50:01
tags: 前端基础, 前端开发
toc: true
category: 前端开发
thumbnail: /images/esmodules.gif
---


### 问题

在一开始，我们应该带着问题来学习这项技术，因为这样更容易窥探出技术的本质。 既然我们要讨论模块化，那为什么会有模块化？模块化开发有哪些好处呢？带着这些问题往下看。

> 引言：多年以前，js项目是很小的，根本称不上规模。大部分情况是单独的脚本完成单一简单的任务，例如为页面增加一些交互和效果，这种情况下几乎是不会有很庞大的脚本的。

随着时间的推移和浏览器以及现代浏览设备的更新，我们现在已经可以用js来实现完整的浏览器应用，并且js项目的规模也日渐庞大，因此，探索一种机制来将js代码拆分为不同模块变得十分有意义。在浏览器平台之外，NodeJs 拥有这个特性已经比较久了，也有一些第三方库、框架或工具去支持使用模块化开发或提供模块化开发方案，如基于AMD的RequireJs，基于CommonJS的seajs和近几年出现的Webpack 、Babel等。各大现代浏览器厂商也在慢慢地提供一些原生的模块化支持。

本文我们会着眼这个技术点去回顾和展望这些方案和规范，篇幅有限，但尽可能提取重要关键点，希望可以帮助我们更好滴理解基础，为探索深入的js优化和编码技巧提供帮助，也扫除一些知识上的盲区。本文也借鉴了参考了部分大牛的文章（见文末参考资料）。

### 起源

大约09-10年，[Modules/1.0]([http://wiki.commonjs.org/wiki/Modules/1.0](http://wiki.commonjs.org/wiki/Modules/1.0)) 规范的推出后，在NodeJS环境下取得了不错的实践，当时被称为ServerJS，社区们大牛云集。

09年下半年，社区的大牛们希望把ServerJS的成功经验进一步推广到浏览器端，于是将社区改名为CommonJS，并同时激烈争论Modules的下一版规范。分歧由此产生，逐步形成了三大流派：

1. **Modules/1.x 流派**。这个观点觉得 1.x 规范已经够用，只要移植到浏览器端就好。要做的是新增 [Modules/Transport](http://wiki.commonjs.org/wiki/Modules/Transport) 规范，即在浏览器上运行前，先通过转换工具将模块转换为符合 Transport 规范的代码。主流代表是服务端的开发人员。现在值得关注的有两个实现：越来越火的 [component](https://github.com/component/component) 和走在前沿的 [es6 module transpiler](https://github.com/square/es6-module-transpiler)。
2. **Modules/Async 流派**。这个观点觉得浏览器有自身的特征，不应该直接用 Modules/1.x 规范。这个观点下的典型代表是 [AMD](http://wiki.commonjs.org/wiki/Modules/AsynchronousDefinition) 规范及其实现 [RequireJS](http://requirejs.org/)。这个稍后再细说。
3. **Modules/2.0 流派**。这个观点觉得浏览器有自身的特征，不应该直接用 Modules/1.x 规范，但应该尽可能与 Modules/1.x 规范保持一致。这个观点下的典型代表是 [BravoJS](https://code.google.com/p/bravojs/) 和 FlyScript 的作者。BravoJS 作者对 CommonJS 的社区的贡献很大，这份 [Modules/2.0-draft](http://www.page.ca/~wes/CommonJS/modules-2.0-7/) 规范花了很多心思。FlyScript 的作者提出了 [Modules/Wrappings](http://wiki.commonjs.org/wiki/Modules/Wrappings) 规范，这规范是 CMD 规范的前身。可惜的是 BravoJS 太学院派，FlyScript 后来做了自我阉割，将整个网站（flyscript.org）下线了。这个故事有点悲壮，下文细说。

2015年，随着ES6规范的制定，Javascript 的下一代模块化规范也随之推出了，模块化进一步走向成熟。



#### AMD 与 RequireJS

>  AMD的规范在这里：[Modules/AsynchronousDefinition](http://wiki.commonjs.org/wiki/Modules/AsynchronousDefinition)

##### 概览

RequireJS的基本思想是，通过define方法，将代码定义为模块；通过require方法，实现代码的模块加载。

首先，将require.js嵌入网页，然后就能在网页中进行模块化编程了。

```html
<!-- 引入require.js -->
<script data-main="scripts/main" src="scripts/require.js"></script>
```

主要api:

###### define

定义模块

```javascript
// 独立无依赖模块可以这样定义
define(function () {
	return {
	    method1: function() {},
			method2: function() {},
    };
});

```

```javascript
// 有依赖的模块，第一个参数表时候依赖模块的id数组
define(['module1', 'module2'], function(m1, m2) {
    return {
        method: function() {
            m1.methodA();
						m2.methodB();
        }
    };
});
```



有一段时间，RequireJS成为十分流行的模块化方案。但AMD 规范一直没有被 CommonJS 社区认同，核心争议点如下：

##### 执行时机有异议

看代码

Modules/1.0:

```javascript
var a = require("./a") // 执行到此处时，a.js 才同步下载并执行
```

AMD:

```
define(["require"], function(require) {
  // 在这里，模块 a 已经下载并执行好
  // ...
  var a = require("./a") // 此处仅仅是取模块 a 的 exports

})
```

AMD 里提前下载 a.js 是浏览器的限制，没办法做到同步下载，这个社区都认可。

但执行，AMD 里是 Early Executing，Modules/1.0 里是第一次 require 时才执行。这个差异很多人不能接受，包括持 Modules/2.0 观点的也不能接受。

这个差异，也导致实质上 Node 的模块与 AMD 模块是无法共享的，存在潜在冲突。

##### 模块书写风格有争议

AMD 风格下，通过参数传入依赖模块，破坏了 **就近声明** 原则。比如：

```javascript
define(["a", "b", "c", "d", "e", "f"], function(a, b, c, d, e, f) {

    // 等于在最前面申明并初始化了要用到的所有模块

   if (false) {
       // 即便压根儿没用到某个模块 b，但 b 还是提前执行了
       b.foo()
   }

})
```

还有就是 AMD 下 require 的用法，以及增加了全局变量 define 等细节，当时在社区被很多人不认可。

最后，AMD 从 CommonJS 社区独立了出去，单独成为了 AMD 社区。有阵子，CommonJS 社区还要求 RequireJS 的文档里，不能再打 CommonJS 的旗帜（这个 CommonJS 社区做得有点小气）。

脱离了 CommonJS 社区的 AMD 规范，实质上演化成了 RequireJS 的附属品。比如

1. AMD 规范里增加了对 [Simplified CommonJS Wrapper](http://requirejs.org/docs/api.html#cjsmodule) 格式的支持。这个背后是因为 RequireJS 社区有很多人反馈想用 require 的方式，最后 RequireJS 作者妥协，才有了这个半残的 CJS 格式支持。（注意这个是伪支持，背后依旧是 AMD 的运行逻辑，比如提前执行。）
2. AMD 规范的演进，离不开 RequireJS。



#### Modules/2.0

BravoJS 的作者 Wes Garland 有很深厚的程序功底，在 CommonJS 社区也非常受人尊敬。但 BravoJS 本身非常学院派，是为了论证 Modules/2.0-draft 规范而写的一个项目。学院派的 BravoJS 在实用派的 RequireJS 面前不堪一击，现在基本上只留存了一些美好的回忆。

这时，Modules/2.0 阵营也有一个实战派：FlyScript。FlyScript 抛去了 Modules/2.0 中的学究气，提出了非常简洁的 [Modules/Wrappings](http://wiki.commonjs.org/wiki/Modules/Wrappings) 规范：

```
module.declare(function(require, exports, module)
{
   var a = require("a");
   exports.foo = a.name;
});
```

这个简洁的规范考虑了浏览器的特殊性，同时也尽可能兼容了 Modules/1.0 规范。悲催的是，FlyScript 在推出正式版和官网之后，RequireJS 当时正直红火。期间 FlyScript 作者 khs4473 和 RequireJS 作者 James Burke 有过一些争论。再后来，FlyScript 作者做了自我阉割，将 GitHub 上的项目和官网都清空了，官网上当时留了一句话，模糊中记得是

```
我会回来的，带着更好的东西。
```

这中间究竟发生了什么，不得而知。



#### CMD 与 Sea.js

 Sea.js 借鉴了RequireJS，吸收了Modules/2.0的观点，但尽可能去掉了学院派的东西，加入了不少实战派的理念。在推广Sea.js过程中，CMD模块定义规范诞生了，Sea.js中所有模块定义都遵循[CMD]([Common Module Definition](https://github.com/cmdjs/specification/blob/master/draft/module.md))模块定义规范。

> 💡 CMD 规范是Sea.js在推广过程中对模块定义的规范化产出

##### 概览

在 SeaJS 的世界里，一个文件就是一个模块。所有模块都遵循 [CMD](https://github.com/seajs/seajs/issues/242) 规范，我们可以像在 [Node](http://nodejs.org/) 环境中一样来书写模块代码：

```javascript
define(function(require, exports, module) {
  var $ = require('jquery');

  exports.sayHello = function() {
    $('#hello').toggle('slow');
  };
});
```

将上面的代码保存为 `hello.js`，然后就可以通过 SeaJS 来加载使用了：

```javascript
seajs.config({
  alias: {
    'jquery': 'http://modules.seajs.org/jquery/1.7.2/jquery.js'
  }
});

seajs.use(['./hello', 'jquery'], function(hello, $) {
  $('#beautiful-sea').click(hello.sayHello);
});
```



### UMD

一种[通用模块定义 Universal Module Definition](https://github.com/umdjs/umd)，使得相同的文件能够被多个模块系统（例如 CommonJS 和 AMD ）

```javascript
(function (root, factory) {
    if (typeof exports === 'object') {
        // Commonjs
        module.exports = factory();

    } else if (typeof define === 'function' && define.amd) {
        // AMD
        define(factory);

    } else {
        //  没有使用模块加载器的方式
        window.eventUtil = factory();
    }
})(this, function() {
    // module
    return {
        addEvent: function(el, type, handle) {
            //...
        },
        removeEvent: function(el, type, handle) {

        },
    };
});
```



### ES6 Modules

经过了近十年的标准化工作，ES Modules 终于为 Javascript带来了正式的标准化的模块系统。随着 Firefox 60 在2018年五月发布，所有的主流浏览器都支持 ES 模块，并且 Node 模块工作小组目前也正在为 Node.js 添加对 ES 模块的支持。同时，[ES 模块对 WebAssembly](https://www.youtube.com/watch?v=qR_b5gajwug) 的支持也正在进行当中。

![image-20190802162633674](/Users/wangchengkai/learn/notebook/source/images/es-modules.png)

#### 概览

ECMAScript 6模块的目标是创建一个格式，使 CommonJS 和 AMD 的用户都满意：

- 与 CommonJS 类似，简洁的语法，倾向于单一的接口并且支持循环依赖。
- 与AMD类似，直接支持异步加载和可配置的模块加载。

内置语言允许ES6模块超越 CommonJS 和 AMD：

- 他们的语法比 CommonJS 更简洁。
- 他们的结构可以静态分析（用于静态检查，优化等）。
- 他们支持的循环依赖性优于 CommonJS。

ES6模块标准有两个部分：

- 声明语法（用于导入和导出）
- 编程式加载器（loader）API：配置如何加载模块以及有条件地加载模块

#### ES 模块语法

##### 导出

命名的导出（每个模块可以导出多个）和 默认的导出（每个模块仅导出一个）

```javascript
// 命名的导出
export const sqrt = Math.sqrt;
export function square(x) {
    return x * x;
}
export function diag(x, y) {
    return sqrt(square(x) + square(y));
}

export { MY_CONST, myFunc };
export { MY_CONST as THE_CONST, myFunc as theFunc };
export { diag as Diag };

// 将另一个模块的导出添加到当前模块的导出
export * from 'src/other_module';

// 默认的导出
export default function() {...}
```

> 在一个模块中可以同时包含两种方式的导出

###### 默认导出只是另一个命名导出

默认导出实际上只是一个具有特殊名称`default`的命名导出。也就是说，以下两个语句是是等价的：

```javascript
import { default as foo } from 'lib';
import foo from 'lib';
```

类似地，以下两个模块也是等价的默认导出：

```javascript
//------ module1.js ------
export default 123;

//------ module2.js ------
const D = 123;
export { D as default };
```

##### 导入

```javascript
// 默认导出和命名导出
import theDefault, { named1, named2 } from 'src/mylib';
import theDefault from 'src/mylib';
import { named1, named2 } from 'src/mylib';

// 重命名: 导入 named1 作为 myNamed1
import { named1 as myNamed1, named2 } from 'src/mylib';

// 导入模块作为一个对象
// (每个命名导出都作为一个属性)
import * as mylib from 'src/mylib';
export { foo as myFoo, bar } from 'src/other_module';

// 只加载模块，不导入任何东西
import 'src/mylib';
```

HTML页面可以使用带有特殊 `type="module"` 属性的 `<script>` 标记添加模块

```html
<script type="module" src="index.js"></script>
```

你还可以使用绝对路径来导入模块，以便引用其它域名中定义的模块：

```javascript
import toUpperCase from 'https://flavio-es-modules-example.glitch.me/uppercase.js'
```

对于不支持module的浏览器，我们可以采用以下兼容手段

```html
<script type="module" src="module.js"></script>
<script nomodule src="fallback.js"></script>
```

#### 静态模块结构

在当前的JavaScript模块系统中，你必须执行代码，来找出什么是 导入 和 什么是 导出。这是 ECMAScript 6 与这些模块系统（注：指 CMD，AMD）决裂的主要原因： 通过将模块系统构建到JavaScript语言中，您可以在语法上强制执行静态模块结构。让我们先来看看这意味着什么，带来什么好处。

模块的静态结构，意味着您可以在编译时确定导入和导出（静态） – 你只需要看看源代码，你不必执行它。下面是两个 CommonJS 模块的例子，告诉你为什么 CommonJS 模块在编译时确定导入和导出是不可能的。

在第一示例中，你必须运行代码才可以找出它导入的是什么：

```javascript
var mylib;
if (Math.random()) {
    mylib = require('foo');
} else {
    mylib = require('bar');
}
```

在第二个示例中，您必须运行代码才可以找出它导出的内容：

```javascript
if (Math.random()) {
    exports.baz = ...;
}
```



ECMAScript 6 模块的灵活性不如 CommonJS 模块，强迫使用静态结构。但却使你得到几个好处：

###### 更快的查找

如果你在 CommonJS 中 `require` 一个库，你会得到一个对象：

```javascript
var lib = require('lib');
lib.someFunc(); // 属性查找
```

相反，如果您在 ES6 中导入一个库，您可以静态地了解其内容并可以优化访问：

```javascript
import * as lib from 'lib';
lib.someFunc(); // 静态解析
```

###### 变量检查

利用静态模块结构，你总是静态地知道哪些变量在模块内的任何位置是可见的：

- 全局变量：越来越多，唯一完全的全局变量将将来自适当的语言。一切都将来自模块（包括来自标准库和浏览器的功能）。也就是说，你静态地知道所有的全局变量。

- 模块导入：你也能静态地知道。
- 模块局部变量：可以通过静态检查模块来确定。

这有助于检查给定的标识符是否拼写正确。这种检查是程序检测器中一个受欢迎的特性，如JSLint和JSHint; 而在 ECMAScript 6 中，大多数可以由 JavaScript 引擎执行。

#### 同时支持同步和异步加载

ECMAScript 6 模块必须能独立于引擎加载模块，不论是否同步地（例如在服务器上）或异步地（例如在浏览器中）。它的语法非常适合于同步加载，通过其静态结构启用异步加载：因为你可以静态确定所有导入，您可以在评估模块的主体之前加载它们（这种让人联想到AMD模块的方式）。



### 问题&应用&技巧

#### Tree-shaking 原理与使用

*`tree shaking`* 是一个术语，通常用于描述移除 JavaScript 上下文中的未引用代码(dead-code)。它依赖于 ES2015+ 模块系统中的静态结构特性，例如 `import` 和 `export`。这个术语和概念实际上是兴起于 ES2015 模块打包工具 rollup。

新的 webpack 4 正式版本，扩展了这个检测能力，通过 `package.json` 的 `"sideEffects"` 属性作为标记，向 compiler 提供提示，表明项目中的哪些文件是 "pure(纯的 ES2015 模块)"，由此可以安全地删除文件中未使用的部分。

> 在一个纯粹的 ESM 模块世界中，识别出哪些文件有副作用很简单。然而，我们的项目无法达到这种纯度，所以，此时有必要向 webpack 的 compiler 提供提示哪些代码是“纯粹部分”。如果所有代码都不包含副作用，我们就可以简单地将该属性标记为 `false`，来告知 webpack，它可以安全地删除未用到的 export 导出。
>
> ```json
> // package.json
> {
> "name": "your-project",
> "sideEffects": [
> "./src/some-side-effectful-file.js"
>   ]
> }
> ```

💡：注意，任何导入的文件都会受到 `tree shaking` 的影响。这意味着，如果在项目中使用类似 `css-loader` 并导入 CSS 文件，则需要将其添加到 side effect 列表中，以免在生产模式中无意中将它删除：

```json
{
"name": "your-project",
"sideEffects": [
"./src/some-side-effectful-file.js",
"*.css"
  ]
}
```

最后，还可以在 [`module.rules` 配置选项](https://github.com/webpack/webpack/issues/6065#issuecomment-351060570) 中设置 `"sideEffects"`。

```javascript
module.rules: [
  {
    include: path.resolve("node_modules", "lodash"),
    sideEffects: false
  }
]
```

通过如上方式，我们已经可以通过 `import` 和 `export` 语法，找出那些需要删除的“未使用代码(dead code)”，然而，我们不只是要找出，还需要在 bundle 中删除它们。为此，我们将使用 `-p`(production) 这个 webpack 编译标记，来启用 uglifyjs 压缩插件。

> 从 webpack 4 开始，也可以通过 `"mode"` 配置选项轻松切换到压缩输出，只需设置为 `"production"`。
>
> ```javascript
> const path = require('path');
>
> module.exports = {
>   entry: './src/index.js',
>   output: {
>     filename: 'bundle.js',
>     path: path.resolve(__dirname, 'dist')- }
>   },
>   mode: "production"
> };
> ```

在实际项目中，我们使用的第三方库很多是以UMD模式定义的，比如lodash :

![image-20190805113336440](/images/image-20190805113336440.png)

上面我们说过，只有ES 模块的 静态结构特性才能使用TreeShaking优化剔除无用模块导出，所以如果要使用 `TreeShaking` 来优化 `bundle` 的大小，我们要尝试去找对应库的ES模块的实现或替代，比如 [lodash-es](https://github.com/lodash/lodash/tree/es)



#### 如何让浏览器直接执行含modules定义的脚本?

现在 Safari, Chrome, Firefox 和 Edge 已经都支持了 ES Modules 的 `import`语法， 就像下面这样：

```html
<script type="module" src="app.js"></script>
```

```javascript
// app.js
import { tag } from './html.js'

const h1 = tag('h1', ' Hello Modules!')
document.body.appendChild(h1)
```

只要加上`type="module"`， 浏览器就会以 ES 模块加载方式去加载你的文件了，浏览器不会重复下载每个模块。

对于旧版本或不支持的浏览器，可以使用带 `nomodule`属性的 script来做兼容处理：

```html
<script type="module" src="runs-if-module-supported.js"></script>
<script nomodule src="runs-if-module-not-supported.js"></script>
```

##### 得失利弊:

- 缓存上的优势：以多个独立的 ES 模块构成的js 程序，将会对缓存有所帮助，因为页面将只需要重新下载修改的模块而不是一整个改变了的 bundle（合并了众多js模块在一个文件中）。
- ES 模块不会阻塞页面渲染，默认的行为就像`<script defer>`一样
- 让浏览器加载ES模块会产生更多的浏览器请求（看下面的例子），这在目前来说是一个弊端（受限于浏览器和网络），相信在未来，随着http2协议的应用 和 网络速度的进一步提升，这将不是一个主要问题。
- 如果需要跨域加载 ES 模块，则需要js资源支持`CORS`

```html
<!-- 下面这段代码会产生 460个文件请求，这在现在是无法接受的 -->
<script type="module">
  import _ from 'https://unpkg.com/lodash-es'
</script>
```

让浏览器直接加载 ES 模块现在还未被广泛的实践，可以做一些试验性的尝试，但并不推荐普遍应用到生产环境中去。



#### 在 NodeJS中使用 ES Modules ?

ES 模块在 Node中使用需要使用特定的 tag (`--experimental-modules`)， 虽然CommonJS 和 ES6 模块语法相近，但是他们的工作机制却十分不同。

- ES 模块是预加载的，在代码执行之前就解决了后续的模块引用问题；
- CommonJS 模块只有被执行到时才会去解决模块间的依赖。

例如：有如下ES Modules代码

```javascript
// ES2015 modules

// ---------------------------------
// one.js
console.log('running one.js');
import { hello } from './two.js';
console.log(hello);

// ---------------------------------
// two.js
console.log('running two.js');
export const hello = 'Hello from two.js';
```

输出结果：

```bash
running two.js
running one.js
hello from two.js
```

用CommonJS实现相同代码：

```javascript
// CommonJS modules

// ---------------------------------
// one.js
console.log('running one.js');
const hello = require('./two.js');
console.log(hello);

// ---------------------------------
// two.js
console.log('running two.js');
module.exports = 'Hello from two.js';
```

```bash
running one.js
running two.js
hello from two.js
```

在有些对执行顺序有严格要求的程序中，这种不一致性会变成问题产生的隐患。

为了解决这一问题，Nodejs默认会允许 `.mjs`后缀的脚本被按ES Modules方式加载，默认的`.js`文件则会按照`CommonJS`来处理，其他配置方式可以查看官方文档：https://nodejs.org/docs/latest/api/esm.html。

###### 我们需要在NodeJS中使用ES Modules吗？

Es6 模块 只能在 V10以上的Node中使用，对于一些老项目，改写为ES modules形势并不会带来什么益处，反而会带来不兼容旧版Node等问题。

对于新项目，ES modules可以成为 CommonJS 的替代，因为他的语法和客户端js 保持一致，如果有多远运行的程序，这种语法的一致性会给程序的移植带来方便。




### 总结

- 说到模块化，社区在创造了两种主流的解决方案 CommonJS 和 AMD。
  - CommonJS主要在NodeJS平台，同步加载本地模块。( CMD 是遵循 CommonJS的思想，由浏览器端Sea.js的推进过程中衍生出来的 )。
  - AMD是非同步的，可以指定回调函数，比较适合浏览器环境。
- 各大引擎暂时都没有对import提供良好的原生支持，甚至就连 CSS 都有`@import`，这也是js模块化演进的动因之一。
- AMD 和 CMD 必须要执行代码才能确定导入和导出的内容，也就是模块的分析是在运行时进行的。
- ECMAScript 6 模块具有无法通过库添加的功能，例如非常紧凑的语法和静态模块结构（这有助于优化，静态检查等）。
- ECMAScript 6 模块 有望结束当前主流标准 CommonJS 和 AMD 之间的分裂
- UMD（[通用模块定义 Universal Module Definition](https://github.com/umdjs/umd)）是模式的名称，即使得相同的文件能够被多个模块系统（例如 CommonJS 和 AMD ）使用。一旦ES6是唯一模块成为标准，UMD已过时。
- Webpack 暂时还不支持将libTarget设置为`module`来输出运行时可以使用的ES 模块形式代码。

### 参考资料

> 参考
>
> AMD https://github.com/amdjs/amdjs-api/blob/master/AMD.md
>
> CommonJS (http://wiki.commonjs.org/wiki/CommonJS)
>
> CMD 模块定义规范 https://github.com/seajs/seajs/issues/242
>
> 《前端模块化那点历史》 https://github.com/seajs/seajs/issues/588
>
> 深入理解 ES Modules https://www.zcfy.cc/article/es-modules-a-cartoon-deep-dive-mozilla-hacks-the-web-developer-blog
>
> Using ES Modules in the Browser Today https://www.sitepoint.com/using-es-modules/
>
> Understanding ES6 Modules https://www.sitepoint.com/understanding-es6-modules/
