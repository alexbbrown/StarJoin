//
//  NSViewAdaptor.swift
//  StarJoinNSViewAdaptor
//
//  Created by apple on 7/26/17.
//  Copyright © 2017 apple. All rights reserved.
//

import Foundation
//
//  UIViewAdaptor.swift
//  StarJoinUIViewAdaptor
//
//  Created by apple on 7/26/17.
//  Copyright © 2017 apple. All rights reserved.
//

import Foundation
import AppKit
import StarJoinSelector
import CoreGraphics.CGGeometry

// The following should really be in a SKNode swift module for adapting this protocol to SKNode
extension NSView: TreeNavigable {

    final public var childNodes: [NSView] {
        get { return self.subviews }
    }

    public func remove(child: NSView) {
        child.removeFromSuperview()
    }

    public func add(child: NSView) {
        self.addSubview(child)
    }
}

extension NSView: NodeMetadata {

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

extension NSView: KVC {

    public func setNodeValue(_ toValue:Any?, forKeyPath keyPath:String)
    {
        if let toValue = toValue {
            self.setValue(toValue, forKeyPath: keyPath)
        }
    }
}

