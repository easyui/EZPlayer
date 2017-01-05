//
//  ParamsEmbedTableViewController.swift
//  EZPlayerExample
//
//  Created by yangjun zhu on 2016/12/28.
//  Copyright © 2016年 yangjun zhu. All rights reserved.
//

import UIKit
import EZPlayer

class ParamsEmbedTableViewController: UITableViewController {
    weak var  paramsViewController: ParamsViewController!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    //    override func numberOfSections(in tableView: UITableView) -> Int {
    //        // #warning Incomplete implementation, return the number of sections
    //        return 0
    //    }
    //
    //    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    //        // #warning Incomplete implementation, return the number of rows
    //        return 0
    //    }

    /*
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

     // Configure the cell...

     return cell
     }
     */

    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */

    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */

    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

     }
     */

    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */

    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */

    // MARK: - url
    //http://www.cnblogs.com/linr/p/6185172.html
    @IBOutlet weak var urlTextField: UITextField!
    @IBAction func playButtonTap(_ sender: UIButton) {
        self.view.endEditing(true)
        if let text = self.urlTextField.text,let url = URL(string: text){
            MediaManager.sharedInstance.playEmbeddedVideo(url: url, embeddedContentView: self.paramsViewController.dlView)
        }
    }


    // MARK: - local
    @IBAction func localMP4ButtonTap(_ sender: UIButton) {
        MediaManager.sharedInstance.playEmbeddedVideo(url:URL.Test.localMP4_0, embeddedContentView: self.paramsViewController.dlView)
    }
    // MARK: - remote

    @IBAction func remoteT1Tap(_ sender: UIButton) {
        MediaManager.sharedInstance.playEmbeddedVideo(url: URL.Test.apple_0, embeddedContentView: self.paramsViewController.dlView)
    }

    @IBAction func remoteT2Tap(_ sender: UIButton) {
        MediaManager.sharedInstance.playEmbeddedVideo(url: URL.Test.apple_1, embeddedContentView: self.paramsViewController.dlView)
    }

    @IBAction func remoteT3Tap(_ sender: UIButton) {
        MediaManager.sharedInstance.playEmbeddedVideo(url: URL.Test.remoteMP4_0, embeddedContentView: self.paramsViewController.dlView)
    }
    // MARK: - rate
    @IBAction func rateSlowTap(_ sender: UIButton) {
        MediaManager.sharedInstance.player?.rate = 0.5
    }

    @IBAction func rateNormalTap(_ sender: UIButton) {
        MediaManager.sharedInstance.player?.rate = 1
    }

    @IBAction func rateFastTap(_ sender: UIButton) {
        MediaManager.sharedInstance.player?.rate = 1.5
    }

    // MARK: - videoGravity

    @IBAction func aspectTap(_ sender: UIButton) {
        MediaManager.sharedInstance.player?.videoGravity = .aspect
    }

    @IBAction func aspectFillTap(_ sender: UIButton) {
        MediaManager.sharedInstance.player?.videoGravity = .aspectFill
    }

    @IBAction func scaleFillTap(_ sender: UIButton) {
        MediaManager.sharedInstance.player?.videoGravity = .scaleFill
    }


    // MARK: - displayMode
    @IBAction func embeddedTap(_ sender: UIButton) {
//        MediaManager.sharedInstance.hiddenFloatVideo()
        if MediaManager.sharedInstance.player != nil {
            MediaManager.sharedInstance.player?.toEmbedded()
        }else{
            MediaManager.sharedInstance.playEmbeddedVideo(url:URL.Test.localMP4_0, embeddedContentView: self.paramsViewController.dlView)
        }

    }

    @IBAction func fullscreenPortraitTap(_ sender: UIButton) {
        if MediaManager.sharedInstance.player != nil {
            MediaManager.sharedInstance.player?.fullScreenMode = .portrait
            MediaManager.sharedInstance.player?.toFull()
        }else{
            MediaManager.sharedInstance.onlyFor_fullscreenPortraitTap()
        }
    }

    @IBAction func fullscreenLandscapeTap(_ sender: UIButton) {
        if MediaManager.sharedInstance.player != nil {
            MediaManager.sharedInstance.player?.fullScreenMode = .landscape
            MediaManager.sharedInstance.player?.toFull()
        }else{
            MediaManager.sharedInstance.playEmbeddedVideo(url:URL.Test.localMP4_0)
        }

    }

    @IBAction func floatTap(_ sender: UIButton) {
//        MediaManager.sharedInstance.showFloatVideo()
        if MediaManager.sharedInstance.player != nil {
            MediaManager.sharedInstance.player?.toFloat()
        }else{

        }

    }

    // MARK: - skin
    @IBAction func noneSkinTap(_ sender: UIButton) {

        if MediaManager.sharedInstance.player != nil {
            MediaManager.sharedInstance.player?.controlViewForIntercept = UIView()
        }else{
            MediaManager.sharedInstance.playEmbeddedVideo(url:URL.Test.localMP4_0, embeddedContentView: self.paramsViewController.dlView, skin: UIView())
        }

    }

    @IBAction func yellowSkinTap(_ sender: UIButton) {

        if MediaManager.sharedInstance.player != nil {
            let yellow = UIView()
            yellow.backgroundColor = UIColor.yellow.withAlphaComponent(0.3)
            MediaManager.sharedInstance.player?.controlViewForIntercept = yellow
        }else{
            MediaManager.sharedInstance.playEmbeddedVideo(url:URL.Test.localMP4_0, embeddedContentView: self.paramsViewController.dlView, skin: UIView())
        }

    }

    @IBAction func defaultSkinTap(_ sender: UIButton) {
        if MediaManager.sharedInstance.player != nil {
//            let view =  Bundle(for: EZPlayerControlView.self).loadNibNamed(String(describing: EZPlayerControlView.self), owner: self, options: nil)?.last
//            MediaManager.sharedInstance.player?.controlView = view as! UIView?
            MediaManager.sharedInstance.player?.controlViewForIntercept = nil

        }else{
            MediaManager.sharedInstance.playEmbeddedVideo(url:URL.Test.localMP4_0, embeddedContentView: self.paramsViewController.dlView)
        }
    }



    // MARK: - Continued：

    @IBAction func firstVideoTap(_ sender: UIButton) {
        if MediaManager.sharedInstance.player != nil {
            MediaManager.sharedInstance.player?.replaceToPlayWithURL(URL.Test.remoteMP4_0)
        }else{
            MediaManager.sharedInstance.playEmbeddedVideo(url:URL.Test.localMP4_0, embeddedContentView: self.paramsViewController.dlView)
        }
    }

    @IBAction func secondTap(_ sender: UIButton) {
        if MediaManager.sharedInstance.player != nil {
            MediaManager.sharedInstance.player?.replaceToPlayWithURL(URL.Test.remoteM3U8_0)

        }else{
            MediaManager.sharedInstance.playEmbeddedVideo(url:URL.Test.apple_0, embeddedContentView: self.paramsViewController.dlView)
        }

    }
    /*



     public enum EZPlayerDisplayMode  {
     case none
     case embedded
     case fullscreenPortrait
     fullscreenLandscape
     }

     public enum EZPlayerFullScreenMode  {
     case portrait
     case landscape
     }
     */

}
