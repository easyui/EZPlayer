//
//  EZPlayer.swift
//  EZPlayer
//
//  Created by yangjun zhu on 2016/12/28.
//  Copyright © 2016年 yangjun zhu. All rights reserved.
//

import Foundation
import AVFoundation
import AVKit


/// 播放器错误类型
public enum EZPlayerError: Error {
    case invalidContentURL              //错误的url
    case playerFail                   // AVPlayer failed to load the asset.
}


/// 播放器的状态
public enum EZPlayerState {
    case unknown      // 播放前
    case error(EZPlayerError)      // 出现错误
    case readyToPlay    // 可以播放
    case buffering      // 缓冲中
    case bufferFinished // 缓冲完毕
    case playing // 播放
    case seekingForward // 快进
    case seekingBackward // 快退
    case pause // 播放暂停
    case stopped // 播放结束
}

//播放器浮框模式
public enum EZPlayerFloatMode  {
    case none
    case auto //支持系统pip的就是system，否则是window
    case system //iPhone在ios14一下不显示
    case window
}

//播放器显示模式类型
public enum EZPlayerDisplayMode  {
    case none
    case embedded
    case fullscreen
    case float
}

//播放器全屏模式类型
public enum EZPlayerFullScreenMode  {
    case portrait
    case landscape
}

//播放器流的显示比例
public enum EZPlayerVideoGravity : String {
    case aspect = "AVLayerVideoGravityResizeAspect"    //视频值 ,等比例填充，直到一个维度到达区域边界
    case aspectFill = "AVLayerVideoGravityResizeAspectFill"   //等比例填充，直到填充满整个视图区域，其中一个维度的部分区域会被裁剪
    case scaleFill = "AVLayerVideoGravityResize"     //非均匀模式。两个维度完全填充至整个视图区域
}

//播放器结束原因
public enum EZPlayerPlaybackDidFinishReason  {
    case playbackEndTime
    case playbackError
    case stopByUser
}

//屏幕左右上下划动时的类型
public enum EZPlayerSlideTrigger{
    case none
    case volume
    case brightness
}

//public enum EZPlayerFileType: String {
//    case unknown
//    case mp4
//    case m3u8
//
//}

open class EZPlayer: NSObject {
    // MARK: -  player utils
    public static var showLog = true//是否显示log
    // MARK: -  player setting
    open weak var delegate: EZPlayerDelegate?

    open var videoGravity = EZPlayerVideoGravity.aspect{
        didSet {
            if let layer = self.playerView?.layer as? AVPlayerLayer{
                layer.videoGravity = AVLayerVideoGravity(rawValue: videoGravity.rawValue)
            }
        }
    }


    /// 设置url会自动播放
    open var autoPlay = true

    /// 设备横屏时自动旋转(phone)
    open var autoLandscapeFullScreenLandscape = UIDevice.current.userInterfaceIdiom == .phone
    /// 全屏的模式
    open var floatMode = EZPlayerFloatMode.auto
    /// 全屏的模式
    open var fullScreenMode = EZPlayerFullScreenMode.landscape
    /// 全屏时status bar的样式
    open var fullScreenPreferredStatusBarStyle = UIStatusBarStyle.lightContent
    /// 全屏时status bar的背景色
    open var fullScreenStatusbarBackgroundColor = UIColor.black.withAlphaComponent(0.3)

    /// 支持airplay
    open var allowsExternalPlayback = true{
        didSet{
            guard let avplayer = self.player else {
                return
            }
            avplayer.allowsExternalPlayback = allowsExternalPlayback
        }
    }

    /// airplay连接状态
    open var isExternalPlaybackActive: Bool  {
        guard let avplayer = self.player else {
            return false
        }
        return  avplayer.isExternalPlaybackActive
    }


    private var timeObserver: Any?//addPeriodicTimeObserver的返回值
    private var timer       : Timer?//.EZPlayerHeartbeat使用

    // MARK: -  player resource
    open var contentItem: EZPlayerContentItem?

    open private(set)  var contentURL :URL?{//readonly
        didSet{
            guard let url = contentURL else {
                return
            }
            self.isM3U8 = url.absoluteString.hasSuffix(".m3u8")
        }
    }

