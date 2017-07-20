//
//  NumericConformances.swift
//  StarJoinSelector
//
//  Created by apple on 7/20/17.
//  Copyright © 2017 apple. All rights reserved.
//

import Foundation

//
//  NumericExtensions.swift
//  SpriteJoin
//
//  Created by apple on 24/08/2014.
//  Copyright (c) 2014 apple. All rights reserved.
//

import Foundation
import CoreGraphics
import StarJoin

extension Double: SJFloatingPointType {
    public func pow(_ lhs: Double, rhs: Double) -> Double {
        return Darwin.pow(lhs, rhs)
    }
    public func ceil(x:Double) -> Double {
        return Darwin.ceil(x)
    }
    public func floor(x:Double) -> Double {
        return Darwin.floor(x)
    }
    public func log(x:Double) -> Double {
        return Darwin.log(x)
    }
}

extension Float: SJFloatingPointType {
    public func pow(lhs: Float, rhs: Float) -> Float {
        return Darwin.pow(lhs, rhs)
    }
    public func ceil(x:Float) -> Float {
        return Darwin.ceil(x)
    }
    public func floor(x:Float) -> Float {
        return Darwin.floor(x)
    }
    public func log(x:Float) -> Float {
        return Darwin.log(x)
    }
}

//extension Float: SJFloatingPointType { }
extension CGFloat: SJFloatingPointType {
    public func pow(lhs: CGFloat, rhs: CGFloat) -> CGFloat {
        return CoreGraphics.pow(lhs, rhs)
    }
    public func ceil(x:CGFloat) -> CGFloat {
        return CoreGraphics.ceil(x)
    }
    public func floor(x:CGFloat) -> CGFloat {
        return CoreGraphics.floor(x)
    }
    public func log(x:CGFloat) -> CGFloat {
        return CoreGraphics.log(x)
    }
}

