//
//  BlockQueue.swift
//  YMCore
//
//  Created by Yanke Guo on 16/2/1.
//  Copyright © 2016年 Juxian(Beijing) Technology Co., Ltd. All rights reserved.
//

import Foundation

public class BlockQueue: Loggable {

  public typealias DoneBlock    = VoidBlock

  public typealias StartBlock   = VoidBlock

  public typealias DrainBlock   = VoidBlock

  public typealias ActionBlock  = (DoneBlock) -> Void

  public enum QueueResult {
    case MaxLengthExceeded
    case Success
  }

  public var maxLength: Int? = nil

  public var timeout: NSTimeInterval? = nil

  public var isRunning: Bool {
    return self.running
  }

  public var startBlock: StartBlock?

  public var drainBlock: DrainBlock?

  private var actions = [ActionBlock]()

  private var actionNames = [String]()

  private var running = false

  public func run(name: String = "\(__FILE__):\(__LINE__)", action: ActionBlock) -> QueueResult {
    //  Check maxLength
    if let maxLength = self.maxLength {
      if self.actions.count >= maxLength {
        return .MaxLengthExceeded
      }
    }

    //  Append actions
    self.actions.append(action)
    self.actionNames.append(name)

    ensureQueue()

    DLog("Block Queued: \(name)")

    return .Success
  }

  private func ensureQueue() {
    if !self.isRunning {
      runQueue()
    }
  }

  private func runQueue() {
    //  Check drain
    if self.actions.count == 0 {
      self.drainBlock?()
      self.running = false
      return
    }

    self.running = true
    self.startBlock?()

    let action = self.actions.first!
    let actionName = self.actionNames.first!

    let doneBlock: DoneBlock = {
      dispatch_async_main_alt {
        var _ = self.actions.removeFirst()
        var _ = self.actionNames.removeFirst()
      }
    }

    if let timeout = self.timeout {
      //  Create a onceBlock for Timeout/Execution
      let doneBlock1 = CreateOnceBlock(doneBlock)

      //  Timeout
      dispatch_main_after(timeout) {
        if doneBlock1() {
          self.ELog("block expired \(actionName)")
        }
      }

      //  Execute
      dispatch_async_main_alt {
        action {
          if doneBlock1() {
            self.ILog("block invoked \(actionName)")
          }
        }
      }
    } else {

      // Just execute
      dispatch_async_main_alt {
        action {
          doneBlock()
          self.ILog("block invoked \(actionName)")
        }
      }
    }
  }
}
