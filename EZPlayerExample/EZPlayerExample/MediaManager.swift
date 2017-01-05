//
//  MediaManager.swift
//  EZPlayerExample
//
//  Created by yangjun zhu on 2016/12/28.
//  Copyright © 2016年 yangjun zhu. All rights reserved.
//

import UIKit
import EZPlayer
class MediaManager {
     var player: EZPlayer?
     var mediaItem: MediaItem?
     var embeddedContentView: UIView?

    static let sharedInstance = MediaManager()
    private init(){

        NotificationCenter.default.addObserver(self, selector: #selector(self.playerDidPlayToEnd(_:)), name: NSNotification.Name.EZPlayerPlaybackDidFinish, object: nil)

    }

    func playEmbeddedVideo(url: URL, embeddedContentView contentView: UIView? = nil, skin: UIView? = nil ) {
        var mediaItem = MediaItem()
        mediaItem.url = url
        self.playEmbeddedVideo(mediaItem: mediaItem, embeddedContentView: contentView , skin: skin)

    }


    func playEmbeddedVideo(mediaItem: MediaItem, embeddedContentView contentView: UIView? = nil , skin: UIView? = nil ) {
        //stop
        self.releasePlayer()

        self.player = skin == nil ? EZPlayer() : EZPlayer(controlView: skin)
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


//        if self.embeddedContentView != nil {
//            self.embeddedContentView!.addSubview(self.player!.view)
//            self.player!.view.frame = self.embeddedContentView!.bounds
//        }
        self.player!.playWithURL(mediaItem.url! , embeddedContentView: self.embeddedContentView)

    }


    func releasePlayer(){
            self.player?.stop()
            self.player?.view.removeFromSuperview()
        
        self.player = nil
        self.embeddedContentView = nil
        self.mediaItem = nil

    }
    @objc  func playerDidPlayToEnd(_ notifiaction: Notification) {
        print("oooooooooooooooo")
//        //        self.state   = BMPlayerState.playedToTheEnd
//        //        self.playDidEnd = true
//        self.state = .stopped
//        NotificationCenter.default.post(name: .EZPlayerPlaybackDidFinish, object: self, userInfo: [Notification.Key.EZPlayerPlaybackDidFinishReasonKey: EZPlayerPlaybackDidFinishReason.playbackEndTime])
        self.releasePlayer()

    }

    func showFloatVideo(){
//      self.player?.showFloatVideo()

    }

    func hiddenFloatVideo() {
//        self.player?.hiddenFloatVideo()

    }


    func onlyFor_fullscreenPortraitTap(){
        //stop
        self.releasePlayer()
        var mediaItem = MediaItem()
        mediaItem.url = Bundle.main.url(forResource: "hubblecast", withExtension: "m4v")!

        self.player =  EZPlayer()
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

        self.player!.fullScreenMode = .portrait
        self.player!.playWithURL(mediaItem.url! , embeddedContentView: self.embeddedContentView)

    }

}
