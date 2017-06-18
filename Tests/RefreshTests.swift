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
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
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
