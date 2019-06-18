---
title: 快速排序的js实现
date: 2017-06-18 18:14:12
tags: 前端开发,数据结构与算法
thumbnail: /images/order.jpeg
---

### 常见算法的js实现：

##### 1. 快速排序

二分思想：快速排序的思想是选择一个中心元素，然后以它为中轴点划分元素：使它左边的元素都比它小，它右边的元素都比它大。

> 快速排序不需要辅助数组来储存排序过程中的中间数据，因此空间复杂度较低，但是也增加了时间复杂度，最差时间复杂度O(N^2), 平均时间复杂度O(NlogN)。

实现一：来自阮一峰网站：

```javascript
function quickSort(arr) {
  if (arr.length <= 1) return arr;
  var pivotIndex = Math.floor(arr.length / 2);
  var pivot = arr.slice(pivotIndex, 1)[0];
  var left = [];
  var right = [];
  for (var i = 0; i < arr.length; i++) {
    if (arr[i] < pivot) {
      left.push(arr[i]);
    } else {
      right.push(arr[i]);
    }
  }
  return quickSort(left).concat([pivot], quickSort(right));
}
```

> 缺点： 会改变原数组，每次排序后原数组中的pivot会被剪掉



针对以上问题，实现二：

```javascript
function quickSort(arr) {
  if (arr.length <= 1) return arr;
  function sort(leftIndex, rightIndex) {
    if (rightIndex <= leftIndex) return;
   	var pivot = arr[leftIndex];
	var i = leftIndex;
    var j = rightIndex;
	while (i != j) {
      while (arr[j] >= pivot && i < j) j--;
      while (arr[i] <= pivot && i < j) i++;
      var temp = arr[i];
      arr[i] = arr[j];
      arr[j] = temp;
	}
    arr[leftIndex] = arr[i];
    arr[i] = pivot;
    sort(leftIndex, i-1);
    sort(i + 1, rightIndex);
  }
  sort(1, arr.length - 1);
  return arr;
}
```

> 此实现不改变原数组对象，只是交换其中元素位置。









### 附录

> [算法复杂度计算](http://blog.csdn.net/wuxinyicomeon/article/details/5996675)
>
> 一个算法演示网页动画
>
> http://jsdo.it/norahiko/oxIy/fullscreen
