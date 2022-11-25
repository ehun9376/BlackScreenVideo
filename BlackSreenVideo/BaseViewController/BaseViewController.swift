//
//  BaseViewController.swift
//  BlackSreenVideo
//
//  Created by 陳逸煌 on 2022/11/23.
//

import Foundation
import UIKit

class BaseViewController: UIViewController {
    
    var navigationTitle: String? = ""
    
    var defaultBottomBarHeight: CGFloat = 80
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.defaultNavigationSet()
        KeyboardHelper.shared.registFor(viewController: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        KeyboardHelper.shared.unregist()
    }
    
    func showAlert(title:String = "",message: String = "",confirmTitle: String = "",cancelTitle: String,confirmAction: (()->())? = nil,cancelAction:(()->())? = nil){
        DispatchQueue.main.async {
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

    }
    
    func showSingleAlert(title:String = "",message: String = "",confirmTitle: String = "",confirmAction: (()->())? = nil){
        DispatchQueue.main.async {
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
    
    func showInputDialog(title:String? = nil,
                         subtitle:String? = nil,
                         actionTitle:String? = "Add",
                         cancelTitle:String? = "Cancel",
                         inputPlaceholder:String? = nil,
                         inputKeyboardType:UIKeyboardType = UIKeyboardType.default,
                         cancelHandler: ((UIAlertAction) -> Swift.Void)? = nil,
                         actionHandler: ((_ text: String?) -> Void)? = nil) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: subtitle, preferredStyle: .alert)
            alert.addTextField { (textField:UITextField) in
                textField.placeholder = inputPlaceholder
                textField.keyboardType = inputKeyboardType
            }
            alert.addAction(UIAlertAction(title: actionTitle, style: .default, handler: { (action:UIAlertAction) in
                guard let textField =  alert.textFields?.first else {
                    actionHandler?(nil)
                    return
                }
                actionHandler?(textField.text)
            }))
            alert.addAction(UIAlertAction(title: cancelTitle, style: .cancel, handler: cancelHandler))
            
            self.present(alert, animated: true, completion: nil)
        }

    }


    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupNavigationtitle()
    }
    
    
    private func setupNavigationtitle() {
        if let naviTitle = self.navigationTitle {
            self.title = naviTitle
        }
    }

    ///if need bottoBar override this func
    func setBottomButtons() -> [BottomBarButton] {
        return []
    }
    
    func setBottomBarStyle() -> StackBottomBarView.BottomBarStyle {
        return .white
    }
    
    func setBottomBarView(buttons: [BottomBarButton]) { }
    
    func showToast(message:String) {
        DispatchQueue.main.async {
            guard self.presentedViewController?.classForCoder != UIAlertController.self else { return }
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            self.present(alert, animated: true, completion: nil)
            DispatchQueue.global().async {
                sleep(1)
                DispatchQueue.main.async {
                    alert.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    private func defaultNavigationSet() {
        
        if #available(iOS 14.0, *) {
            self.navigationItem.backButtonDisplayMode = .minimal
        }
        
        if #available(iOS 13.0, *) {
            let barAppearance = UINavigationBarAppearance()
            barAppearance.backgroundColor = .white
            barAppearance.shadowColor = .clear
            navigationItem.standardAppearance = barAppearance
            navigationItem.scrollEdgeAppearance = barAppearance
        }

        if #available(iOS 15.0, *){
            UITableView.appearance().sectionHeaderTopPadding = 0
        }
    }
 
}
