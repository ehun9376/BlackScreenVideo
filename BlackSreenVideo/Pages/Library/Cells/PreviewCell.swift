//
//  PreviewCell.swift
//  BlackSreenVideo
//
//  Created by 陳逸煌 on 2022/11/25.
//

import Foundation
import UIKit

class PreviewCellRowModel: CellRowModel {
    override func cellReUseID() -> String {
        return "PreviewCell"
    }
    
    var image: UIImage?
    
    var fileName: String?
    
    var fileURL: URL?
    
    init(
        image: UIImage?,
        fileName: String?,
        fileURL: URL? = nil,
        cellDidSelect: ((CellRowModel)->())?
    ){
        super.init()
        self.image = image
        self.fileName = fileName
        self.fileURL = fileURL
        self.cellDidSelect = cellDidSelect
    }
    
}

class PreviewCell: UITableViewCell {
    
    @IBOutlet weak var previewImageView: UIImageView!
    
    @IBOutlet weak var fileNameLabel: UILabel!
    
    override func awakeFromNib() {
        self.fileNameLabel.font = .systemFont(ofSize: 17)
    }
    
}
extension PreviewCell: CellViewBase {
    func setupCellView(rowModel: CellRowModel) {
        guard let rowModel = rowModel as? PreviewCellRowModel else { return }
        self.previewImageView.image = rowModel.image?.resizeImage(targetSize: .init(width: 100, height: 100))
        self.fileNameLabel.text = rowModel.fileName
    }
}
