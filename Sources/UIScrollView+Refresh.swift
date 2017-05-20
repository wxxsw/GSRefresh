//
//  UIScrollView+Refresh.swift
//  GSRefresh
//
//  Created by GeSen on 2017/5/20.
//  Copyright © 2017年 GeSen. All rights reserved.
//

import UIKit

extension UIScrollView: RefreshCompatible { }

extension GSRefresh where Base: UIScrollView {
    
    func begin() {
        
    }
    
    func end() {
        
    }
    
}

func test() {
    let tableView = UITableView()
    
    tableView.refresh.begin()
    tableView.refresh.end()
}
