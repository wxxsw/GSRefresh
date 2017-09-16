//
//  Refresh.swift
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

public protocol CustomRefreshView {
    
    /// -top: increase the trigger refresh distance.
    /// -left and right: set the horizontal offset.
    /// -bottom: increase the distance from scrollview.
    var edgeInsets: UIEdgeInsets { get }
    
    /**
     In this method, set the UI in different states.
     There are three status types: initial, pulling, refreshing.
    
     - parameter previous: previous refresh state
     - parameter newState: new refresh state
    */
    func refreshStateChanged(previous: RefreshState, newState: RefreshState)
}

public extension Refresh {
    
    /**
     Set up a custom refresh view and handler.
    */
    @discardableResult
    func setup<T: CustomRefreshView>(view: T, handler: @escaping () -> Void) -> Self where T: UIView {
        self.view = view
        self.handler = handler
        return self
    }
    
    /**
     Immediately trigger the refresh state.
    */
    func beginRefreshing() {
        refreshState = .refreshing
    }
    
    /**
     End the refresh state.
    */
    func endRefreshing() {
        refreshState = .initial
    }
    
}

public enum RefreshState {
    
    /// when the pull is not started and refresh view is not displayed.
    case initial
    
    /// is pulling down, the refresh view shows, but not release.
    /// the associated value contains the fraction, not less than 0,
    /// but will be greater than 1.
    case pulling(fraction: CGFloat)
    
    /// refreshing and load the data.
    case refreshing

}

public class Refresh: Observer {
    
    // MARK: Properties
    
    var refreshState: RefreshState = .initial {
        didSet {
            if oldValue != refreshState {
                refreshStateChanged(previous: oldValue,
                                    newState: refreshState)
            }
        }
    }
    
    // MARK: Helper Properties
    
    /// The custom refresh view.
    var custom: CustomRefreshView? {
        return view as? CustomRefreshView
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

extension Refresh {
    
    func refreshStateChanged(previous: RefreshState, newState: RefreshState) {

        guard let scrollView = scrollView, let view = view else {
            return
        }
        
        if case .initial = previous {
            
            observerState.insets = scrollView.insets
            
            if view.superview == nil {
                
                view.frame = viewFrame
                
                scrollView.addSubview(view)
                
            } else {
                
                view.isHidden = false
                
            }
        }
        
        if case .pulling = previous {
            
            if newState == .initial {
                
                view.isHidden = true
            }
        }
        
        if case .refreshing = previous {
            
            if newState == .initial {
                
                UIView.animate(
                    withDuration: 0.25,
                    animations: {
                        scrollView.insets.top = self.observerState.insets.top
                    },
                    completion: {
                        if $0 { view.isHidden = true }
                    }
                )
            }
        }
        
        if case .refreshing = newState {
            
            UIView.animate(withDuration: 0.1) {
                scrollView.insets.top = abs(self.topside)
            }
            
            handler?()
        }
        
        custom?.refreshStateChanged(previous: previous, newState: newState)
    }
    
}

// MARK: - ScrollView State Changed

extension Refresh: ObserverDelegate {
    
    func observerStateChanged(previous: Observer.ObserverState,
                              newState: Observer.ObserverState) {
        
        guard refreshState != .refreshing else {
            return
        }
        
        if previous.size != newState.size {
            refreshState = .initial
        }
        
        if previous.offset != newState.offset {
            
            let pullingFraction = self.pullingFraction
            
            if pullingFraction > 0 {
                refreshState = .pulling(fraction: pullingFraction)
            } else {
                refreshState = .initial
            }
        }
        
        if previous.dragState != newState.dragState {
            
            if case .ended = newState.dragState {
                
                if pullingFraction >= 1 {
                    refreshState = .refreshing
                }
            }
        }
    }

}

// MARK: - Equatable

extension RefreshState: Equatable {}

public func ==(lhs: RefreshState, rhs: RefreshState) -> Bool {
    switch (lhs, rhs) {
    case (.initial, .initial):                  return true
    case (.pulling(let f1), .pulling(let f2)):  return f1 == f2
    case (.refreshing, .refreshing):            return true
    default:                                    return false
    }
}
