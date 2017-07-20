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

    var root = TestNode()

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    // Examine the relationship between the enter and append selections
    func testEnterCounts() {

        let mySelection = Selection<TestNode>.selection(parent: root, nodes: root.children, data: data1)

        XCTAssertEqual(0, mySelection.nodes.count)
        XCTAssertEqual(1, mySelection.data.count)

        let enterSelection = mySelection.enter()

        XCTAssertEqual(0, mySelection.nodes.count)
        XCTAssertEqual(0, enterSelection.nodes.count)

        let appendSelection = enterSelection.append { (s, d, i) -> TestNode in
            return .init()
        }

        XCTAssertEqual(1, appendSelection.nodes.count)
        XCTAssertEqual(0, enterSelection.nodes.count)

        enterSelection.each { (s, d, i) in
            fatalError()
        }

        XCTAssertEqual(1, mySelection.nodes.count)
        XCTAssertEqual(1, mySelection.data.count)
        XCTAssertEqual(1, root.children.count)
    }

    // Examine the relationship between the enter and append selections
    func testSelectionOneZeroEnterExit() {

        // If the node has children my code fails.

        let selection1 = Selection.selection(parent: root, nodes: root.children, data: data1)

        selection1.enter().append { (s, d, i) in
            return .init()
        }

        let selection0 = Selection.selection(parent: root, nodes: root.children, data: data0)

        let enterSelection = selection0.enter()

        XCTAssertEqual(0, enterSelection.nodes.count)


        let appendSelection = enterSelection.append { (s, d, i)  in
            return .init()
        }

        enterSelection.each { (s, d, i) in
            XCTFail("There is no each for enter - that's only on the append selection")
        }

        selection0.exit().remove()

        XCTAssertEqual(0, selection0.nodes.count) // the selection array gets initialised with nil optionals.
        XCTAssertEqual(0, selection0.data.count)
        XCTAssertEqual(0, root.children.count) // will fail until exit is implemented

    }

}
