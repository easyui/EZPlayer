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
        static let apple_1 = URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_fmp4/master.m3u8")!

        static let remoteMP4_0 =  URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!

        static let remoteM3U8_0 =  URL(string: "http://www.streambox.fr/playlists/x36xhzz/url_6/193039199_mp4_h264_aac_hq_7.m3u8")!



        //live
        static let live_0 = URL(string: "http://ivi.bupt.edu.cn/hls/cctv1hd.m3u8")!



    }
}
