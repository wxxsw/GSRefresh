//
//  LoadMore.swift
//  GSRefresh
//  https://github.com/wxxsw/GSRefresh
//
//  Created by Gesen on 2017/5/20.
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

import Foundation

public typealias CustomLoadMoreView = CustomLoadMore & UIView

public protocol CustomLoadMore {
    
    /// @optional, default is 0.
    /// Set the preload configuration, such as half screen 0.5, one screen is 1, two screens are 2, no preload is 0.
    var preload: CGFloat { get }
    
    /// @optional, default is true.
    /// When there is no more data, is it necessary to keep the height of the custom view? If it is false, it will not be displayed.
    var isVisibleNoMore: Bool { get }
    
    /// @optional, default is .zero.
    /// -top: increase the distance from scrollview.
    /// -left and right: set the horizontal offset.
    /// -bottom: increase the distance from the bottom.
    var loadMoreInsets: UIEdgeInsets { get }
    
    /**
     In this method, set the UI in different states.
     There are three status types: initial, refreshing, noMore.
     
     - parameter previous: previous load more state
     - parameter newState: new load more state
     */
    func loadMoreStateChanged(previous: LoadMoreState, newState: LoadMoreState)
}

public extension CustomLoadMore {
    
    /// Default value
    var preload: CGFloat { return 0 }
    var isVisibleNoMore: Bool { return true }
    var loadMoreInsets: UIEdgeInsets { return .zero }
    
}

public extension LoadMore {
    
    /**
     Set up a custom refresh view and handler.
     */
    @discardableResult
    func setup(view: CustomLoadMoreView,
               handler: @escaping () -> Void) -> Self {
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
     End the refresh state and set whether no longer try to load new data.
     */
    func endRefreshing(noMore: Bool) {
        loadMoreState = noMore ? .noMore : .initial
    }
    
    /**
     Reset to continue loading data.
     */
    func reset() {
        loadMoreState = .initial
    }
    
    /**
     No longer try to load new data.
     */
    func noMore() {
        loadMoreState = .noMore
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
    
    public private(set) var loadMoreState: LoadMoreState = .initial {
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
        return observerState.size.height + observerState.insets.bottom
    }
    
    /// The total size of the refresh view and the margin.
    var outside: CGSize {
        guard let view = view else {
            return .zero
        }
        guard let insets = custom?.loadMoreInsets else {
            return view.bounds.size
        }
        return CGSize(
            width: view.bounds.width + insets.horizontal,
            height: view.bounds.height + insets.vertical
        )
    }
    
    /// The absolute position of the refresh view in scrollview.
    var viewFrame: CGRect {
        guard let maxW = scrollView?.bounds.width,
              let view = view else {
            return .zero
        }
        guard let insets = custom?.loadMoreInsets else {
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
    
    /// The fraction for refreshing.
    var fraction: CGFloat {
        return (topside - observerState.offset.y) / (scrollView?.bounds.height ?? 0) - 1
    }
    
}

// MARK: - State Changed

extension LoadMore {
    
    func loadMoreStateChanged(previous: LoadMoreState, newState: LoadMoreState) {
        
        guard let scrollView = scrollView, let view = view else {
            return
        }
        
        if case .initial = previous {
            
            if newState == .refreshing ||
              (newState == .noMore && custom?.isVisibleNoMore == true) {
                
                observerState.insets = scrollView.insets
                
                scrollView.insets.bottom += outside.height
                
                if view.superview == nil { scrollView.addSubview(view) }
                
                view.frame = viewFrame
                view.isHidden = false
            }
            
            if case .refreshing = newState {
                handler?()
            }
        }
        
        if case .initial = newState {
            
            view.isHidden = true
            scrollView.insets.bottom = observerState.insets.bottom
        }
        
        if case .refreshing = previous, newState == .noMore {
            
            if custom?.isVisibleNoMore == true {
                view.frame = viewFrame
            } else {
                view.isHidden = true
                scrollView.insets.bottom = observerState.insets.bottom
            }
        }
        
        custom?.loadMoreStateChanged(previous: previous, newState: newState)
    }
    
}

// MARK: - ScrollView State Changed

extension LoadMore: ObserverDelegate {
    
    func observerStateChanged(previous: Observer.ObserverState,
                              newState: Observer.ObserverState) {
        
        guard newState.size.height > 0 else {
            return
        }
        
        if loadMoreState == .initial {
            if previous.offset != newState.offset {
                if fraction - (custom?.preload ?? 0) <= 0 {
                    loadMoreState = .refreshing
                }
            }
        }
        
        if previous.size != newState.size {
            view?.frame = viewFrame
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
