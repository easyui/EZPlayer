//
//  AVAsset+EZPlayer.swift
//  EZPlayer
//
//  Created by yangjun zhu on 2016/12/28.
//  Copyright © 2016年 yangjun zhu. All rights reserved.
//

import AVFoundation
extension AVAsset {

    public var title: String? {
        var error: NSError?
        let status = self.statusOfValue(forKey: "commonMetadata", error: &error)
        if error != nil {
            return nil
        }
        if status == .loaded{
            let metadataItems = AVMetadataItem.metadataItems(from: self.commonMetadata, withKey: AVMetadataKey.commonKeyTitle, keySpace: AVMetadataKeySpace.common)
            if metadataItems.count > 0  {
                let titleItem = metadataItems.first
                return titleItem?.value as? String
            }
        }
        return nil
    }

    /// 获取所有cc
    public var closedCaption: [AVMediaSelectionOption]? {
        var closedCaptions = [AVMediaSelectionOption]()
        if let mediaSelectionGroup = self.mediaSelectionGroup(forMediaCharacteristic: AVMediaCharacteristic.legible){
            for option in mediaSelectionGroup.options {
                if option.mediaType.rawValue == "clcp" {
                    closedCaptions.append(option)
                }
            }
        }
        if closedCaptions.count > 0{
            return closedCaptions
        }
        return nil
    }

    /// 获取所有subtitle
    public var subtitles: [(subtitle: AVMediaSelectionOption,localDisplayName: String)]? {
        var subtitles = [(subtitle: AVMediaSelectionOption,localDisplayName: String)]()
        if let mediaSelectionGroup = self.mediaSelectionGroup(forMediaCharacteristic: AVMediaCharacteristic.legible){
            for option in mediaSelectionGroup.options {
                if !option.hasMediaCharacteristic(AVMediaCharacteristic.containsOnlyForcedSubtitles) {
                    if let localDisplayName = self.localDisplayName(forMediaSelectionOption: option){
                        subtitles.append((option,localDisplayName))
                    }
                }
            }
        }
        if subtitles.count > 0{
            return subtitles
        }
        return nil
    }

    /// 获取所有audio
    public var audios: [(audio: AVMediaSelectionOption,localDisplayName: String)]? {
        var audios = [(audio: AVMediaSelectionOption,localDisplayName: String)]()
        if let mediaSelectionGroup = self.mediaSelectionGroup(forMediaCharacteristic: AVMediaCharacteristic.audible){
            for option in mediaSelectionGroup.options {
                if let localDisplayName = self.localDisplayName(forMediaSelectionOption: option){
                    audios.append((option,localDisplayName))
                }
            }
            if audios.count > 0{
                return audios
            }
        }
        return nil
    }

    public func localDisplayName(forMediaSelectionOption subtitle: AVMediaSelectionOption) -> String?{
        var title: String? = nil
        let metadataItems = AVMetadataItem.metadataItems(from: subtitle.commonMetadata, withKey: AVMetadataKey.commonKeyTitle, keySpace: AVMetadataKeySpace.common)
        if metadataItems.count > 0 {
            let preferredLanguages = NSLocale.preferredLanguages
            for language: String in preferredLanguages {
                let locale = Locale(identifier: language)
                let titlesForLocale = AVMetadataItem.metadataItems(from: metadataItems, with: locale)
                if titlesForLocale.count > 0 {
                    title = titlesForLocale[0].stringValue
                    break
                }
            }
            if title == nil {
                title = metadataItems[0].stringValue
            }
        }
        return title
    }

}