    open private(set)  var player: AVPlayer?
    open private(set)  var playerasset: AVAsset?{
        didSet{
            if oldValue != playerasset{
                if playerasset != nil {
                    self.imageGenerator = AVAssetImageGenerator(asset: playerasset!)
                }else{
                    self.imageGenerator = nil
                }
            }
        }
    }
    open private(set)  var playerItem: AVPlayerItem?{
        willSet{
            if playerItem != newValue{
                if let item = playerItem{
                    NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: item)
                    item.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.status))
                    item.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.loadedTimeRanges))
                    item.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.playbackBufferEmpty))
                    item.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.playbackLikelyToKeepUp))
                }
            }
        }
        didSet {
            if playerItem != oldValue{
                if let item = playerItem{

                    NotificationCenter.default.addObserver(self, selector: #selector(self.playerDidPlayToEnd(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
                    item.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), options: NSKeyValueObservingOptions.new, context: nil)
                    //缓冲区大小
                    item.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.loadedTimeRanges), options: NSKeyValueObservingOptions.new, context: nil)
                    // 缓冲区空了，需要等待数据
                    item.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.playbackBufferEmpty), options: NSKeyValueObservingOptions.new, context: nil)
                    // 缓冲区有足够数据可以播放了
                    item.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.playbackLikelyToKeepUp), options: NSKeyValueObservingOptions.new, context: nil)
                }
            }
        }
    }
    /// 视频截图
    open private(set)  var imageGenerator: AVAssetImageGenerator?
    /// 视频截图m3u8
    open private(set)  var videoOutput: AVPlayerItemVideoOutput?


    open private(set)  var isM3U8 = false

    open  var isLive: Bool? {
        if let duration = self.duration {
            return duration.isNaN
        }
        return nil
    }

    /// 上下滑动屏幕的控制类型
    open var slideTrigger = (left:EZPlayerSlideTrigger.volume,right:EZPlayerSlideTrigger.brightness)
    /// 左右滑动屏幕改变视频进度
    open var canSlideProgress = true

    // MARK: -  player component

    //只读
    open  var controlView : UIView?{
        if let view = self.controlViewForIntercept{
            return view
        }
        switch self.displayMode {
        case .embedded:
            return self.controlViewForEmbedded
        case .fullscreen:
            return self.controlViewForFullscreen
        case .float:
            return self.controlViewForFloat
        case .none:
            return self.controlViewForEmbedded
        }
    }

    /// 拦截原来的各种controlView，作用：比如你要插入一个广告的view，广告结束置空即可
    open  var controlViewForIntercept : UIView? {
        didSet{
            self.updateCustomView()
        }
    }

    ///cactus todo EZPlayerControlView
    /// 嵌入模式的控制皮肤
    open  var controlViewForEmbedded : UIView?
    /// 浮动模式的控制皮肤
    open  var controlViewForFloat : UIView?
    /// 全屏模式的控制皮肤
    open  var controlViewForFullscreen : UIView?



    /// 全屏模式控制器
    open private(set) var fullScreenViewController : EZPlayerFullScreenViewController?

    /// 视频控制器视图
    fileprivate var playerView: EZPlayerView?
    open var view: UIView{
        if self.playerView == nil{
            self.playerView = EZPlayerView(controlView: self.controlView)
        }
        return self.playerView!
    }

    /// 嵌入模式的容器
    open weak var embeddedContentView: UIView?

    /// 嵌入模式的显示隐藏
    open  private(set)  var controlsHidden = false

    /// 过多久自动消失控件，设置为<=0不消失
    open var autohiddenTimeInterval: TimeInterval = 8


    /// 返回按钮block
    open var backButtonBlock:(( _ fromDisplayMode: EZPlayerDisplayMode) -> Void)?


    open var floatContainer: EZPlayerWindowContainer?
    open var floatContainerRootViewController: EZPlayerWindowContainerRootViewController?
    open var floatInitFrame = CGRect(x: UIScreen.main.bounds.size.width - 213 - 10, y: UIScreen.main.bounds.size.height - 120 - 49 - 34 - 10, width: 213, height: 120)
    //    autohideTimeInterval//
    // MARK: -  player status

    open fileprivate(set) var state = EZPlayerState.unknown{
        didSet{
            printLog("old state: \(oldValue)")
            printLog("new state: \(state)")

            if oldValue != state{

                (self.controlView as? EZPlayerDelegate)?.player(self, playerStateDidChange: state)
                self.delegate?.player(self, playerStateDidChange: state)
                NotificationCenter.default.post(name: .EZPlayerStatusDidChange, object: self, userInfo: [Notification.Key.EZPlayerNewStateKey: state,Notification.Key.EZPlayerOldStateKey: oldValue])
                switch state {
                case  .readyToPlay,.playing ,.pause,.seekingForward,.seekingBackward,.stopped,.bufferFinished://cactus todo
                    (self.controlView as? EZPlayerDelegate)?.player(self, showLoading: false)
                    self.delegate?.player(self, showLoading: false)
                    NotificationCenter.default.post(name: .EZPlayerLoadingDidChange, object: self, userInfo: [Notification.Key.EZPlayerLoadingDidChangeKey: false])
                    break
                default:
                    (self.controlView as? EZPlayerDelegate)?.player(self, showLoading: true)
                    self.delegate?.player(self, showLoading: true)
                    NotificationCenter.default.post(name: .EZPlayerLoadingDidChange, object: self, userInfo: [Notification.Key.EZPlayerLoadingDidChangeKey: true])
                    break
                }

                if case .error(_) = state {
                    NotificationCenter.default.post(name: .EZPlayerPlaybackDidFinish, object: self, userInfo: [Notification.Key.EZPlayerPlaybackDidFinishReasonKey: EZPlayerPlaybackDidFinishReason.playbackError])

                }
            }
        }
    }

    open private(set)  var displayMode = EZPlayerDisplayMode.none{
        didSet{
            if oldValue != displayMode{
                (self.controlView as? EZPlayerDelegate)?.player(self, playerDisplayModeDidChange: displayMode)
                self.delegate?.player(self, playerDisplayModeDidChange: displayMode)
                NotificationCenter.default.post(name: .EZPlayerDisplayModeDidChange, object: self, userInfo: [Notification.Key.EZPlayerDisplayModeDidChangeKey: displayMode])

            }
        }
    }
    open private(set)  var lastDisplayMode = EZPlayerDisplayMode.none

    open var isPlaying:Bool{
        guard let player = self.player else {
            return false
        }
        if #available(iOS 10.0, *) {
            return player.timeControlStatus == .playing;
        }else{
            return player.rate > Float(0) && player.error == nil
        }
    }

    /// 视频长度，live是NaN
    open var duration: TimeInterval? {
        if let  duration = self.player?.duration  {
            return duration
        }
        return nil
    }


    /// 视频进度
    open var currentTime: TimeInterval? {
        if let  currentTime = self.player?.currentTime {
            return currentTime
        }
        return nil
    }

    /// 视频播放速率
    open var rate: Float{
        get {
            if let player = self.player {
                return player.rate
            }
            return .nan
        }
        set {
            if let player = self.player {
                player.rate = newValue
            }
        }
    }


    /// 系统音量
    open var systemVolume: Float{
        get {
            return systemVolumeSlider.value
        }
        set {
            systemVolumeSlider.value = newValue
        }
    }

    private let systemVolumeSlider = EZPlayerUtils.systemVolumeSlider

    open weak var  scrollView: UITableView?{
        willSet{
            if scrollView != newValue{
                if let view = scrollView{
                    view.removeObserver(self, forKeyPath: #keyPath(UITableView.contentOffset))

                }
            }
        }
        didSet {
            if playerItem != oldValue{
                if let view = scrollView{
                    view.addObserver(self, forKeyPath: #keyPath(UITableView.contentOffset), options: NSKeyValueObservingOptions.new, context: nil)
                }
            }
        }
    }
    open  var  indexPath: IndexPath?

    // MARK: - Picture in Picture
    open var pipController: AVPictureInPictureController?
    fileprivate var startPIPWithCompletion : ((Error?) -> Void)?
    fileprivate var endPIPWithCompletion : (() -> Void)?

    // MARK: - Life cycle

    deinit {
        NotificationCenter.default.removeObserver(self)
        self.timer?.invalidate()
        self.timer = nil
        self.releasePlayerResource()
    }


    public override init() {
        super.init()
        self.commonInit()


    }

    public init(controlView: UIView? ) {
        super.init()
        if controlView == nil{
            self.controlViewForEmbedded = UIView()
        }else{
            self.controlViewForEmbedded = controlView
        }
        self.commonInit()
    }

    // MARK: - Player action
    open func playWithURL(_ url: URL,embeddedContentView contentView: UIView? = nil, title: String? = nil) {

        self.contentItem = EZPlayerContentItem(url: url, title: title)
        self.contentURL = url

        self.prepareToPlay()

        if contentView != nil {
            self.embeddedContentView = contentView
            self.embeddedContentView!.addSubview(self.view)
            self.view.frame = self.embeddedContentView!.bounds
            self.displayMode = .embedded
        }else{
            self.toFull()
        }
    }

    open func replaceToPlayWithURL(_ url: URL, title: String? = nil) {
        self.resetPlayerResource()

        self.contentItem = EZPlayerContentItem(url: url, title: title)
        self.contentURL = url

        guard let url = self.contentURL else {
            self.state = .error(.invalidContentURL)
            return
        }


        self.playerasset = AVAsset(url: url)

        let keys = ["tracks","duration","commonMetadata","availableMediaCharacteristicsWithMediaSelectionOptions"]
        self.playerItem = AVPlayerItem(asset: self.playerasset!, automaticallyLoadedAssetKeys: keys)
        self.player?.replaceCurrentItem(with: self.playerItem)

        self.setControlsHidden(false, animated: true)
    }

    open func play(){
        self.state = .playing
        self.player?.play()

    }


    open func pause(){
        self.state = .pause
        self.player?.pause()
    }

    open func stop(){
        let lastState = self.state
        self.state = .stopped
        self.player?.pause()

        self.releasePlayerResource()
        guard case .error(_) = lastState else{
            if lastState != .stopped {
                NotificationCenter.default.post(name: .EZPlayerPlaybackDidFinish, object: self, userInfo: [Notification.Key.EZPlayerPlaybackDidFinishReasonKey: EZPlayerPlaybackDidFinishReason.stopByUser])

            }
            return
        }
    }

    open func seek(to time: TimeInterval, completionHandler: ((Bool) -> Swift.Void )? = nil){
        guard let player = self.player else {
            return
        }

        let lastState = self.state
        if let currentTime = self.currentTime {
            if currentTime > time {
                self.state = .seekingBackward
            }else if currentTime < time {
                self.state = .seekingForward
            }
        }


        player.seek(to: CMTimeMakeWithSeconds(time,preferredTimescale: CMTimeScale(NSEC_PER_SEC)), toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero, completionHandler: {  [weak self]  (finished) in
            guard let weakSelf = self else {
                return
            }
            switch (weakSelf.state) {
            case .seekingBackward,.seekingForward:
                weakSelf.state = lastState
            default: break
            }
            completionHandler?(finished)
        })

    }


    private var isChangingDisplayMode = false
    open func toFull(_ orientation:UIDeviceOrientation = .landscapeLeft, animated: Bool = true ,completion: ((Bool) -> Swift.Void)? = nil) {
        if self.isChangingDisplayMode == true {
            completion?(false)
            return
        }
        if self.displayMode == .fullscreen {
            completion?(false)
            return
        }
        guard let activityViewController = EZPlayerUtils.activityViewController() else {
            completion?(false)
            return
        }

        func __toFull(from view: UIView)  {
            self.isChangingDisplayMode = true
            self.updateCustomView(toDisplayMode: .fullscreen)
            NotificationCenter.default.post(name: .EZPlayerDisplayModeChangedWillAppear, object: self, userInfo: [Notification.Key.EZPlayerDisplayModeChangedFrom : self.lastDisplayMode, Notification.Key.EZPlayerDisplayModeChangedTo : EZPlayerDisplayMode.fullscreen])
            self.setControlsHidden(true, animated: false)

            self.fullScreenViewController = EZPlayerFullScreenViewController()
            self.fullScreenViewController!.preferredlandscapeForPresentation = orientation == .landscapeRight ? .landscapeLeft : .landscapeRight
            self.fullScreenViewController!.player = self

            if animated {

                let rect = view.convert(self.view.frame, to: activityViewController.view)
                let x = activityViewController.view.bounds.size.width - rect.size.width - rect.origin.x
                let y = activityViewController.view.bounds.size.height - rect.size.height - rect.origin.y
                self.fullScreenViewController!.modalPresentationStyle = .fullScreen
                activityViewController.present(self.fullScreenViewController!, animated: false, completion: {
                    self.view.removeFromSuperview()
                    self.fullScreenViewController!.view.addSubview(self.view)
                    self.fullScreenViewController!.view.sendSubviewToBack(self.view)
                    if self.autoLandscapeFullScreenLandscape && self.fullScreenMode == .landscape{
                        self.view.transform = CGAffineTransform(rotationAngle:orientation == .landscapeRight ? CGFloat(Double.pi / 2) : -CGFloat(Double.pi / 2))
                        self.view.frame = orientation == .landscapeRight ?  CGRect(x:  y, y: rect.origin.x, width: rect.size.height, height: rect.size.width) : CGRect(x: rect.origin.y, y: x, width: rect.size.height, height: rect.size.width)
                    }else{
                        self.view.frame = rect
                    }

                    UIView.animate(withDuration: EZPlayerAnimatedDuration, animations: {
                        if self.autoLandscapeFullScreenLandscape && self.fullScreenMode == .landscape{
                            self.view.transform = CGAffineTransform.identity
                        }
                        self.view.bounds = self.fullScreenViewController!.view.bounds
                        self.view.center = self.fullScreenViewController!.view.center
                    }, completion: {finished in
                        self.setControlsHidden(false, animated: true)
                        NotificationCenter.default.post(name: .EZPlayerDisplayModeChangedDidAppear, object: self, userInfo: [Notification.Key.EZPlayerDisplayModeChangedFrom : self.lastDisplayMode, Notification.Key.EZPlayerDisplayModeChangedTo : EZPlayerDisplayMode.fullscreen])
                        completion?(finished)
                        self.isChangingDisplayMode = false
                    })
                })
            }else{
                self.fullScreenViewController!.modalPresentationStyle = .fullScreen
                activityViewController.present(self.fullScreenViewController!, animated: false, completion: {
                    self.view.removeFromSuperview()
                    self.fullScreenViewController!.view.addSubview(self.view)
                    self.fullScreenViewController!.view.sendSubviewToBack(self.view)

                    self.view.bounds = self.fullScreenViewController!.view.bounds
                    self.view.center = self.fullScreenViewController!.view.center

                    self.setControlsHidden(false, animated: true)
                    NotificationCenter.default.post(name: .EZPlayerDisplayModeChangedDidAppear, object: self, userInfo: [Notification.Key.EZPlayerDisplayModeChangedFrom : self.lastDisplayMode, Notification.Key.EZPlayerDisplayModeChangedTo : EZPlayerDisplayMode.fullscreen])
                    completion?(true)
                    self.isChangingDisplayMode = false



                })
            }
        }

        let lastDisplayModeTemp = self.displayMode

        if lastDisplayModeTemp == .embedded{
            guard let embeddedContentView = self.embeddedContentView else {
                completion?(false)
                return
            }
            self.lastDisplayMode = lastDisplayModeTemp
            __toFull(from: embeddedContentView)
        }else if lastDisplayModeTemp == .float{
            let floatModelSupported = EZPlayerUtils.floatModelSupported(self)
            if floatModelSupported == .system{
                self.lastDisplayMode = .fullscreen//特殊处理：设置目标
                self.stopPIP {

                }

            }else{
                guard let floatContainer = self.floatContainer  else {
                    completion?(false)
                    return
                }
                self.lastDisplayMode = lastDisplayModeTemp
                floatContainer.hidden()
                __toFull(from: floatContainer.floatWindow)
            }
        }else{
            //直接进入全屏
            self.updateCustomView(toDisplayMode: .fullscreen)
            NotificationCenter.default.post(name: .EZPlayerDisplayModeChangedWillAppear, object: self, userInfo: [Notification.Key.EZPlayerDisplayModeChangedFrom : self.lastDisplayMode, Notification.Key.EZPlayerDisplayModeChangedTo : EZPlayerDisplayMode.fullscreen])
            self.setControlsHidden(true, animated: false)

            self.fullScreenViewController = EZPlayerFullScreenViewController()
            self.fullScreenViewController!.preferredlandscapeForPresentation = orientation == .landscapeRight ? .landscapeLeft : .landscapeRight
            self.fullScreenViewController!.player = self

            self.view.frame = self.fullScreenViewController!.view.bounds
            self.fullScreenViewController!.view.addSubview(self.view)
            self.fullScreenViewController!.view.sendSubviewToBack(self.view)
            self.fullScreenViewController!.modalPresentationStyle = .fullScreen
            activityViewController.present(self.fullScreenViewController!, animated: animated, completion: {
                self.floatContainer?.hidden()
                self.setControlsHidden(false, animated: true)
                completion?(true)
                NotificationCenter.default.post(name: .EZPlayerDisplayModeChangedDidAppear, object: self, userInfo: [Notification.Key.EZPlayerDisplayModeChangedFrom : self.lastDisplayMode, Notification.Key.EZPlayerDisplayModeChangedTo : EZPlayerDisplayMode.fullscreen])

            })
        }


    }

    open func toEmbedded(animated: Bool = true , completion: ((Bool) -> Swift.Void)? = nil){
        if self.isChangingDisplayMode == true {
            completion?(false)
            return
        }
        if self.displayMode == .embedded {
            completion?(false)
            return
        }
        guard let embeddedContentView = self.embeddedContentView else{
            completion?(false)
            return
        }

        func __endToEmbedded(finished :Bool)  {
            self.view.removeFromSuperview()
            embeddedContentView.addSubview(self.view)
            self.view.frame = embeddedContentView.bounds

            self.setControlsHidden(false, animated: true)
            self.fullScreenViewController = nil
            completion?(finished)
            NotificationCenter.default.post(name: .EZPlayerDisplayModeChangedDidAppear, object: self, userInfo: [Notification.Key.EZPlayerDisplayModeChangedFrom : self.lastDisplayMode, Notification.Key.EZPlayerDisplayModeChangedTo : EZPlayerDisplayMode.embedded])
            self.isChangingDisplayMode = false
        }

        let lastDisplayModeTemp = self.displayMode

        if lastDisplayModeTemp == .fullscreen{
            guard let fullScreenViewController = self.fullScreenViewController else{
                completion?(false)
                return
            }
            self.lastDisplayMode = lastDisplayModeTemp
            self.isChangingDisplayMode = true
            self.updateCustomView(toDisplayMode: .embedded)
            NotificationCenter.default.post(name: .EZPlayerDisplayModeChangedWillAppear, object: self, userInfo: [Notification.Key.EZPlayerDisplayModeChangedFrom : self.lastDisplayMode, Notification.Key.EZPlayerDisplayModeChangedTo : EZPlayerDisplayMode.embedded])

            self.setControlsHidden(true, animated: false)
            if animated {

                let rect = fullScreenViewController.view.bounds
                self.view.removeFromSuperview()
                UIApplication.shared.keyWindow?.addSubview(self.view)
                fullScreenViewController.dismiss(animated: false, completion: {

                    if self.autoLandscapeFullScreenLandscape && self.fullScreenMode == .landscape{
                        self.view.transform = CGAffineTransform(rotationAngle : fullScreenViewController.currentOrientation == .landscapeLeft ? CGFloat(Double.pi / 2) : -CGFloat(Double.pi / 2))
                        self.view.frame = CGRect(x: rect.origin.x, y: rect.origin.y, width: rect.size.height, height: rect.size.width)
                    }else{
                        self.view.bounds = embeddedContentView.bounds

                    }

                    UIView.animate(withDuration: EZPlayerAnimatedDuration, animations: {
                        if self.autoLandscapeFullScreenLandscape && self.fullScreenMode == .landscape{
                            self.view.transform = CGAffineTransform.identity
                        }
                        var center = embeddedContentView.center
                        if let embeddedContentSuperview  = embeddedContentView.superview {
                            center = embeddedContentSuperview.convert(embeddedContentView.center, to: UIApplication.shared.keyWindow)
                        }
                        self.view.bounds = embeddedContentView.bounds
                        self.view.center = center
                    }, completion: {finished in
                        __endToEmbedded(finished: finished)

                    })
                })
            }else{
                fullScreenViewController.dismiss(animated: false, completion: {
                    __endToEmbedded(finished: true)


                })



            }

        }else if lastDisplayModeTemp == .float{
            let floatModelSupported = EZPlayerUtils.floatModelSupported(self)
            if floatModelSupported == .system{
                self.lastDisplayMode = .embedded//特殊处理：设置目标

                self.stopPIP {

                }

            }else{
                guard let floatContainer = self.floatContainer  else {
                    completion?(false)
                    return
                }
                self.lastDisplayMode = lastDisplayModeTemp

                floatContainer.hidden()

                //            self.controlView = Bundle(for: EZPlayerControlView.self).loadNibNamed(String(describing: EZPlayerControlView.self), owner: self, options: nil)?.last as? EZPlayerControlView
                //            self.displayMode = .embedded
                self.isChangingDisplayMode = true
                self.updateCustomView(toDisplayMode: .embedded)
                NotificationCenter.default.post(name: .EZPlayerDisplayModeChangedWillAppear, object: self, userInfo: [Notification.Key.EZPlayerDisplayModeChangedFrom : self.lastDisplayMode, Notification.Key.EZPlayerDisplayModeChangedTo : EZPlayerDisplayMode.embedded])
                self.setControlsHidden(true, animated: false)
                if animated {
                    let rect = floatContainer.floatWindow.convert(self.view.frame, to:  UIApplication.shared.keyWindow)
                    self.view.removeFromSuperview()
                    UIApplication.shared.keyWindow?.addSubview(self.view)
                    self.view.frame = rect

                    UIView.animate(withDuration: EZPlayerAnimatedDuration, animations: {
                        self.view.bounds = embeddedContentView.bounds
                        self.view.center = embeddedContentView.center

                    }, completion: {finished in
                        __endToEmbedded(finished: finished)

                    })
                }else{
                    __endToEmbedded(finished: true)

                }
            }

        }else{
            completion?(false)

        }
    }

    /// 进入浮层模式，
    /// - Parameters:
    ///   - animated: <#animated description#>
    ///   - completion: <#completion description#>
    open func toFloat(animated: Bool = true, completion: ((Bool) -> Swift.Void)? = nil) {
        if self.floatMode == .none {
            completion?(false)
            return
        }

        if self.isChangingDisplayMode == true {
            completion?(false)
            return
        }
        if self.displayMode == .float {
            completion?(false)
            return
        }

        let floatModelSupported = EZPlayerUtils.floatModelSupported(self)
        if floatModelSupported == .system{
            self.isChangingDisplayMode = true
            NotificationCenter.default.post(name: .EZPlayerDisplayModeChangedWillAppear, object: self, userInfo: [Notification.Key.EZPlayerDisplayModeChangedFrom : self.displayMode, Notification.Key.EZPlayerDisplayModeChangedTo : EZPlayerDisplayMode.float])
            self.startPIP { [weak self] error in
                guard let weakSelf = self else{
                    return
                }
                weakSelf.isChangingDisplayMode = false
                weakSelf.lastDisplayMode = weakSelf.displayMode

                if weakSelf.lastDisplayMode == .fullscreen{
                    guard let fullScreenViewController = weakSelf.fullScreenViewController else{
                        return
                    }
                    fullScreenViewController.dismiss(animated: false) {

                    }
                }else if weakSelf.lastDisplayMode == .embedded{
                    //                    weakSelf.view.removeFromSuperview()
                    //                    weakSelf.controlViewForEmbedded = nil
                    weakSelf.view.isHidden = true

                }
                weakSelf.updateCustomView(toDisplayMode: .float)
                completion?(error != nil ? true : false)
                NotificationCenter.default.post(name: .EZPlayerDisplayModeChangedDidAppear, object: weakSelf, userInfo: [Notification.Key.EZPlayerDisplayModeChangedFrom : weakSelf.lastDisplayMode, Notification.Key.EZPlayerDisplayModeChangedTo : error != nil ? weakSelf.lastDisplayMode : EZPlayerDisplayMode.float])
            }
        }else{
            self.toWindow(animated: animated, completion: completion)
        }
    }

    // MARK: - public

    open func setControlsHidden(_ hidden: Bool, animated: Bool = false){
        self.controlsHidden = hidden
        (self.controlView as? EZPlayerDelegate)?.player(self, playerControlsHiddenDidChange: hidden ,animated: animated )
        self.delegate?.player(self, playerControlsHiddenDidChange: hidden,animated: animated)
        NotificationCenter.default.post(name: .EZPlayerControlsHiddenDidChange, object: self, userInfo: [Notification.Key.EZPlayerControlsHiddenDidChangeKey: hidden,Notification.Key.EZPlayerControlsHiddenDidChangeByAnimatedKey: animated])
    }

    open  func updateCustomView(toDisplayMode: EZPlayerDisplayMode? = nil){
        var nextDisplayMode = self.displayMode
        if toDisplayMode != nil{
            nextDisplayMode = toDisplayMode!
        }
        if let view = self.controlViewForIntercept{
            self.playerView?.controlView = view
            self.displayMode = nextDisplayMode
            return
        }
        switch nextDisplayMode {
        case .embedded:
            //playerView加问号，其实不关心playerView存不存在，存在就更新
            if self.playerView?.controlView == nil || self.playerView?.controlView != self.controlViewForEmbedded{
                if self.controlViewForEmbedded == nil {
                    self.controlViewForEmbedded = self.controlViewForFullscreen ?? Bundle(for: EZPlayerControlView.self).loadNibNamed(String(describing: EZPlayerControlView.self), owner: self, options: nil)?.last as? EZPlayerControlView
                }
            }
            self.playerView?.controlView = self.controlViewForEmbedded

        case .fullscreen:
            if self.playerView?.controlView == nil || self.playerView?.controlView != self.controlViewForFullscreen{
                if self.controlViewForFullscreen == nil {
                    self.controlViewForFullscreen = self.controlViewForEmbedded ?? Bundle(for: EZPlayerControlView.self).loadNibNamed(String(describing: EZPlayerControlView.self), owner: self, options: nil)?.last as? EZPlayerControlView
                }
            }
            self.playerView?.controlView = self.controlViewForFullscreen

        case .float:
            //                    if self.controlViewForFloat == nil {
            //                        self.controlViewForFloat =   Bundle(for: EZPlayerFloatView.self).loadNibNamed(String(describing: EZPlayerFloatView.self), owner: self, options: nil)?.last as? UIView
            //                    }
            let floatModelSupported = EZPlayerUtils.floatModelSupported(self)
            if self.playerView?.controlView == nil || self.playerView?.controlView != self.controlViewForFloat{
                if self.controlViewForFloat == nil {
                    self.controlViewForFloat = floatModelSupported == .window ?  Bundle(for: EZPlayerWindowView.self).loadNibNamed(String(describing: EZPlayerWindowView.self), owner: self, options: nil)?.last as? UIView : Bundle(for: EZPlayerControlView.self).loadNibNamed(String(describing: EZPlayerControlView.self), owner: self, options: nil)?.last as? EZPlayerControlView
                }
            }
            self.playerView?.controlView = self.controlViewForFloat
            break
        case .none:
            //初始化的时候
            if self.controlView == nil {
                self.controlViewForEmbedded =  Bundle(for: EZPlayerControlView.self).loadNibNamed(String(describing: EZPlayerControlView.self), owner: self, options: nil)?.last as? EZPlayerControlView
            }
        }
        self.displayMode = nextDisplayMode
    }

    // MARK: - private
    private func commonInit() {
        self.updateCustomView()//走case .none:，防止没有初始化
        NotificationCenter.default.addObserver(self, selector: #selector(self.applicationWillEnterForeground(_:)), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.applicationDidBecomeActive(_:)), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.applicationWillResignActive(_:)), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.applicationDidEnterBackground(_:)), name: UIApplication.didEnterBackgroundNotification, object: nil)

        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        NotificationCenter.default.addObserver(self, selector: #selector(self.deviceOrientationDidChange(_:)), name: UIDevice.orientationDidChangeNotification, object: nil)
        //        NotificationCenter.default.addObserver(self, selector: #selector(self.playerDidPlayToEnd(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
        self.timer?.invalidate()
        self.timer = nil
        self.timer =  Timer.timerWithTimeInterval(0.5, block: {  [weak self] in
            //            guard let weakself = self, let player = weakself.pl

            guard let weakSelf = self, let _ = weakSelf.player, let playerItem = weakSelf.playerItem else{
                return
            }
            if !playerItem.isPlaybackLikelyToKeepUp && weakSelf.state == .playing{
                weakSelf.state = .buffering
            }

            if playerItem.isPlaybackLikelyToKeepUp && (weakSelf.state == .buffering || weakSelf.state == .readyToPlay){
                weakSelf.state = .bufferFinished
                if weakSelf.autoPlay {
                    weakSelf.state = .playing
                }
            }

            (weakSelf.controlView as? EZPlayerDelegate)?.playerHeartbeat(weakSelf)
            weakSelf.delegate?.playerHeartbeat(weakSelf)
            NotificationCenter.default.post(name: .EZPlayerHeartbeat, object: self, userInfo:nil)

        }, repeats: true)
        RunLoop.current.add(self.timer!, forMode: RunLoop.Mode.common)
    }

    private func prepareToPlay(){
        guard let url = self.contentURL else {
            self.state = .error(.invalidContentURL)
            return
        }
        self.releasePlayerResource()

        self.playerasset = AVAsset(url: url)

        let keys = ["tracks","duration","commonMetadata","availableMediaCharacteristicsWithMediaSelectionOptions"]
        self.playerItem = AVPlayerItem(asset: self.playerasset!, automaticallyLoadedAssetKeys: keys)
        self.player   = AVPlayer(playerItem: playerItem!)
        //        if #available(iOS 10.0, *) {
        //            self.player!.automaticallyWaitsToMinimizeStalling = false
        //        }
        self.player!.allowsExternalPlayback = self.allowsExternalPlayback
        if self.playerView == nil {
            self.playerView = EZPlayerView(controlView: self.controlView )
        }
        (self.playerView?.layer as! AVPlayerLayer).videoGravity = AVLayerVideoGravity(rawValue: self.videoGravity.rawValue)
        self.playerView?.config(player: self)

        (self.controlView as? EZPlayerDelegate)?.player(self, showLoading: true)
        self.delegate?.player(self, showLoading: true)
        NotificationCenter.default.post(name: .EZPlayerLoadingDidChange, object: self, userInfo: [Notification.Key.EZPlayerLoadingDidChangeKey: true])

        self.addPlayerItemTimeObserver()
    }


    private func addPlayerItemTimeObserver(){
        self.timeObserver = self.player?.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC)), queue: DispatchQueue.main, using: {  [weak self] time in
            guard let weakSelf = self else {
                return
            }

            (weakSelf.controlView as? EZPlayerDelegate)?.player(weakSelf, currentTime: weakSelf.currentTime ?? 0, duration: weakSelf.duration ?? 0)
            weakSelf.delegate?.player(weakSelf, currentTime: weakSelf.currentTime ?? 0, duration: weakSelf.duration ?? 0)
            NotificationCenter.default.post(name: .EZPlayerPlaybackTimeDidChange, object: self, userInfo:nil)

        })
    }

    private func  resetPlayerResource() {
        self.contentItem = nil
        self.contentURL = nil

        if self.videoOutput != nil {
            self.playerItem?.remove(self.videoOutput!)
        }
        self.videoOutput = nil

        self.playerasset = nil
        self.playerItem = nil
        self.player?.replaceCurrentItem(with: nil)

        self.playerView?.layer.removeAllAnimations()

        (self.controlView as? EZPlayerDelegate)?.player(self, bufferDurationDidChange: 0, totalDuration: 0)
        self.delegate?.player(self, bufferDurationDidChange: 0, totalDuration: 0)

        (self.controlView as? EZPlayerDelegate)?.player(self, currentTime:0, duration: 0)
        self.delegate?.player(self, currentTime: 0, duration: 0)
        NotificationCenter.default.post(name: .EZPlayerPlaybackTimeDidChange, object: self, userInfo:nil)
    }

    private func  releasePlayerResource() {
        self.releasePIPResource()

        if self.fullScreenViewController != nil {
            self.fullScreenViewController!.dismiss(animated: true, completion: {
            })
        }

        self.scrollView = nil
        self.indexPath = nil

        if self.videoOutput != nil {
            self.playerItem?.remove(self.videoOutput!)
        }
        self.videoOutput = nil

        self.playerasset = nil
        self.playerItem = nil
        self.player?.replaceCurrentItem(with: nil)
        self.playerView?.layer.removeAllAnimations()
        self.playerView?.removeFromSuperview()
        self.playerView = nil

        if self.timeObserver != nil{
            self.player?.removeTimeObserver(self.timeObserver!)
            self.timeObserver = nil
        }

    }
}

