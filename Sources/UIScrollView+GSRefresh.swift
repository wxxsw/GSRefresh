//
//  UIScrollView+GSRefresh.swift
//  GSRefresh
//  https://github.com/wxxsw/GSRefresh
//
//  Created by Gesen on 2017/6/12.
//
//  Copyright © 2017 Gesen <i@gesen.me>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import UIKit

public extension UIScrollView {
    
    public var refresh: Refresh {
        guard let refresh = objc_getAssociatedObject(self, &refreshKey) as? Refresh else {
            let newRefresh = Refresh(scrollView: self)
            objc_setAssociatedObject(self, &refreshKey, newRefresh, .OBJC_ASSOCIATION_RETAIN)
            return newRefresh
        }
        return refresh
    }
    
    public var loadMore: LoadMore {
        guard let loadMore = objc_getAssociatedObject(self, &loadMoreKey) as? LoadMore else {
            let newLoadMore = LoadMore(scrollView: self)
            objc_setAssociatedObject(self, &loadMoreKey, newLoadMore, .OBJC_ASSOCIATION_RETAIN)
            return newLoadMore
        }
        return loadMore
    }
    
}

extension UIScrollView {
    
    var dataCount: Int {
        var count = 0
        
        if let tableView = self as? UITableView {
            for section in 0 ..< tableView.numberOfSections {
                count += tableView.numberOfRows(inSection: section)
            }
        } else if let collectionView = self as? UICollectionView {
            for section in 0 ..< collectionView.numberOfSections {
                count += collectionView.numberOfItems(inSection: section)
            }
        }

        return count
    }
    
    var insets: Insets {
        get { return self.contentInset }
        set { self.contentInset = newValue }
    }
    
    @available(iOS 11.0, *)
    var adjustedInsets: Insets {
        return self.adjustedContentInset
    }
    
}

private var refreshKey: Void?
private var loadMoreKey: Void?
