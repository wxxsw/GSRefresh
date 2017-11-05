//
//  UIScrollView+GSRefreshTests.swift
//  GSRefresh
//
//  Created by Gesen on 2017/6/18.
//  Copyright © 2017年 Gesen. All rights reserved.
//

import XCTest
@testable import GSRefresh

class UIScrollView_GSRefreshTests: XCTestCase {
    
    var scrollView: UIScrollView!
    
    override func setUp() {
        super.setUp()
        scrollView = UIScrollView()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testRefresh() {
        XCTAssertNotNil(scrollView.refresh)
        XCTAssert(type(of: scrollView.refresh) == Refresh.self)
    }
    
    func testLoadMore() {
        XCTAssertNotNil(scrollView.loadMore)
        XCTAssert(type(of: scrollView.loadMore) == LoadMore.self)
    }
    
}
