//
//  SelectionAttr.swift
//  StarJoinSelector
//
//  Created by apple on 7/23/17.
//  Copyright © 2017 apple. All rights reserved.
//

import Foundation

// TODO
// allow simple types and tuples to satisfy setKeyAttr 

/// Mark Attr

extension MultiSelection where NodeType : KVC & NodeMetadata {

    // set a property using key value coding
    @discardableResult public func attr(_ keyPath: String, toValueFn: NodeValueIndexToAny) -> Self {
        for (i, node) in nodes.enumerated() {
            node.setNodeValue(toValueFn(node, (), i), forKeyPath: keyPath)
        }
        return self;
    }

}



extension PerfectSelection where NodeType : KVC & NodeMetadata {



    // set a property using key value coding
    @discardableResult public func attr(_ keyPath: String, toValue: Any!) -> Self {
        for selected in nodes {
            selected.setNodeValue(toValue, forKeyPath: keyPath)
        }
        return self;
    }

    // set a property using key value coding
    @discardableResult public func attr(_ keyPath: String, toValueFn: NodeValueIndexToAny) -> Self {
        for (i, node) in nodes.enumerated() {
            let dataValue = self.metadata(from: node)
            node.setNodeValue(toValueFn(node, dataValue!, i), forKeyPath: keyPath) // todo: explain the ! here
        }
        return self;
    }




}

/// Each

extension PerfectSelection where NodeType : NodeMetadata {

    private func metadata(from node:NodeType?) -> ValueType? {
        return node?.metadata as? ValueType
    }

    @discardableResult public func each(_ eachFn:NodeValueIndexToVoid) -> Self {
        for (i, node) in nodes.enumerated() {
            let dataValue = self.metadata(from: node)
            eachFn(node, dataValue!, i) // TODO: explain the ! here - any if it's true.  what about re-binds?
        }
        return self;
    }
}

/// Call
