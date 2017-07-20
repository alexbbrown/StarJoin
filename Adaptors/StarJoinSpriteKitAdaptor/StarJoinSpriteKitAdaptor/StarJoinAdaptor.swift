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
extension SKNode: TreeNavigable, KVC, NodeMetadata {

    final public var childNodes: [SKNode]! {
        get { return self.children }
    }

    public func removeNodeFromParent() {
        self.removeFromParent()


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
    public var metadata: AnyObject? {
        get { return self.userData?["data"] as AnyObject }
        set(value) {
            if let userDataDictionary = self.userData {
                userDataDictionary["data"] = value
            } else {
                let newUserDataDictionary = NSMutableDictionary()
                self.userData = newUserDataDictionary
                newUserDataDictionary["data"] = value
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
                run(.move(to: (toValue as! NSValue).CGPointValue(),
                                    duration: withDuration))

            case "xPosition":
                run(.moveTo(x: toValue as! CGFloat, duration: withDuration))

            case "yPosition":
                run(.moveTo(y: toValue as! CGFloat, duration: withDuration))

            case "scale":
                run(.scale(to: toValue as! CGFloat, duration: withDuration))

            case "size":
                if let sizeO = toValue as? NSValue {
                    let size = sizeO.CGPointValue()
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
        func CGPointValue() -> CGPoint {
            return self.pointValue
        }
        convenience init(CGPoint point:CGPoint) {
            self.init(point:point)
        }
    }

    // Convenience functions for CG types
    public func SKPoint(x:CGFloat,y:CGFloat) -> NSValue {
        return NSValue(point: CGPoint(x: x, y: y))
    }
    public func SKPoint(x:Double,y:Double) -> NSValue {
        return NSValue(point: CGPoint(x: x, y: y))
    }
    public func SKPoint(x:Int,y:Int) -> NSValue {
        return NSValue(point: CGPoint(x: x, y: y))
    }

    // Convenience functions for CG types
    public func SKSize(width x:CGFloat, height y:CGFloat) -> NSValue {
        return NSValue(size: CGSize(width: x, height: y))
    }
    public func SKSize(width x:Double, height y:Double) -> NSValue {
        return NSValue(size: CGSize(width: x, height: y))
    }
    public func SKSize(width x:Int,height y:Int) -> NSValue {
        return NSValue(size: CGSize(width: x, height: y))
    }

#elseif os(iOS)

    //    extension NSValue {
    //    func point() -> CGPoint {
    //    return self.pointValue
    //    }
    //    convenience init(CGPoint:CGPoint) {
    //    self.init(point:CGPoint)
    //    }
    //    }

    // Convenience functions for CG types
    public func SKPoint(x:CGFloat,y:CGFloat) -> NSValue {
        return NSValue(CGPoint: CGPointMake(CGFloat(x),CGFloat(y)))
    }
    public func SKPoint(x:Double,y:Double) -> NSValue {
        return NSValue(CGPoint: CGPointMake(CGFloat(x),CGFloat(y)))
    }
    public func SKPoint(x:Int,y:Int) -> NSValue {
        return NSValue(CGPoint: CGPointMake(CGFloat(x),CGFloat(y)))
    }
    public func SKPoint(x:NSNumber,y:NSNumber) -> NSValue {
        return NSValue(CGPoint: CGPointMake(CGFloat(x.doubleValue),CGFloat(y.doubleValue)))
    }

    // Convenience functions for CG types
    public func SKSize(width x:CGFloat, height y:CGFloat) -> NSValue {
        return NSValue(CGSize: CGSizeMake(CGFloat(x),CGFloat(y)))
    }
    public func SKSize(width x:Double, height y:Double) -> NSValue {
        return NSValue(CGSize: CGSizeMake(CGFloat(x),CGFloat(y)))
    }
    public func SKSize(width x:Int,height y:Int) -> NSValue {
        return NSValue(CGSize: CGSizeMake(CGFloat(x),CGFloat(y)))
    }

#endif
