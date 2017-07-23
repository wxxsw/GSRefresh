//
//  Observer.swift
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

public class Observer: NSObject {
    
    struct KeyPath {
        static let contentOffset = "contentOffset"
        static let contentSize   = "contentSize"
        static let state         = "state"
    }
    
    // MARK: - Public property
    
    public var view: UIView? {
        didSet { view != nil ? startObserver() : stopObserver() }
    }
    
    public var viewHeight: CGFloat {
        return (view?.bounds.height ?? 0)
    }
    
    // MARK: - Internal property
    
    weak var scrollView: UIScrollView?
    
    var didScroll: ObserverHandler?
    var didLayout: ObserverHandler?
    var didDraging: ObserverHandler?
    
    var offset: Offset = .zero
    var size: Size = .zero
    var dragState: DragState = .possible
    
    var inset: Inset {
        get { return scrollView?.contentInset ?? .zero }
        set { scrollView?.contentInset = newValue }
    }
    
    var isObserving: Bool
    
    // MARK: - Initialize function
    
    init(scrollView: UIScrollView) {
        self.scrollView = scrollView
        self.isObserving = false
    }
    
    deinit {
        didScroll = nil
        didLayout = nil
        didDraging = nil
        stopObserver()
    }
    
    // MARK: - Control function
    
    func startObserver() {
        stopObserver()
        
        scrollView?.addObserver(self, forKeyPath: KeyPath.contentOffset, options: [.old, .new], context: nil)
        scrollView?.addObserver(self, forKeyPath: KeyPath.contentSize, options: [.old, .new], context: nil)
        scrollView?.panGestureRecognizer.addObserver(self, forKeyPath: KeyPath.state, options: [.old, .new], context: nil)
        isObserving = true
    }
    
    func stopObserver() {
        guard isObserving else { return }
        
        scrollView?.removeObserver(self, forKeyPath: KeyPath.contentOffset)
        scrollView?.removeObserver(self, forKeyPath: KeyPath.contentSize)
        scrollView?.panGestureRecognizer.removeObserver(self, forKeyPath: KeyPath.state)
        isObserving = false
    }
    
    // MARK: - KVO function
    
    override public func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey : Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        guard
            let scrollView = scrollView,
            let view = view,
            let keyPath = keyPath,
            let change = change
            else { return }
        
        switch keyPath {
            
        case KeyPath.contentOffset:
            guard
                let oldValue = change[.oldKey] as? Offset,
                let newValue = change[.newKey] as? Offset,
                oldValue != newValue
                else { return }
            
            offset = newValue
            didScroll?(scrollView, view)
            
        case KeyPath.contentSize:
            guard
                let oldValue = change[.oldKey] as? Size,
                let newValue = change[.newKey] as? Size,
                oldValue != newValue
                else { return }
            
            size = newValue
            didLayout?(scrollView, view)
            
        case KeyPath.state:
            guard
                let oldRawValue = change[.oldKey] as? Int,
                let oldValue = DragState(rawValue: oldRawValue),
                let newRawValue = change[.newKey] as? Int,
                let newValue = DragState(rawValue: newRawValue),
                oldValue != newValue
                else { return }
            
            dragState = newValue
            didDraging?(scrollView, view)
            
        default: break
        }
    }
    
}
