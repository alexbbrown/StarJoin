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
extension PerfectSelection {

    @discardableResult public
    func transition(duration: TimeInterval = 3) -> TransitionSelection<NodeType, ValueType> {
        return TransitionSelection(parent: self.parent, nodes:self.nodes, duration:duration)
    }

}

/// PerfectTransitionSelection is a PerfectSelection with delayed property operations
// it has a duration property which defines how long the transitions take.
// TODO: allow duration to be a function for each node.
public class TransitionSelection<NodeType: KVC & TreeNavigable & NodeMetadata, ValueType> : JoinedSelection<NodeType, ValueType> {

    let duration : TimeInterval

    internal init (parent:ParentType, nodes: [NodeType], duration:TimeInterval)
    {
        self.duration = duration
        super.init(parent: parent, nodes: nodes)
    }

    // set a property using key value coding
    public override func setKeyedAttr(keyPath: String, toValue: Any!) -> Self {

        for node in nodes {
            node.setNodeValueAnimated(toValue, forKeyPath: keyPath, withDuration:self.duration)
        }

        return self;
    }

    // set a property using key value coding
    public override func setKeyedAttr(keyPath: String, toValueFn: NodeToIdFunction) -> Self {

        for (i, node) in nodes.enumerated() {
            node.setNodeValueAnimated(toValueFn(node, self.metadataForNode(i:i), i), forKeyPath: keyPath, withDuration:self.duration)
        }
        return self;
    }

    override public func remove() {

        // fixme: is this safe:
        for node in nodes {
            node.removeNodeFromParent(withDelay:duration)
        }
    }
}

// imperfect Transition
public class TransitionMultiSelection<NodeType: KVC & TreeNavigable & NodeMetadata> : MultiSelection<NodeType> {

    let duration : TimeInterval

    internal init (parent:ParentType, nodes: [NodeType], duration:TimeInterval)
    {
        self.duration = duration
        super.init(parent: parent, nodes: nodes)
    }

    // set a property using key value coding
    public override func setKeyedAttr(keyPath: String, toValue: Any!) -> Self {

        // TODO: make action deferred for at least some cases

        for node in nodes {
            node.setNodeValueAnimated(toValue, forKeyPath: keyPath, withDuration:self.duration)
        }

        return self;
    }

    // set a property using key value coding
    public override func setKeyedAttr(keyPath: String, toValueFn: NodeToIdFunction) -> Self {

        // TODO: make action deferred for at least some cases

        for (i, node) in nodes.enumerated() {

            node.setNodeValueAnimated(toValueFn(node, (), i), forKeyPath: keyPath, withDuration:self.duration)
        }
        return self;
    }

    override public func remove() {

        // be careful what we are iterating across here to avoid deleting and iterating
        for node in nodes {
            node.removeNodeFromParent(withDelay:duration)
        }
    }
}
