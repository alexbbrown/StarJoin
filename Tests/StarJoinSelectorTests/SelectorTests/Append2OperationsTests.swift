//
//  Append2.swift
//  StarJoinSelectorTests
//
//  Created by alex on 7/22/17.
//  Copyright © 2017 Alex B Brown. All rights reserved.
//

import XCTest
@testable import StarJoinSelector

// todo: unit test operation of append2 when there is 0 elements in first selection
// repeated append2

class Append2OperationsTests: XCTestCase {

    typealias TableRow = [String:Any]

    // empty data set
    // could I use collections instead?  would a range work?
    var data0:[Void] = []
    var data1:[Void] = [()]

    var root = TestNode()

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testSimpleData() {
        XCTAssertEqual(0, data0.count)
        XCTAssertEqual(1, data1.count)

    }
//
//    func testSelectionConstructionZero() {
//        // This is an example of a functional test case.
//
//        let se0 = Selection<TestNode, TestNode>.select(only: root)
//
//        let se1 = se0.select(all: root.children)
//
//        let mySelection = se1.join(data0)
//
//        XCTAssertEqual(0, mySelection.nodes.count)
//        XCTAssertEqual(0, mySelection.debugNewData.count)
//
//        XCTAssert(true, "Pass")
//    }
}
