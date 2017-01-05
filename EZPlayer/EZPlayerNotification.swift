//
//  EZPlayerNotification.swift
//  EZPlayer
//
//  Created by yangjun zhu on 2016/12/28.
//  Copyright © 2016年 yangjun zhu. All rights reserved.
//

import Foundation



public extension Notification.Name {
    //

    static let EZPlayerHeartbeat = Notification.Name(rawValue: "com.ezplayer.EZPlayerHeartbeat")


    static let EZPlayerPlaybackTimeDidChange = Notification.Name(rawValue: "com.ezplayer.EZPlayerPlaybackTimeDidChange")

    static let EZPlayerStatusDidChange = Notification.Name(rawValue: "com.ezplayer.EZPlayerStatusDidChange")
    static let EZPlayerLoadingDidChange = Notification.Name(rawValue: "com.ezplayer.EZPlayerLoadingDidChange")

    //    static let EZPlayeStatusDidChangeToStopped = Notification.Name(rawValue: "com.ezplayer.EZPlayeStatusDidChangeToStopped")

    //
    static let EZPlayerDisplayModeDidChange = Notification.Name(rawValue: "com.ezplayer.EZPlayerStatusDidChang")
    //
    static let EZPlayerControlsHiddenDidChange = Notification.Name(rawValue: "com.ezplayer.EZPlayerControlsHiddenDidChange")

    //
    static let EZPlayerThumbnailsGenerated = Notification.Name(rawValue: "com.ezplayer.EZPlayerThumbnailsGenerated")

    //
//    static let EZPlayeFullscreenWillAppear = Notification.Name(rawValue: "com.ezplayer.EZPlayeFullscreenWillAppear")
//
//    static let EZPlayeFullscreenDidAppear = Notification.Name(rawValue: "com.ezplayer.EZPlayeFullscreenDidAppear")
//
//    static let EZPlayeFullscreenWillDisappear = Notification.Name(rawValue: "com.ezplayer.EZPlayeFullscreenWillDisappear")
//
//    static let EZPlayeFullscreenDidDisappear = Notification.Name(rawValue: "com.ezplayer.EZPlayeFullscreenWillDisappear")

    static let EZPlayerDisplayModeChangedWillAppear = Notification.Name(rawValue: "EZPlayerDisplayModeChangedWillAppear")
    static let EZPlayerDisplayModeChangedDidAppear = Notification.Name(rawValue: "EZPlayerDisplayModeChangedDidAppear")



    static let EZPlayerPlaybackDidFinish = Notification.Name(rawValue: "com.ezplayer.EZPlayerPlaybackDidFinish")

    //    static let NLMoviePlayerIsAirPlayVideoActiveDidChangeNotification = Notification.Name(rawValue: "com.ezplayer.EZPlayerPlassybackDidFinish")
    static let EZPlayerTapGestureRecognizer = Notification.Name(rawValue: "com.ezplayer.EZPlayerTapGestureRecognizer")




}

extension Notification {
    struct Key {
        //
        static let EZPlayerStatusDidChangeKey = "EZPlayerStatusDidChangeKey"
        static let EZPlayerLoadingDidChangeKey = "EZPlayerLoadingDidChangeKey"

        //
        static let EZPlayerDisplayModeDidChangeKey = "EZPlayerDisplayModeDidChangeKey"
        //
        static let EZPlayerControlsHiddenDidChangeKey = "EZPlayerControlsHiddenDidChangeKey"
        static let EZPlayerControlsHiddenDidChangeByAnimatedKey = "EZPlayerControlsHiddenDidChangeByAnimatedKey"

        static let EZPlayerThumbnailsKey = "EZPlayerThumbnailsKey"


        static let EZPlayerDisplayModeChangedFrom = "EZPlayerDisplayModeChangedFrom"
        static let EZPlayerDisplayModeChangedTo = "EZPlayerDisplayModeChangedTo"


        static let EZPlayerPlaybackDidFinishReasonKey = "EZPlayerPlaybackDidFinishReasonKey"


        static let EZPlayerNumberOfTaps =  "EZPlayerNumberOfTaps"
        static let EZPlayerTapGestureRecognizer =  "EZPlayerTapGestureRecognizer"


    }

}
