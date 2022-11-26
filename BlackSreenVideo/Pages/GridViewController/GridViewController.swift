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
        
        var appModels: [AppImageModel] = [
            .init(image: UIImage(named: "pikachu"), imageName: .pikachuIcon),
            .init(image: UIImage(named: "charmander"), imageName: .charmanderIcon)
        ]
        

        
        let width = self.view.frame.width / 3
        
        for appModel in appModels {
            let itemModel: ImageCellItemModel = .init(image: appModel.image,
                                                      imageName: appModel.imageName,
                                                      itemSize: .init(width: width, height: width),
                                                      cellDidPressed: { [weak self] _ in
                IconManager.shared.changeAppIcon(to: appModel.imageName ?? .pikachuIcon)
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
