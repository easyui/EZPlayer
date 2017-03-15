//
//  AVPlayerItem+EZPlayer.swift
//  EZPlayer
//
//  Created by yangjun zhu on 2016/12/28.
//  Copyright © 2016年 yangjun zhu. All rights reserved.
//

import AVFoundation
public extension AVPlayerItem {

    public var bufferDuration: TimeInterval? {
        if  let first = self.loadedTimeRanges.first { //获取缓冲进度
            let timeRange = first.timeRangeValue // 获取缓冲区域
            let startSeconds = CMTimeGetSeconds(timeRange.start)//开始的时间
            let durationSecound = CMTimeGetSeconds(timeRange.duration)//表示已经缓冲的时间
            let result = startSeconds + durationSecound // 计算缓冲总时间
            return result
        }
        return nil
    }

    
    /// 获取／设置当前subtitle／cc
    public var selectedMediaCharacteristicLegibleOption:AVMediaSelectionOption?{
        get{
            if let legibleGroup = self.asset.mediaSelectionGroup(forMediaCharacteristic: AVMediaCharacteristicLegible){
                return self.selectedMediaOption(in: legibleGroup)
            }
            return nil
        }
        set{
            if let legibleGroup = self.asset.mediaSelectionGroup(forMediaCharacteristic: AVMediaCharacteristicLegible){
                self.select(newValue, in: legibleGroup)
            }
        }
    }

    /// 获取／设置当前cc
    public var selectedClosedCaptionOption:AVMediaSelectionOption?{
        get{
            if let option = self.selectedMediaCharacteristicLegibleOption{
                if option.mediaType == "clcp" {
                    return option
                }
            }
            return nil
        }
        set{
            if let legibleGroup = self.asset.mediaSelectionGroup(forMediaCharacteristic: AVMediaCharacteristicLegible){
                if newValue == nil{
                    self.select(newValue, in: legibleGroup)
                }else if newValue!.mediaType == "clcp"{
                    self.select(newValue, in: legibleGroup)
                }
            }
        }
    }

    /// 获取／设置当前subtitle
    public var selectedSubtitleOption:AVMediaSelectionOption?{
        get{
            if let option = self.selectedMediaCharacteristicLegibleOption{
                if !option.hasMediaCharacteristic(AVMediaCharacteristicContainsOnlyForcedSubtitles) {
                    return option
                }
            }
            return nil
        }
        set{
            if let legibleGroup = self.asset.mediaSelectionGroup(forMediaCharacteristic: AVMediaCharacteristicLegible){
                if newValue == nil{
                    self.select(newValue, in: legibleGroup)
                }else if !newValue!.hasMediaCharacteristic(AVMediaCharacteristicContainsOnlyForcedSubtitles) {
                    self.select(newValue, in: legibleGroup)
                }
            }
        }
    }

    /// 获取／设置当前audio
    public var selectedMediaCharacteristicAudibleOption:AVMediaSelectionOption?{
        get{
            if let group = self.asset.mediaSelectionGroup(forMediaCharacteristic: AVMediaCharacteristicAudible){
                return self.selectedMediaOption(in: group)
            }
            return nil
        }
        set{
            if let group = self.asset.mediaSelectionGroup(forMediaCharacteristic: AVMediaCharacteristicAudible){
                self.select(newValue, in: group)
            }
        }
    }

}
