//
//  SettingCell.swift
//  BlackSreenVideo
//
//  Created by 陳逸煌 on 2022/11/23.
//

import Foundation
import UIKit

class SettingCellRowModel: CellRowModel {
    
    override func cellReUseID() -> String {
        return "SettingCell"
    }
    
    var title: String?
    
    var detail: String?
    
    var imageName: String?
    
    var showSwitch: Bool = false
    
    var switchON: Bool = true
    
    var switchAction: ((Bool)->())?
    
    init(
        title: String? = nil,
        detail: String? = nil,
        imageName: String? = nil,
        showSwitch: Bool = false,
        switchON: Bool = true,
        switchAction: ((Bool) -> ())? = nil,
        cellDidSelect: ((CellRowModel)->())? = nil) {
            super.init()
            self.title = title
            self.detail = detail
            self.imageName = imageName
            self.showSwitch = showSwitch
            self.switchAction = switchAction
            self.switchON = switchON
            self.cellDidSelect = cellDidSelect
        }
    
}

class SettingCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var detailLabel: UILabel!
    
    @IBOutlet weak var iconImageView: UIImageView!
    
    @IBOutlet weak var functionSwitch: UISwitch!
    
    var rowModel: SettingCellRowModel?
    
    override func awakeFromNib() {
        self.selectionStyle = .none
        
        self.titleLabel.font = .systemFont(ofSize: 17)
        
        self.detailLabel.font = .systemFont(ofSize: 14)
        self.detailLabel.textColor = .gray
        
        self.functionSwitch.addTarget(self, action: #selector(switchAction(_:)), for: .valueChanged)
        
    }
    
    @objc func switchAction(_ sender: UISwitch) {
        if let rowModel = self.rowModel {
            rowModel.switchAction?(sender.isOn)
        }
    }
    
}

extension SettingCell: CellViewBase {
    
    func setupCellView(rowModel: CellRowModel) {
        
        guard let rowModel = rowModel as? SettingCellRowModel else { return }
        
        self.rowModel = rowModel
        
        if let title = rowModel.title, title != "" {
            self.titleLabel.text = title
            self.titleLabel.isHidden = false
        } else {
            self.titleLabel.text = nil
            self.titleLabel.isHidden = true
        }
        
        if let detail = rowModel.detail, detail != "" {
            self.detailLabel.text = detail
            self.detailLabel.isHidden = false
        } else {
            self.detailLabel.text = nil
            self.detailLabel.isHidden = true
        }
        
        self.functionSwitch.isHidden = !rowModel.showSwitch
        self.functionSwitch.isOn = rowModel.switchON
        
        self.iconImageView.image = UIImage(named: rowModel.imageName ?? "")
        
    }
    
}
