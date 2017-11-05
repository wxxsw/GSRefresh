//
//  TableViewController.swift
//  Example
//
//  Created by Gesen on 2017/9/2.
//  Copyright © 2017年 Gesen <i@gesen.me>. All rights reserved.
//

import UIKit
import GSRefresh

class TableViewController: UITableViewController {
    
    enum Page {
        case basic(Basic)
//        case advanced(Advanced)
        
        enum Basic {
            case `default`
        }
        
        enum Advanced {
            /// coming soon
        }
    }
    
    var page: Page = .basic(.default)
    
    var count = 30
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let refreshView: CustomRefreshView
        let loadMoreView: CustomLoadMoreView
        
        switch page {
            
        case .basic(let type):
            
            switch type {
            case .default:
                let frame = CGRect(x: 0, y: 0, width: 300, height: 40)
                refreshView = BasicDefaultView(frame: frame)
                loadMoreView = BasicDefaultView(frame: frame)
            }

        }
        
        tableView.refresh.setup(view: refreshView) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                guard let this = self else { return }
                
                this.count = 30
                this.tableView.reloadData()
                this.tableView.refresh.endRefreshing()
                this.tableView.loadMore.reset()
            }
        }
        
        tableView.loadMore.setup(view: loadMoreView) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                guard let this = self else { return }
                
                this.count += 30
                this.tableView.reloadData()
                this.tableView.loadMore.endRefreshing(noMore: this.count > 60)
            }
        }
    }
    
    deinit {
        print("safe deinit")
    }
    
}

// MARK: - TableView data source

extension TableViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell",
                                                 for: indexPath)

        cell.textLabel?.text = "\(indexPath.row)"
        
        return cell
    }
}
