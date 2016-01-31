//
//  BlockDefinition.swift
//  YMCore
//
//  Created by Yanke Guo on 16/1/31.
//  Copyright © 2016年 Juxian(Beijing) Technology Co., Ltd. All rights reserved.
//

import Foundation

/// Block accepts nothing and returns nothing
public typealias VoidBlock = () -> Void

/// Block returns a Bool
public typealias BoolBlock = () -> Bool

/// Block returns a NSComparisonResult
public typealias CompareBlock = ()-> NSComparisonResult

/// Block accepts a NSError? and returns nothing, suitable for a callback
public typealias ErrorCallbackBlock = (NSError?) -> Void

/// Block accetps a ErrorCallbackBlock and returns nothing, suitable for a async operation
public typealias OperationBlock = (ErrorCallbackBlock) -> Void
