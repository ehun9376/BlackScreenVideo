//
//  IConManager.swift
//  BlackSreenVideo
//
//  Created by 陳逸煌 on 2022/11/25.
//

import Foundation
import UIKit

enum AppIcon: String {
    case opIcon
    case blackIcon
    case ranbowIcon
}

class IconManager {
    
    static let shared = IconManager()
    
    private let application = UIApplication.shared
   
    public func changeAppIcon(to appIcon: AppIcon) {
        guard UIApplication.shared.supportsAlternateIcons else { return }

        let name = appIcon.rawValue
        DispatchQueue.main.async {
            self.application.setAlternateIconName(name)

        }
    }
}
