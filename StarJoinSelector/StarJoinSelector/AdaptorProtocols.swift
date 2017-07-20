//
//  AdaptorProtocols.swift
//  StarJoinSelector
//
//  Created by apple on 21/08/2014.
//  Copyright © 2017 apple. All rights reserved.
//

import Foundation

// MARK: start of Adaptor Protocols AdaptorProtocols.swift

// MARK: required delegate protocols

// TODO: why do we need this?
// TODO: it looks like a mutable collection of some kind
// TODO: can it be actually an array?  can we generalise to non linear structures such as matrixes or trees?
public protocol TreeNavigable {
    associatedtype T = Self
    func add(child: Self)

    // this is a problematic one.  what's it for?
    func removeNodeFromParent()

    // TODO: check if I can drop !
    var childNodes: [T]! { get }
}

// this is a way to store metadata in the node itself, which lets us put the value in there so it can be retrieved without reference to the origianl array, for examine in 'each'.  I need to consider what this means.
public protocol NodeMetadata {
    // TODO: can this be Any in swift 4? I probably won't find out until I build real code
    var metadata: AnyObject? { get set }
}

// KVC protocol encapsulates the idea that values can be accessed using string accessors.  This enables one sort of interaction, bit it's not the only one.
public protocol KVC {
    // real functions

    func setValue(_ value: Any?, forKey:String) -> Void

    func value(forKey: String) -> Any?

    func setValue(_ value: Any?, forKeyPath:String) -> Void
    func value(forKeyPath: String) -> Any?

    // proxy functions
    func setNodeValue(_ toValue:Any?, forKeyPath keyPath:String)

    func setNodeValueAnimated(_ toValue:Any?, forKeyPath keyPath:String, withDuration: TimeInterval)

    // this feels closer to TreeNavigable
    func removeNodeFromParent(withDelay: TimeInterval)
}