// MARK: - Notification
extension EZPlayer {
    @objc fileprivate func playerDidPlayToEnd(_ notifiaction: Notification) {

        self.state = .stopped
        NotificationCenter.default.post(name: .EZPlayerPlaybackDidFinish, object: self, userInfo: [Notification.Key.EZPlayerPlaybackDidFinishReasonKey: EZPlayerPlaybackDidFinishReason.playbackEndTime])

    }

    @objc fileprivate  func deviceOrientationDidChange(_ notifiaction: Notification){
        //        if !self.autoLandscapeFullScreenLandscape || self.embeddedContentView == nil{
        if !self.autoLandscapeFullScreenLandscape || self.fullScreenMode == .portrait {
            return
        }
        switch UIDevice.current.orientation {
        case .portrait:
            if self.lastDisplayMode == .embedded{
                self.toEmbedded()
            }else if self.lastDisplayMode == .float{
                self.toFloat()
            }
        case .landscapeLeft:
            self.toFull(UIDevice.current.orientation)
        case .landscapeRight:
            self.toFull(UIDevice.current.orientation)

        default:
            break
        }


    }

    @objc fileprivate  func applicationWillEnterForeground(_ notifiaction: Notification){

    }

    @objc fileprivate  func applicationDidBecomeActive(_ notifiaction: Notification){

    }


