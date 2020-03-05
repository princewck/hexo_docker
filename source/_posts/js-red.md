---
title: JavaScript高级程序设计（第3版）要点总结
date: 2020-02-01 17:09:05
category: 前端开发
tags: js技巧
thumbnail: /images/protractor.jpeg
---

##### 完整的 JavaScript 实现由以下三部分组成

- ECMAScript 核心
- 文档对象模型DOM
- 浏览器对象模型BOM

- `script`标签的属性
  - `async` 表示立即下载，但不应妨碍页面中的其他操作
  - `defer` 表示可以延迟到文档完全解析和显示之后再执行。
  - 除了带`async`和`defer`的情况，页面中的`script`总是按在页面中的顺序依次解析。
  - `<script>`标签不支持自闭合写法，因为这种语法不符合 HTML  规范，很多浏览器不支持。



##### 文档类型

标准模式

```html
<!-- HTML 4.01 严格型 -->
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">

<!--XHTML 1.0 严格型 -->
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">

<!-- HTML 5 -->
<!DOCTYPE html>
```

> 准标准模式，通过使用过度型或框架集文档类型来触发。我们通常把除混杂模式外的模式都称为标准模式。

混杂模式：除了标准模式（和准标准模式）之外的其他模式

##### 严格模式

ES5开始引入严格模式，用法，在脚本顶部或函数体顶部增加：

```javascript
"use strict"
```

##### 数据类型

- 简单数据类型（5种）
  - `Undefined`
  - `Null`
  - `Boolean`
  - `Number`
  - `String`
- 复杂数据类型 (1种)
  - `Object`：由无序键值对组成

`typeof`返回值类型：

- `undefined`
- `boolean`
- `string`
- `number`
- `object`
- `function`

> typeof 不是函数，而是操作符，所以括号可以不用写，如 `typeof null`

```javascript
var b;
typeof a; // a is not defined ==> "undefined"
typeof b; // ==> "undefined"
```

为什么 `typeof null`结果为 `object`

> 因为 `null` 类型的含义其实是代表一个空对象的指针，所以返回`object`有其合理性。

###### 数字类型

8 进制数第一位必须是`0`，如 `010`代表十进制8，八进制字面量不能用于严格模式。

十六进制前两位必须是 `0x`

计算时所有八进制和十六进制都会转换成十进制。

关于浮点数计算会产生误差的问题，这是基于 IEEE754 数值的浮点计算的通病

**科学表示法**：

```javascript
1e+3 // 1000
```

NaN是一个特殊的数值类型的值，`NaN`与任何值都不等，包括它自身

```javascript
NaN == 	NaN; // false
```

类型转换

```javascript
isNaN(NaN); // false
isNaN('10'); // false
isNaN('blue'); // true
isNaN(true); // false
```

数值转换

```javascript
Number(undefined); // NaN
Number('011'); // 11
Number('0xf'); // 15
Number(''); // 0
Number('Infinity'); // Infinity
```

> 一元加操作符（`+`）的操作和 Number 函数相同

由于Number函数在转换字符串时比较复杂且不够合理，因此处理整数更常用 `parseInt`

`parseInt`接受第二个参数表示要转换的数值的进制：

```JavaScript
var num = parseInt("AF", 16);
```

> ES5 开始, parseInt 不传第二个参数时，不能用于解析八进制值。

###### 字符串类型 string

ECMAScript 中的字符串是不可变的，一旦创建它的值就不能改变。要改变某个变量保存的字符串，首先要销毁原来的值，然后再用一个包含新值的字符串填充该变量。

数值、布尔值、对象和字符串都有 `toString`方法，`null`和 `undefined`没有此方法。`toString`支持传一个参数表示进制。

> 在不清楚要转换的是不是 `null`或`undefined`时，可以使用 `String()`函数，它能将任何类型的值转换为字符串。`null`和 `undefined`会被转换成字符串`'null'`和 `'undefined'`

要把某个值转换为字符串，可以使用以下方式：

```javascript
var a = 1;
var stra = a + '';
```

###### 对象类型 object

`toLocalString`常用于数字类型转换为带`,`格式的字符串：

```javascript
var a = 1000000;
console.log(a.toLocalString()); // 1,000,000
```

##### 语句

用 `for`语句 实现无限循环：

```javascript
for(;;) {
	//  do something
}
```

下面这种用法等价于 `while`

```javascript
var count = 10;
var i = 0;
for (; i < count; ) {
  alert(i);
  i++;
}
```

`for-in`，迭代对象为`null`或 `undefined`时 ES5以前的版本会抛出错误，ES5修正该错误改为不执行循环体，为了兼容性，使用 `for-in` 之前需要先检查对象是不是 `null` 或 `undefined`。

`break`和`continue`

- break：停止循环，执行循环后面的语句。
- continue：退出循环，从循环的顶部继续执行。

##### 函数

js 中的参数在内部是使用一个类数组表示的，它不是 `Array` 的实例

js 中没有重载，可以通过检查传入函数中参数的类型和数量并作出不同的反应来模仿其他语言中的函数重载。

##### 变量、作用域、内存问题

