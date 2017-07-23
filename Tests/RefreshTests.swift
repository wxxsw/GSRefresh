//
//  RefreshTests.swift
//  GSRefresh
//
//  Created by GeSen on 2017/5/20.
//  Copyright © 2017年 GeSen. All rights reserved.
//

import XCTest
@testable import GSRefresh

class RefreshTests: XCTestCase {
    
    var scrollView: UIScrollView!
    var refresh: Refresh!
    
    override func setUp() {
        super.setUp()
        scrollView = UIScrollView()
        refresh = Refresh(scrollView: self.scrollView)
        refresh.view = UIView(frame: CGRect(x: 0, y: 0, width: 99, height: 99))
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testBeganDraging() {
        XCTAssert(refresh.view?.superview == nil)
        refresh.observeValue(forKeyPath: Observer.KeyPath.state, of: nil, change: [.oldKey: UIGestureRecognizerState.possible.rawValue, .newKey: UIGestureRecognizerState.began.rawValue], context: nil)
        XCTAssert(refresh.view?.superview != nil)
        XCTAssert(refresh.view!.frame.origin.y == (-refresh.inset.top + -refresh.view!.bounds.height))
    }
    
    func testDefaultValues() {
        XCTAssert(refresh.state == .default)
    }
    
    func testBegin() {
        refresh.state = .default
        refresh.begin()
        XCTAssert(refresh.state == .refreshing)
    }
    
    func testEnd() {
        refresh.state = .refreshing
        refresh.end()
        XCTAssert(refresh.state == .default)
    }
    
}
