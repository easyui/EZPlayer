//
//  NavigationController.swift
//  EZPlayerExample
//
//  Created by yangjun zhu on 2016/12/28.
//  Copyright © 2016年 yangjun zhu. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    // MARK: - Orientations
    override var shouldAutorotate : Bool {
        if self.topViewController != nil{
            return self.topViewController!.shouldAutorotate
        }else{
            return  super.shouldAutorotate
        }
    }

    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        if self.topViewController != nil{
            return self.topViewController!.supportedInterfaceOrientations
        }else{
            return  super.supportedInterfaceOrientations
        }
    }

    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation{
        if self.topViewController != nil{
            return self.topViewController!.preferredInterfaceOrientationForPresentation
        }else{
            return  super.preferredInterfaceOrientationForPresentation
        }
    }

    override var preferredStatusBarStyle : UIStatusBarStyle {
        return self.topViewController!.preferredStatusBarStyle
    }

}
