//
//  Utils.swift
//  EZPlayerExample
//
//  Created by yangjun zhu on 2016/12/30.
//  Copyright © 2016年 yangjun zhu. All rights reserved.
//

import Foundation
extension URL {
    struct Test {
        //local
        static let localMP4_0 =  Bundle.main.url(forResource: "hubblecast", withExtension: "m4v")!
        static let localMP4_1 =  Bundle.main.url(forResource: "Charlie The Unicorn", withExtension: "m4v")!
        static let localMP4_2 =  Bundle.main.url(forResource: "blackhole", withExtension: "mp4")!

        //remote vod
        static let apple_0 = URL(string: "http://devimages.apple.com/iphone/samples/bipbop/bipbopall.m3u8")!
        static let apple_1 = URL(string: "https://devimages.apple.com.edgekey.net/streaming/examples/bipbop_16x9/bipbop_16x9_variant.m3u8")!

        static let remoteMP4_0 =  URL(string: "http://baobab.wdjcdn.com/1456459181808howtoloseweight_x264.mp4")!

        static let remoteM3U8_0 =  URL(string: "http://www.streambox.fr/playlists/x36xhzz/url_6/193039199_mp4_h264_aac_hq_7.m3u8")!



        //live
        static let live_0 = URL(string: "https://devimages.apple.com.edgekey.net/streaming/examples/bipbop_16x9/bipbop_16x9_variant.m3u8")!



    }
}
