//
//  LoadMore.swift
//  GSRefresh
//  https://github.com/wxxsw/GSRefresh
//
//  Created by GeSen on 2017/5/20.
//
//  Copyright © 2017 GeSen <i@gesen.me>
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

import Foundation

public protocol CustomLoadMoreView {
    
    /// -top: increase the distance from scrollview.
    /// -left and right: set the horizontal offset.
    /// -bottom: increase the trigger refresh distance.
    var edgeInsets: UIEdgeInsets { get }
    
    /**
     In this method, set the UI in different states.
     There are three status types: initial, refreshing, noMore.
     
     - parameter previous: previous load more state
     - parameter newState: new load more state
     */
    func loadMoreStateChanged(previous: LoadMoreState, newState: LoadMoreState)
}

public extension LoadMore {
    
    /**
     Set up a custom refresh view and handler.
     */
    @discardableResult
    func setup<T: CustomLoadMoreView>(view: T, handler: @escaping () -> Void) -> Self where T: UIView {
        self.view = view
        self.handler = handler
        return self
    }
    
    /**
     Immediately trigger the refresh state.
     */
    func beginRefreshing() {
        loadMoreState = .refreshing
    }
    
    /**
     End the refresh state.
     */
    func endRefreshing() {
        loadMoreState = .initial
    }
    
}

public enum LoadMoreState {
    
    /// when the load more view is not displayed.
    case initial
    
    /// refreshing and load the data.
    case refreshing
    
    /// no more data.
    case noMore
    
}

public class LoadMore: Observer {
    
    // MARK: Properties
    
    var loadMoreState: LoadMoreState = .initial {
        didSet {
            if oldValue != loadMoreState {
                loadMoreStateChanged(previous: oldValue,
                                     newState: loadMoreState)
            }
        }
    }
    
    // MARK: Helper Properties
    
    /// The custom refresh view.
    var custom: CustomLoadMoreView? {
        return view as? CustomLoadMoreView
    }
    
    /// The topmost position of the refresh view.
    var topside: CGFloat {
        return -observerState.insets.top + -outside.height
    }
    
    /// The total size of the refresh view and the margin.
    var outside: CGSize {
        guard let view = view else {
            return .zero
        }
        guard let insets = custom?.edgeInsets else {
            return view.bounds.size
        }
        return CGSize(
            width: insets.left + view.bounds.width + insets.right,
            height: insets.top + view.bounds.height + insets.bottom
        )
    }
    
    /// The absolute position of the refresh view in scrollview.
    var viewFrame: CGRect {
        guard let maxW = scrollView?.bounds.width,
            let view = view else {
                return .zero
        }
        guard let insets = custom?.edgeInsets else {
            return CGRect(
                x: (maxW - view.bounds.width) / 2,
                y: topside,
                width: view.bounds.width,
                height: view.bounds.height
            )
        }
        return CGRect(
            x: (maxW - view.bounds.width) / 2 + (insets.right - insets.left),
            y: topside + insets.top,
            width: view.bounds.width,
            height: view.bounds.height
        )
    }
    
    /// The fraction of the pulling state.
    var pullingFraction: CGFloat {
        return (observerState.offset.y + (scrollView?.insets.top ?? 0)) / -outside.height
    }
    
}

// MARK: - State Changed

extension LoadMore {
    
    func loadMoreStateChanged(previous: LoadMoreState, newState: LoadMoreState) {
        
        guard let scrollView = scrollView, let view = view else {
            return
        }
        
        custom?.loadMoreStateChanged(previous: previous, newState: newState)
    }
    
}

// MARK: - ScrollView State Changed

extension LoadMore: ObserverDelegate {
    
    func observerStateChanged(previous: Observer.ObserverState,
                              newState: Observer.ObserverState) {
        
        guard loadMoreState != .refreshing else {
            return
        }
    }
    
}

// MARK: - Equatable

extension LoadMoreState: Equatable {}

public func ==(lhs: LoadMoreState, rhs: LoadMoreState) -> Bool {
    switch (lhs, rhs) {
    case (.initial, .initial):                  return true
    case (.noMore, .noMore):                    return true
    case (.refreshing, .refreshing):            return true
    default:                                    return false
    }
}
