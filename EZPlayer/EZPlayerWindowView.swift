//
//  EZPlayerFloatView.swift
//  EZPlayer
//
//  Created by yangjun zhu on 2016/12/28.
//  Copyright © 2016年 yangjun zhu. All rights reserved.
//

import UIKit

open class EZPlayerWindowView: UIView, EZPlayerCustomAction {
    public var autohidedControlViews = [UIView]()
    
    @IBOutlet weak var backButton: UIButton!
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    weak public var player: EZPlayer?{
        didSet {
            if let _ = player?.scrollView{
                self.backButton.isHidden = true
            }else{
                self.backButton.isHidden = false
            }
        }
    }
    public func playPauseButtonPressed(_ sender: Any){
    }
    public func fullEmbeddedScreenButtonPressed(_ sender: Any){
    }
    public func audioSubtitleCCButtonPressed(_ sender: Any){
    }
    
    @IBAction public func backButtonPressed(_ sender: Any){
        guard let player = self.player else {
            return
        }
        let displayMode = player.displayMode
        if displayMode == .float {
            if player.lastDisplayMode == .embedded{
                player.toEmbedded()
            }else  if player.lastDisplayMode == .fullscreen{
                player.toFull()
            }
        }
        self.player?.backButtonBlock?(.float)
    }
    
    @IBAction public func closeButtonPressed(_ sender: Any){
        self.player?.stop()
    }
    
}


extension EZPlayerWindowView: EZPlayerGestureRecognizer {
    
    public func player(_ player: EZPlayer, singleTapGestureTapped singleTap: UITapGestureRecognizer)
    {
        if player.isPlaying {
            player.pause()
        }else{
            player.play()
        }
    }
    
    public func player(_ player: EZPlayer, doubleTapGestureTapped doubleTap: UITapGestureRecognizer) {
        player.toFull()
    }
    
    
}