[堆和栈的区别 ](https://blog.csdn.net/sinat_15951543/article/details/79228675)

**<u>参数传递</u>**：当向参数传递引用类型的值时，会把这个值在内存中的地址复制给一个局部变量，因此这个局部变量的变化会反映在函数外部。

**<u>执行环境</u>**：每个函数都有自己的执行环境，当执行流进入一个函数时，函数的环境就会被推入一个环境栈中，而在函数执行后，栈将其环境弹出，把控制权返回给之前的执行环境。

当代码在一个环境中执行时，会创建变量对象的一个**作用域链**（scope chain）用于搜索变量和函数，作用域链的用途，是保证对执行环境有权访问的所有变量和函数的有序访问。

<u>**标识符解析**</u>是沿着作用域链一级一级地搜索标识符的过程。搜索过程始终从作用域链的前端开始，然后逐级向后回溯，直到找到标识符为止（如果找不到，会导致错误）。

###### **垃圾收集**

- 标记清除（主流）
- 引用计数（有循环引用问题）

###### 管理内存

确保占用最少的内存可以让页面获得更好的性能，而优化内存占用的最佳方式，就是为执行中的代码只保留必要的数据，一旦数据不再有用，最好通过将其值设置为 null 来释放其引用，这个做法叫做**解除引用**（ dereferencing ）。

> 局部变量在离开其执行环境时会自动解除引用，全局变量则需要我们显式地为它解除引用。

##### 数组

>  数组的最大长度 4294967295，超过这个长度会发生异常

###### 检测数组

`value instanceof Array`的问题，它假设只有一个全局环境，如果页面有多个 frame 那么就会存在多个 Array 构造函数，如果一个框架把数组传给另一个那么它使用这种方式检测数组是有问题的。

为了解决这个问题，ES5以上的版本中可以使用 `Array.isArray()`检测数组，IE9+ 的浏览器均可使用。

###### 方法

`Array.prototype.slice` 方法

- 如果参数是负数，则执行时使用数组长度加该负数。如 `arr.slice(1, -1)`
- 第二个参数缺省时默认提取到数组末尾
- 常用无参数形式 `arr.slice()` 来实现数组的浅拷贝

归并方法

- `reduce`从左到右
- `reduceRight` 从右到左

##### 日期

使用字符串创建日期：

```javascript
var date = new Date(Date.parse("May 25, 2004")); // 字符串因地区而异
var date2 = new Date("May 25, 2004"); // 内部默认对字符串调用了 Date.parse
```

常用时间组件方法：

- getTime 与 valueOf 返回值同
- setTime 用毫秒数设置日期
- getFullYear / setFullYear 使用4位数年份
- getMonth / setMonth 月份，0表示1月
- getDate / setDate 月内的日期，从 1 到 31
- getDay 星期，0表示星期日
- getHours / setHours 小时数， 0 - 23， 设置时超过23则加一天
- getMinutes / setMinutes 分钟数 0 - 59
- getSeconds / setSeconds 秒， 0 - 59
- getMilliseconds / setMilliseconds  毫秒数获取/设置

##### 正则

使用正则表达式字面量和使用 RegExp 构造函数创建的正则表达式不一样，字面量始终共享同一个 RegExp 实例，而使用构造函数创建的是不同的实例。

看如下例子，注意比较区别：

```javascript
var re = /cat/g;
var i;
for (i = 0; i < 10; i++) {
  re.test("catastrophe"); // true, false, true, false ,...
  // 匹配到一次后，下一次会从lastIndex = 3开始，此时没有找到 
  // 因为没找到时, lastIndex 会变成 -1， 下一次又从头开始，所以结果是 true 和 false 交替
}
for (i =0; i < 10; i++) {
  re = new RegExp("cat", "g");
  re.test("catastrophe"); // true, true, true, ....
}
```

> [MDN: 当设置全局标志的正则使用`test()`](https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/Reference/Global_Objects/RegExp/test)
>
> 如果正则表达式设置了全局标志，`test() `的执行会改变正则表达式   [`lastIndex`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/RegExp/lastIndex)属性。连续的执行`test()`方法，后续的执行将会从 lastIndex 处开始匹配字符串，([`exec()`](https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/Reference/Global_Objects/RegExp/exec) 同样改变正则本身的 `lastIndex属性值`).

正则对象的主要方法是`exec()`，该方法是为捕获组而设计的，看下面例子：

```JavaScript
var text = "mom and dad and baby";
var pattern = /mon( and dad ( and baby)?)?/gi;
console.log(match.index); // 0
console.log(match.input); // mom and dad and baby
console.log(match[0]); // mom and dad and baby
console.log(match[1]); // and dad and baby
console.log(match[2]); // and baby
```

正则还有9个用于存储捕获组的构造函数属性，`$1`- `$9`。在使用 `exec()` 或 `test()`  方法时，这些属性会被自动填充：

```javascript
var text = 'this has been a short summer';
var pattern = /(..)or(.)/g;
if (pattern.test(text)) {
  alert(RegExp.$1); // sh
  alert(RegExp.$2); // t 
}
```

##### Function 类型

函数声明和函数表达式是两种初始化函数的方法，两种方式的区别：

解析器会率先读取函数声明，并使其在执行任何代码之前可用，至于函数表达式，必须等到解析器执行到它所在的代码行，才会真正被解析执行。

> 解析器通过一个称为**函数声明提升**的过程，读取并将函数声明添加到执行环境中。

##### Boolean类型

```javascript
var b = new Boolean(false);
!!b; // true
```

> 建议永远不要使用 Boolean 包装类型。

##### String 类型

比较 `slice()`、`substr()`、`substring()`

参数为正数时， 第一个参数都表示字符串的开始，第二个参数表示何时结束。

slice 和 substring 第二个参数表示结束字符的位置，substr 表示返回字符的个数。

参数为负数时，slice 方法会将传入的负值与字符串的长度相加，substr 会把负的第一个参数加上字符串长度，负的第二个参数转换成0， substring 会把所有负的参数都转换成0；

##### 全局对象

`encodeURI` 和 `encodeURIComponent`

-  `encodeURI`：只处理空格
- `encodeURIComponent`：处理非数字字母字符

> 只可以对整个 URI使用`encodeURI`，但可以对附加在现有 URI 后面的字符串使用 `encodeURIComponent`
>
> 不要再使用已废弃的 `escape` 和 `unescape` 方法

在任何环境下获取全局对象：

```javascript
var global = function() {
  return this;
}
```

##### 创建对象

- ###### **1.工厂模式**

```javascript
function createPerson(name, age, job) {
  var o = new Object();
  o.name = name;
  o.age = age;
  o.job = job;
  o.sayName = function() {
    alert(this.name);
  };
  return o;
}
var person = createPerson('Greg', 27, 'Doctor');
```

- ###### **2.构造函数模式**

```javascript
function Person(name, age, job) {
  this.name = name;
  this.age = age;
  this.job = job;
  this.sayName = function() {
    alert(this.name);
  }
}
var person = new Person('Greg', 27, 'Doctor');
```

- ###### **3.原型模式**

```javascript
function Person() {}
Person.prototype.name = 'Nicholas';
Person.prototype.age = 29;
Person.prototype.sayName = function() {
  alert(this.name);
}

var person = new 	Person();
```

##### 💎 理解原型对象

观察如下代码

```javascript
function Person() {}
Person.prototype.name = 'person';

Person.prototype.constructor === Person; // true

function() Man{}
Man.prototype = Person.prototype;
Man.prototype.constructor; // ƒ Person() {}

Man.prototype.constructor = Man; // 修正constructor
```

创建新函数时会根据特定规则为该函数创建一个 prototype 属性，这个属性指向函数的原型对象，默认情况下，所有原型对象会自动获得一个 constructor 属性，这个属性是一个指向 prototype 属性所在函数的指针。

调用构造函数创建一个实例后，该实例内部将包含一个指针，指向构造函数的原型对象，即 `XX.prototype`，浏览器中通常用`__protp__`属性表示该指针。理解以下代码

```javascript
var person = new Person();
person.__proto__ === Person.prototype; // true
```

原型上的属性和方法被所有实例共享，实例可以访问原型上的属性但是无法修改它。

```javascript
function Person() {}
Person.prototype.age = 1;

var p1 = new Person();
var p2 = new Person();

p1.age ++ // 增加了实例属性 p1.age = 2屏蔽了对原型属性的访问;
console.log(p2.age); // 1
delete p1.age; // 删除实例属性

const proto = Object.getPrototypeOf(p1);
proto.age ++; // 这样修改共享的变量
console.log(p2.age); // 2 

// 但对数组等引用类型，还是可以被修改的，这也是原型对象的一个问题
```

更简单的原型语法：

```javascript
Person.prototype = {
  name: 'Nicholas',
  age: 29
};
// Person.prototype 的 constructor属性变成了用字面量创建对象的原型，即 Object

var friend = new Person();
alert(friend instanceof Person); // true
alert(friend.constructor == Person) // false
alert(friend.constructor == Object) // true

Person.prototype.constructor = Person; // 修正原型对象,或直接在上面字面量对象中设置constructor
// 上面存在的问题是constructor变成可枚举属性了，ES5 以上版本可以使用 Object.defineProperty
Object.defineProperty(Person.prototype, "constructor", {
  enumerable: false,
  value: Person
});

```

> 实例和原型之间的连接其实是一个指针，而不是副本，所以可以在原型上添加属性和方法可以被已经创建的实例访问到。但是如果完全重写原型对象，则会出错：
>
> ```javascript
> function Person() {}
> var friend = new Person();
> Person.prototype = {
>   constructor: Person,
>   name: 'Nicholas',
>   age: 29,
>   sayName: function() {
>     alert(this.name);
>   }
> };
> 
> friend.sayName(); //error
> ```

- 寄生构造函数模式

```javascript
function Person(name, age, job) {
  var o = new Object();
  o.name = name;
  o.age = age;
  o.job = job;
  o.sayName = function() {
    alert(this.name);
  };
  return o;
}
```

> 寄生构造函数模式的问题，不能使用 instanceof 来确定类型

##### 💎继承

ECMAScript 将原型链作为实现继承的主要方法。

######  组合继承

原型链 + 借用构造函数技术

- 原型链：原型属性和方法的继承

- 借用构造函数：实例属性的继承

```JavaScript
function SuperType(name) {
  this.name = name;
  this.colors = ['red', 'blue', 'green'];
}
SuperType.prototype.sayName = function() {
  alert(this.name);
}

function SubType(name, age) {
  // 继承属性
  SuperType.call(this, name); // 第一次调用超类型构造函数
  this.age = age;
}
// 继承方法
SubType.prototype = new SuperType(); // 第二次调用超类型构造函数
SubType.prototype.constructor = SubType;
SubType.prototype.sayAge = function() {
  alert(this.age);
}

var instance1 = new SubType('Nicholas', 29);
instance1.colors.push('black');
alert(instance1.colors);
instance1.sayName();
instance1.sayAge();

var instance2 = new SubType('Greg', 27);
alert(instance2.colors);
instance2.sayName();
instance2.sayAge();
```

###### 原型式继承

没有使用严格意义上的构造函数，也没有自定义新的类型：

```javascript
function object(o) {
  function F(){};
  f.prototype = o;
  return new F();
}
```

ES5 新增了 `Object.create`方法规范了原型式继承。这个方法接收两个参数，一个用作新对象原型的对象和一个为新对象定义额外属性的对象。

> ```javascript
> var person = { gender: 'female' };
> var Man = Object.create(person, { name: { value: 'Bob' } });
> ```

###### 寄生式继承

```javascript
function createAnother(original) {
  var clone = Object(original); // Object 不是必须的，通过调用函数创建新对象都可以
  clone.sayHi = function() { // 增强这个对象
    alert('hi');
  };
  return clone;
}

var person = {
  name: 'Nicholas',
};
var anotherPerson = createAnother(person);
anotherPerson.sayHi();
```

> 这种方式实例中的方法不是共享的，因为函数不能复用而效率降低。与构造函数模式相似

###### 寄生组合式继承

前面说过组合继承是最常用的继承模式，不过它也有它的不足。组合继承最大的问题是，无论在什么情况下，都会调用两次超类构造函数：

- 一次是在创建子类型原型的时候
- 另一次是在子类型构造函数内部

解决办法：寄生组合式继承

```javascript
function inheritPrototype(subType, superType) {
  var prototype = Object(superType.prototype);
  prototype.constructor = subType;
  subType.prototype = prototype;
}

function SuperType(name) {
  this.name = name;
  this.colors = ['red', 'blue', 'green'];
}

SuperType.prototype.sayName = function() {
  alert(this.name);
}
function SubType(name, age) {
  SuperType.call(this, name);
  this.age = age;
}

inheritPrototype(SubType, SuperType);
SubType.prototype.sayAge = function() {
  alert(this.age);
}
```

> 这个例子高效率体现在它只调用了一次 SuperType 构造函数，并且避免了在 SubType.prototype 上面创建不必要的、多余的属性。与此同时，原型链还能保持不变，还能够正常使用 instanceof 和 isPrototypeOf()，这是引用类型最理想的继承范式。

##### 函数表达式

###### 理解函数声明提升

```javascript
// 不要这样做
if (condition) {
  function sayHi() {
    alert('Hi!');
  }
} else {
  function sayHi() {
    alert('Yo!');
  }
}
```

>  这在 ECMAScript 中属于无效语法，不应该出现在代码里！

###### 闭包

闭包是指有权访问另一个函数作用域中变量的函数。创建闭包的常见方式，就是在函数内部创建另一个函数。

这里需要我们对作用域链有一个清楚的理解，当函数被调用时，会创建一个执行环境及相应的作用域链。然后，使用 arguments 和 其他明明参数的值来初始化函数的活动对象。但在作用域链中，外部函数的活动对象始终处于第二位，外部函数的外部函数的活动对象处于第三位，。。。直至作为作用域链终点的全局执行环境。

在函数的执行过程中，为读取和写入变量的值，就需要在作用域链中查找变量。

###### 闭包与变量

作用域链的配置机制引出了一个值得注意的副作用，即闭包只能取得包含函数中任何变量的最后一个值。因为闭包保存的是整个变量对象，而不是某个特殊的变量。看下面例子：

```javascript
function createFunctions() {
  var result= [];
  for (var i = 0; i < 10; i++) {
    result[i] = function() {
      return i;
    }
  }
  return result;
}
```

这个函数会返回一个函数数组，似乎每个函数都应该返回自己的索引值。但实际上所有函数都会返回 10；因为每个函数作用域链中都保存着 createFunctions 的活动对象，所以他们引用的都是同一个变量 i 。当 createFunctions 返回后， i 的值是10， 此时每个函数都引用着保存变量 i 的同一个变量对象，所以在每个函数内部 i 的值都是10；我们可以通过创建另一个匿名函数强制让闭包的行为符合预期：

```javascript
function createFunctions() {
  var result = new Array();
  for (var i = 0; i < 10; i++) {
    result[i] = function (num) {
      return function() {
        return num;
      }
    }(i);
  }
}
```

###### 闭包中的 this

```javascript
var name = 'The window';
var object = {
  name: 'My Object',
  getNameFunc: function() {
    return function() {
      return this.name;
    }
  }
};

alert(object.getNameFunc()()); // The window
```

###### 模仿块级作用域

```javascript
(function() {
  // 此处为块级作用域
})();
```

注意以下形式会出错：

```javascript
function() {
  // 此处为块级作用域
}(); //  出错
```

原因是函数声明后面不能跟圆括号，而函数表达式后面可以跟圆括号。加上圆括号可以将函数声明转化为函数表达式。

> 这种做法也不存在闭包占用内存问题，因为没有指向匿名函数的引用，只要函数执行完毕，就可以立即销毁其作用域链了。

#### 闭包有哪些用途？

- 实现 js 中的块级作用域 （IIFE， 缓存数据， 封装）
- 实现静态私有变量和单例模式

------

#### window对象

###### 全局变量和直接在 window上定义属性有何区别：

```javascript
var age = 29;
window.color = 'red';

delete window.age; // false
delete window.color; // true
```

`var` 声明的全局变量，[[configurable]]属性为 false，不能使用 `delete `操作符删除。

###### setTimeout ( setInterval )的问题

`setTimeout` 的第二个参数表示等待多长时间的毫秒数，但经过该时间后指定的代码不一定执行。js 是单线程语言，因此一定时间内只能执行一段代码。为了控制要执行的代码，就有一个 JavaScript 任务队列。setTimeout 告诉js 再过多长时间把当前任务添加到队列中，如果队列是空的，那么添加的代码会立即执行，如果队列不是空的，那么就要等前面代码执行完了以后再执行。件下面的<u>**事件循环**</u>。

> 用 setTimeout 来模拟 setInterval 是最佳实践，很少直接使用 setInterval，因为使用 setInterval 后一次调用可能会在前一次调用结束前启动，这不符合我们的预期。

###### 事件循环( Event Loop)

// todo



#### 客户端检测

IE5.0 之前不支持`document.getElementById()`如何兼容？

```javascript
function getElement(id) {
  if (document.getElementById) {
    return document.getElementById(id);
  } else if (documet.all) {
    return document.all[id];
  } else {
    throw new Error('No way to retrieve element');
  }
}
```

###### 用户代理检测

检测用户使用的是什么浏览器  （略）

#### 💎DOM（文档对象模型）

一个层次化的节点树

##### NodeList 

每个结点都有一个 childNodes属性，保存着一个 NodeList，NodeList 是一种类数组对象，它是基于 DOM 结构动态执行查询的结果，因此 DOM 结构变化能自动反映在 NodeList 中。

> NodeList 是有生命、有呼吸的对象，而不是在我们第一次访问它们的某个瞬间拍摄下来的一张快照。

NodeList 转换为数组：

```javascript
function convertToArray(nodes) {
  var array = null;
  try {
    array = Array.prototype.slice.call(nodes, 0); // 针对非 IE 浏览器
  } catch (e) {
    array = new Array();
    for (var i = 0, len = nodes.length; i < len; i++) {
      array.push(nodes[i]);
    }
  }
}
```

#####  结点关系

- Node
- `childNodes`
- `firstChild`
- `lastChild`
- `nextSibling`
- `previousSibling`
- `hasChildNodes()`

##### 操作结点

- `appendChild()`
- `insertBefore()`

```javascript
someNode.insertBefore(newNode, null); // 插入后成为最后一个结点
```

- `replaceChild()`

```javascript
parentNode.replaceChild(newNode, parentNode.lastChild);
```

- `removeChild()`

##### Document

文档信息

- `document.title`
- `document.URL`
- `document.domain`

查找结点

- `document.getElementById()`
- `document.getElementsByTagName()`,想要获取全部元素可以传入 `*`

> `document.getElementsByTagName()`返回类型为 `HTMLCollection`，和 `NodeList`类似（即时更新，DOM 改变会实时反映到结果中）
>
> `HTMLCollection.namedItem()` 可以获取 `[name=??]`的元素

- `document.getElementsByName()` document 特有

特殊集合

- `document.anchors`
- `document.forms`
- `document.links`

##### Element

列举一些常用方法和属性

```javascript
div.getAttribute('id');
div.setAttribute('id', 'anotherId');
div.removeAttribute('id'); // > IE 6.0
div.id; // 获取 id
div.align;

var div = document.createElement('div');
```
遍历结点的问题
```html
<ul id="list">
	<li>item 1</li>
	<li>item 2</li>
	<li>item 3</li>  
</ul>
```

```javascript
const element = document.getElementById('list');
for (var i =0, len = element.childNodes.length; i < len; i++) {
  // 空白和换行会以 <text> 结点出现，检查nodeType过滤掉
  if (element.childNodes[i].nodeType === 1) {
    // ...
  }
}
```

`element.normalzie()`

用于合并element下多个相邻的 `<text>`标签。

`element.splitText()`

与 normalize 相反

##### 选择符API

- `querySelector`
- `querySelectorAll`，底层实现类似于一组元素的快照，而非动态查询，区别于 `document.getElementsByTagName`的结果
- `document.matchesSelector`（`document.webkitMatchesSelector`）

##### 遍历元素

```javascript
var i,len,child = element.firstElementChild;
while(child != element.lastElementChild) {
  processChild(child);
  child = child.nextElementSibling;
}
```

##### HTML5 API 

- `getElementsByClassName()`
- `classList`
  - add
  - contains
  - remove
  - toggle
- `document.activeElement`
- `document.hasFocus()`
- `document.readyState`
  - loading
  - complete
- `document.head`
- `document.charset`
- `element.dataset`
- `innerHTML`
- `outerHTML`
- `scrollIntoView()`
- `children` , 与 `childNodes`的区别是它只包含元素类型的结点，不包含  `<text>`结点
- `contains()`，用 `compareDocumentPosition()`也可以确定节点之间的关系
- `innerText`/`outerText`
- `scrollIntoViewIfNeeded(alignCenter)`
- `scrollByLines(lineCount)`
- `scrollByPages(pageCount)`

#### 事件

###### 冒泡和捕获

事件冒泡（IE团队提出），事件开始时由最具体的元素接收，即嵌套层次最内层的元素，然后逐级向上传播到较为不具体的节点。

事件捕获（Netscape团队提出），与冒泡相反，最不具体的节点最先接收到事件，然后沿着DOM树向内。

###### DOM事件流

包括三个阶段：

- 事件捕获阶段
- 处于目标阶段
- 事件冒泡阶段

```
document
	- html
		- body
			-div
```

点击上面的 div 时，div 在捕获阶段不会接收到事件，实际事件从 document 到 body 后就停止了，然后开始“处于目标”阶段，于是事件在 div 上发生了，并在事件处理中被看成是冒泡阶段的一部分，然后进入冒泡阶段，事件又传播回文档。

###### 事件处理

DOM0级事件处理

```javascript
var btn = document.getElementById('myBtn');
btn.onclick = function() {
  alert(this.id); // this 作用域为当前 btn 元素
}

btn.onclick = null; // 删除事件
```

DOM2级事件处理

```javascript
var btn = document.getElementById('myBtn');
function handler() {
  alert(this.id);
}
btn.addEventListener('click', handler, false);
btn.removeEventListener('click', handler);
```

> 好处是可以指定多个事件处理程序

IE 事件处理

```javascript
var btn = document.getElementById('myBtn');
function handler() {
  alert('clicked');
	console.log(this === window); // true, this 为全局作用域
}
btn.attachEvent('onclick', handler);

btn.detachEvent('click', handler);
```

跨浏览器兼容

```javascript
var EnentUtils = {
  addHandler: function(element, type, handler) {
    if (element.addEventListener) {
      element.addEventListener(type, handler, false);
    } else if (element.attachEvent) {
      element.attachEvent('on' + type, handler);
    } else {
      element['on' + type] = handler;
    }
  },
  removeHandler: function(element, type, handler) {
    // 略
  }
}
```

###### 禁用系统默认的右键菜单

```javascript
window.addEventListener('contextmenu', function(e) {
  e.preventDefault();
  // 可在此实现自定义右键菜单逻辑
  // e.clientX 和 e.clientY 帮我们确定鼠标在页面的位置
});
```

###### DOMContentLoaded 事件

形成完整的 DOM 树之后就会触发，不会处理图像， Javascript 文件， CSS 文件或其他资源是否已经下载完毕。与 `load` 事件不同，`DOMContentLoaded` 支持在页面下载的早期添加事件处理程序，也就意味着用户能够尽早地与页面进行交互。

###### 检测设备运动

```javascript
window.addEventListener('devicemotion', function (e) {
  if (e.rotationRate !== null) {
    console.log(e.rotationRate.alpha);
    console.log(e.rotationRate.beta);    
    console.log(e.rotationRate.gamma);    
  }
})
```

###### 事件委托

借助冒泡机制，把事件委派给高层元素集中处理，减少时间事件绑定（函数也是对象，占用内存），节省内存开销。

#### 表单

###### focus

加载后默认focus第一个字段

```javascript
window.addEventListener('load', function () {
  documents.forms[0].elements[0].focus();
});
```

不使用js，H5的 `autofocus`：

```javascript
<input type="text" autofocus />
```

限制<input/>的输入长度

```javascript
<input type="text" maxlength="5" />
```

###### 过滤输入

限制输入内容格式，使用 `keypress`事件，分析 `event.charCode `：

```javascript
    const input = document.querySelector('input');
    input.addEventListener('keypress', e => {
      const pressed = String.fromCharCode(e.charCode);
      if (
        !/\d/.test(pressed)
        && e.charCode  > 9 // 适配移动端
        && !event.ctrlKey // 不能屏蔽 ctrl + ? 组合键
      ) {
        e.preventDefault();
      }
    });
```

###### 处理剪贴板

接上面例子的逻辑，验证粘贴内容是数字

```javascript
input.addEventListener('paste', e => {
  const text = e.clipboardData.getData('text');
  if (!/\d/.test(text)) {
    e.preventDefault();
  }      
});
```

###### 富文本编辑器

实现思路： 

- iframe 嵌入页面 + `document.designMode = 'on'`
- content editable 属性

`document.execCommand()`操作富文本

#### HTML5 脚本编程

##### 跨文档消息传递

使用`postMessage(data, origin )`方法，跨域传递消息

##### 原生拖放

1. 可拖动元素增加 `draggable="true"`属性
2. 放置区域事件

```javascript
dragEle.addEventListener('dragstart', e => {
  // 支持 text 和 url
  d.dataTransfer.setData('text', 'some text info');
});


dropEle.addEventListener('dragover', e => {
  e.preventDefault();
  dropEle.style.background = 'yellow';
})

dropEle.addEventListener('dragenter', e => {
  e.preventDefault();
  dropEle.style.background = 'lightblue';
});

dropEle.addEventListener('drop', e => {
  const data = e.dataTransfer.getData('text');
  console.log(data);
  // 根据被拖元素和放置位置分析拖放元素关系，操作DOM达到交换元素或数据的目的
})

```

`event.dataTransfer`

- setData(['text'|'url'], data)
- getData('text'|'url')
- clearData
- setDragImage(element, x, y)

#### History API

- `history.pushState(stateData, '', '/path')`
- `history.replaceState(stateData, '', '/path')`

#### 错误处理与调试

###### 错误上报

```javascript
function logError() {
  var img = new Image();
  img.src = 'log.php?sev=' + encodeURIComponent(sev) + '&msg=' + encodeURIComponent(msg);
}
```

我们常见到许多统计类SDK会发送类似的图片请求，用图片请求上报错误有什么优势？

- 所有浏览器都支持Image对象，包括那些不支持XMLHttpRequest对象的浏览器。
- 可以避免跨域限制。通常都是一台服务器要负责处理多台服务器的错误，而这种情况下使用XMLHttpRequest是不行的。
- 在记录错误的过程中出问题的概率比较低。大多数Ajax通信都是由JavaScript库提供的包装函数来处理的，如果库代码本身有问题，而你还在依赖该库记录错误，可想而知，错误消息是不可能得到记录的。

> IE, FF , Chrome 可以使用`window.onerror` 捕获未被处理的异常和错误

##### XHR

https://developer.mozilla.org/zh-CN/docs/Web/API/XMLHttpRequest

```javascript
function createXHR() {
  if (typeof XMLHttpRequest != 'undefined') {
		return new XMLHttpRequest();
  } else if (typeof ActiveXObject != 'undefined') {
    // 兼容IE 
    if (typeof arguments.callee.activeXString != 'string') {
      var versions = [
        'MSXML2.XMLHttp.6.0',
        'MSXML2.XMLHttp.3.0',        
        'MSXML2.XMLHttp'
      ];
      var i, len;
      for (i =0, len = versions.length; i < len; i++) {
        try {
          new ActiveXObject(versions[i]);
          arguments.callee.activeXString =versions[i];
          break;
        } catch (ex) {
          // 跳过
        }
      }
      return new ActiveXObject(arguments.callee.activeXString);
    } else {
      throw new Error('No XHR object available.');
    }
  }
}

var xhr = createXHR();
xhr.open('get', 'example.php', false); // 这里为 false，使用同步请求
xhr.send(null);

if ((xhr.status >= 200 && xhr.status < 300) || xhr.status == 304) {
  console.log(xhr.responseText);
} else {
  console.error('Request was unsuccessful:' +xhr.status);
}
```

请求相应后响应的数据会自动填充 XHR 对象的相关属性：

- responseText
- responseXML
- status
- statueText

大多数情况我们会使用异步请求，借助 `xhr.onreadystatechange`事件和 `xhr.readyState`状态来处理。

> readyState:
>
> - 0：未初始化，尚未调用 open 方法
> - 1：启动，已经调用 open, 尚未调用 send 方法
> - 2：发送，已经调用 send， 尚未收到响应
> - 3：接收，已经收到部分相应数据
> - 4：完成，已经收到全部相应数据，而且已经可以在客户端使用了。

> 为保证跨浏览器的兼容性，必须在 `open()` 之前指定 `onreadystatechange` 事件

在服务器相应之前，可以调用 `xhr.abort()`来取消异步请求。

#### 跨域技术

常见的跨域技术

- CORS ，浏览器通过 Preflighted Requests 请求检查是否支持 CORS 
- 图像 Ping，图像Ping最常用于跟踪用户点击页面或动态广告曝光次数。
- JSONP

#### 高级用法

##### 安全的类型检测

>  “JavaScript内置的类型检测机制并非完全可靠。事实上，发生错误否定及错误肯定的情况也不在少数。比如说typeof操作符吧，由于它有一些无法预知的行为，经常会导致检测数据类型时得到不靠谱的结果。Safari（直至第4版）在对正则表达式应用typeof操作符时会返回"function"，因此很难确定某个值到底是不是函数。
> 再比如，instanceof操作符在存在多个全局作用域（像一个页面包含多个框架）的情况下，也是问题多多。”
>
> 摘录来自: 泽卡斯. “JavaScript高级程序设计（第3版）。”

```javascript
function isArray(value) {
  return Object.prototype.toString.call(value) === '[object Array]';
}

function isFunction(value) {
  retur Object.prototype.toString.call(value) === '[object Function]';
}

function isRegExp(value) {
  return Object.prototype.toString.call(value) == '[object RegExp]';
}

```

##### 作用域安全的构造函数

```javascript
function Person(name, age, job) {
  // 缺少 new 时，三个属性可能会污染全局作用域，所以做如下检查
  if (this instanceof Person) {
		this.name = name;
  	this.age = age;
    this.job = job;
  } else {
    return new Person(name, age, job);
  }
}
```

##### 防篡改对象

###### 不可扩展对象

不能加属性，但是可以删除

```javascript
var person = {name: 'Nicholas'};
Object.preventExtensions(person);
person.age = 29; // 严格模式会发生异常
console.log(person.age); // undefined

console.log(Object.isExtensible(person)); // false
```

###### 密封的对象

不能删除属性和方法

```javascript
var person = {name: 'Nicholas'};
Object.seal(person);

person.age = 29; // 严格模式会发生异常
console.log(person.age); // undefined

delete person.name;
console.log(person.name); // 'Nicholas'

Object.isSealed(person) // true
```

###### 冻结的对象

```javascript
var person = {name: 'Nicholas'};
Object.freeze(person);

person.age = 29; // 严格模式会发生异常
console.log(person.age); // undefined

delete person.name;
console.log(person.name); // 'Nicholas'

person.name = 'Greg';
console.log(person.name); // 'Nicholas'
```

#### 离线应用域客户端存储

##### 离线检测

```javascript
const isOnline = navigator.onLine
```

chrome 11 之前始终为 true （bug）, 除此之外， H5 定义了两个事件 `online ` 和 `offline`

```javascript
window.addEventListene('online', function() {
  // online
});
window.addEventListene('offline', function() {
  // online
});
```

##### 数据存储

###### Cookie

浏览器对 cookie  的限制

- 每个域 cookie 总数有限， 如IE 和 FF 限制为50个
- 长度限制，大多浏览器约4095B

js获取cookie

```javascript
document.cookie
```

用上面属性可以读取和设置 cookie，但是**并不会覆盖原有的 cookie** , `document.cookie`设置的新 cookie 会被解释并添加到现有的 cookie 集合中。可以像下面这样增加新的 cookie

```javascript
document.cookie = encodeURIComponent('name') + '=' + encodeURIComponent('Nicholas') + '; domain=.wrox.com; path=/';
```

> 这并不好用，是一个蹩脚的 API

封装cookie相关的方法以简化操作：

```javascript
var CookieUtil = {
  get: function(name) {
    var cookieName = encodeURIComponent(name)+'=';
    var cookieStart = document.cookie.indexOf(cookieName);
    cookieValue = null;
    if (cookieStart > -1) {
      var cookieEnd = document.cookie.indexOf(';', cookieStart);
      if (cookieEnd === -1) {
        cookieEnd = document.cookie.length;
      }
      cookieValue = decodeURIComponent(document.cookie.substring(cookieStart + cookieName.length, cookieEnd));
    }
    return cookieValue;
  }
  set: function(name, value, expires, path, domain, secure) {
    var cookieText = encodeURIComponent(name) + '=' + encodeURIComponen(value);
    if (expires instanceof Date) {
      cookieText += ';expires=' + expires.toGMTString();
    }
    if (path) {
      cookieText += ';path=' + path;
    }
    if (domain) {
      cookieText += ';domain=' + domain;
    }
    if (secure) {
      cookieText += ';secure';
    }
    document.cookie = cookieText;
  },
  unset: function (name, path, domain, secure) {
    this.set(name, '', new Date(0), path, domain, secure);
  }
};
```

##### Web Storage

Storage 类型只能存储字符串，非字符串数据在存储之前会被转换成字符串。

###### SessionStorage

- 浏览器（标签页）关闭后消失
- 跨页面（不跨域）刷新不会丢失

> 关于数据写入，FF 和 Webkit 为同步写入，IE为异步写入

如何遍历所有值

```javascript
for (let i =0, len = sessionStorage.length; i < len; i++) {
  const key = sessionStorage.key(i);
  const value = sessionStorage.getItem(key);
}
```

###### localStorage

- 页面同域（同域名，同协议，同端口）

其他特性可以类比 sessionStorage



###### `storage`事件

```javascript
document.addEventListener('storage', function (e) {
  alert('Storage changed for ' + event.domain);
});
```

> 不区分到底是哪一种类型的  Storage

###### 限制

- 空间大小每个来源 5M 

##### IndexedDB

略

> “IndexedDB是一种类似SQL数据库的结构化数据存储机制。但它的数据不是保存在表中，而是保存在对象存储空间中。创建对象存储空间时，需要定义一个键，然后就可以添加数据。可以使用游标在对象存储空间中查询特定的对象。而索引则是为了提高查询速度而基于特定的属性创建的。”
>
> 摘录来自: 泽卡斯. “JavaScript高级程序设计（第3版）。” Apple Books. 
