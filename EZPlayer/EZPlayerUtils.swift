//
//  EZPlayerUtils.swift
//  EZPlayer
//
//  Created by yangjun zhu on 2016/12/28.
//  Copyright © 2016年 yangjun zhu. All rights reserved.
//

import UIKit
import MediaPlayer

// MARK: - 全局变量

/// 动画时间
public var ezAnimatedDuration = 0.3

public let EZPlayerErrorDomain = "EZPlayerErrorDomain"

// MARK: - 全局方法

/// 全局log
///
/// - Parameters:
///   - message: log信息
///   - file: 打印log所属的文件
///   - method: 打印log所属的方法
///   - line: 打印log所在的行
public func printLog<T>(_ message: T...,
    file: String = #file,
    method: String = #function,
    line: Int = #line)
{
    if EZPlayer.showLog {
    print("EZPlayer Log-->\((file as NSString).lastPathComponent)[\(line)], \(method): \(message)")
    }
}



public func toNSError(code: Int, userInfo dict: [AnyHashable : Any]? = nil) -> NSError
{
    return NSError(domain: EZPlayerErrorDomain, code: code, userInfo: dict)
}

// MARK: -

/// EZPlayerState的相等判断
///
/// - Parameters:
///   - lhs: 左值
///   - rhs: 右值
/// - Returns: 比较结果
public func ==(lhs: EZPlayerState, rhs: EZPlayerState) -> Bool {
    switch (lhs, rhs) {
    case (.unknown,   .unknown): return true
    case (.readyToPlay,   .readyToPlay): return true
    case (.buffering,   .buffering): return true
    case (.bufferFinished,   .bufferFinished): return true
    case (.playing,   .playing): return true
    case (.seekingForward,   .seekingForward): return true
    case (.seekingBackward,   .seekingBackward): return true
    case (.pause,   .pause): return true
    case (.stopped,   .stopped): return true
    case (.error(let a), .error(let b)) where a == b: return true
    default: return false
    }
}

/// EZPlayerState的不相等判断
///
/// - Parameters:
///   - lhs: 左值
///   - rhs: 右值
/// - Returns: 比较结果
public func !=(lhs: EZPlayerState, rhs: EZPlayerState) -> Bool {
    return !(lhs == rhs)
}

// MARK: - 辅助方法
public class EZPlayerUtils{

    /// system volume ui
    public static let systemVolumeSlider : UISlider = {
        let volumeView = MPVolumeView()
        volumeView.showsVolumeSlider = true
        volumeView.showsRouteButton = false
        var returnSlider : UISlider!
        for view in volumeView.subviews {
            if let slider = view as? UISlider {
                returnSlider = slider
                break
            }
        }
        return returnSlider
    }()


    /// fotmat time
    ///
    /// - Parameters:
    ///   - position: video current position
    ///   - duration: video duration
    /// - Returns: formated time string
    public static func formatTime( position: TimeInterval,duration:TimeInterval) -> String{
        guard !position.isNaN && !duration.isNaN else{
            return ""
        }
        let positionHours = (Int(position) / 3600) % 60
        let positionMinutes = (Int(position) / 60) % 60
        let positionSeconds = Int(position) % 60;

        let durationHours = (Int(duration) / 3600) % 60
        let durationMinutes = (Int(duration) / 60) % 60
        let durationSeconds = Int(duration) % 60
        if(durationHours == 0){
            return String(format: "%02d:%02d/%02d:%02d",positionMinutes,positionSeconds,durationMinutes,durationSeconds)
        }
        return String(format: "%02d:%02d:%02d/%02d:%02d:%02d",positionHours,positionMinutes,positionSeconds,durationHours,durationMinutes,durationSeconds)
    }


    ///  get current top viewController
    ///
    /// - Returns: current top viewController
    public static func activityViewController() -> UIViewController?{
        var result: UIViewController? = nil
        guard var window = UIApplication.shared.keyWindow else {
            return nil
        }
        if window.windowLevel != UIWindowLevelNormal {
            let windows = UIApplication.shared.windows
            for tmpWin in windows {
                if tmpWin.windowLevel == UIWindowLevelNormal {
                    window = tmpWin
                    break
                }
            }
        }
        result = window.rootViewController
        while let presentedVC = result?.presentedViewController {
            result = presentedVC
        }
        if result is UITabBarController {
            result = (result as? UITabBarController)?.selectedViewController
        }
        while result is UINavigationController && (result as? UINavigationController)?.topViewController != nil{
            result = (result as? UINavigationController)?.topViewController
        }
        return result
    }


    /// get viewController from view
    ///
    /// - Parameter view: view
    /// - Returns: viewController
    public static func viewController(from view: UIView) -> UIViewController? {
        var responder = view as UIResponder
        while let nextResponder = responder.next {
            if (responder is UIViewController) {
                return (responder as! UIViewController)
            }
            responder = nextResponder
        }
        return nil
    }


}
