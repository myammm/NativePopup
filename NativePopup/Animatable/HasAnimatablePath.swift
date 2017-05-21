//
//  HasAnimatablePath.swift
//  NativePopup
//
//  Created by mono on 2017/05/21.
//  Copyright © 2017 mono. All rights reserved.
//

import Foundation

open class AnimatablePathView: UIView, HasAnimatableLayer {
    let animatableLayer = CAShapeLayer()
    open var animatablePath: UIBezierPath { fatalError("Should be overridden.") }
    func setupLayer() {
        animatableLayer.path = animatablePath.cgPath
        animatableLayer.fillColor = UIColor.clear.cgColor
        animatableLayer.strokeColor = tintColor.cgColor
        animatableLayer.lineWidth = 9
        animatableLayer.lineCap = kCALineCapRound
        animatableLayer.lineJoin = kCALineCapRound
        animatableLayer.strokeEnd = 0
        layer.addSublayer(animatableLayer)
    }
}