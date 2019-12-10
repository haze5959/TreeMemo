//
//  treeMemoTests.swift
//  treeMemoTests
//
//  Created by OGyu kwon on 2019/12/09.
//  Copyright © 2019 OGyu kwon. All rights reserved.
//

import XCTest
@testable import treeMemo

class treeMemoTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testRemoveTreeData() {
        let exp01 = expectation(description: "데이터 삭제")
        TreeMemoState.shared.removeAllTreeData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            
            exp01.fulfill()
        }
        
        waitForExpectations(timeout: 10)
    }
}
