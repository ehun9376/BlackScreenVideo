//
//  FakeView.swift
//  AVCam
//
//  Created by 陳逸煌 on 2022/11/18.
//  Copyright © 2022 Apple. All rights reserved.
//

import Foundation
import UIKit

class FakeView: UIView {
    
    
    var dismissAction: (()->())?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .black
        self.addGesture()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addGesture() {
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(fakeTapGestureAction(_:)))
        tapGes.numberOfTouchesRequired = 3
        tapGes.numberOfTapsRequired = 3
        self.addGestureRecognizer(tapGes)
        self.isUserInteractionEnabled = true
    }
    
    @objc func fakeTapGestureAction(_ sender: UITapGestureRecognizer) {
        self.removeFromSuperview()
        self.dismissAction?()
    }
    

    
    
}
