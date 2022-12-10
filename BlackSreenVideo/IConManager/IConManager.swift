//
//  IConManager.swift
//  BlackSreenVideo
//
//  Created by 陳逸煌 on 2022/11/25.
//

import Foundation
import UIKit

enum AppIcon: String {
    case ball1Icon
    case mail1Icon
    case message1Icon
    case oilIcon
    case oil2Icon
    case youtubeIcon
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
