//
//  Refresh.swift
//  GSRefresh
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
    func pulling(fraction: CGFloat)
    func refreshing()
}

public class Refresh: Observer {
    
    public enum State {
        case initial
        case pulling
        case refreshing
    }
    
    // MARK: - Public property
    
    
    
    // MARK: - Internal property
    
    var state: State {
        didSet {
            switch state {
            case .initial:      break
            case .pulling:      customRefresh?.pulling(fraction: fraction)
            case .refreshing:   customRefresh?.refreshing()
            }
        }
    }
    
    var beforeInset: Inset = .zero
    
    var customRefresh: CustomRefresh? {
        return view as? CustomRefresh
    }
    
    var fraction: CGFloat {
        return offset.y / viewTop
    }
    
    var viewTop: CGFloat {
        return -beforeInset.top + -viewHeight
    }
    
    // MARK: - Initialize function
    
    override init(scrollView: UIScrollView) {
        self.state = .initial
        super.init(scrollView: scrollView)
        
        didScroll = { scrollView, view in
            
            if self.fraction >= 0 && self.state != .refreshing {
                self.state = .pulling
            }
        }
        
        didLayout = { scrollView, view in
            
            
            
        }
        
        didDraging = { scrollView, view in
            
            switch self.dragState {
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
                
            default:
                break
            }
        }
    }
    
    // MARK: - Control function
    
    public func beginRefreshing() {
        inset.top = self.viewHeight + self.beforeInset.top
        state = .refreshing
    }
    
    public func endRefreshing() {
        inset.top = self.beforeInset.top
        state = .initial
    }
    
}
