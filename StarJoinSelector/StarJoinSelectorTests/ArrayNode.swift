//
//  ArrayNode.swift
//  StarJoinSelectorTests
//
//  Created by apple on 7/22/17.
//  Copyright © 2017 apple. All rights reserved.
//

import Foundation
@testable import StarJoinSelector

struct ArrayBox {

}

extension Array : TreeNavigable {
    // this suggests we should grab all the nodes and then add them to the container?
    public func add(child: Array<Element>) {

    }

    public var childNodes: [Array<Element>] {
        <#code#>
    }


}

class TestNode {
    var children = [TestNode]()
    weak var parent:TestNode?
}

extension TestNode: TreeNavigable {
    func remove(child: TestNode) {
        // what? not possible.
        children.remove(at: 0) // OK big cheat here.
    }

    func add(child: TestNode) {
        child.parent = self
        children.append(child)
    }

    var childNodes: [TestNode] {
        return children
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
