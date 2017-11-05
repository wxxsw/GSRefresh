//
//  BasicDefaultView.swift
//  Example
//
//  Created by GeSen on 2017/11/1.
//  Copyright © 2017年 GeSen <i@gesen.me>. All rights reserved.
//

import UIKit
import GSRefresh

class BasicDefaultView: UIView {
    
    let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        label.textAlignment = .center
        addSubview(label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        label.frame = bounds
    }
    
}

extension BasicDefaultView: CustomRefresh {
  
  func refreshStateChanged(previous: RefreshState, newState: RefreshState) {
    switch newState {
    case .initial:
      label.text = ""
    case .pulling(let fraction):
      if fraction < 1.0 {
        label.text = "Pull down to refresh..."
      } else {
        label.text = "Release to refresh..."
      }
    case .refreshing:
      label.text = "Refreshing..."
    }
  }
  
}

extension BasicDefaultView: CustomLoadMore {
  
  func loadMoreStateChanged(previous: LoadMoreState, newState: LoadMoreState) {
    switch newState {
    case .initial:
      label.text = ""
    case .refreshing:
      label.text = "Refreshing..."
    case .noMore:
      label.text = "No more data!"
    }
  }
  
}
