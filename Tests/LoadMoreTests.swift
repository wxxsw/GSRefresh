//
//  LoadMoreTests.swift
//  GSRefresh
//
//  Created by Gesen on 2017/6/18.
//  Copyright © 2017年 Gesen. All rights reserved.
//

import XCTest
@testable import GSRefresh

class LoadMoreTests: XCTestCase {
    
    var scrollView: UIScrollView!
    var loadMore: LoadMore!
    
    override func setUp() {
        super.setUp()
        scrollView = UIScrollView()
        loadMore = LoadMore(scrollView: scrollView)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
