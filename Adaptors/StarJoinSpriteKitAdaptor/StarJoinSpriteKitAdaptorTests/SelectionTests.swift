//
//  StarJoinSpriteKitAdaptorTests.swift
//  StarJoinSpriteKitAdaptorTests
//
//  Created by apple on 7/18/17.
//  Copyright © 2017 apple. All rights reserved.
//

import XCTest

import XCTest
//import SpriteJoin
import SpriteKit
@testable import StarJoinSelector
@testable import StarJoinSpriteKitAdaptor

class BasicSpriteKitSelectionTests: XCTestCase {

    typealias TableRow = [String:Any]

    // empty data set
    var emptyData = [TableRow]()
    var oneRowData:[TableRow] = [["x":1.0, "y":2.0]]

    var scene:SKScene? = nil;

    //    func init() {
    //        // throwaway construction
    //        scene = SKScene(size: CGSizeMake(1024, 768))
    //    }

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        scene = SKScene(size:CGSize(width: 1024, height: 768))
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testSelectionConstructionZero() {
        // This is an example of a functional test case.

        let mySelection = Selection<SKNode>.selection(parent: scene!, nodes: scene!.childNodes, data: self.emptyData)

        XCTAssertEqual(0, mySelection.nodes.count)
        XCTAssertEqual(0, mySelection.data.count)

        XCTAssert(true, "Pass")
    }

    func testSelectionConstructionOne() {
        // This is an example of a functional test case.

        let mySelection = Selection<SKNode>.selection(parent: scene!, nodes: scene!.childNodes, data: self.oneRowData)

        XCTAssertEqual(0, mySelection.nodes.count) // the join has NO nodes to begin with (before enter)
        XCTAssertEqual(1, mySelection.data.count)

        // defunct - we don't do it that way any more
        //        let nonNilCount = mySelection.nodes.reduce(0, combine: { (acc, elem) -> Int in
        //            if let elemReal = elem {
        //                return acc + 1
        //            } else {
        //                return acc
        //            }
        //        })
        //
        //        XCTAssertEqual(0, nonNilCount);

        XCTAssert(true, "Pass")
    }

    func testSelectionOneEnter() {
        // This is an example of a functional test case.

        let mySelection = Selection<SKNode>.selection(parent: scene!, nodes: scene!.childNodes, data: self.oneRowData)

        mySelection.enter().append { (s, d, i) -> SKNode in
            return SKNode()
        }

        XCTAssertEqual(0, mySelection.nodes.count)
        XCTAssertEqual(1, mySelection.data.count)
        XCTAssertEqual(1, scene!.children.count)

        // defunct - we don't do it that way any more
        //        let nonNilCount = mySelection.nodes.reduce(0, combine: { (acc, elem) -> Int in
        //            if let elemReal = elem {
        //                return acc + 1
        //            } else {
        //                return acc
        //            }
        //        })
        //
        //        XCTAssertEqual(1, nonNilCount);

        XCTAssert(true, "Pass")
    }

    func testSelectionOneZeroEnterExit() {
        // This is an example of a functional test case.

        // If the node has children my code fails.

        let mySelection = Selection<SKNode>.selection(parent: scene!, nodes: scene!.childNodes, data: self.oneRowData)

        mySelection.enter().append { (s, d, i) -> SKNode in
            return SKNode()
        }

        let mySelection2 = Selection<SKNode>.selection(parent: scene!, nodes: scene!.childNodes, data: self.emptyData)

        mySelection2.enter().append { (s, d, i) -> SKNode in
            return SKNode()
        }

        mySelection2.exit().remove()

        XCTAssertEqual(0, mySelection2.nodes.count) // the selection array gets initialised with nil optionals.
        XCTAssertEqual(0, mySelection2.data.count)
        XCTAssertEqual(0, scene!.children.count) // will fail until exit is implemented

        //        let nonNilCount = mySelection2.selection.reduce(0, combine: { (acc, elem) -> Int in
        //            if let elemReal = elem {
        //                return acc + 1
        //            } else {
        //                return acc
        //            }
        //        })
        //
        //        XCTAssertEqual(0, nonNilCount);

        XCTAssert(true, "Pass")
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
