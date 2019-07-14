---
title: 【数据结构-3】图
toc: true
tags: mse 数据结构
thumbnail: /images/thumbnails/ds3.png
category: '计算机基础'
date: 2019-07-02 17:02:38
---
[TOC]
# 图
> 
>
> 考纲内容：
>
> 图的基本概念
>
> 图的存储结构：邻接矩阵，邻接表
>
> 图的遍历：广度优先遍历和深度优先遍历✨
>
> 最小生成树基本概念
>
> Prim算法，Kruskal算法
>
> 最短路径问题，广度优先遍历算法，Dijkstra，Floyd算法
>
> 拓扑排序

##  图的基本概念

![image-20190713001039524](/images/mse/image-20190713001039524.png)

![image-20190714173303656](/images/mse/image-20190714173303656.png)

### 定义

图G由定点集V和边集E组成，记为G(V, E)，其中V(G)表示图G中顶点的有限非空集；E(G)表示图G中顶点之间的关系（边）集合。若V= { v1, v2, v3 …, vn }，则用 |V|表示图G中顶点的个数，也成图的阶， E = { (u, v) | u ∈ V, v ∈ V }，用|E|表示图G中边的条数。

> 线性表、树都可以为空，但是图不能是空图，也就是说图中不能一个顶点也没有，但是可以直有一个顶点没有边。

### 有向图

若E是有向边的有限集合时，则G为有向图

> 有向图的边称为弧，带箭头的一侧称为弧头，另一侧称为弧尾。

### 无向图

若E是无向边的有限集合时，则G为无向图。

### 简单图 

一个图G满足：不存在重复边，不存在顶点到自身的边，则称G为简单图。

### 多重图

若图G中某两个结点之间的边数多于一条，又允许顶点通过一条边和自己关联，则G为多重图。多重图的定义和简单图相对。

### 完全图（也称简单完全图）

在无向图中，若任意两个顶点之间都存在边，则称图为无向完全图。含有n个顶点的无向完全图有n(n-1)/2条边。

在有向图中，若任意两个顶点之间都存在方向相反的两条弧，则称该图为有向完全图，含有n个顶点的有向完全图中有 n(n-1)条边。

![屏幕快照 2019-07-12 23.55.43](/images/mse/屏幕快照 2019-07-12 23.55.43.png)

### 子图

如有两个图，G = (V, E) 和 G' = (V', E')，若V' 是 V 的子集，且 E' 是 E 的子集，则称G' 是 G 的子图。

> 并非 V 和 E 的任何子集都能构成 G 的子图

### 连通、连通图和连通分量

在无向图中，若从顶点v到顶点 w 有路径存在，则称 v 和 w 是连通的。

若图 G 中任意两个顶点都是连通的，则称 G 为连通图，否则称为非连通图。

无向图中的极大连通子图称为连通分量。

> 若一个图有 n 个顶点，并且边数小于 n - 1， 则此图必是非连通图。

### 强连通子图、强连通分量

在有向图中，若从顶点 v 到顶点 w 和顶点 w 到顶点 v 之间都有路径，则称这两个顶点是强连通的。

若图中任何一对顶点都是强连通的，则称此图为强连通图。

有向图中的极大强连通子图称为有向图的强连通分量。

![image-20190713000734440](/images/mse/image-20190713000734440.png)



![image-20190713001155263](/images/mse/image-20190713001155263.png)

> 强连通知识针对有向图而言的，一般在无向图中讨论连通性，在有向图中考虑强连通性。

🤔️ ❓n 个顶点的连通图（强连通图），最少有多少条边？

> 连通图： n - 1
>
> 
>强连通图：n 



### 生成树、生成森林

连通图的生成树是包含图中全部顶点的一个<b>极小连通子图</b>。若图中<b>顶点数为 n , 则它的生成树含有 n - 1条边</b>。对生成树而言，若砍去它的一条边，则会变成非连通图，若加上一条边则会形成一个回路。

![image-20190713001442893](/images/mse/image-20190713001442893.png)

在非连通图中连通分量的生成树构成了非连通分量的生成森林。

![image-20190713001619320](/images/mse/image-20190713001619320.png)

### 顶点的度、入度和出度

图中每个顶点的度定义为以该顶点为一个端点的边的数目。

