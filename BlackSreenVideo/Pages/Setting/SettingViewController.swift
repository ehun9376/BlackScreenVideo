//
//  SettingViewController.swift
//  BlackSreenVideo
//
//  Created by yihuang on 2022/11/23.
//

import Foundation
import UIKit
import StoreKit

class SettingViewController: BaseTableViewController {
    
    var rowModels: [CellRowModel] = []
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.regisCellID(cellIDs: [
            "SettingCell",
            "TagCell"
        ])

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupRowModel()
        IAPCenter.shared.storeComplete = { [weak self] in
            self?.setupRowModel()
        }
    }
    
    func setupRowModel() {
        
        let buyedIDs = UserInfoCenter.shared.loadValue(.iaped) as? [String] ?? []

        self.rowModels.removeAll()
        
        //影片設定
        let videoTagRowModel = TagCellRowModel(title: "影片設定")
        self.rowModels.append(videoTagRowModel)
        
        //相機
        let caremaCodeModel = CodeModel.cameraLocation.first(where: {$0.number == UserInfoCenter.shared.loadValue(.cameraLocation) as? Int}) ?? .init()
        let caremaRowModel = SettingCellRowModel(title: "相機",
                                                 detail: caremaCodeModel.text,
                                                 imageName: "video",
                                                 showSwitch: false,
                                                 switchON: true,
                                                 switchAction: nil,
                                                 cellDidSelect: { [weak self] _ in
            guard buyedIDs.contains(ProductID.topup_100_a.rawValue) else {
                self?.showToast(message: "要購買才能使用喔")
                return
            }
            self?.pushToSelectVC(title: "相機位置",
                                 dataSource: CodeModel.cameraLocation,
                                 seletedModel: CodeModel.cameraLocation.filter({$0 == caremaCodeModel}),
                                 confirmAction: { codeModels in
                if let codeModel = codeModels.first {
                    UserInfoCenter.shared.storeValue(.cameraLocation, data: codeModel.number)
                    self?.setupRowModel()
                    
                }
            })
        })
        
        self.rowModels.append(caremaRowModel)
        
        //影片方向
        let videoCodeModel = CodeModel.videoDirection.first(where: {$0.number == UserInfoCenter.shared.loadValue(.videoDirection) as? Int}) ?? .init()
        
        let videoRowModel = SettingCellRowModel(title: "影片方向",
                                    detail: videoCodeModel.text,
                                    imageName: "iphone.gen1.landscape",
                                    showSwitch: false,
                                    switchON: true,
                                    switchAction: nil,
                                    cellDidSelect: { [weak self] _ in
            guard buyedIDs.contains(ProductID.topup_50_a.rawValue) else {
                self?.showToast(message: "要購買才能使用喔")
                return
            }
            self?.pushToSelectVC(title: "影片方向",
                                 dataSource: CodeModel.videoDirection,
                                 seletedModel: CodeModel.videoDirection.filter({$0 == videoCodeModel}),
                                 confirmAction: { codeModels in
                if let codeModel = codeModels.first {
                    UserInfoCenter.shared.storeValue(.videoDirection, data: codeModel.number)
                    self?.setupRowModel()
                    
                }
            })
        })
        
        self.rowModels.append(videoRowModel)
        
        //解析度
        let resolutionsCodeModel = CodeModel.resolutions.first(where: {$0.number == UserInfoCenter.shared.loadValue(.resolutions) as? Int}) ?? .init()
        
        let resolutionsRowModel = SettingCellRowModel(title: "解析度",
                                    detail: resolutionsCodeModel.text,
                                    imageName: "aqi.medium",
                                    showSwitch: false,
                                    switchON: true,
                                    switchAction: nil,
                                    cellDidSelect: { [weak self] _ in
            guard buyedIDs.contains(ProductID.tier_50.rawValue) else {
                self?.showToast(message: "要購買才能使用喔")
                return
            }
            self?.pushToSelectVC(title: "解析度",
                                 dataSource: CodeModel.resolutions,
                                 seletedModel: CodeModel.resolutions.filter({$0 == resolutionsCodeModel}),
                                 confirmAction: { codeModels in
                if let codeModel = codeModels.first {
                    UserInfoCenter.shared.storeValue(.resolutions, data: codeModel.number)
                    self?.setupRowModel()
                    
                }
            })
        })
        
        self.rowModels.append(resolutionsRowModel)
        
        //循環錄影
        let cycleTagRowModel = TagCellRowModel(title: "循環錄影")
        self.rowModels.append(cycleTagRowModel)
        
        //時間限制
        let time = UserInfoCenter.shared.loadValue(.videoMaxTime) as? Int ?? 0
        let videoMaxTimeRowModel = SettingCellRowModel(title: String(format: "時間限制(%d分鐘%d秒)",time / 60 ,time % 60),
                                                       detail: "限制錄影時間",
                                                       imageName: "clock",
                                                       showSwitch: true,
                                                       switchON: UserInfoCenter.shared.loadValue(.lockVideoMaxTime) as? Bool ?? false,
                                                       switchAction: { [weak self] isON in
            guard buyedIDs.contains(ProductID.maxTime.rawValue) else {
                self?.showToast(message: "要購買才能使用喔")
                return
            }
            UserInfoCenter.shared.storeValue(.lockVideoMaxTime, data: isON)
            if isON, UserInfoCenter.shared.loadValue(.videoMaxTime) == nil {
                self?.showVideoTimeAlert()
            }
        },
                                                       cellDidSelect: { [weak self] rowModel in
            self?.showVideoTimeAlert()
            
        })
        self.rowModels.append(videoMaxTimeRowModel)
        
        //循環錄影
        let cycleRecodingRowModel = SettingCellRowModel(title: "循環錄影",
                                                        detail: "影片達到限制時間後，繼續錄製影片",
                                                        imageName: "repeat",
                                                        showSwitch: true,
                                                        switchON: UserInfoCenter.shared.loadValue(.cycleRecoding) as? Bool ?? false,
                                                        switchAction: { [weak self] isON in
            guard buyedIDs.contains(ProductID.tier_50.rawValue) else {
                self?.showToast(message: "要購買才能使用喔")
                self?.setupRowModel()
                return
            }
            UserInfoCenter.shared.storeValue(.cycleRecoding, data: isON)
        },
                                                        cellDidSelect: nil)
        self.rowModels.append(cycleRecodingRowModel)
        
        //一般設定
        let normalTagRowModel = TagCellRowModel(title: "一般設定")
        self.rowModels.append(normalTagRowModel)
        
        let previewViewRowModel = SettingCellRowModel(title: "預覽畫面",
                                                      detail: "顯示正在錄製的畫面",
                                                      imageName: "viewfinder",
                                                      showSwitch: true,
                                                      switchON: UserInfoCenter.shared.loadValue(.showPreviewView) as? Bool ?? false,
                                                      switchAction: { isON in
            UserInfoCenter.shared.storeValue(.showPreviewView, data: isON)
        },
                                                      cellDidSelect: nil)
        if VersionCheckCenter.shared.isOnline {
            self.rowModels.append(previewViewRowModel)
        }

        
        //錄影完成時通知
        let recordingCompleteModel = SettingCellRowModel(title: "錄影完成",
                                                         detail: "停止錄影時顯示通知",
                                                         imageName: "bell",
                                                         showSwitch: true,
                                                         switchON: UserInfoCenter.shared.loadValue(.notifiyWhenComplete) as? Bool ?? false,
                                                         switchAction: { isON in
            guard buyedIDs.contains(ProductID.notice.rawValue) else {
                self.showToast(message: "要購買才能使用喔")
                return
            }
            UserInfoCenter.shared.storeValue(.notifiyWhenComplete, data: isON)
        },
                                                         cellDidSelect: nil)
        self.rowModels.append(recordingCompleteModel)
        
        //開始錄影時振動
        let shakeWhenStartRowModel = SettingCellRowModel(title: "開始錄影時振動",
                                                         detail: nil,
                                                         imageName: "iphone.gen1.radiowaves.left.and.right",
                                                         showSwitch: true,
                                                         switchON: UserInfoCenter.shared.loadValue(.shakeWhenStart) as? Bool ?? false,
                                                         switchAction: { isON in
            UserInfoCenter.shared.storeValue(.shakeWhenStart, data: isON)
        },
                                                         cellDidSelect: nil)
        if VersionCheckCenter.shared.isOnline {
            self.rowModels.append(shakeWhenStartRowModel)
        }
        
        //結束錄影時振動
        let shakeWhenEndRowModel = SettingCellRowModel(title: "結束錄影時振動",
                                                       detail: nil,
                                                       imageName: "iphone.gen1.radiowaves.left.and.right",
                                                       showSwitch: true,
                                                       switchON: UserInfoCenter.shared.loadValue(.shakeWhenEnd) as? Bool ?? false,
                                                       switchAction: { isON in
            UserInfoCenter.shared.storeValue(.shakeWhenEnd, data: isON)
        },
                                                       cellDidSelect: nil)
        if VersionCheckCenter.shared.isOnline {
            self.rowModels.append(shakeWhenEndRowModel)
        }
        
        //DarkMode
        let darkModeRowModel = SettingCellRowModel(title: "深色模式",
                                                   imageName: "circle.righthalf.filled",
                                                   showSwitch: true,
                                                   switchON: (UserInfoCenter.shared.loadValue(.darkMode) as? Bool ?? false),
                                                   switchAction: { isON in
            guard buyedIDs.contains(ProductID.darkMode.rawValue) else {
                self.showToast(message: "要購買才能使用喔")
                return
            }
            UserInfoCenter.shared.storeValue(.darkMode, data: isON)
                        
//            if let delegate : SceneDelegate = (scene?.delegate as? SceneDelegate){
//                delegate.window?.overrideUserInterfaceStyle = isON ? .dark : .light
//                delegate.window?.makeKeyAndVisible()
//            }

        })
        
        self.rowModels.append(darkModeRowModel)
        
        //清除所有
        let cleanRowModel = SettingCellRowModel(title: "清除所有檔案",
                                                imageName: "clear",
                                                showSwitch: false,
                                                cellDidSelect:  { [weak self] _ in
            self?.removeFile(complete: {
                self?.showToast(message: "檔案已空")
            })
        })
        
        self.rowModels.append(cleanRowModel)
        
        //換App圖片
        let appImageRowModel = SettingCellRowModel(title: "更換AppIcon",
                                                imageName: "circle.grid.2x2.fill",
                                                showSwitch: false,
                                                cellDidSelect:  { [weak self] _ in
            self?.pushToGridView()
        })
        
//        self.rowModels.append(appImageRowModel)
        
        
        //安全設定
        let safetyTagRowModel = TagCellRowModel(title: "安全設定")
        self.rowModels.append(safetyTagRowModel)
        
        //使用者驗證
        let needPassWordRowModel = SettingCellRowModel(title: "使用者驗證",
                                                       detail: "開啟前輸入密碼",
                                                       imageName: "lock",
                                                       showSwitch: true,
                                                       switchON: UserInfoCenter.shared.loadValue(.needPassword) as? Bool ?? false,
                                                       switchAction: { [weak self] isON in
//            guard buyedIDs.contains(ProductID.password.rawValue) else {
//                self?.showToast(message: "要購買才能使用喔")
//                return
//            }
            UserInfoCenter.shared.storeValue(.needPassword, data: isON)
            if UserInfoCenter.shared.loadValue(.password) == nil {
                self?.showPasswordAlert(isON: isON, fromSwitch: true)
            }
        },
                                                       cellDidSelect: nil)
        self.rowModels.append(needPassWordRowModel)
        
        var passWordDetail = ""
        
        if let password = UserInfoCenter.shared.loadValue(.password) as? String {
            passWordDetail = "目前密碼為" + password
        }
        
        //變更密碼
        let passWordRowModel = SettingCellRowModel(title: "變更密碼",
                                                   detail: passWordDetail,
                                                   imageName: "textformat.abc.dottedunderline",
                                                   showSwitch: false,
                                                   switchAction: nil,
                                                   cellDidSelect: { [weak self] _ in
            self?.showPasswordAlert(isON: true,fromSwitch: false)
        })
        
        self.rowModels.append(passWordRowModel)
        
        //購買紀錄
        let shopingTagRowModel = TagCellRowModel(title: "購買紀錄")
        self.rowModels.append(shopingTagRowModel)


        //購買變影片方向
        let topup_50_aModel = SettingCellRowModel(title: "購買解鎖改變影片方向",
                                                imageName: "briefcase",
                                                showSwitch: false,
                                              cellDidSelect: { [weak self] _ in
//            self?.showAlert(title: "提示",
//                            message: "購買解鎖改變影片方向\n ID: \(ProductID.topup_50_a.rawValue)",
//                            confirmTitle: "前往購買",
//                            cancelTitle: "取消",
//                            confirmAction: {
                if let product = IAPCenter.shared.products.first(where: {$0.productIdentifier == ProductID.topup_50_a.rawValue}) {
                    IAPCenter.shared.buy(product: product)
                }
//            })
            
        })
        
        if !buyedIDs.contains(ProductID.topup_50_a.rawValue){
            self.rowModels.append(topup_50_aModel)
        }
        
        //改變解析度
        let tier_50Model = SettingCellRowModel(title: "購買解鎖改變解析度",
                                                imageName: "briefcase",
                                                showSwitch: false,
                                              cellDidSelect: { [weak self] _ in
//            self?.showAlert(title: "提示",
//                            message: "購買解鎖改變解析度\n ID: \(ProductID.tier_50.rawValue)",
//                            confirmTitle: "前往購買",
//                            cancelTitle: "取消",
//                            confirmAction: {
                if let product = IAPCenter.shared.products.first(where: {$0.productIdentifier == ProductID.tier_50.rawValue}) {
                    IAPCenter.shared.buy(product: product)
                }
//            })
            
        })
        
        if !buyedIDs.contains(ProductID.tier_50.rawValue){
            self.rowModels.append(tier_50Model)
        }
        
        //改變鏡頭位置
        let topup_100_aModel = SettingCellRowModel(title: "購買解鎖改變鏡頭位置",
                                                imageName: "briefcase",
                                                showSwitch: false,
                                              cellDidSelect: { [weak self] _ in
//            self?.showAlert(title: "提示",
//                            message: "購買解鎖改變鏡頭位置\nID:\(ProductID.topup_100_a.rawValue)",
//                            confirmTitle: "前往購買",
//                            cancelTitle: "取消",
//                            confirmAction: {
                if let product = IAPCenter.shared.products.first(where: {$0.productIdentifier == ProductID.topup_100_a.rawValue}) {
                    IAPCenter.shared.buy(product: product)
                }
//            })
            
        })
        
        if !buyedIDs.contains(ProductID.topup_100_a.rawValue){
            self.rowModels.append(topup_100_aModel)
        }
        
        //循環錄影
        let tier_100Model = SettingCellRowModel(title: "購買解鎖循環錄影",
                                                imageName: "briefcase",
                                                showSwitch: false,
                                              cellDidSelect: { [weak self] _ in
//            self?.showAlert(title: "提示",
//                            message: "購買解鎖循環錄影\nID:\(ProductID.tier_100.rawValue)",
//                            confirmTitle: "前往購買",
//                            cancelTitle: "取消",
//                            confirmAction: {
                if let product = IAPCenter.shared.products.first(where: {$0.productIdentifier == ProductID.tier_100.rawValue}) {
                    IAPCenter.shared.buy(product: product)
                }
//            })
            
        })
        
        if !buyedIDs.contains(ProductID.tier_100.rawValue){
            self.rowModels.append(tier_100Model)
        }
        
//        //時間限制
        let buymaxTimeModel = SettingCellRowModel(title: "購買解鎖時間限制",
                                                imageName: "briefcase",
                                                showSwitch: false,
                                              cellDidSelect: { [weak self] _ in
//            self?.showAlert(title: "提示",
//                            message: "購買解鎖時間限制\nID:\(ProductID.maxTime.rawValue)",
//                            confirmTitle: "前往購買",
//                            cancelTitle: "取消",
//                            confirmAction: {
                if let product = IAPCenter.shared.products.first(where: {$0.productIdentifier == ProductID.maxTime.rawValue}) {
                    IAPCenter.shared.buy(product: product)
                }
//            })

        })

        if !buyedIDs.contains(ProductID.maxTime.rawValue){
            self.rowModels.append(buymaxTimeModel)
        }
        
        //完成時通知
        let buynoticeModel = SettingCellRowModel(title: "購買解鎖錄影完成時通知",
                                                imageName: "briefcase",
                                                showSwitch: false,
                                              cellDidSelect: { [weak self] _ in
//            self?.showAlert(title: "提示",
//                            message: "購買解鎖錄影完成時通知\nID:\(ProductID.notice.rawValue)",
//                            confirmTitle: "前往購買",
//                            cancelTitle: "取消",
//                            confirmAction: {
                if let product = IAPCenter.shared.products.first(where: {$0.productIdentifier == ProductID.notice.rawValue}) {
                    IAPCenter.shared.buy(product: product)
                }
//            })

        })

        if !buyedIDs.contains(ProductID.notice.rawValue){
            self.rowModels.append(buynoticeModel)
        }

//        //深色模式
        let buydarkModel = SettingCellRowModel(title: "購買切換深色模式",
                                                imageName: "briefcase",
                                                showSwitch: false,
                                              cellDidSelect: { [weak self] _ in
//            self?.showAlert(title: "提示",
//                            message: "購買切換深色模式\nID:\(ProductID.darkMode.rawValue)",
//                            confirmTitle: "前往購買",
//                            cancelTitle: "取消",
//                            confirmAction: {
                if let product = IAPCenter.shared.products.first(where: {$0.productIdentifier == ProductID.darkMode.rawValue}) {
                    IAPCenter.shared.buy(product: product)
                }
//            })

        })
        if !buyedIDs.contains(ProductID.darkMode.rawValue){
            self.rowModels.append(buydarkModel)
        }
//
//        //開啟密碼
        let buypasswordModel = SettingCellRowModel(title: "購買切換開啟密碼",
                                                imageName: "briefcase",
                                                showSwitch: false,
                                              cellDidSelect: { [weak self] _ in
//            self?.showAlert(title: "提示",
//                            message: "購買切換深色模式\nID:\(ProductID.password.rawValue)",
//                            confirmTitle: "前往購買",
//                            cancelTitle: "取消",
//                            confirmAction: {
                if let product = IAPCenter.shared.products.first(where: {$0.productIdentifier == ProductID.password.rawValue}) {
                    IAPCenter.shared.buy(product: product)
                }
//            })

        })

//        if !buyedIDs.contains(ProductID.notice.rawValue){
//            self.rowModels.append(buypasswordModel)
//        }
        

        //恢復購買紀錄
        let reBuyRowModel = SettingCellRowModel(title: "恢復購買紀錄",
                                                imageName: "briefcase",
                                                showSwitch: false,
                                                cellDidSelect: { [weak self] _ in
            self?.showToast(message: "購買紀錄已恢復")
            SKPaymentQueue.default().restoreCompletedTransactions()
        })
        
        self.rowModels.append(reBuyRowModel)
        
        
        self.adapter?.updateTableViewData(rowModels: rowModels)
    }
    
    func pushToGridView() {
        let gridViewController = GridViewController()
        self.navigationController?.pushViewController(gridViewController, animated: true)
    }
    
    func showPasswordAlert(isON: Bool, fromSwitch: Bool) {
        self.showInputDialog(title: "提示",
                             subtitle: "請輸入新密碼",
                             actionTitle: "確認",
                             cancelTitle: "取消",
                             inputPlaceholder: "請輸入密碼",
                             inputKeyboardType: .numberPad,
                             cancelHandler: { [weak self] _ in
            if isON, fromSwitch {
                UserInfoCenter.shared.storeValue(.needPassword, data: false)
                self?.setupRowModel()
            }
        },
                             actionHandler: { [weak self] password in
            if let password = password {
                UserInfoCenter.shared.storeValue(.password, data: password)
                self?.setupRowModel()
            }
        })
    }
    
    func showVideoTimeAlert() {
        self.showInputDialog(title: "提示",
                             subtitle: "請輸入限制時間(秒)",
                             actionTitle: "確認",
                             cancelTitle: "取消",
                             inputPlaceholder: "請輸入上限時間(秒)",
                             inputKeyboardType: .numberPad,
                             cancelHandler: nil,
                             actionHandler: { [weak self] time in
            if let time = Int(time ?? "") {
                UserInfoCenter.shared.storeValue(.videoMaxTime, data: time)
                self?.setupRowModel()
            }
        })
    }
    
    func pushToSelectVC(title: String,dataSource: [CodeModel], seletedModel: [CodeModel], confirmAction:(([CodeModel])->())?) {
        let vc = SelectViewController()
        vc.navigationtitle = title
        vc.dataSourceModels = dataSource
        vc.selectedModels = seletedModel
        vc.confirmAction = confirmAction
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func getAllfileURL() -> [URL] {
        var urls: [URL] = []
        do {
            let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            if let path = documentURL {
                urls = try FileManager.default.contentsOfDirectory(at: path, includingPropertiesForKeys: nil, options: [])
                return urls
            }
        }
        catch {
            print(error.localizedDescription)
        }
        return urls
    }
    
    func removeFile(complete: (()->())?) {
        
        for url in self.getAllfileURL(){
            if FileManager.default.fileExists(atPath: url.path) {
                do {
                    try FileManager.default.removeItem(at: url)
                } catch {
                    print("remove failed")
                }
            }
        }
        complete?()
    }
    
}
