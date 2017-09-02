//
//  TableViewController.swift
//  Example
//
//  Created by GeSen on 2017/9/2.
//  Copyright © 2017年 GeSen <i@gesen.me>. All rights reserved.
//

import UIKit
import GSRefresh

class TableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let label = UILabel()
        
        label.text = "测试测试测试"
        label.sizeToFit()
        
        tableView.refresh.view(UIRefreshControl()).beginRefreshing()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.tableView.refresh.endRefreshing()
        }
    }
    
    deinit {
        print("safe deinit")
    }
    
}

// MARK: - TableView data source

extension TableViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell",
                                                 for: indexPath)

        cell.textLabel?.text = "\(indexPath.row)"
        
        return cell
    }
}
