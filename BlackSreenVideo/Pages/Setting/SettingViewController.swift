//
//  SettingViewController.swift
//  BlackSreenVideo
//
//  Created by yihuang on 2022/11/23.
//

import Foundation

class SettingViewController: BaseTableViewController {
    
    var rowModels: [CellRowModel] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.regisCellID(cellIDs: [
            "SettingCell"
        ])
        
        self.setupRowModel()
    }
    
    func setupRowModel() {
        
        self.rowModels.removeAll()
        
        //相機
        let caremaCodeModel = CodeModel.cameraLocation.first(where: {$0.number == UserInfoCenter.shared.loadValue(.cameraLocation) as? Int}) ?? .init()
        let caremaRowModel = SettingCellRowModel(title: "相機",
                                                 detail: caremaCodeModel.text,
                                                 imageName: "",
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
        
        //時間限制
        let time = UserInfoCenter.shared.loadValue(.videoMaxTime) as? Int ?? 0
        let videoMaxTimeRowModel = SettingCellRowModel(title: String(format: "時間限制(%d分鐘%d秒)",time / 60 ,time % 60),
                                                       detail: "限制錄影時間",
                                                       imageName: "",
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
                                                       imageName: "",
                                                       showSwitch: true,
                                                       switchON: UserInfoCenter.shared.loadValue(.cycleRecoding) as? Bool ?? false,
                                                       switchAction: { isON in
            UserInfoCenter.shared.storeValue(.cycleRecoding, data: isON)
        },
                                                       cellDidSelect: nil)
        self.rowModels.append(cycleRecodingRowModel)
        
        
        
        //密碼
        let passWordRowModel = SettingCellRowModel(title: "是否需要開啟密碼",
                                                   detail: UserInfoCenter.shared.loadValue(.password) as? String ?? "",
                                                   imageName: "",
                                                   showSwitch: true,
                                                   switchON: UserInfoCenter.shared.loadValue(.needPassword) as? Bool ?? false,
                                                   switchAction: { [weak self] isON in
            UserInfoCenter.shared.storeValue(.needPassword, data: isON)
            if isON, UserInfoCenter.shared.loadValue(.password) == nil {
                self?.showPasswordAlert()
            }
        },
                                                   cellDidSelect: { [weak self] rowModel in
            self?.showPasswordAlert()
        })
        self.rowModels.append(passWordRowModel)
        
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
    
}
