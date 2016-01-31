//
//  ViewController.swift
//  YMCoreExample
//
//  Created by Yanke Guo on 16/1/26.
//  Copyright © 2016年 JuXian (Beijing) Technology Co., Ltd. All rights reserved.
//

import UIKit
import YMCore

public func test() {
  YMCore.LoggerDefaultMinLevel = .Debug
  WLog("AA")
}

class ViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()


    test()
    DLog("What")
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }

}
