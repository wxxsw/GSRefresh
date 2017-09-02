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
    
    /// top: increase the trigger refresh distance.
    /// left and right: set the horizontal offset.
    /// bottom: increase the distance from scrollview
    var edgeInsets: UIEdgeInsets { get }
    
    /*
     In this method, set the UI in different states.
    
     There are three status types: initial, pulling, refreshing.
    
     initial: when the pull is not started and refresh view is not displayed.
     pulling: is pulling down, the refresh view shows, but not release. the associated value contains the fraction, not less than 0, but will be greater than 1.
     refreshing: refreshing and load the data.
    */
    func refreshStateChanged(previous: Refresh.RefreshState,
                             newState: Refresh.RefreshState)
}

public extension Refresh {
    
    /*
     Set up a custom refresh view.
     */
    func view<T: CustomRefreshView>(_ value: T) -> Self where T: UIView {
        view = value
        return self
    }
    
    /*
     Immediately trigger the refresh state.
    */
    func beginRefreshing() {
        state.refreshState = .refreshing
    }
    
    /*
     End the refresh state.
    */
    func endRefreshing() {
        state.refreshState = .initial
    }
    
}

public class Refresh: Observer {
    
    public enum RefreshState {
        case initial
        case pulling(fraction: CGFloat)
        case refreshing
    }
    
    struct State {
        var refreshState: RefreshState = .initial
        var originalInsets: Insets = .zero
    }
    
    // MARK: Properties
    
    var state = State() {
        didSet {
            if oldValue != state {
                stateChanged(previous: oldValue, newState: state)
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
        return -state.originalInsets.top + -outside.height
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
    
}

// MARK: - State Changed

extension Refresh {
    
    func stateChanged(previous: State, newState: State) {

        guard let scrollView = scrollView else { return }
        guard let view = view else {
            print("GSRefresh: Please set custom refresh view use view(_:)!")
            return
        }
        
        if previous.refreshState != newState.refreshState {
            
            if case .initial = previous.refreshState {
                
                if view.superview == nil {
                    view.frame = viewFrame
                    scrollView.addSubview(view)
                }
                
            }
            
            if case .refreshing = previous.refreshState {
                
                if newState.refreshState == .initial {
                    scrollView.insets.top = state.originalInsets.top
                }
                
            }
            
            if case .refreshing = newState.refreshState {
                
                scrollView.insets.top = topside

            }
            
            custom?.refreshStateChanged(previous: previous.refreshState,
                                        newState: newState.refreshState)
        }
    }
    
}

// MARK: - ScrollView State Changed

extension Refresh: ObserverDelegate {
    
    func observerStateChanged(previous: Observer.ObserverState,
                              newState: Observer.ObserverState) {
        
        guard let scrollView = scrollView else { return }
        
        if previous.dragState != newState.dragState {
            
            guard state.refreshState != .refreshing else { return }
            
            switch newState.dragState {
                
            case .began:
                
                state.originalInsets = scrollView.insets
                
            case .ended:
                
                let fraction = newState.offset.y / topside
                
                if fraction >= 1 {
                    state.refreshState = .refreshing
                }
                
            default: break
            }
        }
        
        if previous.offset != newState.offset {
            
            guard state.refreshState != .refreshing else { return }
            
            let fraction = newState.offset.y / topside
            
            if fraction >= 0 {
                state.refreshState = .pulling(fraction: fraction)
            } else {
                state.refreshState = .initial
            }
        }
        
    }
    
}

// MARK: - Equatable

extension Refresh.State: Equatable {}
extension Refresh.RefreshState: Equatable {}

func ==(lhs: Refresh.State, rhs: Refresh.State) -> Bool {
    return lhs.originalInsets == rhs.originalInsets &&
           lhs.refreshState == rhs.refreshState
}

public func ==(lhs: Refresh.RefreshState, rhs: Refresh.RefreshState) -> Bool {
    switch (lhs, rhs) {
    case (.initial, .initial):                  return true
    case (.pulling(let f1), .pulling(let f2)):  return f1 == f2
    case (.refreshing, .refreshing):            return true
    default:                                    return false
    }
}

// MARK: - UIRefreshControl+CustomRefreshView {

extension UIRefreshControl: CustomRefreshView {
    public var edgeInsets: UIEdgeInsets { return .zero }
    public func refreshStateChanged(previous: Refresh.RefreshState, newState: Refresh.RefreshState) {}
}
