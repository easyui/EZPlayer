//
//  TabBarController.swift
//  EZPlayerExample
//
//  Created by yangjun zhu on 2016/12/28.
//  Copyright © 2016年 yangjun zhu. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {

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
    override var shouldAutorotate : Bool {
//        self.selectedViewController
        if let selectedViewController = self.selectedViewController{
            return selectedViewController.shouldAutorotate
        }else{
            return  super.shouldAutorotate
        }
    }

    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        if let selectedViewController = self.selectedViewController{
            return selectedViewController.supportedInterfaceOrientations
        }else{
            return  super.supportedInterfaceOrientations
        }
    }

    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation{

        if let selectedViewController = self.selectedViewController{
            return selectedViewController.preferredInterfaceOrientationForPresentation
        }else{
            return  super.preferredInterfaceOrientationForPresentation
        }
    }

    override var preferredStatusBarStyle : UIStatusBarStyle {
        if let selectedViewController = self.selectedViewController{
            return selectedViewController.preferredStatusBarStyle
        }else{
            return  super.preferredStatusBarStyle
        }
    }

}
