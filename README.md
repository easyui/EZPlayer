<p align="center">
![EZPlayer](EZPlayerExample/EZPlayerExample/Assets.xcassets/AppIcon.appiconset/Icon-83.5@2x.png)


# EZPlayer
![Swift 3.0](https://img.shields.io/badge/Swift-3.0-brightgreen.svg?style=flat) 
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
<a href="https://img.shields.io/cocoapods/v/ZFPlayer.svg"><img src="https://img.shields.io/cocoapods/v/EZPlayer.svg"></a>
[![Platform](https://img.shields.io/cocoapods/p/EZPlayer.svg?style=flat)](http://cocoadocs.org/docsets/EZPlayer)
![License](https://img.shields.io/cocoapods/l/BMPlayer.svg?style=flat)


## 介绍
基于AVPlayer封装的视频播放器，功能丰富，快速集成，可定制性强。

## 要求
- iOS 8.0+ 
- Xcode 8.1+
- Swift 3.0+

## 特性
- 本地视频、网络视频播放（支持的格式请参考苹果AVPlayer文档）
- 全屏模式/嵌入模式/浮动模式随意切换
- 全屏模式支持横屏全屏和竖屏全屏
- 定制手势：播放/暂停(全屏/嵌入模式双击，浮动模式单击)，浮动和全屏切换（双击），音量/亮度调节（上下滑动），进度调节（左右滑动）
- 定制手势：播放/暂停(全屏/嵌入模式双击，浮动模式单击)，浮动和全屏切换（双击），音量/亮度调节（上下滑动），进度调节（左右滑动）
- 支持airPlay
- 支持UITableview自动管理嵌入和浮动模式切换
- 视频比例填充（videoGravity）切换
- 字幕/CC切换
- 音频切换
- 拖动进度显示预览图（m3u8不支持）
- 播放器控件皮肤自定义（自带一套浮动皮肤，嵌入和全屏用的一套皮肤）
- 支持广告功能


## 安装 
### ExportFramework
执行项目中的ExportFramework脚本自动生成framework
### [Carthage](https://github.com/Carthage/Carthage) 
1. 创建一个 `Cartfile` ，在这个文件中列出你想使用的 frameworks

   ```ogdl
   github "easyui/EZPlayer" 
   ```
   
2. 运行 `carthage update` ，获取依赖到 Carthage/Checkouts 文件夹，逐个构建
3. 在工程的 target－> General 选项下，拖拽 Carthage/Build 文件夹内想要添加的 framework 到 “Linked Frameworks and Libraries” 选项下。
   (如果不想拖动这个操作的话，可以设置Xcode自动搜索Framework的目录 Target—>Build Setting—>Framework Search Path—>添加路径＂$(SRCROOT)/Carthage/Build/iOS＂)
4. 在工程的 target－> Build Phases 选项下，点击 “+” 按钮，选择 “New Run Script Phase” ，填入如下内容：

   ```
   /usr/local/bin/carthage copy-frameworks
   ```

   并在 “Input Files” 选项里添加 framework 路径
   
   ```
   $(SRCROOT)/Carthage/Build/iOS/EZPlayer.framework
   ```

### [CocoaPods](http://cocoapods.org)
1. 创建一个 `Podfile` ，在这个文件中列出你想使用的 frameworks

   ```ruby
   project 'EZPlayerExample.xcodeproj'
   platform :ios, '8.0'

   target '<Your Target Name>' do
     use_frameworks!
     pod 'EZPlayer' 
   end
   ```
   
2. 在 `Podfile` 文件目录下执行

   ```bash
   $ pod install
   ```

## Todo
- 优化ui，优化代码，添加注释
- 优化demo
- 支持VR
- 支持iPad pip
- 支持本地m3u8
- 支持多码率控制
- 支持3d touch截图，截图后简单处理
- 支持边缓存边下载
- 支持视频解密播放
- 支持tvOS
## License
EZPlayer遵守MIT协议，具体请参考MIT


## PS
2017年元旦在家撸了个播放器，EZPlayer是2017年码拉松的起点，希望大家多star，谢谢！





