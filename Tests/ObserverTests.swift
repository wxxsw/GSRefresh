//
//  ObserverTests.swift
//  GSRefresh
//
//  Created by GeSen on 2017/6/18.
//  Copyright © 2017年 GeSen. All rights reserved.
//

import XCTest
@testable import GSRefresh

class ObserverTests: XCTestCase {
    
    var scrollView: UIScrollView!
    var observer: Observer!
    
    override func setUp() {
        super.setUp()
        scrollView = UIScrollView()
        observer = Observer(scrollView: scrollView)
        observer.view = UIRefreshControl()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testView() {
        XCTAssertTrue(observer.isObserving)
        observer.view = nil
        XCTAssertFalse(observer.isObserving)
    }
    
    func testDidScroll() {
        let expect = expectation(description: "")
        let toPoint = CGPoint(x: 5, y: 5)
        
        observer.didScroll = { scrollView in
            if self.observer.offset == toPoint {
                expect.fulfill()
            } else {
                expect.expectationDescription = "\(self.observer.offset)"
            }
        }
        
        scrollView.contentOffset = toPoint
        
        wait(for: [expect], timeout: 0.1)
    }
    
    func testDidLayout() {
        let expect = expectation(description: "")
        let toSize = CGSize(width: 100, height: 100)
        
        observer.didLayout = { scrollView in
            if self.observer.size == toSize {
                expect.fulfill()
            } else {
                expect.expectationDescription = "\(self.observer.size)"
            }
        }
        
        scrollView.contentSize = toSize
        
        wait(for: [expect], timeout: 0.1)
    }
    
    func testDidDraging() {
        let expect = expectation(description: "")
        let inset = Inset(top: 100, left: 0, bottom: 0, right: 0)
        
        observer.didDraging = { scrollView in
            if self.observer.dragState == DragState.began, self.observer.inset == inset {
                expect.fulfill()
            } else {
                expect.expectationDescription = "\(self.observer.dragState), \(self.observer.inset)"
            }
        }
        
        scrollView.contentInset = inset
        
        XCTAssert(observer.inset == .zero)
        
        observer.observeValue(forKeyPath: Observer.KeyPath.state, of: nil, change: [.oldKey: UIGestureRecognizerState.possible.rawValue, .newKey: UIGestureRecognizerState.began.rawValue], context: nil)
        
        wait(for: [expect], timeout: 0.1)
    }
    
    class ObserverUnderTest: Observer {
        var deinitCalled: (() -> Void)?
        deinit { deinitCalled?() }
    }
    
    func testDeinit() {
        let expect = expectation(description: "")
        var instance: ObserverUnderTest? = ObserverUnderTest(scrollView: scrollView)
        
        instance?.didScroll = { scrollView in
            self.scrollView.contentOffset = CGPoint(x: 1, y: 1)
            XCTFail()
        }
        
        instance?.deinitCalled = {
            expect.fulfill()
        }
        
        DispatchQueue.global(qos: .background).async {
            instance = nil
            self.scrollView.contentOffset = CGPoint(x: 1, y: 1)
        }
        
        waitForExpectations(timeout: 0.1)
    }
    
}
