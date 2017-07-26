//
//  NumericProtocols.swift
//  StarJoinSelector
//
//  Created by apple on 7/19/17.
//  Copyright © 2017 apple. All rights reserved.
//

import Foundation

//
//  NumericProtocol.swift
//  SpriteJoin
//
//  Created by apple on 24/08/2014.
//  Copyright (c) 2014 apple. All rights reserved.
//

import Foundation

public protocol SJFloatingPointType : ExpressibleByFloatLiteral, FloatingPoint {

    associatedtype Stride = Self

    static func ==(_:Self,_:Self) -> Bool

    static func +(_:Self,_:Self) -> Self
    //func +(_:Self,_:Float) -> Self
    static func += (left: inout Self, right: Self)

    static func *(_:Self,_:Self) -> Self
    static func /(_:Self,_:Self) -> Self
    static func -(_:Self,_:Self) -> Self
//    static func %(_:Self,_:Self) -> Self

    func pow(_:Self,_:Self) -> Self
    func ceil(_:Self) -> Self
    func floor(_:Self) -> Self
    func log(_:Self) -> Self
    func truncatingRemainder(dividingBy other: Self) -> Self

    init(integerLiteral value: IntegerLiteralType)
    init(floatLiteral value: FloatLiteralType)


    init(_ value: Float)
    init(_ value: Double)

}


