//
//  KeyboardHelper.swift
//  Job1111
//
//  Created on 2019/7/23.
//  Copyright © 2019 JobBank. All rights reserved.
//

import UIKit

protocol KeyboardHelperDelegate: AnyObject {
    func didViewChanged(frame: CGRect, duration: Double, isHiddenKeyboard: Bool)
}

class KeyboardHelper {
    static var shared = KeyboardHelper()
    
    weak var relateView: UIView?
    
    private weak var tmpRelateView: UIView?
    
    private var isAnimateKeyboard: Bool = false
    
    /// 如果需要鍵盤變更事件就使用delegate
    weak var delegate: KeyboardHelperDelegate?
    
    var keyboardAnimateDuration: Double = 0.2
    private var originFrame: CGRect = .zero
    public var keyboardFrame: CGRect = .zero {
        didSet {
            if self.keyboardFrame != oldValue {
                self.keyboardFrameUpdated()
            }
        }
    }
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    func registFor(viewController: UIViewController) {
        if self.relateView == nil {
            self.originFrame = .zero
            self.relateView = viewController.view
        } else {
            self.changeRegistTo(viewController: viewController)
        }
    }
    
    private func changeRegistTo(viewController: UIViewController) {
        if self.keyboardFrame == .zero {
            self.relateView = viewController.view
            self.tmpRelateView = nil
        } else {
            if self.relateView == viewController.view {
                self.keyboardFrameUpdated()
            } else {
                self.tmpRelateView = viewController.view
                self.relateView?.endEditing(true)
            }
        }
    }
    
    func unregist() {
        if self.keyboardFrame == .zero {
            self.relateView = nil
            self.originFrame = .zero
        } else {
            self.relateView?.endEditing(true)
        }
    }
    
    private func keyboardFrameUpdated() {
        guard let relateView = self.relateView, !self.isAnimateKeyboard else { return }
        self.isAnimateKeyboard = true
        if self.keyboardFrame != .zero && self.originFrame == .zero {
            self.originFrame = relateView.frame
        }
        let originFrame: CGRect = self.originFrame
        var displayFrame = originFrame
        displayFrame.size.height = originFrame.size.height - self.keyboardFrame.height
        self.delegate?.didViewChanged(frame: displayFrame, duration: self.keyboardAnimateDuration, isHiddenKeyboard: self.keyboardFrame == .zero)

        UIView.animate(withDuration: self.keyboardAnimateDuration, animations: {
            self.relateView?.frame = displayFrame
            self.relateView?.layoutIfNeeded()
        }) { (animatingPosition) in
            if let relateView = self.tmpRelateView {
                self.relateView = relateView
                self.tmpRelateView = nil
            }
            self.isAnimateKeyboard = false
        }
    }
    
    @objc func keyboardWillAppear(notification: NSNotification?) {
        self.keyboardDurationUpdate(notification: notification)
        if let info = notification?.userInfo {
            if let frame = (info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                self.keyboardFrame = frame
            }
        }
    }
    
    @objc func keyboardWillDisappear(notification: NSNotification?) {
        self.keyboardDurationUpdate(notification: notification)
        self.keyboardFrame = .zero
    }
    func keyBoardDisMiss(){
        self.keyboardFrame = .zero
    }
    
    private func keyboardDurationUpdate(notification: NSNotification?) {
        if let info = notification?.userInfo {
            if let keyboardAnimationDuration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber {
                self.keyboardAnimateDuration = TimeInterval(truncating: keyboardAnimationDuration)
            }
        }
    }
}

extension UIView {
    func currentFirstResponder() -> UIResponder? {
        if self.isFirstResponder {
            return self
        }
        
        for view in self.subviews {
            if let responder = view.currentFirstResponder() {
                return responder
            }
        }
        
        return nil
    }
}

extension UIImage {
    func resizeImage(targetSize: CGSize) -> UIImage {
        let widthRatio  = targetSize.width  / self.size.width
        let heightRatio = targetSize.height / self.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 10.0)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage ?? self
    }
}
