//
//  ImageCell.swift
//  TintTint
//
//  Created by yihuang on 2022/10/20.
//

import Foundation
import UIKit

class ImageCellItemModel: CollectionItemModel {
    
    override func cellReUseID() -> String {
        return "ImageCell"
    }
        
    var image: UIImage?
    
    var imageName: AppIcon?
    
    init(
        image: UIImage?,
        imageName: AppIcon?,
        itemSize: CGSize? = nil,
        cellDidPressed: ((CollectionItemModel?) -> ())? = nil
    ) {
        super.init()
        self.image = image
        self.imageName = imageName
        self.itemSize = itemSize
        self.cellDidPressed = cellDidPressed
    }
}

class ImageCell: UICollectionViewCell {
    
    @IBOutlet weak var backImageView: UIImageView!
        
    override func awakeFromNib() {
        self.backImageView.layer.cornerRadius = 5
        self.clipsToBounds = true
    }

}

extension ImageCell: BaseCellView {
    func setupCellView(model: BaseCellModel) {
        guard let itemModel = model as? ImageCellItemModel else { return }
        
        self.backImageView.image = itemModel.image?.resizeImage(targetSize: itemModel.itemSize ?? .zero)

    }
}
