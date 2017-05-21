//
//  HasAnimatablePath.swift
//  NativePopup
//
//  Created by mono on 2017/05/21.
//  Copyright © 2017 mono. All rights reserved.
//

import Foundation

protocol HasAnimatablePath: HasAnimatableLayer {
    var path: UIBezierPath { get }
    func setupLayer()
}

extension HasAnimatablePath where Self: UIView {
    func setupLayer() {
        animatableLayer.path = path.cgPath
        animatableLayer.fillColor = UIColor.clear.cgColor
        animatableLayer.strokeColor = tintColor.cgColor
        animatableLayer.lineWidth = 9
        animatableLayer.lineCap = kCALineCapRound
        animatableLayer.lineJoin = kCALineCapRound
        animatableLayer.strokeEnd = 0
        layer.addSublayer(animatableLayer)
    }
}
