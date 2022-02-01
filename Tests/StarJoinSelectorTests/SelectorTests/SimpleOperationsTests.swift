//
//  SimpleOperations.swift
//  StarJoinSelectorTests
//
//  Created by alex on 7/19/17.
//  Copyright © 2017 Alex B Brown. All rights reserved.
//

import XCTest
@testable import StarJoinSelector

class SimpleOperationsTests: XCTestCase {

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

    func testSelectionConstructionZero() {
        // This is an example of a functional test case.

        let se0 = StarJoin.select(only: root)

        let se1 = se0.select(all: root.children)

        let mySelection = se1.join(data0)

        XCTAssertEqual(0, mySelection.debugNodes.count)
        XCTAssertEqual(0, mySelection.debugNewData.count)

        XCTAssert(true, "Pass")
    }

    func testSelectionConstructionOne() {

        let se0 = StarJoin.select(only: root)

        let se1 = se0.select(all: root.children)

        let mySelection = se1.join(data1)

        XCTAssertEqual(0, mySelection.debugNodes.count) // the join has NO nodes to begin with (before enter)
        XCTAssertEqual(1, mySelection.debugNewData.count)
    }

    func testSelectionOneEnter() {

        let se0 = StarJoin.select(only: root)

        let se1 = se0.select(all: root.children)

        let mySelection = se1.join(data1)

        XCTAssertEqual(0, mySelection.debugNodes.count)
        XCTAssertEqual(1, mySelection.debugNewData.count)

        let enterSelection = mySelection.enter()

        XCTAssertEqual(0, mySelection.debugNodes.count)

        enterSelection.append { (d, i) -> TestNode in
            return .init()
        }

        XCTAssertEqual(0, mySelection.debugNodes.count) // it used to be 1 - now it's not adjusted after enter/append
        XCTAssertEqual(1, mySelection.debugNewData.count)
        XCTAssertEqual(1, root.children.count)

    }

    func testSelectionOneZeroEnterExit() {

        // If the node has children my code fails.

        let se10 = StarJoin.select(only: root)

        let se11 = se10.select(all: root.children)

        let selection1 = se11.join(data1)

        selection1.enter().append { (d, i) in
            return .init()
        }

        let se00 = StarJoin.select(only: root)

        let se01 = se00.select(all: root.children)

        let selection0 = se01.join(data0)

        selection0.enter().append { (d, i)  in
            return .init()
        }

        selection0.exit().remove()

        XCTAssertEqual(0, selection0.debugNodes.count) // the selection array gets initialised with nil optionals.
        XCTAssertEqual(0, selection0.debugNewData.count)
        XCTAssertEqual(0, root.children.count) // will fail until exit is implemented

    }
}