对于无向图，顶点 v 的度是指依附于该顶点的边的条数，记为 TD(v)。

> 在具有 n 个顶点， e 条边的无向图中，全部顶点的度的和等于边数的 2 倍，因为每条边和两个顶点相关联。

对于有向图，顶点 v 的度分为入度和出度，入度是以顶点 v 为终点的有向边的数目，记为 ID(v)，而出度是以 v 为起点的有向边的数目，记为 OD(v)。顶点 v 的度等于其入度和出度之和，即 TD(v) = ID(v) + OD(v)。

> 在具有 n 个顶点， e 条边的有向图中，ID(vi)之和 = OD(vi)之和 = e，即有向图的全部顶点的入度之和与出度之和相等，并且等于边数。这是因为每条有向边都有一个起点和一个终点。

![image-20190713001929279](/images/mse/image-20190713001929279.png)

### 边的权和网

在一个图中，每条边都可以标上具有某种含义的数值，该数值称为该边的权值。这种边上带权值的图称为带权图，也称网。

### 稠密图、稀疏图

边数很少的图称为稀疏图，反之称为稠密图。

![image-20190713002109261](/images/mse/image-20190713002109261.png)

> 这是一个模糊的概念。

### 路径、路径长度和回路

顶点 v<sub>p</sub>和顶点v<sub>q</sub> 之间的一条路径是指顶点序列 v<sub>p</sub>， vi1,  vi2, vi3, …vim, v<sub>q</sub>。路径上边的数目称为路径长度，第一个顶点和最后一个顶点相同的路径称为回路或环。若一个图有 n 个顶点，并且有大于 n - 1 条边，则此图一定有环。

![image-20190713002458932](/images/mse/image-20190713002458932.png)

### 简单环路、简单回路

在路径序列中，顶点不重复出现的路径称为简单路径，除第一个顶点和最后一个顶点外，其余顶点不重复出现的回路称为简单回路。

### 距离

从顶点 u 出发到顶点 v 的最短路径若存在，则此路径的长度称为从 u 到 v 的距离。若从 u 到 v  根本不存在路径，则记该距离为无强（∞）。

### 有向树

一个顶点的入度为 0 ，其余顶点的入度均为 1 的有向图，称为有向树。

![image-20190713002232343](/images/mse/image-20190713002232343.png)

> 有向树是图



## 图的存储和基本操作

主要的存储方式： 邻接矩阵和邻接表

### 邻接矩阵法

用一个数组存储图中点的信息，用一个二维数组存储图中边的信息。

![image-20190714135441063](/images/mse/image-20190714135441063.png)



![image-20190714135721768](/images/mse/image-20190714135721768.png)

> 我们讨论的都是简单图，没有自身到自身的边，所以对角线上的值都为0。
>
> 无向图的邻接矩阵是关于对角线对称的对称矩阵，可以采用压缩存储方式。



#### 邻接矩阵如何存放网（边带权值的图）

只需要将上面邻接矩阵中的 1 换成对应边的权值，而 0 （即不是图中的边）换成 ∞（有时也可以是0） 即可。

#### 图的邻接矩阵的存储结构语言定义

```c
#define MaxVertexNum 100
typedef char VertexType;
typedef int EdgeType;
typedef struct {
  VertexType Vex[MaxVertexNum];
  EdgeType Edge[MaxVertexNum][MaxVertexNum];
  int vexnum, arcnum;
}MGraph;
```



> - 邻接矩阵法空间复杂度 O(n<sup>2</sup>)，适用于稠密图。
>
> - 无向图的邻接矩阵为对称矩阵。
>
> - 无向图中第 i 行（或第 i 列）非 0 元素的（非正无穷）的个数为第 i 个顶点的度。有向图中第 i 行（第 i 列）非 0 元素（非+∞）的个数为第 i 个顶点的出度（入度）。
> - 邻接矩阵法用于存放稀疏图会比较浪费空间，稀疏图一般用下面的邻接表法来存储。

#### 问题

🤔️ 问题：设图 G 的邻接矩阵为 A ，矩阵 A <sup>n</sup> 的含义 ？

![image-20190714141730826](/images/mse/image-20190714141730826.png)



### 邻接表法

