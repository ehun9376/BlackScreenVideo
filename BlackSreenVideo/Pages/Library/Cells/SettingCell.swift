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
}

class SettingCell: UITableViewCell {
    
}

extension SettingCell: CellViewBase {
    func setupCellView(rowModel: CellRowModel) {
        guard let rowModel = rowModel as? SettingCellRowModel else { return }
    }
}
