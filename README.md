<p align="center">
![EZPlayer](EZPlayerExample/EZPlayerExample/Assets.xcassets/AppIcon.appiconset/Icon-83.5@2x.png)


# EZPlayer
![Swift 3.0](https://img.shields.io/badge/Swift-3.0-brightgreen.svg?style=flat) 
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
<a href="https://img.shields.io/cocoapods/v/ZFPlayer.svg"><img src="https://img.shields.io/cocoapods/v/EZPlayer.svg"></a>
[![Platform](https://img.shields.io/cocoapods/p/EZPlayer.svg?style=flat)](http://cocoadocs.org/docsets/EZPlayer)
![License](https://img.shields.io/cocoapods/l/BMPlayer.svg?style=flat)

## 预览
![EZPlayer](EZPlayer.gif)

## 介绍
基于AVPlayer封装的视频播放器，功能丰富，快速集成，可定制性强。

## 要求
- iOS 8.0+ 
- Xcode 8.1+
- Swift 3.0+

## 特性
- 本地视频、网络视频播放（支持的格式请参考苹果AVPlayer文档）
- [全屏模式/嵌入模式/浮动模式随意切换(支持根据设备自动旋转)](#DisplayMode)
- [全屏模式支持横屏全屏和竖屏全屏](#DisplayMode)
- [定制手势：播放/暂停(全屏/嵌入模式双击，浮动模式单击)，浮动和全屏切换（双击），音量/亮度调节（上下滑动），进度调节（左右滑动）](#GestureRecognizer)
- [支持airPlay](#airPlay)
- [支持UITableview自动管理嵌入和浮动模式切换](#tableview)
- [视频比例填充（videoGravity）切换](#videoGravity)
- [字幕/CC切换](#subtitle&cc&audio)
- [音频切换](#subtitle&cc&audio)
- [拖动进度显示预览图（m3u8不支持）](#preview)
- [播放器控件皮肤自定义（自带一套浮动皮肤，嵌入和全屏用的一套皮肤）](#skin)
- [支持广告功能](#ad)



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


## 使用 
- 初始化播放器播放

```
func playEmbeddedVideo(mediaItem: MediaItem, embeddedContentView contentView: UIView? = nil , userinfo: [AnyHashable : Any]? = nil ) {
        //stop
        self.releasePlayer()
......       
        self.player!.backButtonBlock = { fromDisplayMode in
            if fromDisplayMode == .embedded {
                self.releasePlayer()
            }else if fromDisplayMode == .fullscreen {
                if self.embeddedContentView == nil && self.player!.lastDisplayMode != .float{
                    self.releasePlayer()
                }
                
            }else if fromDisplayMode == .float {
                self.releasePlayer()
            }
            
        }
        
        self.embeddedContentView = contentView
        //self.embeddedContentView为nil时就是全屏播放
        self.player!.playWithURL(mediaItem.url! , embeddedContentView: self.embeddedContentView)
    }
```
<a name="DisplayMode"></a>

- 全屏模式/嵌入模式/浮动模式随意切换(支持根据设备自动旋转)
- 全屏模式支持横屏全屏和竖屏全屏

```
//根据设备横置自动全屏
open var autoLandscapeFullScreenLandscape = UIDevice.current.userInterfaceIdiom == .phone
//指定全屏模式是竖屏还是横屏
open var fullScreenMode = EZPlayerFullScreenMode.landscape

//进去全屏模式
open func toFull(_ orientation:UIDeviceOrientation = .landscapeLeft, animated: Bool = true ,completion: ((Bool) -> Swift.Void)? = nil) 
//进入嵌入屏模式
open func toEmbedded(animated: Bool = true , completion: ((Bool) -> Swift.Void)? = nil)
//进入浮动模式
open func toFloat(animated: Bool = true, completion: ((Bool) -> Swift.Void)? = nil) 
```
例子：EZPlayerExample-DisplayMode

<a name="GestureRecognizer"></a>

- 定制手势：播放/暂停(全屏/嵌入模式双击，浮动模式单击)，浮动和全屏切换（双击），音量/亮度调节（上下滑动），进度调节（左右滑动）

```
//自定义皮肤只要实现这两个协议
public protocol EZPlayerHorizontalPan: class {
func player(_ player: EZPlayer ,progressWillChange value: TimeInterval)
func player(_ player: EZPlayer ,progressChanging value: TimeInterval)
func player(_ player: EZPlayer ,progressDidChange value: TimeInterval)
}

public protocol EZPlayerGestureRecognizer: class {
func player(_ player: EZPlayer ,singleTapGestureTapped singleTap: UITapGestureRecognizer)
func player(_ player: EZPlayer ,doubleTapGestureTapped doubleTap: UITapGestureRecognizer)
}
//点击事件还可以接受通知
static let EZPlayerTapGestureRecognizer = Notification.Name(rawValue: "com.ezplayer.EZPlayerTapGestureRecognizer")
```

<a name="airPlay"></a>

- 支持airPlay

```
/// 支持airplay
open var allowsExternalPlayback = true
/// airplay连接状态
open var isExternalPlaybackActive: Bool 
```

<a name="tableview"></a>

- 支持UITableview自动管理嵌入和浮动模式切换

```
override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
...       MediaManager.sharedInstance.playEmbeddedVideo(url:URL.Test.localMP4_0, embeddedContentView: cell?.contentView)

//主要是设置indexPath和scrollView 属性
MediaManager.sharedInstance.player?.indexPath = indexPath
        MediaManager.sharedInstance.player?.scrollView = tableView
    }
```

<a name="videoGravity"></a>

- 视频比例填充（videoGravity）切换

```
//设置
open var videoGravity = EZPlayerVideoGravity.aspect
```

<a name="subtitle&cc&audio"></a>

- 字幕/CC切换
- 音频切换

```
主要通过下面两个extension来设置，查看
AVAsset+EZPlayer.swift
//获取所有cc
public var closedCaption: [AVMediaSelectionOption]? 
//获取所有subtitle
public var subtitles: [(subtitle: AVMediaSelectionOption,localDisplayName: String)]? 
//获取所有audio
public var audios: [(audio: AVMediaSelectionOption,localDisplayName: String)]? 

AVPlayerItem+EZPlayer.swift
/// 获取／设置当前subtitle／cc
public var selectedMediaCharacteristicLegibleOption:AVMediaSelectionOption?
/// 获取／设置当前cc
public var selectedClosedCaptionOption:AVMediaSelectionOption?
/// 获取／设置当前subtitle
public var selectedSubtitleOption:AVMediaSelectionOption?
/// 获取／设置当前audio
public var selectedMediaCharacteristicAudibleOption:AVMediaSelectionOption?
```

<a name="preview"></a>

- 拖动进度显示预览图（m3u8不支持）

```
//不支持m3u8
open func generateThumbnails(times: [TimeInterval],maximumSize: CGSize, completionHandler: @escaping (([EZPlayerThumbnail]) -> Swift.Void ))
//支持m3u8
func snapshotImage() -> UIImage?
```

<a name="skin"></a>

- 播放器控件皮肤自定义（自带一套浮动皮肤，嵌入和全屏用的一套皮肤）

 - EZPlayer一共三套皮肤可以设置： 
```
 /// 嵌入模式的控制皮肤
open  var controlViewForEmbedded : UIView?
/// 浮动模式的控制皮肤
open  var controlViewForFloat : UIView?
/// 浮动模式的控制皮肤
open  var controlViewForFullscreen : UIView?
```

 - 默认controlViewForFullscreen为空的时候会默认使用controlViewForEmbedded皮肤
 - EZPlayer初始化的时候可以设置controlViewForEmbedded皮肤
 
      ```
      public init(controlView: UIView? )
      ```

例子：EZPlayerExample-Skin(ad)

<a name="ad"></a>

- 支持广告功能

假如播放过程中进入广告，那需要临时设置广告皮肤，可以设置属性：

```
open  var controlViewForIntercept : UIView?
```

例子：EZPlayerExample-Skin(ad)


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
- 支持播放百分比触发
- 国际化
- 记忆播放
- 支持滤镜
- 支持RN

## License
EZPlayer遵守MIT协议，具体请参考MIT


## PS
2017年元旦在家撸了个播放器，EZPlayer是2017年码拉松的起点，希望大家多star，给更多动力更新所有todo





