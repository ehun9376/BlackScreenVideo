//
//  BaseViewController.swift
//  BlackSreenVideo
//
//  Created by 陳逸煌 on 2022/11/23.
//

import Foundation
import UIKit

class BaseViewController: UIViewController {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        KeyboardHelper.shared.registFor(viewController: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        KeyboardHelper.shared.unregist()
    }
    
    func showAlert(title:String = "",message: String = "",confirmTitle: String = "",cancelTitle: String,confirmAction: (()->())? = nil,cancelAction:(()->())? = nil){
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: confirmTitle, style: .default) { _ in
            if let confirmAction = confirmAction {
                confirmAction()
            }
        }
        controller.addAction(okAction)
        
        let cancelAction = UIAlertAction(title: cancelTitle, style: .cancel) { _ in
            if let cancelAction = cancelAction {
                cancelAction()
            }
        }
        controller.addAction(cancelAction)
        
        self.present(controller, animated: true, completion: nil)
    }
    
    func showSingleAlert(title:String = "",message: String = "",confirmTitle: String = "",confirmAction: (()->())? = nil){
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: confirmTitle, style: .default) { _ in
            if let confirmAction = confirmAction {
                confirmAction()
            }
        }
        controller.addAction(okAction)
        
        self.present(controller, animated: true, completion: nil)
    }
}
