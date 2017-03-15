//
//  EZPlayerAVAssetResourceLoaderDelegate.swift
//  EZPlayer
//
//  Created by yangjun zhu on 2017/3/6.
//  Copyright © 2017年 yangjun zhu. All rights reserved.
//

import Foundation
import AVFoundation


public class EZPlayerAVAssetResourceLoaderDelegate: NSObject {
    public var customScheme: String{
      return ""
    }

    public unowned let asset: AVURLAsset
    
    public let delegateQueue: DispatchQueue?

    public init(asset: AVURLAsset,delegateQueue: DispatchQueue? = nil) {

        self.asset = asset
        self.delegateQueue = delegateQueue
        super.init()
        self.asset.resourceLoader.setDelegate(self, queue: self.delegateQueue)

    }

}


extension EZPlayerAVAssetResourceLoaderDelegate: AVAssetResourceLoaderDelegate{

}
