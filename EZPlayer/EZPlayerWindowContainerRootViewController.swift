//
//  EZPlayerFloatContainerRootViewController.swift
//  EZPlayer
//
//  Created by yangjun zhu on 2016/12/28.
//  Copyright © 2016年 yangjun zhu. All rights reserved.
//

import UIKit

open class EZPlayerWindowContainerRootViewController: UIViewController {
    weak var floatContainer: EZPlayerWindowContainer!
    override open func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }



    override open var shouldAutorotate : Bool {
            return self.floatContainer.shouldAutorotate
        }

    override open var supportedInterfaceOrientations : UIInterfaceOrientationMask {
            return self.floatContainer.supportedInterfaceOrientations
        }

    override open var preferredStatusBarStyle : UIStatusBarStyle {
            return self.floatContainer.preferredStatusBarStyle
        }

    override open var prefersStatusBarHidden: Bool{
            return self.floatContainer.prefersStatusBarHidden
        }


    /// 子类可以覆盖此方法来调整video view在 float中的位置
    ///
    /// - Parameter view: video view
    open func addVideoView(_ view: UIView){
        view.removeFromSuperview()
        self.view.addSubview(view)
        view.frame = self.view.bounds
    }


}
