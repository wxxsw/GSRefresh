//
//  TableViewController.swift
//  Example
//
//  Created by GeSen on 2017/9/2.
//  Copyright © 2017年 GeSen <i@gesen.me>. All rights reserved.
//

import UIKit
import GSRefresh

class TestView: UIView, CustomRefreshView {
    
    let label = UILabel()
    
    var edgeInsets: UIEdgeInsets = .zero
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        label.text = "测试测试测试"
        label.sizeToFit()
        addSubview(label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = bounds
    }
    
    func refreshStateChanged(previous: RefreshState, newState: RefreshState) {
        switch newState {
        case .initial: label.textColor = .red
        case .pulling: label.textColor = .gray
        case .refreshing: label.textColor = .green
        }
    }
    
}

class TableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let test = TestView(frame: CGRect(x: 0, y: 0, width: 100, height: 40))
        
        tableView
            .refresh
            .setup(view: test) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                    self?.tableView.refresh.endRefreshing()
                }
            }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        tableView.refresh
//            .view(UIRefreshControl())
//            .beginRefreshing()
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
