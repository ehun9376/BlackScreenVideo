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
        self.adapter = .init(self.defaultTableView)
        self.setDefaultTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setDefaultApp()
        KeyboardHelper.shared.registFor(viewController: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        KeyboardHelper.shared.unregist()
    }
    
    func setDefaultApp(){
        if #available(iOS 13.0, *) {
            let barAppearance = UINavigationBarAppearance()
            barAppearance.backgroundColor = .red
            barAppearance.shadowColor = .clear
            barAppearance.titleTextAttributes = [.foregroundColor:UIColor.white,.font: UIFont.systemFont(ofSize: 21)]
            navigationItem.standardAppearance = barAppearance
            navigationItem.scrollEdgeAppearance = barAppearance
        }

        if #available(iOS 15.0, *){
            UITableView.appearance().sectionHeaderTopPadding = 0
        }
    }
    
    func regisCell<celltype>(cellIDs: celltype){
        if let cellIDs = cellIDs as? [String]{
            for cellID in cellIDs {
                self.defaultTableView.register(UINib(nibName: cellID, bundle: nil), forCellReuseIdentifier: cellID)
            }
        }
        
        if let cellIDs = cellIDs as? [UITableViewCell.Type] {
            for cellID in cellIDs {
                self.defaultTableView.register(cellID, forCellReuseIdentifier: "\(cellID.self)")
            }
        }
        
    }
    
    func setDefaultTableView() {
        self.defaultTableView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.defaultTableView)
        self.defaultTableView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        self.defaultTableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.defaultTableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.defaultTableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor,constant: -80.0).isActive = true
        self.defaultTableView.backgroundColor = .white
    }


    
    
}

