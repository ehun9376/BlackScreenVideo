//
//  CellProtocol.swift
//  BlackSreenVideo
//
//  Created by yihuang on 2022/11/26.
//

import Foundation
import UIKit

protocol BaseCellView {
    func setupCellView(model: BaseCellModel)
}

protocol BaseCellModel {
    func cellReUseID() -> String
}

class CollectionItemModel: BaseCellModel {
    
    var itemSize: CGSize?
    var indexPath: IndexPath?
    
    var cellDidPressed: ((CollectionItemModel?) -> ())?
    weak var collectionView: UICollectionView?

    func cellReUseID() -> String {
        fatalError("Need Override")
    }
    
    init(itemSize: CGSize? = nil, itemDidSelectAction: ((CollectionItemModel?) -> ())? = nil) {
        self.itemSize = itemSize
        if let itemDidSelectAction = itemDidSelectAction {
            self.cellDidPressed = itemDidSelectAction
        }
    }
    
    func updateCellView(){
        if let indexPath = self.indexPath {
            self.collectionView?.reloadItems(at: [indexPath])
        }
    }

}




class CellRowModel: BaseCellModel {
    func cellReUseID() -> String {
        fatalError("Need Override ")
    }
    var cellDidSelect: ((CellRowModel)->())?
    var indexPath: IndexPath?
    weak var tableView: UITableView?
    
    func updateCellView() {
        DispatchQueue.main.async {
            if let tableView = self.tableView {
                tableView.reloadRows(at: [self.indexPath ?? IndexPath()], with: .none)
            }
        }

    }
}
