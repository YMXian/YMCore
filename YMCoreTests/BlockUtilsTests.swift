//
//  BlockUtilsTests.swift
//  YMCore
//
//  Created by Yanke Guo on 16/2/1.
//  Copyright © 2016年 Juxian(Beijing) Technology Co., Ltd. All rights reserved.
//

import XCTest
@testable import YMCore

class BlockUtilsTests: XCTestCase {

  func testOnceBlock() {
    var performedCount = 0
    let testBlock: VoidBlock = {
      performedCount = performedCount + 1
    }
    let boolBlock = CreateOnceBlock(testBlock)
    XCTAssertTrue(boolBlock())
    XCTAssertEqual(performedCount, 1)
    XCTAssertFalse(boolBlock())
    XCTAssertEqual(performedCount, 1)
    XCTAssertFalse(boolBlock())
    XCTAssertEqual(performedCount, 1)
  }

  func testAllBlock() {
    var performedCount = 0
    let testBlock: VoidBlock = {
      performedCount = performedCount + 1
    }
    let outBlock = CreateAllBlock(3, testBlock)
    XCTAssertEqual(outBlock(), NSComparisonResult.OrderedDescending)
    XCTAssertEqual(performedCount, 0)
    XCTAssertEqual(outBlock(), NSComparisonResult.OrderedDescending)
    XCTAssertEqual(performedCount, 0)
    XCTAssertEqual(outBlock(), NSComparisonResult.OrderedSame)
    XCTAssertEqual(performedCount, 1)
    XCTAssertEqual(outBlock(), NSComparisonResult.OrderedAscending)
    XCTAssertEqual(performedCount, 1)
  }

}
