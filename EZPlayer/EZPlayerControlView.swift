//
//  EZPlayerControlView.swift
//  EZPlayer
//
//  Created by yangjun zhu on 2016/12/28.
//  Copyright © 2016年 yangjun zhu. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer


open class EZPlayerControlView: UIView{
    weak public var player: EZPlayer?{
        didSet{
            player?.setControlsHidden(false, animated: true)
            self.autohideControlView()

        }
    }

    //    open var tapGesture: UITapGestureRecognizer!

    var hideControlViewTask: Task?

    public var autohidedControlViews = [UIView]()
    //    var controlsHidden = false
    @IBOutlet weak var navBarContainer: UIView!
    @IBOutlet weak var navBarContainerTopConstraint: NSLayoutConstraint!

    @IBOutlet weak var toolBarContainer: UIView!

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var fullEmbeddedScreenButton: UIButton!
    @IBOutlet weak var fullEmbeddedScreenButtonWidthConstraint: NSLayoutConstraint!

    @IBOutlet weak var timeSlider: UISlider!

    @IBOutlet weak var videoshotPreview: UIView!
    @IBOutlet weak var videoshotPreviewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var videoshotImageView: UIImageView!

    @IBOutlet weak var loading: EZPlayerLoading!
    @IBOutlet weak var audioSubtitleCCButtonWidthConstraint: NSLayoutConstraint!

    @IBOutlet weak var airplayContainer: UIView!

    // MARK: - Life cycle

    deinit {

    }
    override open func awakeFromNib() {
        super.awakeFromNib()
        self.timeSlider.value = 0
        self.progressView.progress = 0
        self.progressView.progressTintColor = UIColor.lightGray
        self.progressView.trackTintColor = UIColor.clear
        self.progressView.backgroundColor = UIColor.clear

        self.videoshotPreview.isHidden = true

        self.audioSubtitleCCButtonWidthConstraint.constant = 0



        self.autohidedControlViews = [self.navBarContainer,self.toolBarContainer]
        //        self.tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapGestureTapped(_:)))
        //        self.tapGesture.delegate = self
        //        self.addGestureRecognizer(self.tapGesture)




        let airplayImage = UIImage(named: "btn_airplay", in: Bundle(for: EZPlayerControlView.self),compatibleWith: nil)
        let airplayView = MPVolumeView(frame: self.airplayContainer.bounds)
        airplayView.showsVolumeSlider = false
        airplayView.showsRouteButton = true
        airplayView.setRouteButtonImage(airplayImage, for: .normal)
        self.airplayContainer.addSubview(airplayView)
        //        self.loading.start()


    }

    // MARK: - EZPlayerCustomControlView



    fileprivate var isProgressSliderSliding = false {
        didSet{
            if !(self.player?.isM3U8 ?? true) {
                //                self.videoshotPreview.isHidden = !isProgressSliderSliding
            }
        }

    }

    @IBAction func progressSliderTouchBegan(_ sender: Any) {
        guard let player = self.player else {
            return
        }
        self.player(player, progressWillChange: TimeInterval(self.timeSlider.value))
    }

    @IBAction func progressSliderValueChanged(_ sender: Any) {
        guard let player = self.player else {
            return
        }

        self.player(player, progressChanging: TimeInterval(self.timeSlider.value))

        if !player.isM3U8 {
            self.videoshotPreview.isHidden = false
            player.generateThumbnails(times:  [ TimeInterval(self.timeSlider.value)],maximumSize:CGSize(width: self.videoshotImageView.bounds.size.width, height: self.videoshotImageView.bounds.size.height)) { (thumbnails) in
                let trackRect = self.timeSlider.convert(self.timeSlider.bounds, to: nil)
                let thumbRect = self.timeSlider.thumbRect(forBounds: self.timeSlider.bounds, trackRect: trackRect, value: self.timeSlider.value)
                var lead = thumbRect.origin.x + thumbRect.size.width/2 - self.videoshotPreview.bounds.size.width/2
                if lead < 0 {
                    lead = 0
                }else if lead + self.videoshotPreview.bounds.size.width > player.view.bounds.width {
                    lead = player.view.bounds.width - self.videoshotPreview.bounds.size.width
                }
                self.videoshotPreviewLeadingConstraint.constant = lead
                if thumbnails.count > 0 {
                    let thumbnail = thumbnails[0]
                    if thumbnail.result == .succeeded {
                        self.videoshotImageView.image = thumbnail.image
                    }
                }
            }
        }
    }

    @IBAction func progressSliderTouchEnd(_ sender: Any) {
        self.videoshotPreview.isHidden = true
        guard let player = self.player else {
            return
        }
        self.player(player, progressDidChange: TimeInterval(self.timeSlider.value))
    }


