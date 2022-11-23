//
//  ViewController.swift
//  Pet
//
//  Created by Kai on 2022/7/10.
//

import UIKit

class BaseTableViewController: BaseViewController {
    
    let defaultTableView = UITableView()
                
    var adapter: TableViewAdapter?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupDefaultTableView()
        self.setBottomBarView(buttons: self.setBottomButtons())
        self.adapter = .init(self.defaultTableView)
    }
    
    private func setupDefaultTableView() {
        self.defaultTableView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.defaultTableView)
        self.defaultTableView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        self.defaultTableView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.defaultTableView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        self.defaultTableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor,
                                                      constant: setBottomButtons().isEmpty
                                                      ? 0
                                                      : -self.defaultBottomBarHeight).isActive = true
//        self.defaultTableView.separatorStyle = .none
    }
    
    override func setBottomBarView(buttons: [BottomBarButton]) {
        guard !buttons.isEmpty else { return }
        //刪掉舊的東東
        for subView in self.view.subviews {
            if let subview = subView as? StackBottomBarView {
                subview.removeFromSuperview()
            }
        }
        
        let stackBottomView = StackBottomBarView(bottomBarButtons: buttons,style: self.setBottomBarStyle())
        stackBottomView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(stackBottomView)
        stackBottomView.topAnchor.constraint(equalTo: self.defaultTableView.bottomAnchor).isActive = true
        stackBottomView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        stackBottomView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        stackBottomView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
    }
    
    ///可丟[String] 或是 [UITableViewCell.Type]
    func regisCellID<cellType>(cellIDs: cellType) {
        
        if let ids = cellIDs as? [String] {
            for id in ids {
                self.defaultTableView.register(UINib(nibName: id,
                                                     bundle: nil),
                                               forCellReuseIdentifier: id)
            }
        }
        
        if let cells = cellIDs as? [UITableViewCell.Type] {
            for cell in cells {
                self.defaultTableView.register(cell, forCellReuseIdentifier: cell.description())
            }
        }
    }
    
    ///可丟[String] 或是 [UITableViewCell.Type]
    func regisHeaderFooterView<viewType>(viewIDs: viewType) {
        if let ids = viewIDs as? [String] {
            for id in ids {
                self.defaultTableView.register(UINib(nibName: id, bundle: nil), forHeaderFooterViewReuseIdentifier: id)
            }
        }
        
        if let views = viewIDs as? [UIView.Type] {
            for view in views {
                self.defaultTableView.register(view, forHeaderFooterViewReuseIdentifier: view.description())
            }
        }
    }

}

