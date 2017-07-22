//
//  StarJoinSceneKitAdaptor.swift
//  StarJoinSceneKitAdaptor
//
//  Created by apple on 7/20/17.
//  Copyright © 2017 apple. All rights reserved.
//

import Foundation
import SceneKit
import StarJoinSelector

extension SCNNode: TreeNavigable, NodeMetadata, KVC {

    public func add(child: SCNNode) {
        self.addChildNode(child)
    }

    public func removeNodeFromParent() {
        self.removeFromParentNode()
    }

    public func setNodeValue(_ toValue: Any?, forKeyPath keyPath: String) {
        if let toValue = toValue {
            self.setValue(toValue, forKeyPath: keyPath)
        }
    }

    public var metadata: Any? {
        get { return self.value(forKey: "metadata") }
        set(value) {
            self.setValue(value, forKey: "metadata")
        }
    }
}