为每一个顶点建立一个单链表存放与它相邻的边。

- 顶点表：采用<b>顺序存储</b>，每个数组元素存放顶点的数据和边表的头指针
- 边表（出边表）：采用<b>链式存储</b>，单链表中存放与一个顶点相邻的所有边，一个链表结点表示一条从该顶点到链表结点顶点的边。

![image-20190714142656153](/images/mse/image-20190714142656153.png)

![image-20190714143219176](/images/mse/image-20190714143219176.png)

#### 语言定义

```c
#define MaxVertexNum 100
typedef struct ArcNode {
  int adjvex;
  struct ArcNode *next;
  // InfoType info; 权值
}ArcNode;
typedef struct VNode{
	VertexType data;
  ArcNode *first;
}VNode,AdjList[MaxVertexNum];
typedef struct{
  AdjList vetices;
  int vexnum, arcnum;
}ALGraph;

```



#### 特点

> - 若 G 为无向图，存储空间为 O（|V| + 2|E|
>
> - 若 G 为有向图，存储空间为 O（|V| + |E|）
>
> - 邻接表更加适用于稀疏图
> - 若 G 为无向图，则结点的度为该结点边表的长度
> - 若 G 为有向图，则结点的出度为该结点边表的长度，计算入度则要遍历整个邻接表。
> - 邻接表不唯一，边表结点的顺序根据算法和输入的不同可能会不同

### 存储方式对比

![image-20190714144413545](/images/mse/image-20190714144413545.png)



### 十字链表

有向图的一种链式存储结构。

> 在邻接表法中，找到一个顶点的所有出边（以该点为弧尾）的边比较容易，但是要找到某一个顶点所有的入边是比较困难的，需要遍历所有顶点的边表，十字链表法可以解决这个弊端。

将结点做如下修改：

![image-20190714174550515](/images/mse/image-20190714174550515.png)

增加了出边、入边单链表的头指针，弧头、弧尾结点、弧头弧尾结点。

```c
#define MaxVertexNum 100;
typedef struct ArcNode {
  int tailvex, headvex;
  struct ArcNode *hlink, *tlink;
  // InfoType info;
}ArcNode;
typedef struct VNode {
  VertexType data;
  ArcNode *firstin, *firstout;
}VNode;
typedef struct {
  VNode xlist[MaxVertexNum];
  int vexnum, arcnum;
}GLGraph;
```



### 邻接多重表

无向图的一种链式存储结构

> 对邻接表法的边表结点进行了优化。

![image-20190714175733889](/images/mse/image-20190714175733889.png)

```c
#define MaxVertexNum;
typedef struct ArcNode {
  int ivex, jvex;
  struct ArcNode *ilink, *jlink;
  // InfoType info;
  // bool mark;
}ArcNode;
typedef struct VNode {
  VertexType data;
  ArcNode *firstedge;
}VNode;
typedef struct {
  VNode adjmulist[MaxVertexNum];
  int vexnnum, arcnum;
}AMLGraph;
```



### 对比

![image-20190714180514379](/images/mse/image-20190714180514379.png)

## 图的遍历

从图中某一顶点出发，按照某种搜索方法沿着图中的边对图中的所有顶点访问一次，且仅访问一次。

### 广度优先搜索 ( BFS )

- 首先访问起始顶点 V；
- 接着由出发依次访问 V 的各个未被访问过的邻接顶点 w1, w2, … wi;
- 然后依次访问w1, w2, …, wi 的所有未被访问的所有邻接顶点；
- … 重复以上过程，以此类推；

下面使用 <b> 队列 + 辅助标记数组</b> 的方式来实现广度优先搜索

![image-20190714163657909](/images/mse/image-20190714163657909.png)

> 1 入队， 1 出队，visit[0] = 1,  1 的连接顶点 2 、3 入队, 以此类推，对比树的层序遍历。

![image-20190714163747346](/images/mse/image-20190714163747346.png)

#### 语言定义