    @objc fileprivate  func applicationWillResignActive(_ notifiaction: Notification){

    }

    @objc fileprivate  func applicationDidEnterBackground(_ notifiaction: Notification){

    }

}

// MARK: - KVO

extension EZPlayer {
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let item = object as? AVPlayerItem, let keyPath = keyPath {
            if item == self.playerItem {
                switch keyPath {
                case #keyPath(AVPlayerItem.status):
                    //3）然后是kAVPlayerItemStatus的变化，从0变为1，即变为readyToPlay
                    printLog("AVPlayerItem's status is changed: \(item.status.rawValue)")
                    if item.status == .readyToPlay {//可以播放
                        let lastState = self.state
                        if self.state != .playing{
                            self.state = .readyToPlay
                        }
                        //自动播放
                        if self.autoPlay && lastState == .unknown{
                            self.play()
                        }
                    } else if item.status == .failed {
                        self.state = .error(.playerFail)
                    }

                case #keyPath(AVPlayerItem.loadedTimeRanges):
                    printLog("AVPlayerItem's loadedTimeRanges is changed")
                    (self.controlView as? EZPlayerDelegate)?.player(self, bufferDurationDidChange: item.bufferDuration ?? 0, totalDuration: self.duration ?? 0)
                    self.delegate?.player(self, bufferDurationDidChange: item.bufferDuration ?? 0, totalDuration: self.duration ?? 0)
                case #keyPath(AVPlayerItem.playbackBufferEmpty):
                    //1）首先是观察到kAVPlayerItemPlaybackBufferEmpty的变化，从1变为0，说有缓存到内容了，已经有loadedTimeRanges了，但这时候还不一定能播放，因为数据可能还不够播放；
                    printLog("AVPlayerItem's playbackBufferEmpty is changed")
                case #keyPath(AVPlayerItem.playbackLikelyToKeepUp):
                    //2）然后是kAVPlayerItemPlaybackLikelyToKeepUp，从0变到1，说明可以播放了，这时候会自动开始播放

                    printLog("AVPlayerItem's playbackLikelyToKeepUp is changed")
                default:
                    break
                }
            }
        }else if let view = object as? UITableView ,let keyPath = keyPath{
            switch keyPath {
            case #keyPath(UITableView.contentOffset):
                if isChangingDisplayMode == true{
                    return
                }
                if view == self.scrollView {
                    if let index = self.indexPath {
                        let cellrectInTable = view.rectForRow(at: index)
                        let cellrectInTableSuperView =  view.convert(cellrectInTable, to: view.superview)
                        if cellrectInTableSuperView.origin.y + cellrectInTableSuperView.size.height/2 < view.frame.origin.y + view.contentInset.top || cellrectInTableSuperView.origin.y + cellrectInTableSuperView.size.height/2 > view.frame.origin.y + view.frame.size.height - view.contentInset.bottom{
                            self.toFloat()
                        }else{
                            if let cell = view.cellForRow(at: index){
                                if  !cell.contentView.subviews.contains(self.view){
                                    self.view.removeFromSuperview()
                                    self.embeddedContentView = self.embeddedContentView ?? cell.contentView
                                    self.embeddedContentView!.addSubview(self.view)
                                }
                                self.toEmbedded(animated: false, completion: { flag in
                                })
                            }
                        }
                    }
                }

            default:
                break
            }
        }
    }
}

