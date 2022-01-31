//
//  UIViewAdaptor.swift
//  StarJoinUIViewAdaptor
//
//  Created by alex on 7/26/17.
//  Copyright © 2017 Alex B Brown. All rights reserved.
//

import Foundation
import UIKit
import StarJoinSelector
import CoreGraphics.CGGeometry

// The following should really be in a SKNode swift module for adapting this protocol to SKNode
extension UIView: TreeNavigable {

    final public var childNodes: [UIView] {
        get { return self.subviews }
    }

    public func remove(child: UIView) {
        child.removeFromSuperview()
    }

    public func add(child: UIView) {
        self.addSubview(child)
    }
}

extension UIView: NodeMetadata {

    struct Static {
        static var key = "SJmetadata"
    }
    public var metadata:Any? {
        get {
            return objc_getAssociatedObject( self, &Static.key ) as Any?
        }
        set {
            objc_setAssociatedObject( self, &Static.key,  newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
}

extension UIView: KVC {

    public func setNodeValue(_ toValue:Any?, forKeyPath keyPath:String)
    {
        if let toValue = toValue {
            self.setValue(toValue, forKeyPath: keyPath)
        }
    }
}

