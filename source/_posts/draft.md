---
title: 2019年47周
date: 2019-11-20 11:35:32
tags: js技巧
category: 前端开发
---


### 前端生成zip文件
在chrome内核浏览器中可以实现前端打包文件的功能，本功能虽然对节省下载流量没有任何帮助，但是对于下载资源较多，需要程序协助实现按文件夹归类文件功能时是一个可选的方案。
```typescript
//https://github.com/Stuk/jszip#readme
import JSZip from 'jszip';

interface Material {
  id: string; // 材料
  attachments: [], // 附件
  name: string, // 材料名，二级目录名
}
export async function batchDownloadAttachments(rootFolder: string, materials: Material[], onProgress: any) {
  const configs = [];
  const zip = new JSZip();
  zip.folder(rootFolder);
  materials.map(material => {
    const { id: materialId, attachments = [], name  } = material;
    const folder = zip.folder(`${rootFolder}/${name}`);
    attachments.map(attachment => {
      configs.push({
        folder,
        attachment,
        // 业务中downloadAttachmentAsBlob需要更多参数在此添加
        // materialId,
      });
    });
  });
  await Promise.all(configs.map(async config => {
    const { attachment } = config;
    const blob = await downloadAttachmentAsBlob(attachment, /*materialId*/);
    config.folder.file(attachment.title, blob, { binary: true });
  }));
  zip.generateAsync({
    type: 'blob'
  }).then(function(content: any) {
    var filename = `${rootFolder}.zip`;
    // 创建隐藏的可下载链接
    var eleLink = document.createElement('a');
    eleLink.download = filename;
    eleLink.style.display = 'none';
    // 下载内容转变成blob地址
    eleLink.href = URL.createObjectURL(content);
    // 触发点击
    document.body.appendChild(eleLink);
    eleLink.click();
    // 然后移除
    document.body.removeChild(eleLink);
  });
}

function  downloadAttachmentAsBlob(downloadURL: string, attachment: { id: string; title: string }) {
  return await utils.downloadAsBlob(downloadURL);
}


//utils.js
export function downloadAsBlob(url: string) {
  return axios.create().get(url, { responseType: 'blob'})
    .then(res => res.data);
}
```

### Chrome 新增的 Cookie Samesite 设置
近期开发时，发现引用其他网站图片时，如果图片给第三方发送了cookie，控制台就会发出提醒：
![](http://assets.cbndata.org/same_site_header/FnrHj2O8sQlOWbtolTNmMXOqizw3.png)

查阅资料，发现 `Chrome 51 开始，浏览器的 Cookie 新增加了一个SameSite属性，用来防止 CSRF 攻击和用户追踪。并且 Chrome 80开始，SameSite默认值将被设为 Lax`
详细见下面转载内容：
- [Cookie 的 SameSite 属性](https://www.ruanyifeng.com/blog/2019/09/cookie-samesite.html)
- [Cookies default to SameSite=Lax](https://www.chromestatus.com/feature/5088147346030592)
- [Cross-Site Request Forgery is dead!](https://scotthelme.co.uk/csrf-is-dead/)
