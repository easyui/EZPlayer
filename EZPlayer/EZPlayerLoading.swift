//
//  EZPlayerLoading.swift
//  EZPlayer
//
//  Created by yangjun zhu on 2016/12/28.
//  Copyright © 2016年 yangjun zhu. All rights reserved.
//

import UIKit

open class EZPlayerLoading: UIView {
    private let duration = 1.2

    private var timer: Timer?
    private var radius: Double?

    private lazy var circle: CAShapeLayer = {[weak self] in
        let theCircle = CAShapeLayer()
        theCircle.fillColor = UIColor.clear.cgColor
        theCircle.strokeColor = UIColor.white.cgColor
        theCircle.lineWidth = 3
        theCircle.opacity = 0
        theCircle.strokeEnd = 0
        theCircle.strokeStart = 0
        self?.layer.addSublayer(theCircle)
        return theCircle
        }()


    // MARK: - Life cycle
    deinit{
        self.timer?.invalidate()
        self.timer = nil
        self.layer.removeAllAnimations()
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    open override func awakeFromNib() {
        super.awakeFromNib()
        self.commonInit()
    }

    override open func layoutSubviews() {
        super.layoutSubviews()
        if self.radius == nil {
            self.radius = Double(self.frame.size.width) / 2.0
        }
        let bezierPath = UIBezierPath(ovalIn: CGRect(x: CGFloat(self.frame.size.width / 2.0 - CGFloat(self.radius! / 2.0)), y: CGFloat(self.frame.size.height / 2.0 - CGFloat(self.radius! / 2.0)), width: CGFloat(self.radius!), height: CGFloat(self.radius!)))
        self.circle.path = bezierPath.cgPath
    }


    // MARK: - Public methods
    open func start(){
        if self.timer != nil {
            return
        }

        self.timer?.invalidate()
        self.timer = nil

        self.circle.removeAllAnimations()
        self.addAnimate()

        self.timer =  Timer.timerWithTimeInterval(self.duration, block: {  [weak self] in
            self?.circle.removeAllAnimations()
            self?.addAnimate()
            }, repeats: true)
        RunLoop.current.add(self.timer!, forMode: RunLoopMode.commonModes)

        self.isHidden = false
        UIView.animate(withDuration: 0.15, delay: 0,options: .curveEaseInOut, animations: {
            self.circle.opacity = 1
            self.alpha = 1
        }, completion: {finished in
        })

    }

    open func stop(){
        if self.timer == nil {
            return
        }

        self.timer?.invalidate()
        self.timer = nil

        self.circle.removeAllAnimations()

        UIView.animate(withDuration: 0.15, delay: 0,options: .curveEaseInOut, animations: {[weak self] in
            self?.circle.opacity = 0
            self?.alpha = 0
            }, completion: {[weak self] finished in
                if finished {
                self?.isHidden = true
                }
        })
    }

    // MARK: - Private methods
    private func commonInit(){
        self.isHidden = true
    }

    private func addAnimate() {
        let endAnimation = CABasicAnimation(keyPath: "strokeEnd")
        endAnimation.fromValue = 0
        endAnimation.toValue = 1
        endAnimation.duration = self.duration
        endAnimation.isRemovedOnCompletion = true
        self.circle.add(endAnimation, forKey: "end")
        let startAnimation = CABasicAnimation(keyPath: "strokeStart")
        startAnimation.beginTime = CACurrentMediaTime() + duration / 2
        startAnimation.fromValue = 0
        startAnimation.toValue = 1
        startAnimation.isRemovedOnCompletion = true
        startAnimation.duration = self.duration / 2
        self.circle.add(startAnimation, forKey: "start")
    }

}
