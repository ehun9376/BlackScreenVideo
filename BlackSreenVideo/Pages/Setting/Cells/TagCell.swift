//
//  TagCell.swift
//  BlackSreenVideo
//
//  Created by 陳逸煌 on 2022/11/24.
//

import Foundation
import UIKit

class TagCellRowModel: CellRowModel {
    
    override func cellReUseID() -> String {
        return "TagCell"
    }
    
    var title: String?
    
    
    init(
        title: String? = nil,
        cellDidSelect: ((CellRowModel)->())? = nil) {
            super.init()
            self.title = title
            self.cellDidSelect = cellDidSelect
        }
    
}

class TagCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        self.selectionStyle = .none
        
        self.titleLabel.font = .systemFont(ofSize: 14)
        
    }

}

extension TagCell: CellViewBase {
    
    func setupCellView(rowModel: CellRowModel) {
        
        guard let rowModel = rowModel as? TagCellRowModel else { return }
                
        if let title = rowModel.title, title != "" {
            self.titleLabel.text = title
            self.titleLabel.isHidden = false
        } else {
            self.titleLabel.text = nil
            self.titleLabel.isHidden = true
        }
        
    }
    
}
