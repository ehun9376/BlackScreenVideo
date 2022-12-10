//
//  GridViewController.swift
//  BlackSreenVideo
//
//  Created by yihuang on 2022/11/26.
//

import Foundation
import UIKit

class AppImageModel: NSObject {
    
    var image: UIImage?
    
    var imageName: AppIcon?
    
    init(image: UIImage? = nil,
         imageName: AppIcon? = nil) {
        self.image = image
        self.imageName = imageName
    }
    
}

class GridViewController: BaseCollectionViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.regisCell()
        self.setupItemModel()
    }
    
    func setupItemModel() {
        
        var itemModels: [CollectionItemModel]? = []
        
        let appModels: [AppImageModel] = [
            .init(image: UIImage(named: "ball1"), imageName: .ball1Icon),
            .init(image: UIImage(named: "mail1"), imageName: .mail1Icon),
            .init(image: UIImage(named: "message1"), imageName: .message1Icon),
            .init(image: UIImage(named: "oil1"), imageName: .oilIcon),
            .init(image: UIImage(named: "oil21"), imageName: .oil2Icon),
            .init(image: UIImage(named: "youtube1"), imageName: .youtubeIcon),
        ]
        

        
        let width = self.view.frame.width / 3
        
        for appModel in appModels {
            let itemModel: ImageCellItemModel = .init(image: appModel.image?.resizeImage(targetSize: .init(width: width, height: width)),
                                                      imageName: appModel.imageName,
                                                      itemSize: .init(width: width, height: width),
                                                      cellDidPressed: { _ in
                if let image = appModel.imageName {
                    IconManager.shared.changeAppIcon(to: image)
                }
//                self?.showSingleAlert(title: "提示",
//                                      message: "你的AppIcon已更換",
//                                      confirmTitle: "確定",
//                                      confirmAction: nil)
            })
            itemModels?.append(itemModel)
        }
        
        self.adapter?.updateData(itemModels: itemModels ?? [])
    }
    
    func regisCell(){
        self.collectionView.register(.init(nibName: "ImageCell", bundle: nil), forCellWithReuseIdentifier: "ImageCell")
    }
    
    
}