    //    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool{
    //        self.autohideControlView()
    //        return !self.autohidedControlViews.contains(touch.view!) && !self.autohidedControlViews.contains(touch.view!.superview!)
    //        //        return true
    //    }
    //
    // MARK: - private
    //    @objc fileprivate func tapGestureTapped(_ sender: UIGestureRecognizer) {
    //        guard let player = self.player else {
    //            return
    //        }
    //        player.controlsHidden = !player.controlsHidden
    //    }


    fileprivate func hideControlView(_ animated: Bool) {
        //        if self.controlsHidden == true{
        //          return
        //        }
        if animated{
            UIView.setAnimationsEnabled(false)
            UIView.animate(withDuration: ezAnimatedDuration, delay: 0,options: .curveEaseInOut, animations: {
                self.autohidedControlViews.forEach{
                    $0.alpha = 0
                }
            }, completion: {finished in
                self.autohidedControlViews.forEach{
                    $0.isHidden = true
                }
                UIView.setAnimationsEnabled(true)
            })
        }else{
            self.autohidedControlViews.forEach{
                $0.alpha = 0
                $0.isHidden = true
            }
        }
    }

    fileprivate func showControlView(_ animated: Bool) {
        //        if self.controlsHidden == false{
        //            return
        //        }

        if animated{
            UIView.setAnimationsEnabled(false)
            self.autohidedControlViews.forEach{
                $0.isHidden = false
            }
            UIView.animate(withDuration: ezAnimatedDuration, delay: 0,options: .curveEaseInOut, animations: {
                if self.player?.displayMode == .fullscreen{
                    self.navBarContainerTopConstraint.constant = 20
                }else{
                    self.navBarContainerTopConstraint.constant = 0
                }
                self.autohidedControlViews.forEach{
                    $0.alpha = 1
                }
            }, completion: {finished in
                self.autohideControlView()
                UIView.setAnimationsEnabled(true)
            })
        }else{
            self.autohidedControlViews.forEach{
                $0.isHidden = false
                $0.alpha = 1
            }
            if self.player?.displayMode == .fullscreen{
                self.navBarContainerTopConstraint.constant = 20
            }else{
                self.navBarContainerTopConstraint.constant = 0
            }
            self.autohideControlView()
        }
    }

    fileprivate func autohideControlView(){
        guard let player = self.player , player.autohiddenTimeInterval > 0 else {
            return
        }
        cancel(self.hideControlViewTask)
        self.hideControlViewTask = delay(5, task: { [weak self]  in
            guard let weakSelf = self else {
                return
            }
            //            weakSelf.hideControlView()
            weakSelf.player?.setControlsHidden(true, animated: true)
        })


    }

}

extension EZPlayerControlView: EZPlayerCustom {
    // MARK: - EZPlayerCustomAction
    @IBAction public func playPauseButtonPressed(_ sender: Any) {
        guard let player = self.player else {
            return
        }
        if player.isPlaying {
            player.pause()
        }else{
            player.play()
        }
    }

    @IBAction public func fullEmbeddedScreenButtonPressed(_ sender: Any) {
        guard let player = self.player else {
            return
        }
        switch player.displayMode {
        case .embedded:
            player.toFull()
        case .fullscreen:
            if player.lastDisplayMode == .embedded{
                player.toEmbedded()
            }else  if player.lastDisplayMode == .float{
                player.toFloat()
            }

        default:
            break
        }
    }

    @IBAction public func audioSubtitleCCButtonPressed(_ sender: Any) {
        guard let player = self.player else {
            return
        }
        let audibleLegibleViewController = EZPlayerAudibleLegibleViewController(nibName:  String(describing: EZPlayerAudibleLegibleViewController.self),bundle: Bundle(for: EZPlayerAudibleLegibleViewController.self),player:player, sourceView:sender as? UIView)
        EZPlayerUtils.viewController(from: self)?.present(audibleLegibleViewController, animated: true, completion: {

        })
    }



    @IBAction public func backButtonPressed(_ sender: Any) {
        guard let player = self.player else {
            return
        }
        let displayMode = player.displayMode
        if displayMode == .fullscreen {
            if player.lastDisplayMode == .embedded{
                player.toEmbedded()
            }else  if player.lastDisplayMode == .float{
                player.toFloat()
            }
        }
        player.backButtonBlock?(displayMode)
    }


    // MARK: - EZPlayerGestureRecognizer
    public func player(_ player: EZPlayer, singleTapGestureTapped singleTap: UITapGestureRecognizer) {
        player.setControlsHidden(!player.controlsHidden, animated: true)

    }

    public func player(_ player: EZPlayer, doubleTapGestureTapped doubleTap: UITapGestureRecognizer) {
        self.playPauseButtonPressed(doubleTap)
    }

