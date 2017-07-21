//
//  SelectionConvenience.swift
//  StarJoinSelector
//
//  Created by apple on 7/21/17.
//  Copyright © 2017 apple. All rights reserved.
//

import Foundation

public func select<NodeType>(node:NodeType) -> SingleSelection<NodeType>
    where NodeType : KVC & TreeNavigable & NodeMetadata {
    return SingleSelection(node: node)
}

extension Selection {

    // convenience function to do select, selectAll and join in one throw
    public class func selection<ValueType>(parent: ParentType, nodes: [NodeType], data: [ValueType]) -> JoinSelection<NodeType, ValueType> {
        return self.select(only: parent).select(all: nodes).join(data)
    }

    convenience public init (node:NodeType) {
        self.init(nodes:[node])
    }
}

extension PerfectSelection {

    // this isn't exactly the same as the main append - so let's call it append2
    // it's tested in the axis logic

    /// Append adds a new child node to every node in the selection
    // Take care when using on data-dominant selections - a join
    // after an append can go badly wrong.  Updateselection is a perfect selection
    // so that's OK.
    //
    // returns a new UpdateSelection containing the created nodes.
    // binds the child nodes to the same metadata.
    public func append2(constructorFn:NodeValueIndexToNode) -> PerfectSelection {

        var newNodes = [NodeType]()

        for (i, selected) in nodes.enumerated() {
            // MARK: WORKING FACE
            var newNode = constructorFn(nodes[i], selected.metadata as! ValueType, i)

            nodeData.append(NodeDataType(node: newNode,
                                         value: nodeData[i].value))

            newNode.metadata = nodeData[i].value

            newNodes.append(newNode)
            nodes[i].add(child:newNode)
        }

        return PerfectSelection<NodeType, ValueType>(parent: self.parent, nodeData: [], nodes:newNodes);
    }
}

extension MultiSelection {
    // compound attr for functions
    // TODO: can I unify the value and function dictionary representations?
    // TODO: is this necessary? can I drop this?
    @discardableResult public
    func attr(_ keyedFunctions: [String:NodeValueIndexToAny]) -> Self {
        
        // TODO: performance - could iterate the nodes outside?
        for (keyPath, toValueFn) in keyedFunctions  {
            attr(keyPath, toValueFn: toValueFn)
        }
        return self;
    }
    
    // compound attr for values
    @discardableResult public
    func attr(_ keyedValues: [String:Any?]) -> Self {
        
        // TODO: performance - could iterate the nodes outside?
        for (keyPath, toValue) in keyedValues  {
            attr(keyPath, toValue: toValue)
        }
        return self;
    }
}

extension  JoinedSelection {
    // compound attr for functions
    // TODO: can I unify the value and function dictionary representations?
    // TODO: Do I need this?
    @discardableResult public
    func attr(_ keyedFunctions: [String:NodeValueIndexToAny]) -> Self {

        // TODO: performance - could iterate the nodes outside?
        for (keyPath, toValueFn) in keyedFunctions  {
            attr(keyPath, toValueFn: toValueFn)
        }
        return self;
    }

    // compound attr for values
    @discardableResult public
    func attr(keyedValues: [String:Any?]) -> Self {

        // TODO: performance - could iterate the nodes outside?
        for (keyPath, toValue) in keyedValues  {
            attr(keyPath, toValue: toValue)
        }
        return self;
    }
}

