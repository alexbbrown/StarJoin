//
//  TestNode.swift
//  StarJoinSelectorTests
//
//  Created by apple on 7/22/17.
//  Copyright © 2017 apple. All rights reserved.
//

import Foundation
@testable import StarJoinSelector

class TestNode {
    var children = [TestNode]()
    weak var parent:TestNode?
    var metadataStore:Any? = nil
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
