//
//  CollectionAdapter.swift
//  TintTint
//
//  Created by yihuang on 2022/10/20.
//

import Foundation
import UIKit

class CollectionViewAdapter: NSObject {
    
    weak var collectionView: UICollectionView?
    
    var page: Int = 0
    
    var needKeepLoading: Bool = true
    
    var itemModels: [CollectionItemModel]? = []
    
    var lastCellDidDisplay: ((Int) -> ())?
        
    init(collectionView: UICollectionView) {
        super.init()
        self.collectionView = collectionView
        self.collectionView?.delegate = self
        self.collectionView?.dataSource = self
    }
    
    func updateData(itemModels: [CollectionItemModel]) {
        
        self.itemModels = itemModels
        
        self.collectionView?.reloadData()
    }
    
    func insertItemAtLast(itemModels: [CollectionItemModel]) {
        
        self.itemModels?.append(contentsOf: itemModels)
        
        DispatchQueue.main.async {
            self.collectionView?.reloadData()
        }
        
    }
    
}

extension CollectionViewAdapter: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if let itemModels = self.itemModels {
            return itemModels.count
        } else {
            return 0
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let itemModel = self.itemModels?[indexPath.item] else { return UICollectionViewCell() }
        
        itemModel.indexPath = indexPath
        itemModel.collectionView = collectionView
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: itemModel.cellReUseID(), for: indexPath)
        
        if let cell = cell as? BaseCellView {
            cell.setupCellView(model: itemModel)
        }
        
        if needKeepLoading, indexPath.item + 1 == self.itemModels?.count, let lastCellDidDisplay = lastCellDidDisplay {
            self.page += 1
            lastCellDidDisplay(self.page)
        }
        
        return cell
        
    }
    
}

extension CollectionViewAdapter: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        guard let itemModel = self.itemModels?[indexPath.item] else { return .zero }
        
        return itemModel.itemSize ?? .zero

    }
}

extension CollectionViewAdapter:UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let itemModel = self.itemModels?[indexPath.item] else { return }
        
        if let action = itemModel.cellDidPressed {
            action(itemModel)
        }
        
    }
}

