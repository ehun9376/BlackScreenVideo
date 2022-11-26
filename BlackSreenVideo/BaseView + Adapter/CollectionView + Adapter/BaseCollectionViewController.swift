//
//  BaseCollectionViewController.swift
//  TintTint
//
//  Created by yihuang on 2022/10/20.
//

import Foundation
import UIKit

class BaseCollectionViewController: BaseViewController {
    
    lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: self.view.bounds, collectionViewLayout: creatLayout())
        return view
    }()
    
    var adapter: CollectionViewAdapter?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(collectionView)
        self.setupAdapter()
    }
    
    func creatLayout() -> UICollectionViewFlowLayout {
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .vertical
        
        return layout
    }
    
    func setupAdapter() {
        self.adapter = .init(collectionView: self.collectionView)
        self.adapter?.lastCellDidDisplay = { [weak self] page in
            guard let self = self else { return }
            self.lastCellWillDisplay(page: page)
        }
    }
    
    func lastCellWillDisplay(page:Int){ }
    
}
