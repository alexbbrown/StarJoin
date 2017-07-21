//
//  SelectionConvenience.swift
//  StarJoinSelector
//
//  Created by apple on 7/21/17.
//  Copyright © 2017 apple. All rights reserved.
//

import Foundation


extension Selection {

    // convenience function to do select, selectAll and join in one throw
    public class func selection<ValueType>(parent: ParentType, nodes: [NodeType], data: [ValueType]) -> JoinSelection<NodeType, ValueType> {
        return self.select(parent).selectAll(nodes).join(data)
    }

    convenience public init (node:NodeType) {
        self.init(nodes:[node])
    }
}
