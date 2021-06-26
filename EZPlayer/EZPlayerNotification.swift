//
//  EZPlayerNotification.swift
//  EZPlayer
//
//  Created by yangjun zhu on 2016/12/28.
//  Copyright © 2016年 yangjun zhu. All rights reserved.
//

import Foundation



extension Notification.Name {
    /// EZPlayer生命周期
    public static let EZPlayerHeartbeat = Notification.Name(rawValue: "com.ezplayer.EZPlayerHeartbeat")

    /// addPeriodicTimeObserver方法的触发
    public static let EZPlayerPlaybackTimeDidChange = Notification.Name(rawValue: "com.ezplayer.EZPlayerPlaybackTimeDidChange")

    /// 播放器状态改变
    public static let EZPlayerStatusDidChange = Notification.Name(rawValue: "com.ezplayer.EZPlayerStatusDidChange")

    /// 视频结束
    public static let EZPlayerPlaybackDidFinish = Notification.Name(rawValue: "com.ezplayer.EZPlayerPlaybackDidFinish")

    /// loading状态改变
    public static let EZPlayerLoadingDidChange = Notification.Name(rawValue: "com.ezplayer.EZPlayerLoadingDidChange")

    /// 播放器控制条隐藏显示
    public static let EZPlayerControlsHiddenDidChange = Notification.Name(rawValue: "com.ezplayer.EZPlayerControlsHiddenDidChange")

    /// 播放器显示模式改变了（全屏，嵌入屏，浮动）
    public static let EZPlayerDisplayModeDidChange = Notification.Name(rawValue: "com.ezplayer.EZPlayerDisplayModeDidChange")
    /// 播放器显示模式动画开始
    public static let EZPlayerDisplayModeChangedWillAppear = Notification.Name(rawValue: "EZPlayerDisplayModeChangedWillAppear")
    /// 播放器显示模式动画结束
    public static let EZPlayerDisplayModeChangedDidAppear = Notification.Name(rawValue: "EZPlayerDisplayModeChangedDidAppear")

    /// 点击播放器手势通知
    public static let EZPlayerTapGestureRecognizer = Notification.Name(rawValue: "com.ezplayer.EZPlayerTapGestureRecognizer")

    /// FairPlay DRM
    public static let EZPlayerDidPersistContentKey = Notification.Name(rawValue: "com.ezplayer.EZPlayerDidPersistContentKey")

    /// PIP
    public static let EZPlayerPIPControllerWillStart = Notification.Name(rawValue: "com.ezplayer.EZPlayerPIPControllerWillStart")

    public static let EZPlayerPIPControllerDidStart = Notification.Name(rawValue: "com.ezplayer.EZPlayerPIPControllerDidStart")

    public static let EZPlayerPIPFailedToStart = Notification.Name(rawValue: "com.ezplayer.EZPlayerPIPFailedToStart")

    public static let EZPlayerPIPControllerWillEnd = Notification.Name(rawValue: "com.ezplayer.EZPlayerPIPControllerWillEnd")

    public static let EZPlayerPIPControllerDidEnd = Notification.Name(rawValue: "com.ezplayer.EZPlayerPIPControllerDidEnd")

    public static let EZPlayerPIPRestoreUserInterfaceForStop = Notification.Name(rawValue: "com.ezplayer.EZPlayerPIPRestoreUserInterfaceForStop")


}

extension Notification {
    public struct Key {
        /// 播放器状态改变
        public static let EZPlayerNewStateKey = "EZPlayerNewStateKey"
        public static let EZPlayerOldStateKey = "EZPlayerOldStateKey"

        /// 视频结束
        public static let EZPlayerPlaybackDidFinishReasonKey = "EZPlayerPlaybackDidFinishReasonKey"

        /// loading状态改变
        public static let EZPlayerLoadingDidChangeKey = "EZPlayerLoadingDidChangeKey"

        /// 播放器控制条隐藏显示
        public static let EZPlayerControlsHiddenDidChangeKey = "EZPlayerControlsHiddenDidChangeKey"
        public static let EZPlayerControlsHiddenDidChangeByAnimatedKey = "EZPlayerControlsHiddenDidChangeByAnimatedKey"

        /// 播放器显示模式改变了（全屏，嵌入屏，浮动）
        public static let EZPlayerDisplayModeDidChangeKey = "EZPlayerDisplayModeDidChangeKey"
        public static let EZPlayerDisplayModeChangedFrom = "EZPlayerDisplayModeChangedFrom"
        public static let EZPlayerDisplayModeChangedTo = "EZPlayerDisplayModeChangedTo"

        /// 点击播放器手势通知
        public static let EZPlayerNumberOfTaps =  "EZPlayerNumberOfTaps"
        public static let EZPlayerTapGestureRecognizer =  "EZPlayerTapGestureRecognizer"

        /// FairPlay DRM=
        public static let EZPlayerDidPersistAssetIdentifierKey = "EZPlayerDidPersistAssetIdentifierKey"

        /// PIP 启动失败
        public static let EZPlayerPIPFailedToStart =  "EZPlayerPIPFailedToStart"
        /// PIP 关闭画中画且恢复播放界面
        public static let EZPlayerPIPStopWithCompletionHandler =  "EZPlayerPIPStopWithCompletionHandler"


    }

}
