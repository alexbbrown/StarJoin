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

extension SingleSelection {
    @discardableResult public
    func call(function: (SingleSelection) -> ()) -> Self {
        function(self)

        return self
    }
}

extension MultiSelection where NodeType : KVC {

    // set a property using key value coding
    @discardableResult public func attr(_ keyPath: String, toValueFn: NodeValueIndexToAny) -> Self {
        for (i, node) in nodes.enumerated() {
            node.setNodeValue(toValueFn(node, (), i), forKeyPath: keyPath)
        }
        return self;
    }
}

extension MultiSelection {
    @discardableResult public func each(_ eachFn:NodeValueIndexToVoid) -> Self {
        // TODO create more childrens
        for (i, selected) in nodes.enumerated() {
            eachFn(selected, (), i)
        }
        return self;
    }
}

extension PerfectSelection where NodeType : KVC
{

    // set a property using key value coding
    @discardableResult public func attr(_ keyPath: String, toValue: Any!) -> Self {
        for nodeValue in nodesValues {
            nodeValue.node?.setNodeValue(toValue, forKeyPath: keyPath)
        }
        return self;
    }

    // set a property using key value coding
    @discardableResult public func attr(_ keyPath: String, toValueFn: NodeValueIndexToAny) -> Self {
        for (i, nodeValue) in nodesValues.enumerated() {
            nodeValue.node?.setNodeValue(toValueFn(nodeValue.node, nodeValue.value, i), forKeyPath: keyPath)
        }
        return self;
    }


}

extension PerfectSelection {
    @discardableResult public func each(_ eachFn:NodeValueIndexToVoid) -> Self {
        for (i, nodeValue) in nodesValues.enumerated() {
            eachFn(nodeValue.node!, nodeValue.value, i)
        }
        return self;
    }

    public func call(function: (PerfectSelection) -> ()) -> Self {
        function(self)

        return self
    }
}
