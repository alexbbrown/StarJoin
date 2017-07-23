//
//  TransitionSelection.swift
//  StarJoinSelector
//
//  Created by apple on 7/20/17.
//  Copyright © 2017 apple. All rights reserved.
//

import Foundation

// PerfectSelection is a Node-Data join that has values for both sides
// (assuming someone hasn't futzed with the node graph or metadata)
extension PerfectSelection where NodeType: KVC & KVCAnimated & NodeMetadata {

    @discardableResult public
    func transition(duration: TimeInterval = 3) -> TransitionSelection<ParentType, NodeType, ValueType> {
        return .init(parent: self.parent, nodes:self.nodes, duration:duration)
    }
}

extension MultiSelection where NodeType:KVCAnimated {

    @discardableResult public
    func transition(duration: TimeInterval = 3) -> TransitionMultiSelection<ParentType, NodeType> {
        return .init(parent: self.parent, nodes:self.nodes, duration:duration)
    }
}

/// PerfectTransitionSelection is a PerfectSelection with delayed property operations
// it has a duration property which defines how long the transitions take.
// TODO: allow duration to be a function for each node.
public class TransitionSelection<ParentType, NodeType, ValueType> : InternalJoinedSelection<ParentType, NodeType, ValueType>
where NodeType : KVC & KVCAnimated & NodeMetadata  {

    let duration : TimeInterval

    internal init (parent:ParentType, nodes: [NodeType], duration:TimeInterval)
    {
        self.duration = duration
        super.init(parent: parent, nodes: nodes)
    }

    // set a property using key value coding
    @discardableResult public func attr(_ keyPath: String, toValue: Any!) -> Self {

        for node in nodes {
            node.setNodeValueAnimated(toValue, forKeyPath: keyPath, withDuration:self.duration)
        }

        return self;
    }

    // set a property using key value coding
    @discardableResult public func attr(_ keyPath: String, toValueFn: NodeValueIndexToAny) -> Self {

        for (i, node) in nodes.enumerated() {
            node.setNodeValueAnimated(toValueFn(node, self.metadata(from: node)!, i), forKeyPath: keyPath, withDuration:self.duration)
        }
        return self;
    }

    public func remove() {

        // fixme: is this safe:
        for node in nodes {
            node.removeNodeFromParent(withDelay:duration)
        }
    }

    // dodgy function
    private func metadata(from node:NodeType?) -> ValueType? {

        return node?.metadata as? ValueType
    }
}

// imperfect Transition
public class TransitionMultiSelection<ParentType, NodeType> : InternalMultiSelection<ParentType, NodeType> {

    public typealias NodeValueIndexToAny = (NodeType?,Void,Int) -> Any?

    let duration : TimeInterval

    internal init (parent:ParentType, nodes: [NodeType], duration:TimeInterval)
    {
        self.duration = duration
        super.init(parent: parent, nodes: nodes)
    }

}

extension TransitionMultiSelection where NodeType : KVC & KVCAnimated & NodeMetadata {

    // set a property using key value coding
    @discardableResult public func attr(_ keyPath: String, toValue: Any!) -> Self {

        // TODO: make action deferred for at least some cases

        for node in nodes {
            node.setNodeValueAnimated(toValue, forKeyPath: keyPath, withDuration:self.duration)
        }

        return self;
    }

    // set a property using key value coding
    @discardableResult public func attr(_ keyPath: String, toValueFn: NodeValueIndexToAny) -> Self {

        // TODO: make action deferred for at least some cases

        for (i, node) in nodes.enumerated() {

            node.setNodeValueAnimated(toValueFn(node, (), i), forKeyPath: keyPath, withDuration:self.duration)
        }
        return self;
    }

    public func remove() {

        // be careful what we are iterating across here to avoid deleting and iterating
        for node in nodes {
            node.removeNodeFromParent(withDelay:duration)
        }
    }
}
