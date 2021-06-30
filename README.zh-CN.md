# ZXing-dart Web 演示

本项目是一个演示项目，演示如何在web端使用[zxing-dart](https://gitee.com/shirne/zxing-dart) 进行二维码,pdf417, datamatrix, aztec等格式的编码和解码.

## 已知问题

* 摄像头扫描的功能不可用，不同设备浏览器环境下可能出现无法加载摄像头，无法提取图片，并且提取的图片质量过低。在移动端可以使用选择文件中的照相功能代替此方案.
* 解码操作运行过慢，尤其是在大图片的情况下。演示中自动判断图片超过1000像素进行了均值缩小的操作，对解码速度有一定的优化。整体解码速度上优化空间不大，能用原生方案解决的，不建议使用此方案。如：可以使用app 或服务端解码方案
* 编码操作qrcode默认支持中文，其它几种默认未支持

## 在线演示

[zxingweb](https://www.shirne.com/demo/zxingweb/#/)

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
