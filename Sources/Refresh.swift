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

public protocol CustomRefresh {
    
    var edgeInsets: UIEdgeInsets { get }
    
    func pulling(fraction: CGFloat)
    func refreshing()
}

public class Refresh: Observer {
    
    enum RefreshState {
        case initial
        case pulling(fraction: CGFloat)
        case refreshing
    }
    
    struct State {
        var refreshState: RefreshState = .initial
        var beforeInsets: Inset = .zero
    }
    
    // MARK: - Properties
    
    var state = State() {
        didSet {
            if oldValue != state {
                stateChanged(oldState: oldValue, newState: state)
            }
        }
    }
    
    // MARK: - Helper Properties
    
    var customRefresh: CustomRefresh? {
        return view as? CustomRefresh
    }
    
    var topside: CGFloat {
        return -state.beforeInsets.top + -outside.height
    }
    
    var outside: CGSize {
        guard let view = view else {
            return .zero
        }
        guard let insets = customRefresh?.edgeInsets else {
            return view.bounds.size
        }
        return CGSize(
            width: insets.left + view.bounds.width + insets.right,
            height: insets.top + view.bounds.height + insets.bottom
        )
    }
    
    var viewFrame: CGRect {
        guard let maxW = scrollView?.bounds.width,
            let view = view else {
                return .zero
        }
        guard let insets = customRefresh?.edgeInsets else {
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

// MARK: - Public Functions

public extension Refresh {
    
    func beginRefreshing() {
        state.refreshState = .refreshing
    }
    
    func endRefreshing() {
        state.refreshState = .initial
    }
    
}

// MARK: - State Changed

extension Refresh {
    
    func stateChanged(oldState: State, newState: State) {
        
        guard let scrollView = scrollView else { return }
        
        if oldState.refreshState != newState.refreshState {
            
            switch oldState.refreshState {
                
            case .initial:
                
                switch newState.refreshState {
                case .initial:
                    break
                case .pulling(let fraction):
                    break
                case .refreshing:
                }
                
            case .pulling(let f):
                
                switch newState.refreshState {
                case .initial:
                    break
                case .pulling(let fraction):
                    break
                case .refreshing:
                    break
                }
                
                customRefresh?.pulling(fraction: f)
                
            case .refreshing:
                
                switch newState.refreshState {
                case .initial:
                    scrollView.insets.top = self.beforeInsets.top
                case .pulling(let fraction):
                    break
                case .refreshing:
                    break
                }
                inset.top = self.viewHeight + self.beforeInset.top
                
                customRefresh?.refreshing()
                
            }
            
        }
        
    }
    
}

// MARK: - ScrollView State Changed

extension Refresh: ObserverDelegate {
    
    func observerStateChanged(oldState: Observer.ObserverState,
                              newState: Observer.ObserverState) {
        
        let viewHeight =
        let viewTop = -beforeInset.top + -viewHeight
        
        if oldState.offset != newState.offset {
            
            let fraction = newState.offset.y / topside
            
            if fraction >= 0 && self.state != .refreshing {
                self.state = .pulling
            }
            
        }
        
        if oldState.dragState != newState.dragState {
            
            switch newState.dragState {
                
            case .began:
                
                guard self.state != .refreshing else { return }
                
                self.beforeInset = self.inset
                
                if view.superview == nil {
                    scrollView.addSubview(view)
                }
                
                var newFrame = view.frame
                newFrame.origin.y = self.viewTop
                
                view.frame = newFrame
                
            case .ended:
                
                if self.fraction >= 1 {
                    self.inset.top = self.viewHeight + self.beforeInset.top
                    self.state = .refreshing
                }
                
            default: break
            }
            
        }
        
    }
    
}

// MARK: - Equatable

extension Refresh.State: Equatable {}
extension Refresh.RefreshState: Equatable {}

func ==(lhs: Refresh.State, rhs: Refresh.State) -> Bool {
    return lhs.beforeInset == rhs.beforeInset &&
           lhs.refreshState == rhs.refreshState
}

func ==(lhs: Refresh.RefreshState, rhs: Refresh.RefreshState) -> Bool {
    switch (lhs, rhs) {
    case (.initial, .initial):          return true
    case (.pulling, .pulling):          return true
    case (.refreshing, .refreshing):    return true
    default:                            return false
    }
}

