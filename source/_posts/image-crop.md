---
title: 使用canvas实现最大内接矩形居中裁剪
date: 2019-06-18 09:47:52
tags: 前端开发
thumbnail: /images/SEQUENCE.jpeg
---

使用canvas的drawImage api我们可以在浏览器对图片的尺寸和质量进行一些自定义，下面是项目中用到的图片裁剪案例：给定任意尺寸图片，要求按照规定尺寸裁剪出默认符合要求的图片。
```typescript

class ImageUtil {

  private _promise: Promise<any> | null = null;
  private get promise() {
    if (!this._promise) {
      throw new Error('not allowed, only allow to chain this after image manipulation methods: [rect]');
    }
    return this._promise;
  }

  /**
   * @param url 裁剪出最大内接矩形
   * @param width 目标宽度
   * @param height 目标高度
   * @param scale 缩放到 width, height 的值
   * @param 裁剪完成回调 canvas
   */
  rect(img: string | HTMLImageElement, width: number, height: number, scale: boolean, callback?: any) {
    const promise = new Promise((resolve, reject) => {
      imageToCanvas(img, (imageWidth: number, imageHeight: number) => {
        let sw, sh, dw, dh, sx, sy;
        const ratio = width / height;
        if ((imageWidth / imageHeight) >= ratio) {
          dh = imageHeight;
          dw = imageHeight * ratio;

          sx = (imageWidth - dw) / 2;
          sy = 0;

          sh = imageHeight;
          sw = sh * ratio;
        } else {
          dw = imageWidth;
          dh = dw / ratio;

          sy = (imageHeight - dh) / 2;
          sx = 0;

          sw = imageWidth;
          sh = sw / ratio;
        }
        if (scale) {
          dh = height;
          dw = width;
        }
        const dx = 0;
        const dy = 0;
        return [sx, sy, sw, sh, dx, dy, dw, dh];
      }, (canvas, ctx) => {
        if (callback) {
          callback(canvas);
        }
        resolve(canvas);
      });
    });
    this._promise = promise;
    return this;
  }

  async toDataUrl() {
    const canvas = await this.promise;
    return canvas.toDataURL();
  }

  async toFile(filename?: string, contentType?: 'image/png') {
    filename = filename || `ImageResizerNewImage-${+new Date()}`;
    const canvas = await this.promise;
    const blob: any = await new Promise((resolve, reject) => {
      canvas.toBlob(_blob => resolve(_blob), contentType);
    });
    return new File([blob], filename, {type: contentType, lastModified: Date.now() });
  }

  async toBlobURL() {
    const blob = await this.toFile();
    return URL.createObjectURL(blob);
  }
}

export default ImageUtil;

/**
 * 浏览器端处理图片大小和质量
 */
function imageToCanvas(
  img: string | HTMLImageElement,
  getRenderParams: (imageWidth: number, imageHeight: number) => any[] | null,
  callback: (canvas: HTMLCanvasElement, ctx: CanvasRenderingContext2D) => void
) {
  const canvas = document.createElement('canvas');
  const ctx = canvas.getContext('2d');
  let image;
  const invoke = () => {
    console.log('invoke');
    let params = getRenderParams(image.width, image.height);
    if (!params) {
      params = [0, 0, image.width, image.height, 0, 0, image.height, image.height];
    }
    const [sx, sy, sw, sh, dx, dy, dw, dh] = params;
    canvas.setAttribute('width', `${dw}`);
    canvas.setAttribute('height', `${dh}`);
    ctx.drawImage(image, sx, sy, sw, sh, dx, dy, dw, dh);
    if (callback) {
      callback(canvas, ctx);
    }
  };
  if (typeof(img) === 'string') {
    image = new Image();
    image.src = img;
    image.crossOrigin = 'anonymous';
    image.onload = invoke;
  } else if (img instanceof Image) {
    image = img;
    invoke();
  } else {
    throw new Error('invalid image data!');
  }
}

```

使用方式：
```javascript

async function testCrop() {
  const url = `https://image-url.com`;
  const imageHelper = new ImageUtil();
  const rectangle = imageHelper.rect(url, 430, 300, true);
  const file = await rectangle.toFile();
  const blobUrl = await rectangle.toBlobURL();
  const dataUrl = await rectangle.toDataURL();
}

testCrop();

```
