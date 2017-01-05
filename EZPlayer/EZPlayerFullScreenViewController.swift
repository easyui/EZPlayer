//
//  EZFullScreenViewController.swift
//  EZPlayer
//
//  Created by yangjun zhu on 2016/12/28.
//  Copyright © 2016年 yangjun zhu. All rights reserved.
//

import UIKit

open class EZPlayerFullScreenViewController: UIViewController {
    weak  var player: EZPlayer!
    private var statusbarBackgroundView: UIView!
    public var preferredlandscapeForPresentation = UIInterfaceOrientation.landscapeLeft
    public var currentOrientation = UIDevice.current.orientation


    // MARK: - Life cycle
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override open func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(self.playerControlsHiddenDidChange(_:)), name: NSNotification.Name.EZPlayerControlsHiddenDidChange, object: nil)

        self.view.backgroundColor = UIColor.black

        self.statusbarBackgroundView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: 20))
        self.statusbarBackgroundView.backgroundColor = self.player.fullScreenStatusbarBackgroundColor
        self.statusbarBackgroundView.autoresizingMask = [ .flexibleWidth,.flexibleLeftMargin,.flexibleRightMargin,.flexibleBottomMargin]
        self.view.addSubview(self.statusbarBackgroundView)
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }


    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    override open func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }


    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }

    // MARK: - Orientations
    override open var shouldAutorotate : Bool {
        return true
    }

    override open var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        switch self.player.fullScreenMode {
        case .portrait:
            return [.portrait]
        case .landscape:
            return [.landscapeLeft,.landscapeRight]
        }
    }

    override open var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation{
        self.currentOrientation = preferredlandscapeForPresentation == .landscapeLeft ? .landscapeRight : .landscapeLeft

        switch self.player.fullScreenMode {
        case .portrait:
            self.currentOrientation = .portrait
            return .portrait
        case .landscape:
            return self.preferredlandscapeForPresentation
        }
    }

    // MARK: - status bar
    private var statusBarHiddenAnimated = true

    override open var prefersStatusBarHidden: Bool{
        if self.statusBarHiddenAnimated {
            UIView.animate(withDuration: ezAnimatedDuration, animations: {
                self.statusbarBackgroundView.alpha = self.player.controlsHidden ? 0 : 1
            }, completion: {finished in
            })
        }else{
            self.statusbarBackgroundView.alpha = self.player.controlsHidden ? 0 : 1
        }

        return self.player.controlsHidden
    }

    override open var preferredStatusBarStyle: UIStatusBarStyle{
        return self.player.fullScreenPreferredStatusBarStyle
    }

    // MARK: - notification
    func playerControlsHiddenDidChange(_ notifiaction: Notification) {
        self.statusBarHiddenAnimated = notifiaction.userInfo?[Notification.Key.EZPlayerControlsHiddenDidChangeByAnimatedKey] as? Bool ?? true
        self.setNeedsStatusBarAppearanceUpdate()
    }

    override open func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        self.currentOrientation = UIDevice.current.orientation

    }


}
