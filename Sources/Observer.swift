//
//  Observer.swift
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

protocol ObserverDelegate {
    func observerStateChanged(previous: Observer.ObserverState,
                              newState: Observer.ObserverState)
}

public class Observer: UIView {
    
    enum KeyPath {
        static let contentOffset = "contentOffset"
        static let contentSize   = "contentSize"
        static let state         = "state"
    }
    
    struct ObserverState {
        var offset: Offset = .zero
        var size: Size = .zero
        var dragState: DragState = .possible
        var isObserving: Bool = false
    }
    
    // MARK: Properties
    
    weak var scrollView: UIScrollView?
    
    var view: UIView? {
        didSet {
            view != nil ? startObserver() : stopObserver()
        }
    }
    
    var handler: (() -> Void)?
    
    var observerState = ObserverState() {
        didSet {
            guard observerState != oldValue else { return }
            
            (self as? ObserverDelegate)?
                .observerStateChanged(previous: oldValue,
                                      newState: observerState)
        }
    }

    // MARK: Initialization

    init(scrollView: UIScrollView) {
        self.scrollView = scrollView
        super.init(frame: .zero)
        scrollView.addSubview(self)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        stopObserver()
    }
    
    public override func willMove(toWindow newWindow: UIWindow?) {
        if newWindow == nil {
            stopObserver()
        }
    }
    
    // MARK: KVO
    
    override public func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey : Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        guard scrollView != nil, view != nil,
              let keyPath = keyPath,
              let change = change
              else { return }
        
        switch keyPath {
            
        case KeyPath.contentOffset:
            
            guard let newValue = change[.newKey] as? Offset else { return }
            
            observerState.offset = newValue
            
        case KeyPath.contentSize:
            
            guard let newValue = change[.newKey] as? Size else { return }
            
            observerState.size = newValue
            
        case KeyPath.state:
            
            guard let newRawValue = change[.newKey] as? Int,
                  let newValue = DragState(rawValue: newRawValue)
                  else { return }
            
            observerState.dragState = newValue
            
        default: break
        }
    }
    
}

// MARK: - Private Functions

private extension Observer {
    
    func startObserver() {
        stopObserver()
        
        scrollView?.addObserver(self, forKeyPath: KeyPath.contentOffset, options: [.new], context: nil)
        scrollView?.addObserver(self, forKeyPath: KeyPath.contentSize, options: [.new], context: nil)
        scrollView?.panGestureRecognizer.addObserver(self, forKeyPath: KeyPath.state, options: [.new], context: nil)
        observerState.isObserving = true
    }
    
    func stopObserver() {
        guard observerState.isObserving else { return }
        
        scrollView?.removeObserver(self, forKeyPath: KeyPath.contentOffset)
        scrollView?.removeObserver(self, forKeyPath: KeyPath.contentSize)
        scrollView?.panGestureRecognizer.removeObserver(self, forKeyPath: KeyPath.state)
        observerState.isObserving = false
        
        handler = nil
    }

}

// MARK: - Equatable

extension Observer.ObserverState: Equatable {}

func ==(lhs: Observer.ObserverState, rhs: Observer.ObserverState) -> Bool {
    return lhs.dragState == rhs.dragState &&
           lhs.offset == rhs.offset &&
           lhs.size == rhs.size
}
