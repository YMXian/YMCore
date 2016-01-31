//
//  DispatchUtils.swift
//  YMCore
//
//  Created by Yanke Guo on 16/1/31.
//  Copyright © 2016年 Juxian(Beijing) Technology Co., Ltd. All rights reserved.
//

import Foundation

public func dispatch_async_global(identifier: Int, _ block: VoidBlock) {
  dispatch_async(dispatch_get_global_queue(identifier, 0), block)
}

public func dispatch_async_low(block: VoidBlock) {
  dispatch_async_global(DISPATCH_QUEUE_PRIORITY_LOW, block)
}

public func dispatch_async_high(block: VoidBlock) {
  dispatch_async_global(DISPATCH_QUEUE_PRIORITY_HIGH, block)
}

public func dispatch_async_main(block: VoidBlock) {
  dispatch_async(dispatch_get_main_queue(), block)
}

public func dispatch_sync_main(block: VoidBlock) {
  dispatch_sync(dispatch_get_main_queue(), block)
}

public func dispatch_async_main_alt(block: VoidBlock) {
  if NSThread.isMainThread() {
    block()
  } else {
    dispatch_async_main(block)
  }
}

public func dispatch_sync_main_alt(block: VoidBlock) {
  if NSThread.isMainThread() {
    block()
  } else {
    dispatch_sync_main(block)
  }
}

public func dispatch_after_seconds(queue: dispatch_queue_t, _ seconds: NSTimeInterval, _ block: VoidBlock) {
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(seconds * NSTimeInterval(NSEC_PER_SEC))), queue, block)
}

public func dispatch_main_after(seconds: NSTimeInterval, _ block: VoidBlock) {
  dispatch_after_seconds(dispatch_get_main_queue(), seconds, block)
}