```c
bool visited[MAX_TREE_SIZE];
void BFSTraverse(Graph G) {
  for (int i=0; i<G.vexnum;++i)
    visited[i]=FALSE;
  InitQueue(Q);
  for(int i; i<G.vexnum; ++i)
    if(!visited[i])
      BFS(G,i); // 循环所有顶点，这样即使是非连通图也能保证所有顶点都被访问到
}

void BFS(Graph G, int v) {
  visit(v);
  visited[v] = TRUE;
  EnQueue(Q, v);
  while(!isEmpty(Q)) {
    DeQueue(Q, V);
    for(w=FirstNeighbour(G, V); w>=0;w=NextNeighbour(G, v, w))
      if (!visited[w]) {
        visit[w];
        visited[w] = TRUE;
        EnQueue(Q, w);
      }
  }
}
```



#### 复杂度

空间复杂度：O(|V|)

时间复杂度：

- 对于邻接矩阵： O(|V|<sup>2</sup>)
- 对于邻接表法：O(| v | + | E |)

![image-20190714163525411](/images/mse/image-20190714163525411.png)



#### 应用

##### 无权图单源最短路径问题

> 定义从顶点 u 到顶点 v 的最短路径 d(u, v)为从 u 到 v  的任何路径中最少的边数；若从 u 到 v 没有通路， 则 d(u, v) = ∞ 。

![image-20190714163430852](/images/mse/image-20190714163430852.png)

####  广度优先生成树

在广度遍历过程中，我们可以得到一棵遍历树，称为广度优先生成树（生成森林）。

![image-20190714163133238](/images/mse/image-20190714163133238.png)



> 邻接矩阵法的广度优先生成树唯一，邻接表法的不唯一。



### 深度优先搜索（DFS）

>  深度优先搜索与树的先序遍历类似

- 首先访问起始顶点 v;
- 接着由 v 出发访问 v 的任意一个邻接且未被访问的邻接顶点 W<sub>i</sub>；
- 然后再访问与 W<sub>i</sub> 邻接且未被访问的任意顶点 y<sub>i</sub>；
- 若 w<sub>i</sub> 没有邻接且未被访问到的顶点时，退回到它的上一层顶点 v；
- 重复上述过程直到所有的顶点被访问为止。



#### 语言定义

深度优先搜索可以用栈 + 辅助数组来实现

```c
bool visited[MAX_TREE_SIZE];
void DFSTraverse (Graph G) {
  for (int i = 0; i < G.vexnum; ++i)
    visited[i] = FALSE;
  for (int i=0; i < G.vexnum; ++i)
    if (!visited[i])
      DFS(G, i);
}

void DFS(Graph G, int V) {
  visit(V);
  visited[V] = TRUE;
  for(w=FirstNeighbour(G, V); w >=0; w=NextNeighbour(G, V, W))
    if (!visited[w])
      DFS(G, W);
}
```

> 🌟 邻接矩阵法的DFS （BFS）序列唯一，邻接表法的不唯一。



#### 性能分析

空间复杂度 ： O（|V|） `工作栈`

时间复杂度： 

- 对于邻接矩阵： O(|V|<sup>2</sup>)
- 对于邻接表法：O(| v | + | E |)

![image-20190714172613845](/images/mse/image-20190714172613845.png)



#### 深度优先生成树

在深度遍历过程中，我们可以得到一棵遍历树，称为深度优先生成树（生成森林）。

>  邻接矩阵法的深度优先生成树唯一，邻接表法不唯一。



### 遍历与连通性问题

🌟<b> 在无向图中，在任意结点出发进行一次遍历（调用一次 BFS 或 DFS ），若能访问全部结点，说明该无向图是连通的。</b>

🌟 <b>在无向图中，调用遍历函数（ BFS 或 DFS）的次数为连通分量的个数。</b>

> 在有向图中没有上述两个结论类似的结论。



## 图的应用

### 最小生成树

> 生成树：连通图包含全部顶点的一个极小连通子图。
>
> 这一块主要考察理解，不考代码编写题

![image-20190714180807727](/images/mse/image-20190714180807727.png)

<b>最小生成树</b>：对于<b>带权无向连通图</b> G = (V, E)，G 的所有生成树当中边的权值之和最小的生成树为G的最小生成树(MST)。

![image-20190714181106514](/images/mse/image-20190714181106514.png)

#### 性质

- 最小生成树不一定唯一，即最小生成树的树形不一定唯一。当带权无向连通图 G 的各边权值不等时或 G 只有结点数减 1 条边时， MST 唯一。

