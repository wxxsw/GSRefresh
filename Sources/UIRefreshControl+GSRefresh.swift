//
//  UIRefreshControl+GSRefresh.swift
//  GSRefresh
//
//  Created by GeSen on 2017/9/3.
//  Copyright © 2017年 GeSen. All rights reserved.
//

import UIKit

extension UIRefreshControl: CustomRefreshView {
    
    public var edgeInsets: UIEdgeInsets { return .zero }
    
    public func refreshStateChanged(previous: RefreshState,
                                    newState: RefreshState) {
        
        if previous == .initial, newState == .refreshing {
            beginRefreshing()
        }
        
        if previous == .refreshing, newState == .initial {
            endRefreshing()
        }
    }
}
