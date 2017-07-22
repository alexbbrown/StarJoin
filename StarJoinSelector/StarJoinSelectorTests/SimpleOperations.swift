//
//  SimpleOperations.swift
//  StarJoinSelectorTests
//
//  Created by apple on 7/19/17.
//  Copyright © 2017 apple. All rights reserved.
//

import XCTest
@testable import StarJoinSelector

class TestNode {
    var children = [TestNode]()
    weak var parent:TestNode?
    var metadataStore:Any? = nil
}

extension TestNode: TreeNavigable {
    func add(child: TestNode) {
        child.parent = self
        children.append(child)
    }

    func removeNodeFromParent() {
        // what? not possible.
        parent?.children.remove(at: 0) // OK big cheat here.
    }

    var childNodes: [TestNode] {
        return children
    }
}

extension TestNode:KVC {
    func setValue(_ value: Any?, forKey: String) {
        fatalError()
    }

    func value(forKey: String) -> Any? {
        fatalError()
    }

    func setValue(_ value: Any?, forKeyPath: String) {
        fatalError()
    }

    func value(forKeyPath: String) -> Any? {
        fatalError()
    }

    func setNodeValue(_ toValue: Any?, forKeyPath keyPath: String) {
        fatalError()
    }
}

extension TestNode:NodeMetadata {
    var metadata: Any? {
        get {
            return metadataStore
        }
        set(newValue) {
            metadataStore = newValue
        }
    }
}

class SimpleOperations: XCTestCase {

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

        let mySelection = Selection<TestNode>.selection(parent: root, nodes: root.children, data: data0)

        XCTAssertEqual(0, mySelection.nodes.count)
        XCTAssertEqual(0, mySelection.debugNewData.count)

        XCTAssert(true, "Pass")
    }

    func testSelectionConstructionOne() {

        let mySelection = Selection<TestNode>.selection(parent: root, nodes: root.children, data: data1)

        XCTAssertEqual(0, mySelection.nodes.count) // the join has NO nodes to begin with (before enter)
        XCTAssertEqual(1, mySelection.debugNewData.count)
    }

    func testSelectionOneEnter() {

        let mySelection = Selection<TestNode>.selection(parent: root, nodes: root.children, data: data1)

        XCTAssertEqual(0, mySelection.nodes.count)
        XCTAssertEqual(1, mySelection.debugNewData.count)

        let enterSelection = mySelection.enter()

        XCTAssertEqual(0, mySelection.nodes.count)

        enterSelection.append { (s, d, i) -> TestNode in
            return .init()
        }

        XCTAssertEqual(1, mySelection.nodes.count)
        XCTAssertEqual(1, mySelection.debugNewData.count)
        XCTAssertEqual(1, root.children.count)

    }

    func testSelectionOneZeroEnterExit() {

        // If the node has children my code fails.

        let selection1 = Selection.selection(parent: root, nodes: root.children, data: data1)

        selection1.enter().append { (s, d, i) in
            return .init()
        }

        let selection0 = Selection.selection(parent: root, nodes: root.children, data: data0)

        selection0.enter().append { (s, d, i)  in
            return .init()
        }

        selection0.exit().remove()

        XCTAssertEqual(0, selection0.nodes.count) // the selection array gets initialised with nil optionals.
        XCTAssertEqual(0, selection0.debugNewData.count)
        XCTAssertEqual(0, root.children.count) // will fail until exit is implemented

    }
}
