//
//  NativePopup.swift
//  NativePopup
//
//  Created by mono on 2017/04/23.
//  Copyright © 2017 mono. All rights reserved.
//

import Foundation
import UIKit

public class NativePopup: UIView {
    private let keyWindow = UIApplication.shared.keyWindow!
    fileprivate weak static var currentView: NativePopup?
    private let effectView: UIVisualEffectView
    private let imageView: UIView

    public static func show(image: ImageConvertible,
                            title: String,
                            message: String?,
                            duration: TimeInterval = 1.5,
                            initialEffectType: InitialEffectType = .fromBottom) {
        let view = NativePopup(image: image,
                               title: title,
                               message: message)
        view.show(duration: duration, initialEffectType: initialEffectType)
    }

    public required init(coder aDecoder: NSCoder) {
        fatalError("should not be called")
    }

    private init(image: ImageConvertible,
                 title: String,
                 message: String?) {
        effectView = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))

        let imageValue = image.image
        imageValue.validate()
        switch imageValue {
        case .image(let image):
            imageView = UIImageView(image: image)
            imageView.contentMode = .scaleAspectFit
            imageView.layer.cornerRadius = 6
            imageView.clipsToBounds = true
        case .view(let view):
            imageView = view
        case .emoji(let character):
            let label = UILabel()
            label.text = String(character)
            label.font = UIFont.systemFont(ofSize: 120)
            label.textAlignment = .center
            imageView = UIView()
            imageView.np.addSubviewCenter(label)
            imageView.clipsToBounds = false
        }

        super.init(frame: CGRect.zero)
        np.addSubview(effectView)

        layer.cornerRadius = 8
        clipsToBounds = true

        isUserInteractionEnabled = false

        tintColor = #colorLiteral(red: 0.3529411765, green: 0.3529411765, blue: 0.3529411765, alpha: 1)
        imageView.tintColor = tintColor

        let titleLabel = UILabel()
        titleLabel.text = title
        // not dynamic size
        titleLabel.font = UIFont.boldSystemFont(ofSize: 22)

        let messageLabel = UILabel()
        messageLabel.text = message
        messageLabel.font = UIFont.systemFont(ofSize: 16)

        [titleLabel, messageLabel].forEach {
            $0.textColor = tintColor
            $0.numberOfLines = 0
            let style = NSMutableParagraphStyle()
            style.lineSpacing = 3
            style.alignment = .center
            $0.attributedText = NSAttributedString(string: $0.text ?? "", attributes: [NSParagraphStyleAttributeName: style])
        }

        effectView.addSubview(imageView)
        effectView.addSubview(titleLabel)

        imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 1).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 112).isActive = true
        imageView.topAnchor.constraint(equalTo: topAnchor, constant: 32 + image.additionalMarginTop).isActive = true
        imageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: titleLabel.topAnchor, constant: -(17 + image.additionalMarginBottom)).isActive = true

        let sideSpace: CGFloat = 8
        titleLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: sideSpace).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -sideSpace).isActive = true

        let bottomSpace: CGFloat = 37
        if message?.isEmpty ?? true {
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -bottomSpace).isActive = true
        } else {
            effectView.addSubview(messageLabel)
            titleLabel.bottomAnchor.constraint(equalTo: messageLabel.topAnchor, constant: -6).isActive = true
            messageLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: sideSpace).isActive = true
            messageLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -sideSpace).isActive = true
            messageLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -bottomSpace).isActive = true
        }

        [self, effectView, imageView, titleLabel, messageLabel].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

        if let animatable = imageView as? HasAnimatablePath {
            imageView.layoutIfNeeded()
            animatable.setupLayer()
        }
    }

    private func show(duration: TimeInterval, initialEffectType: InitialEffectType) {
        // MEMO: Need to remove?(iOS native popup doesn't remove previous popup)
        type(of: self).currentView?.removeFromSuperview()
        type(of: self).currentView = self
        keyWindow.addSubview(self)
        widthAnchor.constraint(equalToConstant: 250).isActive = true
        centerXAnchor.constraint(equalTo: keyWindow.centerXAnchor).isActive = true

        let defaultY = centerYAnchor.constraint(equalTo: keyWindow.centerYAnchor)
        let initialY = topAnchor.constraint(equalTo: keyWindow.bottomAnchor)
        initialY.isActive = true
        update(alpha: 0)
        keyWindow.layoutIfNeeded()

        initialY.isActive = false
        defaultY.isActive = true
        switch initialEffectType {
        case .fromBottom:
            showWithFromBottom {
                self.dismissAfter(duration: duration)
            }
        case .fadeIn:
            showWithFadeIn {
                self.dismissAfter(duration: duration)
            }
        }
    }

    private func showWithFromBottom(shown: @escaping (() -> ())) {
        // MEMO: Enhance animation(especially, animation curve)
        // MEMO: Refactor(resolve nest?)
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       options: UIViewAnimationOptions.curveEaseOut,
                       animations: {
                        self.update(alpha: 1)
                        self.keyWindow.layoutIfNeeded()
        }, completion: { finished in
            shown()
        })
    }

    private func showWithFadeIn(shown: @escaping (() -> ())) {
        update(alpha: 0)
        transform = transform.scaledBy(x: 0.8, y: 0.8)
        UIView.animate(withDuration: 0.2,
                       animations: {
                        self.update(alpha: 1)
                        self.transform = CGAffineTransform.identity
        },
                       completion: {finished in
                        shown()
        })
    }

    private func dismissAfter(duration: TimeInterval) {
        if let animatable = imageView as? Animatable {
            animatable.animate()
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + duration) {
            UIView.animate(withDuration: 0.2,
                           animations: {
                            // for visual effecto view smooth animation
                            self.update(alpha: 0)
                            self.transform = self.transform.scaledBy(x: 0.8, y: 0.8)
            },
                           completion: { finished in
                            self.removeFromSuperview()
            })
        }
    }

    private func update(alpha: CGFloat) {
        effectView.alpha = alpha
    }
}
