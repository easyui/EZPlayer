//
//  EZPlayerThumbnail.swift
//  EZPlayer
//
//  Created by yangjun zhu on 2016/12/28.
//  Copyright © 2016年 yangjun zhu. All rights reserved.
//

import AVFoundation

public struct EZPlayerThumbnail {
    public var requestedTime: CMTime
    public var image: UIImage?
    public var actualTime: CMTime
    public var result: AVAssetImageGeneratorResult
    public var error: Error?
}
