//
//  LessSimpleOperations.swift
//  StarJoinSelectorTests
//
//  Created by apple on 7/19/17.
//  Copyright © 2017 apple. All rights reserved.
//
// These tests are designed for cases where it's less obvious what the correct behaviour should be

import XCTest
@testable import StarJoinSelector

class LessSimpleOperations: XCTestCase {

    typealias TableRow = [String:Any]

    // empty data set
    // could I use collections instead?  would a range work?
    var data0:[Void] = []
    var data1:[Void] = [()]
    var data2:[Void] = [(),()]

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
        XCTAssertEqual(2, data2.count)
    }

    // Examine the relationship between the enter and append selections
    func testEnterCounts() {

        let mySelection = Selection<TestNode, TestNode>.select(only: root).select(all: root.children).join(data1)

        XCTAssertEqual(0, mySelection.nodes.count)
        XCTAssertEqual(1, mySelection.debugNewData.count)

        let enterSelection = mySelection.enter()
        let updateSelection = mySelection.update()

        XCTAssertEqual(0, mySelection.nodes.count)
        XCTAssertEqual(1, enterSelection.debugNewData.count)
        XCTAssertEqual(0, updateSelection.nodes.count)


        let appendSelection = enterSelection.append { (d, i) -> TestNode in
            return .init()
        }

        XCTAssertEqual(1, appendSelection.nodes.count)
        XCTAssertEqual(1, enterSelection.debugNewData.count)
        XCTAssertEqual(0, updateSelection.nodes.count)

        let updateSelection2 = mySelection.update()

        XCTAssertEqual(0, mySelection.nodes.count)
        XCTAssertEqual(1, mySelection.debugNewData.count)
//        XCTAssertEqual(updateSelection.nodes.count, updateSelection2.nodes.count) // same

        XCTAssertEqual(0, updateSelection2.nodes.count)
//        XCTAssertEqual(0, updateSelection2.nodes.count) // this should be ZERO in mergeWorld


        XCTAssertEqual(1, root.children.count)
    }

    // Examine the relationship between the enter and append selections
    func testSelectionOneZeroEnterExit() {

        // If the node has children my code fails.

        let selection1 = Selection<TestNode, TestNode>.select(only: root).select(all: root.children).join(data1)

        selection1.enter().append { (d, i) in
            return .init()
        }

        let selection0 = Selection<TestNode, TestNode>.select(only: root).select(all: root.children).join(data0)

        let enterSelection = selection0.enter()

        XCTAssertEqual(0, enterSelection.debugNewData.count)


        let appendSelection = enterSelection.append { (d, i)  in
            return .init()
        }

        selection0.exit().remove()

        XCTAssertEqual(0, selection0.nodes.count) // the selection array gets initialised with nil optionals.
        XCTAssertEqual(0, selection0.debugNewData.count)
        XCTAssertEqual(0, root.children.count)

    }

    func testSelectionOneTwoEnterExitUpdateMerge() {

        // If the node has children my code fails.

        let selection1 = Selection<TestNode, TestNode>.select(only: root).select(all: root.children).join(data1)

        selection1.enter().append { (d, i) in
            return .init()
        }

        let selection2 = Selection<TestNode, TestNode>.select(only: root).select(all: root.children).join(data2)

        let enterSelection = selection2.enter()

        XCTAssertEqual(1, enterSelection.debugNewData.count)

        let appendSelection = enterSelection.append { (d, i)  in
            return .init()
        }

        XCTAssertEqual(1, appendSelection.nodes.count)

        selection2.exit().remove()

        let updateSelection = selection2.update()

        XCTAssertEqual(1, updateSelection.nodes.count)

        let mergeSelection = updateSelection.merge(with: appendSelection)

        XCTAssertEqual(2, mergeSelection.nodes.count)
        XCTAssertEqual(2, root.children.count)

    }

}
