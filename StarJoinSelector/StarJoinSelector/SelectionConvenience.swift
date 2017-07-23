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

//    // convenience function to do select, selectAll and join in one throw
//    public class func selection<ParentType, ValueType>(parent: ParentType, nodes: [NodeType], data: [ValueType]) -> JoinSelection<ParentType, NodeType, ValueType> {
//        return self.select(only: parent).select(all: nodes).join(data)
//    }

}



extension MultiSelection {
//    // compound attr for functions
//    // TODO: can I unify the value and function dictionary representations?
//    // TODO: is this necessary? can I drop this?
//    @discardableResult public
//    func attr(_ keyedFunctions: [String:NodeValueIndexToAny]) -> Self {
//        
//        // TODO: performance - could iterate the nodes outside?
//        for (keyPath, toValueFn) in keyedFunctions  {
//            attr(keyPath, toValueFn: toValueFn)
//        }
//        return self;
//    }
//    
//    // compound attr for values
//    @discardableResult public
//    func attr(_ keyedValues: [String:Any?]) -> Self {
//        
//        // TODO: performance - could iterate the nodes outside?
//        for (keyPath, toValue) in keyedValues  {
//            attr(keyPath, toValue: toValue)
//        }
//        return self;
//    }
}

//extension InternalJoinedSelection {
//    // compound attr for functions
//    // TODO: can I unify the value and function dictionary representations?
//    // TODO: Do I need this?
//    @discardableResult public
//    func attr(_ keyedFunctions: [String:NodeValueIndexToAny]) -> Self {
//
//        // TODO: performance - could iterate the nodes outside?
//        for (keyPath, toValueFn) in keyedFunctions  {
//            attr(keyPath, toValueFn: toValueFn)
//        }
//        return self;
//    }
//
//    // compound attr for values
//    @discardableResult public
//    func attr(keyedValues: [String:Any?]) -> Self {
//
//        // TODO: performance - could iterate the nodes outside?
//        for (keyPath, toValue) in keyedValues  {
//            attr(keyPath, toValue: toValue)
//        }
//        return self;
//    }
//}

