//
//  ViewController.swift
//  Example
//
//  Created by Gesen on 2017/5/14.
//  Copyright © 2017年 GeSen. All rights reserved.
//

import UIKit
import GSRefresh

class ViewController: UIViewController {
    
    let tableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.frame = view.bounds
        tableView.contentInset = .init(top: 10, left: 0, bottom: 0, right: 0)
        view.addSubview(tableView)
        
        let label = UILabel()
        
        label.text = "测试测试测试"
        label.sizeToFit()
        
        tableView.refresh.view = UIRefreshControl()
    }


}

