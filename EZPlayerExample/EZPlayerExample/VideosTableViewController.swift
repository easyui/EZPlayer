//
//  VideosTableViewController.swift
//  EZPlayerExample
//
//  Created by yangjun zhu on 2016/12/30.
//  Copyright © 2016年 yangjun zhu. All rights reserved.
//

import UIKit

class VideosTableViewController: UITableViewController {
    var index : IndexPath?
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

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 50
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "videosIdentifier", for: indexPath)
        cell.selectionStyle = .none
        // Configure the cell...
        cell.textLabel?.text = "the \(indexPath.row) video"

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let player = MediaManager.sharedInstance.player  ,let index = player.indexPath , index == indexPath{
           return
        }
        let cell = tableView.cellForRow(at: indexPath)
        self.index = indexPath
//        MediaManager.sharedInstance.playEmbeddedVideo(url:URL.Test.localMP4_0, embeddedContentView: cell?.contentView)
        MediaManager.sharedInstance.playEmbeddedVideo(url:URL.Test.localMP4_0, embeddedContentView: cell?.textLabel)
        MediaManager.sharedInstance.player?.indexPath = indexPath
        MediaManager.sharedInstance.player?.scrollView = tableView
        MediaManager.sharedInstance.player?.floatMode = .window

    }


   /*
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.tableView {
            if let index = self.index , let player = MediaManager.sharedInstance.player{
                let cellrectInTable = self.tableView.rectForRow(at: index)
                let cellrectInTableSuperView =  self.tableView.convert(cellrectInTable, to: self.tableView.superview)
                if cellrectInTableSuperView.origin.y + cellrectInTableSuperView.size.height/2 < self.tableView.frame.origin.y + self.tableView.contentInset.top || cellrectInTableSuperView.origin.y + cellrectInTableSuperView.size.height/2 > self.tableView.frame.origin.y + self.tableView.frame.size.height - self.tableView.contentInset.bottom{
                    player.toFloat()
                }else{
                        if let cell = self.tableView.cellForRow(at: index){
                            if  !cell.contentView.subviews.contains(player.view){
                                player.view.removeFromSuperview()
                                cell.contentView.addSubview( player.view)
                                player.embeddedContentView = cell.contentView
                            }
                            MediaManager.sharedInstance.player?.toEmbedded(animated: false, completion: { flag in

                            })

                        }



                }

            }
        }
    }
 */


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

}
