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
        
        let scene = UIApplication.shared.connectedScenes.first
        
        if let delegate : SceneDelegate = (scene?.delegate as? SceneDelegate){
            delegate.window?.overrideUserInterfaceStyle = .dark
            delegate.window?.makeKeyAndVisible()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        VersionCheckCenter.shared.enablePurchaseInAppIfNeeded(complete: {
            DispatchQueue.main.async {
                self.checkPassword()
            }
        })

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
        
        IAPCenter.shared.requestComplete = {
            DispatchQueue.main.async {
                let scene = UIApplication.shared.connectedScenes.first
                
                if let delegate : SceneDelegate = (scene?.delegate as? SceneDelegate),
                   let initialViewController = self.storyboard?.instantiateViewController(withIdentifier: "NavigationVC"){
                    delegate.window?.rootViewController = initialViewController
                    delegate.window?.makeKeyAndVisible()
                }
            }
        }
        
        IAPCenter.shared.getProducts()


        
    }
    
}
