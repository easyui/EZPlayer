//
//  ParamsViewController.swift
//  EZPlayerExample
//
//  Created by yangjun zhu on 2016/12/28.
//  Copyright © 2016年 yangjun zhu. All rights reserved.
//

import UIKit
import EZPlayer
class ParamsViewController: UIViewController {

    @IBOutlet weak var dlView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func playButtonAction(_ sender: Any) {
//          MediaManager.sharedInstance.playEmbeddedVideo(url: URL(string: "http://gslb.miaopai.com/stream/kPzSuadRd2ipEo82jk9~sA__.mp4")!, embeddedContentView: self.dlView)
//                  MediaManager.sharedInstance.playEmbeddedVideo(url: URL(string: "http://baobab.wdjcdn.com/14571455324031.mp4")!, embeddedContentView: self.dlView)
         MediaManager.sharedInstance.playEmbeddedVideo(url:URL.Test.localMP4_1, embeddedContentView: self.dlView)
//         MediaManager.sharedInstance.playEmbeddedVideo(url:Bundle.main.url(forResource: "testVideo", withExtension: "m3u8")!, embeddedContentView: self.dlView)
//        MediaManager.sharedInstance.playEmbeddedVideo(url: URL(string: "http://www.streambox.fr/playlists/x36xhzz/url_6/193039199_mp4_h264_aac_hq_7.m3u8")!, embeddedContentView: self.dlView)
//        MediaManager.sharedInstance.playEmbeddedVideo(url: URL(string: "http://baobab.wdjcdn.com/1455968234865481297704.mp4")!, embeddedContentView: self.dlView)


//        MediaManager.sharedInstance.playEmbeddedVideo(url: URL(string: "http://172.16.1.113/packager/media1/hls/chicago.mp4.m3u8")!, embeddedContentView: self.dlView)


   }


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ParamsEmbedTableViewController"{
             let vc = segue.destination as! ParamsEmbedTableViewController
             vc.paramsViewController = self

        }
    }


    override var shouldAutorotate : Bool {
       return true
    }

    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return .landscape
        }else {
            return .portrait
        }
    }

    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation{
        if UIDevice.current.userInterfaceIdiom == .pad {
            return .landscapeRight
        }else {
            return .portrait
        }
    }





    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

}