// MARK: - generateThumbnails
extension EZPlayer {
    //不支持m3u8
    open func generateThumbnails(times: [TimeInterval],maximumSize: CGSize, completionHandler: @escaping (([EZPlayerThumbnail]) -> Swift.Void )){
        guard let imageGenerator = self.imageGenerator else {
            return
        }

        var values = [NSValue]()
        for time in times {
            values.append(NSValue(time: CMTimeMakeWithSeconds(time,preferredTimescale: CMTimeScale(NSEC_PER_SEC))))
        }

        var thumbnailCount = values.count
        var thumbnails = [EZPlayerThumbnail]()
        imageGenerator.cancelAllCGImageGeneration()
        imageGenerator.appliesPreferredTrackTransform = true// 截图的时候调整到正确的方向
        imageGenerator.maximumSize = maximumSize//设置后可以获取缩略图
        imageGenerator.generateCGImagesAsynchronously(forTimes:values) { (requestedTime: CMTime,image: CGImage?,actualTime: CMTime,result: AVAssetImageGenerator.Result,error: Error?) in

            let thumbnail = EZPlayerThumbnail(requestedTime: requestedTime, image: image == nil ? nil :  UIImage(cgImage: image!) , actualTime: actualTime, result: result, error: error)
            thumbnails.append(thumbnail)
            thumbnailCount -= 1
            if thumbnailCount == 0 {
                DispatchQueue.main.async {
                    completionHandler(thumbnails)
                }

            }
        }
    }


