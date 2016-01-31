//
//  CoreTests.swift
//  CoreTests
//
//  Created by Yanke Guo on 16/1/26.
//  Copyright © 2016年 JuXian (Beijing) Technology Co., Ltd. All rights reserved.
//

import XCTest
@testable import YMCore

class RouterTests: XCTestCase {

  func testBasicRouter() {
    let router = Router(scheme: "test")

    var hit = 0

    router.on("/test") { (params) -> Void in
      XCTAssertEqual("value1", params["key1"])
      hit = hit+1
    }

    router.routePath("/test?key1=value1")
    XCTAssertEqual(hit, 1)
    router.routeUrlString("test://test?key1=value1")
    XCTAssertEqual(hit, 2)
    router.routeUrlString("test:///test?key1=value1")
    XCTAssertEqual(hit, 3)
    router.routePath("/test", params: ["key1":"value1"])
    XCTAssertEqual(hit, 4)
  }

  func testInlineRouter() {
    let router = Router(scheme: "test")

    var hit = 0

    router.on("/test/:key1") { (params) -> Void in
      XCTAssertEqual("value1", params["key1"])
      hit = hit+1
    }

    router.routePath("/test/value1")
    XCTAssertEqual(hit, 1)
    router.routeUrlString("test://test/what?key1=value1")
    XCTAssertEqual(hit, 2)
    router.routeUrlString("test:///test/what?key1=value1")
    XCTAssertEqual(hit, 3)
    router.routePath("/test/what", params: ["key1":"value1"])
    XCTAssertEqual(hit, 4)
  }

  func testHybridRouter() {
    let router = Router(scheme: "test")

    var hit = 0

    router.on("/test/:key1") { (params) -> Void in
      XCTAssertEqual("value1", params["key1"])
      XCTAssertEqual("value2", params["key2"])
      hit = hit+1
    }

    router.routePath("/test/value1?key2=value2")
    XCTAssertEqual(hit, 1)
    router.routeUrlString("test://test/value1?key2=value2")
    XCTAssertEqual(hit, 2)
    router.routeUrlString("test:///test/value1?key2=value2")
    XCTAssertEqual(hit, 3)
    router.routePath("/test/value1", params: ["key2":"value2"])
    XCTAssertEqual(hit, 4)
  }

  func testHybridAliasRouter() {
    let router = Router(scheme: "test")

    var hit = 0

    router.on("/test/:key1") { (params) -> Void in
      XCTAssertEqual("value1", params["key1"])
      XCTAssertEqual("value2", params["key2"])
      hit = hit+1
    }

    router.alias("/test2", to: "/test/value1")

    router.routePath("/test2?key2=value2")
    XCTAssertEqual(hit, 1)
    router.routeUrlString("test://test2?key2=value2")
    XCTAssertEqual(hit, 2)
    router.routeUrlString("test:///test2?key2=value2")
    XCTAssertEqual(hit, 3)
    router.routePath("/test2", params: ["key2":"value2"])
    XCTAssertEqual(hit, 4)
  }

  func testSubRouter() {
    let router = Router(scheme: "test")

    var hit = 0

    router.on("/test") { (params) -> Void in
      XCTAssertEqual("value1", params["key1"])
      hit = hit+1
    }

    let router2 = Router(scheme: "test1")

    var hit2 = 0

    router2.on("/test") { (params) -> Void in
      XCTAssertEqual("value2", params["key2"])
      hit2 = hit2 + 1
    }

    router.registerRouter(router2, forScheme: router2.scheme)

    router.routeUrlString("test1://test?key2=value2")
    XCTAssertEqual(hit2, 1)
  }

  func testSubRouter2() {
    let router = Router(scheme: "test")

    var hit = 0

    router.on("/test") { (params) -> Void in
      XCTAssertEqual("value1", params["key1"])
      hit = hit+1
    }

    let router2 = Router(scheme: "test")

    var hit2 = 0

    router2.on("/test2") { (params) -> Void in
      XCTAssertEqual("value2", params["key2"])
      hit2 = hit2 + 1
    }

    router.registerRouter(router2, forScheme: router2.scheme)

    router.routeUrlString("test://test2?key2=value2")
    XCTAssertEqual(hit, 0)
    XCTAssertEqual(hit2, 1)
  }

}
