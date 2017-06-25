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

public class Refresh: Observer {
    
    public enum State {
        case `default`
        case pulling
        case refreshing
    }
    
    // MARK: -
    
    public internal(set) var state: State
    
    // MARK: -
    
    override init(scrollView: UIScrollView) {
        self.state = .default
        super.init(scrollView: scrollView)
        
        didScroll = { scrollView in
            
            
            
        }
        
        didLayout = { scrollView in
            
            if let view = self.view {
                scrollView.addSubview(view)
            }
            
        }
        
        didDraging = { scrollView in
            
            
            
        }
    }
    
    // MARK: -
    
    public func begin() {
        state = .refreshing
    }
    
    public func end() {
        state = .default
    }
    
}
