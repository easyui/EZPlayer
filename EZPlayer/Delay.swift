//
//  Delay.swift
//  EZPlayer
//
//  Created by yangjun zhu on 2016/12/28.
//  Copyright © 2016年 yangjun zhu. All rights reserved.
//

import Foundation

public typealias Task = (_ cancel : Bool) -> Void

public func delay(_ time: TimeInterval, task: @escaping ()->()) ->  Task? {

    func dispatch_later(block: @escaping ()->()) {
        let t = DispatchTime.now() + time
        DispatchQueue.main.asyncAfter(deadline: t, execute: block)
    }



    var closure: (()->Void)? = task
    var result: Task?

    let delayedClosure: Task = {
        cancel in
        if let internalClosure = closure {
            if (cancel == false) {
                DispatchQueue.main.async(execute: internalClosure)
            }
        }
        closure = nil
        result = nil
    }

    result = delayedClosure

    dispatch_later {
        if let delayedClosure = result {
            delayedClosure(false)
        }
    }

    return result

}

public func cancel(_ task: Task?) {
    task?(true)
}
