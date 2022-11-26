//
//  IConManager.swift
//  BlackSreenVideo
//
//  Created by 陳逸煌 on 2022/11/25.
//

import Foundation
import UIKit

enum AppIcon: String {
    case charmanderIcon
    case pikachuIcon
}

class IconManager {
    
    static let shared = IconManager()
    
    private let application = UIApplication.shared
   
    public func changeAppIcon(to appIcon: AppIcon) {
        application.setAlternateIconName(appIcon.rawValue)
    }
}
