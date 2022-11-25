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
    
    var fileCreateTime: String?
    
    var videoTime: String?
    
    var fileURL: URL?
    
    var deletebuttonAction: (()->())?

    
    init(
        image: UIImage?,
        fileName: String?,
        fileCreateTime: String?,
        videoTime: String?,
        fileURL: URL? = nil,
        deletebuttonAction: (()->())?,
        cellDidSelect: ((CellRowModel)->())?
    ){
        super.init()
        self.image = image
        self.fileName = fileName
        self.fileCreateTime = fileCreateTime
        self.videoTime = videoTime
        self.fileURL = fileURL
        self.deletebuttonAction = deletebuttonAction
        self.cellDidSelect = cellDidSelect
    }
    
}

class PreviewCell: UITableViewCell {
    
    @IBOutlet weak var deleteButton: UIButton!
    
    @IBOutlet weak var previewImageView: UIImageView!
    
    @IBOutlet weak var createTimeLabel: UILabel!
    
    @IBOutlet weak var videoTimeLabel: UILabel!
    
    var rowModel: PreviewCellRowModel?
    
    override func awakeFromNib() {
        
        self.createTimeLabel.font = .systemFont(ofSize: 17)
        self.createTimeLabel.numberOfLines = 0
        
        self.videoTimeLabel.font = .systemFont(ofSize: 17)
        self.videoTimeLabel.numberOfLines = 0
        
        self.deleteButton.addTarget(self, action: #selector(deleteButtonAction(_:)), for: .touchUpInside)
    }
    
    @objc func deleteButtonAction(_ sender: UIButton) {
        self.rowModel?.deletebuttonAction?()
    }
    
}
extension PreviewCell: CellViewBase {
    func setupCellView(rowModel: CellRowModel) {
        guard let rowModel = rowModel as? PreviewCellRowModel else { return }
        
        self.rowModel = rowModel
        
        self.previewImageView.image = rowModel.image?.resizeImage(targetSize: .init(width: 100, height: 100))
        
        self.createTimeLabel.text = "建立時間:" + (rowModel.fileCreateTime ?? "")
        
        self.videoTimeLabel.text = "影片時間:" + (rowModel.videoTime ?? "")
        
    }
}
