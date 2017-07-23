//
//  StarJoinAdaptor.swift
//  StarJoinSpriteKitAdaptor
//
//  Created by apple on 7/18/17.
//  Copyright © 2017 apple. All rights reserved.
//

import Foundation

import Foundation
import SpriteKit
import StarJoinSelector
import CoreGraphics.CGGeometry

// Convenience extension
public extension SKNode {
    convenience init(name:String) {
        self.init()
        self.name = name
    }
}

public func namedNode<T:SKNode>(node:T, _ name:String) -> T {
    node.name = name;
    return node
}

// The following should really be in a SKNode swift module for adapting this protocol to SKNode
extension SKNode: TreeNavigable, KVC, KVCAnimated, NodeMetadata {


    final public var childNodes: [SKNode] {
        get { return self.children }
    }

    public func remove(child: SKNode) {
        child.removeFromParent()
    }


    #if false // not sure
    public override func isEqual(object: AnyObject?) -> Bool {
    if let object = object {
    return self === object
    } else {
    return false
    }
    }
    #endif


    public func removeNodeFromParent(withDelay: TimeInterval) {

    run(.sequence(
        [.wait(forDuration:withDelay),
         .removeFromParent()]))
    }

    //    // the argument type should be [SKNode] but the compiler fails
    //    public func removeChildNodesInArray(children:[SKNode]) {
    //        self.removeChildrenInArray(children as [SKNode])
    //    }

    public func add(child: SKNode) {
        self.addChild(child)
    }

    // can we make this Any?
    public var metadata: Any? {
        get { return self.userData?["data"] }
        set(newValue) {
            if let userDataDictionary = self.userData {
                userDataDictionary["data"] = newValue
            } else {
                let newUserDataDictionary = NSMutableDictionary()
                self.userData = newUserDataDictionary
                newUserDataDictionary["data"] = newValue
            }
        }
    }

    public func setNodeValue(_ toValue:Any?, forKeyPath keyPath:String)
    {
        if let toValue = toValue {
            self.setValue(toValue, forKeyPath: keyPath)
        }
    }

    public func setNodeValueAnimated(_ toValue:Any?, forKeyPath keyPath:String, withDuration: TimeInterval)
    {
        if let toValue = toValue {

            switch keyPath {
            case "position":
                run(.move(to: (toValue as! NSValue).cgPointValue,
                                    duration: withDuration))

            case "xPosition":
                run(.moveTo(x: toValue as! CGFloat, duration: withDuration))

            case "yPosition":
                run(.moveTo(y: toValue as! CGFloat, duration: withDuration))

            case "scale":
                run(.scale(to: toValue as! CGFloat, duration: withDuration))

            case "size":
                if let sizeO = toValue as? NSValue {
                    let size = sizeO.cgPointValue
                    run(.resize(toWidth: size.x, height: size.y, duration: withDuration))
                }
            case "color":
                run(.colorize(with: toValue as! SKColor, colorBlendFactor:1.0, duration: withDuration))

            case "alpha":
                run(.fadeAlpha(to: toValue as! CGFloat, duration: withDuration))

            default:
                setValue(toValue, forKeyPath: keyPath)
            }
        }
    }
}

// Convenience function for selection

public func allChildrenSelector(node:SKNode) -> [SKNode] {
    return node.childNodes
}

// Note that SKNode leaves it open as to whether there is one or multiple nodes named something
public func allChildrenNamedSelector(name:String) -> (_:SKNode) -> [SKNode] {
    return { (node:SKNode) in
        return node.childNodes.filter { (node) in node.name != nil && node.name == name }
    }
}

#if os(OSX)

    extension NSValue {
        var cgPointValue:CGPoint {
            return self.pointValue
        }
        convenience init(CGPoint point:CGPoint) {
            self.init(point:point)
        }
    }
    
#elseif os(iOS)



#endif