    // MARK: - EZPlayerHorizontalPan
    public func player(_ player: EZPlayer, progressWillChange value: TimeInterval) {
        if player.isLive ?? true{
          return
        }
        cancel(self.hideControlViewTask)
        self.isProgressSliderSliding = true
    }

    public func player(_ player: EZPlayer, progressChanging value: TimeInterval) {
        if player.isLive ?? true{
            return
        }
        self.timeLabel.text = EZPlayerUtils.formatTime(position: value, duration: self.player?.duration ?? 0)
        if !self.timeSlider.isTracking {
            self.timeSlider.value = Float(value)
        }
    }

    public func player(_ player: EZPlayer, progressDidChange value: TimeInterval) {
        if player.isLive ?? true{
            return
        }
        self.autohideControlView()
        //        self.isProgressSliderSliding = false
        self.player?.seek(to: value, completionHandler: { (isFinished) in
            self.isProgressSliderSliding = false

        })
    }

    // MARK: - EZPlayerDelegate

    public func playerHeartbeat(_ player: EZPlayer) {
        if let asset = player.playerasset, let  playerIntem = player.playerItem ,playerIntem.status == .readyToPlay{
            if asset.audios != nil || asset.subtitles != nil || asset.closedCaption != nil{
                self.audioSubtitleCCButtonWidthConstraint.constant = 50
            }else{
                self.audioSubtitleCCButtonWidthConstraint.constant = 0
            }
        }
        self.airplayContainer.isHidden = !player.allowsExternalPlayback
    }


    public func player(_ player: EZPlayer, playerDisplayModeDidChange displayMode: EZPlayerDisplayMode) {
        switch displayMode {
        case .none:
            break
        case .embedded:
            self.fullEmbeddedScreenButtonWidthConstraint.constant = 50
            self.fullEmbeddedScreenButton.setImage(UIImage(named: "btn_fullscreen22x22", in: Bundle(for: EZPlayerControlView.self), compatibleWith: nil), for: .normal)
        case .fullscreen:
            self.fullEmbeddedScreenButtonWidthConstraint.constant = 50
            self.fullEmbeddedScreenButton.setImage(UIImage(named: "btn_normalscreen22x22", in: Bundle(for: EZPlayerControlView.self), compatibleWith: nil), for: .normal)
            if player.lastDisplayMode == .none{
                self.fullEmbeddedScreenButtonWidthConstraint.constant = 0
            }
        case .float:
            break

        }
    }

    public func player(_ player: EZPlayer, playerStateDidChange state: EZPlayerState) {
        //播放器按钮状态
        switch state {
        case .playing ,.buffering:
            //播放状态
            //            self.playPauseButton.isSelected = true //暂停按钮
            self.playPauseButton.setImage(UIImage(named: "btn_pause22x22", in: Bundle(for: EZPlayerControlView.self), compatibleWith: nil), for: .normal)

        case .seekingBackward ,.seekingForward:
            break
        default:
            //            self.playPauseButton.isSelected = false // 播放按钮
            self.playPauseButton.setImage(UIImage(named: "btn_play22x22", in: Bundle(for: EZPlayerControlView.self), compatibleWith: nil), for: .normal)

        }



        //        switch state {
        //        case  .playing ,.pause,.seekingForward,.seekingBackward,.stopped,.bufferFinished:
        //            self.loading.stop()
        //            break
        //        default:
        //            self.loading.start()
        //            break
        //        }

    }

    public func player(_ player: EZPlayer, bufferDurationDidChange bufferDuration: TimeInterval, totalDuration: TimeInterval) {
        if totalDuration.isNaN || bufferDuration.isNaN || totalDuration == 0 || bufferDuration == 0{
            self.progressView.progress = 0
        }else{
        self.progressView.progress = Float(bufferDuration/totalDuration)
        }
    }

    public func player(_ player: EZPlayer, currentTime: TimeInterval, duration: TimeInterval) {
        if currentTime.isNaN || (currentTime == 0 && duration.isNaN){
            return
        }
        self.timeSlider.isEnabled = !duration.isNaN
        self.timeSlider.minimumValue = 0
        self.timeSlider.maximumValue = duration.isNaN ? Float(currentTime) : Float(duration)
        self.titleLabel.text = player.contentItem?.title ?? player.playerasset?.title
        if !self.isProgressSliderSliding {
            self.timeSlider.value = Float(currentTime)
            self.timeLabel.text = duration.isNaN ? "Live" : EZPlayerUtils.formatTime(position: currentTime, duration: duration)

        }
    }


    public func player(_ player: EZPlayer, playerControlsHiddenDidChange controlsHidden: Bool, animated: Bool) {
        if controlsHidden {
            self.hideControlView(animated)
        }else{
            self.showControlView(animated)
        }
    }

    public func player(_ player: EZPlayer ,showLoading: Bool){
        if showLoading {
            self.loading.start()
        }else{
            self.loading.stop()
        }
    }


}
