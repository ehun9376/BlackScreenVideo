//
//  IConManager.swift
//  BlackSreenVideo
//
//  Created by 陳逸煌 on 2022/11/25.
//

import Foundation
import UIKit

public class IconManager {
    
    private let application = UIApplication.shared
    
    public enum AppIcon: String {
        case charmanderIcon = "charmanderIcon"
        case pikachuIcon = "pikachuIcon"
    }
   
    public func changeAppIcon(to appIcon: AppIcon) {
        application.setAlternateIconName(appIcon.rawValue)
    }
}
