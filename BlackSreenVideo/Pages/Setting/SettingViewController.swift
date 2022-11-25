//
//  SettingViewController.swift
//  BlackSreenVideo
//
//  Created by yihuang on 2022/11/23.
//

import Foundation
import UIKit

class SettingViewController: BaseTableViewController {
    
    var rowModels: [CellRowModel] = []
    
    
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
    }
    
    func setupRowModel() {
        
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
            self?.pushToSelectVC(dataSource: CodeModel.cameraLocation,
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
            self?.pushToSelectVC(dataSource: CodeModel.videoDirection,
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
            self?.pushToSelectVC(dataSource: CodeModel.resolutions,
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
                                                        switchAction: { isON in
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
        self.rowModels.append(previewViewRowModel)
        
        //錄影完成時通知
        let recordingCompleteModel = SettingCellRowModel(title: "錄影完成",
                                                         detail: "停止錄影時顯示通知",
                                                         imageName: "bell",
                                                         showSwitch: true,
                                                         switchON: UserInfoCenter.shared.loadValue(.notifiyWhenComplete) as? Bool ?? false,
                                                         switchAction: { isON in
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
        
        self.rowModels.append(shakeWhenStartRowModel)
        
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
        self.rowModels.append(shakeWhenEndRowModel)
        
        //DarkMode
        let darkModeRowModel = SettingCellRowModel(title: "深色模式",
                                                   imageName: "circle.righthalf.filled",
                                                   showSwitch: true,
                                                   switchON: (UserInfoCenter.shared.loadValue(.darkMode) as? Bool ?? false),
                                                   switchAction: { isON in
            UserInfoCenter.shared.storeValue(.darkMode, data: isON)
            let scene = UIApplication.shared.connectedScenes.first
            
            if let delegate : SceneDelegate = (scene?.delegate as? SceneDelegate){
                delegate.window?.overrideUserInterfaceStyle = isON ? .dark : .light
                delegate.window?.makeKeyAndVisible()
            }
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
            UserInfoCenter.shared.storeValue(.needPassword, data: isON)
            if UserInfoCenter.shared.loadValue(.password) == nil {
                self?.showPasswordAlert()
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
            self?.showPasswordAlert()
        })
        
        self.rowModels.append(passWordRowModel)
        
        //購買紀錄
        let shopingTagRowModel = TagCellRowModel(title: "購買紀錄")
        self.rowModels.append(shopingTagRowModel)
        
        //恢復購買紀錄
        let reBuyRowModel = SettingCellRowModel(title: "恢復購買紀錄",
                                                imageName: "briefcase",
                                                showSwitch: false,
                                                cellDidSelect: { [weak self] _ in
            self?.showToast(message: "購買紀錄已恢復")
        })
        
        self.rowModels.append(reBuyRowModel)
        
        
        self.adapter?.updateTableViewData(rowModels: rowModels)
    }
    
    func showPasswordAlert() {
        self.showInputDialog(title: "提示",
                             subtitle: "請輸入新密碼",
                             actionTitle: "確認",
                             cancelTitle: "取消",
                             inputPlaceholder: "請輸入密碼",
                             inputKeyboardType: .numberPad,
                             cancelHandler: nil,
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
    
    func pushToSelectVC(dataSource: [CodeModel], seletedModel: [CodeModel], confirmAction:(([CodeModel])->())?) {
        let vc = SelectViewController()
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
                let directoryContents = try FileManager.default.contentsOfDirectory(at: path, includingPropertiesForKeys: nil, options: [])
                return directoryContents
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
