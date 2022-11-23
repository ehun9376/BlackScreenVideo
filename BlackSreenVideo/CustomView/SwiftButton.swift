//
//  JButton.swift
//  Job1111
//
//  Created by drbingbing on 2020/6/22.
//  Copyright © 2020 JobBank. All rights reserved.
//

import UIKit

/// Create a button that can easy to use
class SwiftButton: UIButton {

    typealias ButtonItemAction = (SwiftButton) -> Void
    
    private var onTouchUpInsideAction: ButtonItemAction = { _ in }
    private var onEnabledAction: ButtonItemAction = { _ in }
    private var onDisabledAction: ButtonItemAction = { _ in }
    
    var padding: UIEdgeInsets = .zero {
        didSet { setNeedsDisplay() }
    }
    
    override var isEnabled: Bool {
        didSet {
            if isEnabled {
                onEnabledAction(self)
            } else {
                onDisabledAction(self)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    override func contentRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setup()
    }
    
    func setup() {
        addTarget(self, action: #selector(SwiftButton.touchUpInsideAction), for: .touchUpInside)
    }
    
    @objc func touchUpInsideAction() {
        onTouchUpInsideAction(self)
    }
    
    // MARK: - Hook Setup Methods
    
    /// Used to setup your own initial properties
    ///
    /// - Parameter item: A reference to Self
    /// - Returns: Self
    @discardableResult
    func configure(_ item: ButtonItemAction) -> Self {
        item(self)
        return self
    }
    
    /// Sets the onTouchUpInsideAction
    ///
    /// - Parameter action: The new onTouchUpInsideAction
    /// - Returns: Self
    @discardableResult
    func onTouchUpInside(_ action: @escaping ButtonItemAction) -> Self {
        onTouchUpInsideAction = action
        return self
    }
    
    /// Sets the onEnabledAction
    ///
    /// - Parameter action: The new onEnabledAction
    /// - Returns: Self
    @discardableResult
    func onEnabled(_ action: @escaping ButtonItemAction) -> Self {
        onEnabledAction = action
        return self
    }
    
    /// Sets the onDisabledAction
    ///
    /// - Parameter action: The new onDisabledAction
    /// - Returns: Self
    @discardableResult
    func onDisabled(_ action: @escaping ButtonItemAction) -> Self {
        onDisabledAction = action
        return self
    }
    
    
    class func create(_ type: UIButton.ButtonType = .custom, _ item: ButtonItemAction) -> SwiftButton {
        return SwiftButton(type: type).configure(item)
    }
}