    //支持m3u8
    open func snapshotImage() -> UIImage? {
        guard let playerItem = self.playerItem else {  //playerItem is AVPlayerItem
            return nil
        }

        if self.videoOutput == nil {
            self.videoOutput = AVPlayerItemVideoOutput(pixelBufferAttributes: nil)
            playerItem.remove(self.videoOutput!)
            playerItem.add(self.videoOutput!)
        }

        guard let videoOutput = self.videoOutput else {
            return nil
        }

        let time = videoOutput.itemTime(forHostTime: CACurrentMediaTime())
        if videoOutput.hasNewPixelBuffer(forItemTime: time) {
            let lastSnapshotPixelBuffer = videoOutput.copyPixelBuffer(forItemTime: time, itemTimeForDisplay: nil)
            if lastSnapshotPixelBuffer != nil {
                let ciImage = CIImage(cvPixelBuffer: lastSnapshotPixelBuffer!)
                let context = CIContext(options: nil)
                let rect = CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(CVPixelBufferGetWidth(lastSnapshotPixelBuffer!)), height: CGFloat(CVPixelBufferGetHeight(lastSnapshotPixelBuffer!)))
                let cgImage = context.createCGImage(ciImage, from: rect)
                if cgImage != nil {
                    return UIImage(cgImage: cgImage!)
                }
            }
        }
        return nil
    }
}

