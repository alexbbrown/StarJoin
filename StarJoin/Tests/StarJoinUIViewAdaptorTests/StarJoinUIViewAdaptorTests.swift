//
//  StarJoinUIViewAdaptorTests.swift
//  StarJoinUIViewAdaptorTests
//
//  Created by alex on 7/26/17.
//  Copyright © 2017 Alex B Brown. All rights reserved.
//

import XCTest
import UIKit
@testable import StarJoinSelector
@testable import StarJoinUIViewAdaptor

class StarJoinUIViewAdaptorTests: XCTestCase {

    typealias TableRow = [String:Any]

    // empty data set
    var emptyData = [TableRow]()
    var oneRowData:[TableRow] = [["x":1.0, "y":2.0]]

    var root:UIView? = nil;

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        root = UIView(frame:CGRect(x:0, y:0, width: 1024, height: 768))

    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

    func testSelectionConstructionZero() {
        // This is an example of a functional test case.

        let mySelection = StarJoin.select(only: root!).select(all: root!.childNodes).join(emptyData)

        XCTAssertEqual(0, mySelection.debugNodes.count)
        XCTAssertEqual(0, mySelection.debugNewData.count)

        XCTAssert(true, "Pass")
    }

    func testSelectionConstructionOne() {
        // This is an example of a functional test case.

        let mySelection = StarJoin.select(only: root!).select(all: root!.childNodes).join(oneRowData)

        XCTAssertEqual(0, mySelection.debugNodes.count) // the join has NO nodes to begin with (before enter)
        XCTAssertEqual(1, mySelection.debugNewData.count)

        XCTAssert(true, "Pass")
    }

    func testSelectionOneEnter() {
        // This is an example of a functional test case.

        let mySelection = StarJoin.select(only: root!).select(all: root!.childNodes).join(self.oneRowData)

        XCTAssertEqual(0, mySelection.debugNodes.count)
        XCTAssertEqual(1, mySelection.debugNewData.count)

        let enterSelection = mySelection.enter()

        XCTAssertEqual(0, mySelection.debugNodes.count)

        enterSelection.append { (d, i) -> UIView in
            return UIView()
        }

        XCTAssertEqual(0, mySelection.debugNodes.count) // used to be 1
        XCTAssertEqual(1, mySelection.debugNewData.count)
        XCTAssertEqual(1, root!.childNodes.count)

        XCTAssert(true, "Pass")
    }

    
}
