//
//  SelectViewController.swift
//  BlackSreenVideo
//
//  Created by yihuang on 2022/11/23.
//

import Foundation

class SelectViewController: BaseTableViewController {
    
    var selectedModels: [CodeModel] = []
    
    var dataSourceModels: [CodeModel] = []
    
    var confirmAction: (([CodeModel])->())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.regisCellID(cellIDs: [
            "SettingCell"
        ])
        
        self.setupRow()
    }
    
    func setupRow() {
        var rowModels: [CellRowModel] = []
        for model in dataSourceModels {
            
            let isSelected: Bool = self.selectedModels.contains(model)
            
            rowModels.append(SettingCellRowModel(title: model.text,
                                                 detail: nil,
                                                 //TODO: - 換圖
                                                 imageName: isSelected ? "checkmark" : "",
                                                 imageTintColor: (UserInfoCenter.shared.loadValue(.darkMode) as? Bool ?? false) ? .red : .black,
                                                 showSwitch: false,
                                                 switchON: false,
                                                 switchAction: nil,
                                                 cellDidSelect: { [weak self] _ in
                self?.selectedModels = [model]
                self?.setupRow()
            }))
        }
        self.adapter?.updateTableViewData(rowModels: rowModels)
    }
    
    override func setBottomButtons() -> [BottomBarButton] {
        
        let confirmButton: BottomBarButton = .createButtonModel(title: .confirm,
                                                                textColor: .red,
                                                                backgroundColor: .white,
                                                                borderColor: .red) {
            if let confirmAction = self.confirmAction{
                confirmAction(self.selectedModels)
                self.navigationController?.popViewController(animated: true)
            }
        }
        
        return [confirmButton]
    }
    
}
