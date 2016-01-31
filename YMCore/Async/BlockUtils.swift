//
//  BlockUtils.swift
//  YMCore
//
//  Created by Yanke Guo on 16/1/31.
//  Copyright © 2016年 Juxian(Beijing) Technology Co., Ltd. All rights reserved.
//

import Foundation

/**
 Create a block from inputBlock, no matter how many times outputBlock is invoked, inputBlock will be invoked once

 - parameter input: input block, will called once

 - returns: output block, returns true if it is the first time invoked
 */
public func CreateOnceBlock(input: VoidBlock) -> BoolBlock {
  var clean = true
  return {
    if clean {
      clean = false
      input()
      return true
    }
    return false
  }
}

/**
 Create a block from inputBlock, inputBlock will be invoked once when outputBlock is invoked for a certain count

 - parameter count: the count
 - parameter input: the input block

 - returns: returns NSComparisonResult between target count and current counter
 */
public func CreateAllBlock(count: UInt, _ input: VoidBlock) -> CompareBlock {
  var n: UInt = 0
  return {
    n = n + 1
    if n == count {
      //  Invoke the inputBlock
      input()
      return .OrderedSame
    }
    return n < count ? .OrderedDescending : .OrderedAscending
  }
}
