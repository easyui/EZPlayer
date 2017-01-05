//
//  ViewController.swift
//  EZPlayerExample
//
//  Created by yangjun zhu on 2016/12/28.
//  Copyright © 2016年 yangjun zhu. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    // MARK: - Life cycle
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()


        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    deinit{
        NotificationCenter.default.removeObserver(self)
        if self.isViewLoaded{
            self.view.layer .removeAllAnimations()
        }
    }

    // MARK: - Config
    // MARK: - Public methods



    // MARK: - Private methods
    // MARK: - Target
    // MARK: - Action
    // MARK: - Notification

    // MARK: - Orientations
    override var shouldAutorotate : Bool {
        return true
    }

    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.phone {
            return [.portrait]
        }else{
            return [.portrait]

//            return [.landscape]
        }

    }


    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation{

        return .portrait
    }


    // MARK: - StatusBar Style
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }



}
