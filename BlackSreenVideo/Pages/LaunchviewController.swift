//
//  LaunchPage.swift
//  BlackSreenVideo
//
//  Created by yihuang on 2022/11/23.
//

import Foundation
import UIKit

class LaunchViewController: BaseViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UserInfoCenter.shared.startCheck()
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
            DispatchQueue.main.async {
                self.pushToTabbarController()
            }
    }
    
    func checkPassword(password: String? = nil) {
        if let storePassword = UserInfoCenter.shared.loadValue(.password) as? String,
           let password = password, storePassword == password {
            self.pushToTabbarController()
            return
        }

        if let needPassword = UserInfoCenter.shared.loadValue(.needPassword) as? Bool, needPassword {
            self.showInputDialog(title: "提示",
                                 subtitle: "請輸入開啟密碼",
                                 actionTitle: "確認",
                                 cancelTitle: "取消",
                                 inputPlaceholder: "請輸入密碼",
                                 inputKeyboardType: .numberPad,
                                 cancelHandler: nil,
                                 actionHandler: { [weak self] password in
                self?.checkPassword(password: password)
            })
        } else {
            self.pushToTabbarController()
        }

    }
    
    func pushToTabbarController() {
        
        IAPCenter.shared.requestComplete = { [weak self] debug in
            self?.toVC()
        }
        
        IAPCenter.shared.getProducts()


        
    }
    
    func toVC() {
        DispatchQueue.main.async {
            if let vc = self.storyboard?.instantiateViewController(withIdentifier: "NavigationVC") {
                UIApplication.shared.windows.first?.rootViewController = vc
                UIApplication.shared.windows.first?.makeKeyAndVisible()
            }
        }
    }
    
}
