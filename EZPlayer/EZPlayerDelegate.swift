//
//  EZPlayerDelegate.swift
//  EZPlayer
//
//  Created by Yangjun Zhu on 2020/10/24.
//  Copyright © 2020 yangjun zhu. All rights reserved.
//

import Foundation
import AVKit

public protocol EZPlayerDelegate : AnyObject {
    func player(_ player: EZPlayer ,playerStateDidChange state: EZPlayerState)//.EZPlayerStatusDidChange
    func player(_ player: EZPlayer ,playerDisplayModeDidChange displayMode: EZPlayerDisplayMode)//.EZPlayerDisplayModeDidChange

    func player(_ player: EZPlayer ,playerControlsHiddenDidChange controlsHidden: Bool , animated: Bool)//.EZPlayerControlsHiddenDidChange

    func player(_ player: EZPlayer ,bufferDurationDidChange  bufferDuration: TimeInterval , totalDuration: TimeInterval)//.EZPlayerPlaybackTimeDidChange
    func player(_ player: EZPlayer , currentTime: TimeInterval , duration: TimeInterval)//.EZPlayerPlaybackTimeDidChange
    func playerHeartbeat(_ player: EZPlayer )//.EZPlayerHeartbeat

    func player(_ player: EZPlayer ,showLoading: Bool)//.EZPlayerLoadingDidChange

    func player(_ player: EZPlayer ,pictureInPictureControllerWillStartPictureInPicture pictureInPictureController: AVPictureInPictureController)
    func player(_ player: EZPlayer ,pictureInPictureControllerDidStartPictureInPicture pictureInPictureController: AVPictureInPictureController)

    func player(_ player: EZPlayer , pictureInPictureController: AVPictureInPictureController,failedToStartPictureInPictureWithError error: Error)

    func player(_ player: EZPlayer ,pictureInPictureControllerWillStopPictureInPicture pictureInPictureController: AVPictureInPictureController)
    func player(_ player: EZPlayer ,pictureInPictureControllerDidStopPictureInPicture pictureInPictureController: AVPictureInPictureController)

    func player(_ player: EZPlayer , pictureInPictureController: AVPictureInPictureController,restoreUserInterfaceForPictureInPictureStopWithCompletionHandler: @escaping (Bool) -> Void)
}


extension EZPlayerDelegate{
    public func player(_ player: EZPlayer ,pictureInPictureControllerWillStartPictureInPicture pictureInPictureController: AVPictureInPictureController){

    }

    public func player(_ player: EZPlayer ,pictureInPictureControllerDidStartPictureInPicture pictureInPictureController: AVPictureInPictureController){

    }

    public func player(_ player: EZPlayer , pictureInPictureController: AVPictureInPictureController,failedToStartPictureInPictureWithError error: Error){

    }

    public func player(_ player: EZPlayer ,pictureInPictureControllerWillStopPictureInPicture pictureInPictureController: AVPictureInPictureController){

    }

    public func player(_ player: EZPlayer ,pictureInPictureControllerDidStopPictureInPicture pictureInPictureController: AVPictureInPictureController){

    }

    public func player(_ player: EZPlayer , pictureInPictureController: AVPictureInPictureController,restoreUserInterfaceForPictureInPictureStopWithCompletionHandler: @escaping (Bool) -> Void){

    }

}
