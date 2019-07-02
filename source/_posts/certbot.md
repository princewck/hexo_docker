---
title: 未备案网站使用Certbot生成https证书
toc: true
tags: certbot-auto https
thumbnail: /images/letsencrypt.png
category: '运维技术'
date: 2019-07-02 17:02:38
---


在使用cert-bot nginx生成或更新网站证书时，如果网站未备案，`certbot --nginx`会失败，报认证失败的错误。
我们可以使用手动方式来完成认证过程：
1. 输入以下命令
```
./certbot-auto certonly --manual --preferred-challenge dns -d api.domain.org

```

2. 过程中会让你在域名的DNS列表添加一条TXT记录，添加生效后继续：

```bash
Are you OK with your IP being logged?
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
(Y)es/(N)o: Y

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Please deploy a DNS TXT record under the name
_acme-challenge.api.domain.org with the following value:

8Cck__LuDXGa92S2fDEtQZE42qYJOTFOgqTz9IQSOxg

Before continuing, verify the record is deployed.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Press Enter to Continue
```
