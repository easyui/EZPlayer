//
//  EZPlayerFloatContainer.swift
//  EZPlayer
//
//  Created by yangjun zhu on 2016/12/28.
//  Copyright © 2016年 yangjun zhu. All rights reserved.
//

import UIKit
let windowWidth = (UIScreen.main.bounds.size.width)
let windowHight = (UIScreen.main.bounds.size.height)

open class EZPlayerWindowContainer {
    open private(set) var isShow = false
    // MARK: - Autorotation
    open var shouldAutorotate = true
    //default: YES
    open var supportedInterfaceOrientations = UIInterfaceOrientationMask.portrait
    //default: iPhone(UIInterfaceOrientationMaskPortrait) iPad(UIInterfaceOrientationMaskLandscape)
    // MARK: - StatusBar
    open var prefersStatusBarHidden = false
    //default: NO
    open var preferredStatusBarStyle = UIStatusBarStyle.default
    //default: UIStatusBarStyleDefault

    private(set) var floatWindow: UIWindow!

    private var frame = CGRect.zero



    deinit {
        NotificationCenter.default.removeObserver(self)
        self.floatWindow = nil
    }
    // MARK: - init

    init(frame: CGRect, rootViewController: EZPlayerWindowContainerRootViewController) {
        self.commonInit()
        rootViewController.floatContainer = self
        self.frame = frame
        self.floatWindow = UIWindow(frame: self.frame)
        self.floatWindow.backgroundColor = UIColor.clear
        self.floatWindow.windowLevel = UIWindow.Level.normal + 1
        self.floatWindow.clipsToBounds = true
        self.floatWindow.rootViewController = rootViewController


        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        NotificationCenter.default.addObserver(self, selector: #selector(self.deviceOrientationDidChange(_:)), name: UIDevice.orientationDidChangeNotification, object: nil)

        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.floatHandlePan))
        self.floatWindow.addGestureRecognizer(panGestureRecognizer)
    }

    @objc private  func floatHandlePan(_ panGestureRecognizer: UIPanGestureRecognizer) {
        guard let moveView = panGestureRecognizer.view else {
            return;
        }
        UIView.animate(withDuration: 0.1, animations: {() -> Void in
            if panGestureRecognizer.state == .began || panGestureRecognizer.state == .changed {
                let translation = panGestureRecognizer.translation(in: moveView)
                moveView.center =  CGPoint(x:moveView.center.x + translation.x, y:moveView.center.y + translation.y)
                panGestureRecognizer.setTranslation(CGPoint.zero, in: moveView)
                //            [self setImgaeNameWithMove:YES];
            }
            if panGestureRecognizer.state == .ended {
                //            if (self.floatWindow.frame.origin.y + self.floatWindow.frame.size.height > windowHight - _keyBoardSize.height) {
                //                if (_showKeyBoard) {
                //                    if (moveView.frame.origin.x < 0) {
                //                        [moveView setCenter:(CGPoint){moveView.frame.size.width/2,windowHight - _keyBoardSize.height - self.floatWindow.frame.size.height/2}];
                //                    }else if (moveView.frame.origin.x + moveView.frame.size.width > windowWidth)
                //                    {
                //                        [moveView setCenter:(CGPoint){windowWidth - moveView.frame.size.width/2,windowHight - _keyBoardSize.height - self.floatWindow.frame.size.height/2}];
                //                    }else
                //                    {
                //                        [moveView setCenter:(CGPoint){moveView.center.x,windowHight - _keyBoardSize.height - self.floatWindow.frame.size.height/2}];
                //                    }
                //                    _showKeyBoardWindowRect = CGRectMake(self.floatWindow.frame.origin.x, windowHight - moveView.frame.size.height, 60, 60);
                //                    _locationTag = kLocationTag_bottom;
                //                }else
                //                {
                //                    [self moveEndWithMoveView:moveView];
                //                    _showKeyBoardWindowRect = _boardWindow.frame;
                //                }
                //            }else
                //            {
                //                [self moveEndWithMoveView:moveView];
                //                _showKeyBoardWindowRect = _boardWindow.frame;
                //            }
                //            [self setImgaeNameWithMove:NO];
                self.moveEnd(withMove: moveView)
            }
        })
    }

    func moveEnd(withMove moveView: UIView) {
        if moveView.frame.origin.y <= 40 {
            if moveView.frame.origin.x < 0 {
                moveView.center = CGPoint(x:moveView.frame.size.width / 2, y:moveView.frame.size.height / 2)
                //            _locationTag = kLocationTag_left;
            }
            else if moveView.frame.origin.x + moveView.frame.size.width > windowWidth {
                moveView.center = CGPoint(x:windowWidth - moveView.frame.size.width / 2, y:moveView.frame.size.height / 2)
                //            _locationTag = kLocationTag_right;
            }
            else {
                moveView.center = CGPoint(x:moveView.center.x, y:moveView.frame.size.height / 2)
                //            _locationTag = kLocationTag_top;
            }
        }
        else if moveView.frame.origin.y + moveView.frame.size.height >= windowHight - 40 {
            if moveView.frame.origin.x < 0 {
                moveView.center = CGPoint(x:moveView.frame.size.width / 2, y:windowHight - moveView.frame.size.height / 2)
                //            _locationTag = kLocationTag_left;
            }
            else if moveView.frame.origin.x + moveView.frame.size.width > windowWidth {
                moveView.center = CGPoint(x:windowWidth - moveView.frame.size.width / 2, y:windowHight - moveView.frame.size.height / 2)
                //            _locationTag = kLocationTag_right;
            }
            else {
                moveView.center = CGPoint(x:moveView.center.x, y:windowHight - moveView.frame.size.height / 2)
                //            _locationTag = kLocationTag_bottom;
            }
        }
        else {
            if moveView.frame.origin.x + moveView.frame.size.width / 2 < windowWidth / 2 {
                if moveView.frame.origin.x != 0 {
                    moveView.center = CGPoint(x:moveView.frame.size.width / 2, y:moveView.center.y)
                }
                //            _locationTag = kLocationTag_left;
            }
            else {
                if moveView.frame.origin.x + moveView.frame.size.width != windowWidth {
                    moveView.center = CGPoint(x:windowWidth - moveView.frame.size.width / 2, y:moveView.center.y)
                }
                //            _locationTag = kLocationTag_right;
            }
        }

    }
    // MARK: - action
    @discardableResult func show() ->Bool {

//        self.floatWindow.frame = self.frame



        //    if( self.delegate && [self.delegate respondsToSelector:@selector(willshowFloatView:)] ){
        //        if (![self.delegate willshowFloatView:self]) {
        //            return;
        //        }
        //    }
        //    [self.castWindow makeKeyAndVisible];
        self.floatWindow.isHidden = false
        self.isShow = !self.floatWindow.isHidden

        return true
    }

    @discardableResult func hidden() ->Bool {
        self.floatWindow.isHidden = true
        self.isShow = !self.floatWindow.isHidden
        return true

    }

    func addSubview(_ view: UIView) {
        self.floatWindow.rootViewController!.view.addSubview(view)
        view.frame = self.floatWindow.rootViewController!.view.bounds
    }
    // MARK: - Orientation
    //#define DegreesToRadians(degrees) (degrees * M_PI / 180)

    @objc private func deviceOrientationDidChange(_ notification: Notification) {
        //    self.floatWindow.frame = self.frame;
        //    NSLog(@"%@",NSStringFromCGRect(self.floatWindow.frame));
        /*
        return
        var orientation = UIDevice.current.orientation
        var interfaceOrientation = (orientation as! UIInterfaceOrientation)
        switch interfaceOrientation {
        case .portraitUpsideDown:
            //            NSLog(@"第3个旋转方向---电池栏在下");
            self.floatWindow.transform = CGAffineTransform(rotationAngle: DegreesToRadians(180))

        case .portrait:
            //            NSLog(@"第0个旋转方向---电池栏在上");
            self.floatWindow.transform = CGAffineTransform(rotationAngle: DegreesToRadians(180))

        case .landscapeLeft:
            //            NSLog(@"第2个旋转方向---电池栏在左");
            self.floatWindow.transform = CGAffineTransform(rotationAngle: DegreesToRadians(180))

        case .landscapeRight:
            //            NSLog(@"第1个旋转方向---电池栏在右");
            self.floatWindow.transform = CGAffineTransform(rotationAngle: DegreesToRadians(180))

        default:
            break
        }
 */

    }
    // MARK: - private

    private func commonInit() {
        self.shouldAutorotate = true
//        if UIDevice.current.userInterfaceIdiom == .pad {
//            self.supportedInterfaceOrientations = .landscape
//        }else {
//            self.supportedInterfaceOrientations = .portrait
//        }
        switch UIDevice.current.orientation {
        case .portrait:
            self.supportedInterfaceOrientations = .portrait
        case .landscapeRight:
            self.supportedInterfaceOrientations = .landscapeLeft
        case .landscapeLeft:
            self.supportedInterfaceOrientations = .landscapeRight
        default:
            break
        }

        self.prefersStatusBarHidden = false
        self.preferredStatusBarStyle = .default
    }}