// MARK: - display Mode
extension EZPlayer {
    private func configFloatVideo(){
        if self.floatContainerRootViewController == nil {
            self.floatContainerRootViewController = EZPlayerWindowContainerRootViewController(nibName: String(describing: EZPlayerWindowContainerRootViewController.self), bundle: Bundle(for: EZPlayerWindowContainerRootViewController.self))
        }
        if self.floatContainer == nil {
            self.floatContainer = EZPlayerWindowContainer(frame: self.floatInitFrame, rootViewController: self.floatContainerRootViewController!)
        }
    }

    open func toWindow(animated: Bool = true, completion: ((Bool) -> Swift.Void)? = nil) {
        func __endToWindow(finished :Bool)  {
            self.view.removeFromSuperview()
            self.floatContainerRootViewController?.addVideoView(self.view)
            self.floatContainer?.show()
            self.setControlsHidden(false, animated: true)
            self.fullScreenViewController = nil
            completion?(finished)
            NotificationCenter.default.post(name: .EZPlayerDisplayModeChangedDidAppear, object: self, userInfo: [Notification.Key.EZPlayerDisplayModeChangedFrom : self.lastDisplayMode, Notification.Key.EZPlayerDisplayModeChangedTo : EZPlayerDisplayMode.float])
            self.isChangingDisplayMode = false
        }

        self.lastDisplayMode = self.displayMode
        if self.lastDisplayMode == .embedded {
            self.configFloatVideo()

            self.isChangingDisplayMode = true
            self.updateCustomView(toDisplayMode: .float)
            NotificationCenter.default.post(name: .EZPlayerDisplayModeChangedWillAppear, object: self, userInfo: [Notification.Key.EZPlayerDisplayModeChangedFrom : self.lastDisplayMode, Notification.Key.EZPlayerDisplayModeChangedTo : EZPlayerDisplayMode.float])
            self.setControlsHidden(true, animated: false)

            if animated{
                let rect = self.embeddedContentView!.convert(self.view.frame, to: UIApplication.shared.keyWindow)
                self.view.removeFromSuperview()
                UIApplication.shared.keyWindow?.addSubview(self.view)
                self.view.frame = rect
                UIView.animate(withDuration: EZPlayerAnimatedDuration, animations: {
                    self.view.bounds = self.floatContainer!.floatWindow.bounds
                    self.view.center = self.floatContainer!.floatWindow.center
                }, completion: {finished in
                    __endToWindow(finished: finished)
                })
            }else{
                __endToWindow(finished: true)
            }
        }else if self.lastDisplayMode == .fullscreen{
            guard let fullScreenViewController = self.fullScreenViewController else{
                completion?(false)
                return
            }
            self.configFloatVideo()

            self.isChangingDisplayMode = true
            self.updateCustomView(toDisplayMode: .float)
            NotificationCenter.default.post(name: .EZPlayerDisplayModeChangedWillAppear, object: self, userInfo: [Notification.Key.EZPlayerDisplayModeChangedFrom : self.lastDisplayMode, Notification.Key.EZPlayerDisplayModeChangedTo : EZPlayerDisplayMode.float])
            self.setControlsHidden(true, animated: false)

            if animated{
                let rect = fullScreenViewController.view.bounds
                self.view.removeFromSuperview()
                UIApplication.shared.keyWindow?.addSubview(self.view)
                fullScreenViewController.dismiss(animated: false, completion: {
                    if self.autoLandscapeFullScreenLandscape && self.fullScreenMode == .landscape{
                        self.view.transform = CGAffineTransform(rotationAngle : fullScreenViewController.currentOrientation == .landscapeLeft ? CGFloat(Double.pi / 2) : -CGFloat(Double.pi / 2))
                        self.view.frame = CGRect(x: rect.origin.x, y: rect.origin.y, width: rect.size.height, height: rect.size.width)
                    }else{
                        self.view.bounds = self.floatContainer!.floatWindow.bounds
                    }
                    UIView.animate(withDuration: EZPlayerAnimatedDuration, animations: {
                        if self.autoLandscapeFullScreenLandscape && self.fullScreenMode == .landscape{
                            self.view.transform = CGAffineTransform.identity
                        }
                        self.view.bounds = self.floatContainer!.floatWindow.bounds
                        self.view.center = self.floatContainer!.floatWindow.center
                    }, completion: {finished in
                        __endToWindow(finished: finished)

                    })

                })
            }else{
                fullScreenViewController.dismiss(animated: false, completion: {
                    __endToWindow(finished: true)
                })
            }

        }else{
            completion?(false)
        }
    }


}

// MARK: - Picture in Picture Mode
extension EZPlayer: AVPictureInPictureControllerDelegate {

    /// 是否支持pip
    open var isPIPSupported: Bool{
        return AVPictureInPictureController.isPictureInPictureSupported()
    }

    /// 当前是否处于画中画状态显示在屏幕上
    open var isPIPActive: Bool{
        return self.pipController?.isPictureInPictureActive ?? false
    }

    /// 当前画中画是否被挂起。如果你的app因为其他的app在使用PiP而导致你的视频后台播放播放状态为暂停并且不可见，将会返回true。当其他的app离开了PiP时，你的视频会被重新播放
    open var isPIPSuspended: Bool{
        return self.pipController?.isPictureInPictureSuspended ?? false
    }

    /// 告诉你画中画窗口是可用的。如果其他的app再使用PiP模式，他将会返回false。这个实行也能够通过KVO来观察，同样通过观察这种状态的改变，你也能够很好地额处理PiP按钮的的隐藏于展示。
    open var isPIPPossible: Bool{
        return self.pipController?.isPictureInPicturePossible ?? false
    }