![image-20190714211036967](/images/mse/image-20190714211036967.png)

- 最小生成树的权值是唯一的，且是最小。

![image-20190714211108644](/images/mse/image-20190714211108644.png)

- 最小生成树的边数为顶点数减 1



#### 生成算法

![image-20190714211330983](/images/mse/image-20190714211330983.png)

![image-20190714211411489](/images/mse/image-20190714211411489.png)



##### Prim

![image-20190714212244183](/images/mse/image-20190714212244183.png)

![image-20190714212432806](/images/mse/image-20190714212432806.png)

![image-20190714212814565](/images/mse/image-20190714212814565.png)

![image-20190714213503740](/images/mse/image-20190714213503740.png)

>  该算法适用于稠密图



##### Kruskal

![image-20190714215238657](/images/mse/image-20190714215238657.png)

初始化如下图：

![image-20190714220119313](/images/mse/image-20190714220119313.png)

![image-20190714222523252](/images/mse/image-20190714222523252.png)

![image-20190714222852678](/images/mse/image-20190714222852678.png)

> 复杂度只与边数有关，适于稀疏图。



### 最短路径

两个顶点之间带权路径长度最短的路径为最短路径。

> 在带权图当中，把从一个顶点 v 到 另一个顶点 u  所经历的边的权值之和称为<b>路径的带权路径长度</b>

![image-20190714223307142](/images/mse/image-20190714223307142.png)

主要介绍两种方法： Dijkstra 和 Floyd

####Dijkstra 

##### 定义

 带权图单源最短路径

![image-20190714223900624](/images/mse/image-20190714223900624.png)

![image-20190714224459711](/images/mse/image-20190714224459711.png)

举例来看执行过程：

![image-20190714224751613](/images/mse/image-20190714224751613.png)

![image-20190714224942663](/images/mse/image-20190714224942663.png)

![image-20190714225142308](/images/mse/image-20190714225142308.png)

![image-20190714225309175](/images/mse/image-20190714225309175.png)

![image-20190714225509621](/images/mse/image-20190714225509621.png)

##### 代码实例

```c
void Dijkstra(Graph G, int V) {
  int s[G.vexnum];
  int path[G.vexnum];
  for(int i=0; i < G.vexnum; i++) {
    dist[i] = G.edge[V][i];
    s[i] = 0;
    if (G.edge[V][i] < MAX)
      path[i]=v;
    else
      path[i]=-1;
  }
  s[V]=1;
	path[V]=1;
  
  for(i=0; i< G.vexnum; i++) {
    int min = MAX;
    int u;
    for(int j=0; j<G.vexnum; j++)
      if(s[j]==0 && dist[j]<min) {
        min=dist[j];
        u=j;
      }
    s[u] = 1;
    
   for(int j=0; j<G.vexnum; j++)
     if(s[j]==0 && dist[u]+G.Edge[u][j] < dist[j]) {
       dist[j]=dist[u] + G.Edges[u][i];
       path[j]=u;
     }
  }
}
```

> 时间复杂度  O(|V|<sup>2</sup>)

##### 局限性

![image-20190714230810882](/images/mse/image-20190714230810882.png)



#### Floyd 

##### 定义

各顶点之间的最短路径

> 算法思想：递推产生一个 n 阶方阵序列 A<sup>(-1)</sup>, A<sup>(0)</sup>, …, A<sup>(k)</sup>,…,  A<sup>(n-1)</sup>

![image-20190714231440447](/images/mse/image-20190714231440447.png)

##### 执行过程

![image-20190714231911734](/images/mse/image-20190714231911734.png)

##### 代码实现

```c
void Floyd(Graph G) {
  int A[G.vexnum][G.vexnum];
  for (int i = 0; i< G.vexnum; i++)
    for(int j=0; j<G.vexnum; j++)
      A[i][j]=G.Edge[i][i];
  for(int k=0; k<G.vexnum; k++)
    for(int i=0; i<G.vexnum; i++)
      for(int j=0; j<G.vexnum; j++)
        if(A[i][j] > A[i][k] + A[k][j])
          A[i][j] = A[i][k] + A[k][j];
}
```

> 时间复杂度： O(|V|<sup>3</sup>)

