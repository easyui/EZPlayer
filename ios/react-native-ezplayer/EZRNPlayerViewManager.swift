//
//  EZRNPlayerViewManager.swift
//  EZPlayerExample_RN
//
//  Created by IQIYI on 2017/9/30.
//  Copyright © 2017年 Facebook. All rights reserved.
//

import Foundation


@objc(EZRNPlayerViewManager)
class EZRNPlayerViewManager : RCTViewManager {
  
  override func view() -> UIView! {
    return EZRNPlayerView();
  }
  
  @objc func play(_ reactTag: NSNumber) {
    self.execute(reactTag: reactTag) { (playerView) in
      playerView.play();
    }
  }
  
  @objc func pause(_ reactTag: NSNumber) {
    self.execute(reactTag: reactTag) { (playerView) in
      playerView.pause();
    }
  }
  
  @objc func stop(_ reactTag: NSNumber) {
    self.execute(reactTag: reactTag) { (playerView) in
      playerView.stop();
    }
  }

  @objc func seek(_ reactTag: NSNumber, time: Double, callback : (RCTResponseSenderBlock)? = nil) {
    self.execute(reactTag: reactTag) { (playerView) in
      playerView.seek(to: time, completionHandler: { (finished) in
        // callback([NSNull(),finished])
        callback?([finished])
      });
    }
  }
  
  @objc func replaceToPlay(_ reactTag: NSNumber, source: [String: Any]) {
    self.execute(reactTag: reactTag) { (playerView) in
      playerView.replaceToPlay(source: source)
    }
  }
  
  @objc func rate(_ reactTag: NSNumber, rate: Float) {
    self.execute(reactTag: reactTag) { (playerView) in
      playerView.player?.rate = rate
    }
  }
  
  @objc func autoPlay(_ reactTag: NSNumber, autoPlay: Bool) {
    self.execute(reactTag: reactTag) { (playerView) in
      playerView.autoPlay = autoPlay
    }
  }
  
  @objc func videoGravity(_ reactTag: NSNumber, videoGravity: String) {
    self.execute(reactTag: reactTag) { (playerView) in
      playerView.videoGravity = videoGravity
    }
  }
  
  @objc func toEmbedded(_ reactTag: NSNumber, animated: Bool = true, callback : (RCTResponseSenderBlock)? = nil) {
      self.execute(reactTag: reactTag) { (playerView) in
        playerView.player?.toEmbedded(animated: animated, completion: { (finished) in
          callback?([finished])
        })
      }
  }

  @objc func toFloat(_ reactTag: NSNumber, animated: Bool = true, callback : (RCTResponseSenderBlock)? = nil) {
    self.execute(reactTag: reactTag) { (playerView) in
      playerView.player?.toFloat(animated: animated, completion: { (finished) in
        callback?([finished])
      })
    }
  }
  
  @objc func toFull(_ reactTag: NSNumber, orientation:String = "landscapeLeft", animated: Bool = true, callback : (RCTResponseSenderBlock)? = nil) {
    self.execute(reactTag: reactTag) { (playerView) in
      playerView.player?.toFull(orientation == "landscapeLeft" ? .landscapeLeft : .landscapeRight  ,animated: animated, completion: { (finished) in
        callback?([finished])
      })
    }
  }
  
  @objc func fullScreenMode(_ reactTag: NSNumber, fullScreenMode:String =  "portrait") {
    self.execute(reactTag: reactTag) { (playerView) in
      playerView.player?.fullScreenMode = fullScreenMode == "portrait" ? .portrait : .landscape
    }
  }
  
  

 private func execute(reactTag: NSNumber,action:  @escaping ((EZRNPlayerView) -> Swift.Void )){
    self.bridge!.uiManager.addUIBlock { (uiManager: RCTUIManager?, viewRegistry:[NSNumber : UIView]?) in
      if let playerView = viewRegistry![reactTag] as? EZRNPlayerView {
        action(playerView);
      }
    }
  }

}
