//
//  StackBottomBarView.swift
//  Recruit
//
//  Created by 陳逸煌 on 2022/8/22.
//  Copyright © 2022 Daniel. All rights reserved.
//

import Foundation
import UIKit

class BottomBarButton: SwiftButton {
    enum ButtonTitle: String {
        ///確認
        case confirm = "確認"
        ///確認條件
        case confirmConditions = "確認條件"
        ///取消
        case cancel = "取消"
        ///確認送出
        case confirmAndSend = "確認送出"
        ///刪除
        case delete = "刪除"
        ///清除條件
        case cleanConditions = "清除條件"
        ///搜尋
        case search = "搜尋"
        ///重新選取
        case reSelect = "重新選取"
        ///儲存
        case save = "儲存"
        ///預覽
        case preview = "預覽"
        ///清空紀錄
        case cleanRecord = "清空紀錄"
        
    }
    
    func resetStatus(canClick: Bool = true, canClickColor: UIColor = .red, canNotClickColor: UIColor = .gray) {
        DispatchQueue.main.async {
            self.backgroundColor = canClick ? canClickColor : canNotClickColor
            self.isEnabled = canClick
        }
    }
    
    static func createButtonModel(title: ButtonTitle, textColor: StackBottomBarView.BottomBarStyle = .red,  backgroundColor: StackBottomBarView.BottomBarStyle = .none, borderColor: StackBottomBarView.BottomBarStyle = .none, action: (()->())? = nil) -> BottomBarButton {
        
        let button = BottomBarButton()
        
        button.setTitle(title.rawValue, for: .normal)
        
        button.titleLabel?.font = .systemFont(ofSize: 18)
        
        button.layer.cornerRadius = 9
        
        button.clipsToBounds = true

        switch textColor {
        case .red:
            button.setTitleColor(.red, for: .normal)
        case .white:
            button.setTitleColor(.white, for: .normal)
        case .none:
            button.setTitleColor(.clear, for: .normal)
        }
        
        switch backgroundColor {
        case .red:
            button.backgroundColor = .red
        case .white:
            button.backgroundColor = .white
        case .none:
            button.backgroundColor = .clear
        }
        
        switch borderColor {
        case .red:
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.red.cgColor
        case .white:
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.white.cgColor
        case .none:
            button.layer.borderWidth = 0
            button.layer.borderColor = UIColor.clear.cgColor
        }
        
        button.onTouchUpInside { button in
            if let action = action {
                action()
            }
        }
        
        return button
    }
    
    static func createCustomButtonModel(action: (()->())? = nil) -> BottomBarButton {
        
        let button = BottomBarButton()
        
        button.onTouchUpInside { button in
            if let action = action {
                action()
            }
        }
        return button
    }
    
}

class StackBottomBarView: UIView {
    enum BottomBarStyle {
        case red
        case white
        case none
    }
    var style: BottomBarStyle = .white
    
    convenience init(bottomBarButtons: [BottomBarButton] = [],style: BottomBarStyle = .white) {
        self.init(frame: .zero)
        self.style = style
        self.setupView(bottomBarButtons: bottomBarButtons,style: style)
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    func createStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.spacing = 20
        return stackView
    }
    
    func setupView(bottomBarButtons: [BottomBarButton] = [],style: BottomBarStyle = .red) {
        
        
        switch style {
        case .red:
            self.backgroundColor = .red
        case .white:
            self.backgroundColor = .white
            self.layer.shadowColor = UIColor.black.cgColor
            self.layer.shadowRadius = 3
            self.layer.shadowOpacity = 0.1
        case .none:
            break
        }

        
        let stackView = createStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(stackView)
        
        stackView.topAnchor.constraint(equalTo: self.topAnchor, constant: 10).isActive = true
        stackView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        stackView.leadingAnchor.constraint(greaterThanOrEqualTo: self.leadingAnchor, constant: 33).isActive = true
        stackView.trailingAnchor.constraint(lessThanOrEqualTo: self.trailingAnchor, constant: -33.0).isActive = true
        
        let totalButtons = bottomBarButtons.count
        let spacing: CGFloat = 20
        let availableWidth = UIScreen.main.bounds.width - CGFloat(totalButtons - 1) * spacing - 66
        let minWidth = min(availableWidth / CGFloat(totalButtons), CGFloat(140))
        
        for button in bottomBarButtons {
            button.translatesAutoresizingMaskIntoConstraints = false
            stackView.addArrangedSubview(button)
            button.widthAnchor.constraint(equalToConstant: minWidth).isActive = true
        }

    }
}
