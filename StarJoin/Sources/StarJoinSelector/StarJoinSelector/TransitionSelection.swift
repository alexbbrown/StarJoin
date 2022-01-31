//
//  TransitionSelection.swift
//  StarJoinSelector
//
//  Created by alex on 7/20/17.
//  Copyright © 2017 apple. All rights reserved.
//

import Foundation

// PerfectSelection is a Node-Data join that has values for both sides
// (assuming someone hasn't futzed with the node graph or metadata)
extension PerfectSelection where NodeType: KVC & KVCAnimated & NodeMetadata {

    @discardableResult public
    func transition(duration: TimeInterval = 3) -> TransitionPerfectSelection<ParentType, NodeType, ValueType> {
        return .init(parent: self.parent, nodesValues:self.nodesValues, duration:duration)
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
public class TransitionPerfectSelection<ParentType, NodeType, ValueType> : InternalJoinedSelection<ParentType, NodeType, ValueType>
where NodeType : KVC & KVCAnimated & NodeMetadata  {

    let duration : TimeInterval

    internal init(parent: ParentType, nodesValues:[NodeValuePairType], duration: TimeInterval) {
        self.duration = duration
        super.init(parent: parent, nodesValues: nodesValues)
    }

    // set a property using key value coding
    @discardableResult public func attr(_ keyPath: String, toValue: Any!) -> Self {

        for nodeValue in nodesValues {
            nodeValue.node?.setNodeValueAnimated(toValue, forKeyPath: keyPath, withDuration:self.duration)
        }

        return self;
    }

    // set a property using key value coding
    @discardableResult public func attr(_ keyPath: String, toValueFn: NodeValueIndexToAny) -> Self {

        for (i, nodeValue) in nodesValues.enumerated() {
            nodeValue.node?.setNodeValueAnimated(toValueFn(nodeValue.node, nodeValue.value, i), forKeyPath: keyPath, withDuration:self.duration)
        }
        return self;
    }

    public func remove() {

        // fixme: is this safe:
        for nodeValue in nodesValues {
            nodeValue.node?.removeNodeFromParent(withDelay:duration)
        }

        // TODO: this selection is dead!  we should prevent further edits.
    }

    // dodgy function
    private func metadata(from node:NodeType?) -> ValueType? {

        return node?.metadata as? ValueType
    }
}

///// PerfectTransitionSelection is a PerfectSelection with delayed property operations
//// it has a duration property which defines how long the transitions take.
//// TODO: allow duration to be a function for each node.
//public class TransitionSelection<ParentType, NodeType, ValueType> : InternalJoinedSelection<ParentType, NodeType, ValueType>
//where NodeType : KVC & KVCAnimated & NodeMetadata  {
//
//    let duration : TimeInterval
//
//    internal init (parent:ParentType, nodes: [NodeType], duration:TimeInterval)
//    {
//        self.duration = duration
//        super.init(parent: parent, nodes: nodes)
//    }
//
//    // set a property using key value coding
//    @discardableResult public func attr(_ keyPath: String, toValue: Any!) -> Self {
//
//        for node in nodes {
//            node.setNodeValueAnimated(toValue, forKeyPath: keyPath, withDuration:self.duration)
//        }
//
//        return self;
//    }
//
//    // set a property using key value coding
//    @discardableResult public func attr(_ keyPath: String, toValueFn: NodeValueIndexToAny) -> Self {
//
//        for (i, node) in nodes.enumerated() {
//            node.setNodeValueAnimated(toValueFn(node, self.metadata(from: node)!, i), forKeyPath: keyPath, withDuration:self.duration)
//        }
//        return self;
//    }
//
//    public func remove() {
//
//        // fixme: is this safe:
//        for node in nodes {
//            node.removeNodeFromParent(withDelay:duration)
//        }
//    }
//
//    // dodgy function
//    private func metadata(from node:NodeType?) -> ValueType? {
//
//        return node?.metadata as? ValueType
//    }
//}

// imperfect Transition
public class TransitionMultiSelection<ParentType, NodeType> : _InternalImperfectSelection<ParentType, NodeType> {

    public typealias NodeValueIndexToAny = (NodeType?,Void,Int) -> Any?

    let duration : TimeInterval

    internal init (parent:ParentType, nodes: [NodeType], duration:TimeInterval)
    {
        self.duration = duration
        super.init(parent: parent, nodes:nodes)
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

    // ISSUE: there may be a race condition if a later selection picks them up
    // while they are in a timed animation and exit.  Should take care to check that
    // such nodes have their timed exit terminated (or that they are not eligible)
    public func remove() {

        // be careful what we are iterating across here to avoid deleting and iterating
        for node in nodes {
            node.removeNodeFromParent(withDelay:duration)
        }
    }
}