    open func startPIP(completion: ((Error?) -> Void)? = nil){
        self.configPIP()
        self.startPIPWithCompletion = completion
        //isPIPSupported和isPIPPossible为true才有效
        //        self.pipController?.startPictureInPicture()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
            self.pipController?.startPictureInPicture()
        }
    }

    open func stopPIP(completion: (() -> Void)? = nil){
        self.endPIPWithCompletion = completion
        self.pipController?.stopPictureInPicture()
    }

    private func configPIP(){
        if isPIPSupported && playerView != nil && pipController == nil {
            pipController = AVPictureInPictureController(playerLayer: playerView!.layer as! AVPlayerLayer)
            pipController?.delegate = self
        }
    }

    private func  releasePIPResource() {
        pipController?.delegate = nil
        pipController = nil
    }


    /// 即将开启画中画
    /// - Parameter pictureInPictureController: <#pictureInPictureController description#>
    public func pictureInPictureControllerWillStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        printLog("pip 即将开启画中画")

        (self.controlView as? EZPlayerDelegate)?.player(self, pictureInPictureControllerWillStartPictureInPicture: pictureInPictureController)
        self.delegate?.player(self, pictureInPictureControllerWillStartPictureInPicture: pictureInPictureController)
        NotificationCenter.default.post(name: .EZPlayerPIPControllerWillStart, object: self, userInfo: nil)

    }

    /// 已经开启画中画
    /// - Parameter pictureInPictureController: <#pictureInPictureController description#>
    public func pictureInPictureControllerDidStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        printLog("pip 已经开启画中画")
        self.startPIPWithCompletion?(nil)
        (self.controlView as? EZPlayerDelegate)?.player(self, pictureInPictureControllerDidStartPictureInPicture: pictureInPictureController)
        self.delegate?.player(self, pictureInPictureControllerDidStartPictureInPicture: pictureInPictureController)
        NotificationCenter.default.post(name: .EZPlayerPIPControllerDidStart, object: self, userInfo: nil)



    }

    /// 开启画中画失败
    /// - Parameters:
    ///   - pictureInPictureController: <#pictureInPictureController description#>
    ///   - error: <#error description#>
    public func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, failedToStartPictureInPictureWithError error: Error) {
        printLog("pip 开启画中画失败")
        self.releasePIPResource()
        self.startPIPWithCompletion?(error)

        (self.controlView as? EZPlayerDelegate)?.player(self, pictureInPictureController: pictureInPictureController, failedToStartPictureInPictureWithError: error)
        self.delegate?.player(self, pictureInPictureController: pictureInPictureController, failedToStartPictureInPictureWithError: error)
        NotificationCenter.default.post(name: .EZPlayerPIPFailedToStart, object: self, userInfo: [Notification.Key.EZPlayerPIPFailedToStart: error])

    }

    /// 即将关闭画中画
    /// - Parameter pictureInPictureController: <#pictureInPictureController description#>
    public func pictureInPictureControllerWillStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        printLog("pip 即将关闭画中画")
        self.isChangingDisplayMode = true
        NotificationCenter.default.post(name: .EZPlayerDisplayModeChangedWillAppear, object: self, userInfo: [Notification.Key.EZPlayerDisplayModeChangedFrom : self.displayMode, Notification.Key.EZPlayerDisplayModeChangedTo : self.lastDisplayMode])

        (self.controlView as? EZPlayerDelegate)?.player(self, pictureInPictureControllerWillStopPictureInPicture: pictureInPictureController)
        self.delegate?.player(self, pictureInPictureControllerWillStopPictureInPicture: pictureInPictureController)
        NotificationCenter.default.post(name: .EZPlayerPIPControllerWillEnd, object: self, userInfo: nil)

    }

    /// 已经关闭画中画
    /// - Parameter pictureInPictureController: <#pictureInPictureController description#>
    public func pictureInPictureControllerDidStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        printLog("pip 已经关闭画中画")
        self.releasePIPResource()

        // 按钮last float x , last x float
        self.isChangingDisplayMode = false

        //        if self.lastDisplayMode != .float{
        let lastDisPlayModeTemp = self.lastDisplayMode
        self.lastDisplayMode = .float
        self.updateCustomView(toDisplayMode: lastDisPlayModeTemp)
        //        }else{
        //            self.updateCustomView(toDisplayMode: lastDisPlayModeTemp)
        //            self.updateCustomView(toDisplayMode: self.displayMode)

        //        }



        //        self.view.removeFromSuperview()
        //        self.embeddedContentView!.addSubview(self.view)
        //        self.view.frame = self.embeddedContentView!.bounds
        self.endPIPWithCompletion?()

        NotificationCenter.default.post(name: .EZPlayerDisplayModeChangedDidAppear, object: self, userInfo: [Notification.Key.EZPlayerDisplayModeChangedFrom : .float, Notification.Key.EZPlayerDisplayModeChangedTo :  self.displayMode])

        (self.controlView as? EZPlayerDelegate)?.player(self, pictureInPictureControllerDidStopPictureInPicture: pictureInPictureController)
        self.delegate?.player(self, pictureInPictureControllerDidStopPictureInPicture: pictureInPictureController)
        NotificationCenter.default.post(name: .EZPlayerPIPControllerDidEnd, object: self, userInfo: nil)

        if self.displayMode == .fullscreen{
            if self.fullScreenViewController == nil {
                self.fullScreenViewController = EZPlayerFullScreenViewController()
                self.fullScreenViewController!.preferredlandscapeForPresentation = UIDevice.current.orientation == .landscapeRight ? .landscapeLeft : .landscapeRight
                self.fullScreenViewController!.player = self
            }
            //            guard let fullScreenViewController = self.fullScreenViewController else{
            //                return
            //            }
            self.fullScreenViewController!.modalPresentationStyle = .fullScreen
            guard let activityViewController = EZPlayerUtils.activityViewController() else {
                return
            }
            activityViewController.present(self.fullScreenViewController!, animated: false) {
//                self.view.removeFromSuperview()
                self.fullScreenViewController!.view.addSubview(self.view)
                self.fullScreenViewController!.view.sendSubviewToBack(self.view)

                self.view.bounds = self.fullScreenViewController!.view.bounds
                self.view.center = self.fullScreenViewController!.view.center
                self.view.isHidden = false

                self.setControlsHidden(false, animated: true)
            }
        }else if self.displayMode == .embedded{
            self.view.isHidden = false
        }
    }

    /// 关闭画中画且恢复播放界面
    /// - Parameters:
    ///   - pictureInPictureController: <#pictureInPictureController description#>
    ///   - completionHandler: <#completionHandler description#>
    public func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void) {
        printLog("pip 关闭画中画且恢复播放界面")
//        completionHandler(true)


        (self.controlView as? EZPlayerDelegate)?.player(self, pictureInPictureController: pictureInPictureController, restoreUserInterfaceForPictureInPictureStopWithCompletionHandler: completionHandler)
        self.delegate?.player(self, pictureInPictureController: pictureInPictureController, restoreUserInterfaceForPictureInPictureStopWithCompletionHandler: completionHandler)
        NotificationCenter.default.post(name: .EZPlayerPIPRestoreUserInterfaceForStop, object: self, userInfo: [Notification.Key.EZPlayerPIPStopWithCompletionHandler: completionHandler])
    }

}

