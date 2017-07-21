//
//  MoreScales.swift
//  StarJoinSelector
//
//  Created by apple on 7/19/17.
//  Copyright © 2017 apple. All rights reserved.
//

import Foundation

//
//  from Scale.swift
//  SpriteJoin
//
//  Created by apple on 21/08/2014.
//  Copyright (c) 2014 apple. All rights reserved.
//

// DateScale is just a linear scale with better ticks.
open class DateScale<D:SJFloatingPointType> : LinearScale<D> where D.Stride == D {

    public override init(domain: [D]?, range: (D,D)?) {
        super.init(domain: domain, range: range)
    }

    override open func copy() -> DateScale {

        return DateScale(domain: domain, range: range)
    }

    // toy ticks for now.
    open override func ticks(_ count:D = 10.0) -> [D] {
        // nice code taken directly from d3
        if let domain = domain {
            return DateExtent<D>(domain: domain).ticks(count: count)
        } else { return [] }
    }


}

open class OrdinalScale<D : Equatable, R:SJFloatingPointType> : Scale<D,R> {

    public override init(domain: [D]?, range: (R,R)?) {
        super.init(domain: domain, range: range)
    }

    open override func scale(_ dv:D) -> R? {

        switch (range, domain) {
        case (.some(let r), .some(let d)):
            let dExtent = d.count
            if let dvIndex = d.index(of: dv) {
                return r.0 + R(dvIndex) / (R(dExtent)-1) * (r.1 - r.0)
            } else {
                return nil
            }
        default:
            return nil
        }
    }
}

open class OrdinalRangeBandsScale<D : Equatable, R:SJFloatingPointType> : Scale<D,R> {

    open var padding:R = 0.0

    public override init(domain: [D]?, range: (R,R)?) {
        super.init(domain: domain, range: range)
    }

    open override func scale(_ dv:D) -> R? {

        switch (range, domain) {
        case (.some(let r), .some(let d)):
            let dExtent = R(d.count)
            if let dvIndex = d.index(of: dv) {
                let X1:R = r.1 - r.0
                let X2:R = padding * (dExtent - 1)
                let X3:R = outerPadding * 2
                let bandWidth:R = (X1 - X2 - X3) / dExtent
                let a:R = (bandWidth + padding) * R(dvIndex)
                return outerPadding + r.0 + a + bandWidth / R(2)
            } else {
                return nil
            }
        default:
            return nil
        }
    }

    open func bandWidth() -> R? {

        switch (range, domain) {
        case (.some(let r), .some(let d)):
            let dExtent = R(d.count)
            let X1:R = r.1 - r.0
            let X2:R = padding * (dExtent - 1)
            let X3:R = outerPadding * 2
            let bandWidth:R = (X1 - X2 - X3) / dExtent
            return bandWidth
        default:
            return nil
        }
    }

    open func band(_ dv:D) -> (left:R,right:R)? {

        switch (range, domain) {
        case (.some(let r), .some(let d)):
            let dExtent = R(d.count)
            if let dvIndex = d.index(of: dv) {
                let X1:R = r.1 - r.0
                let X2:R = padding * (dExtent - 1)
                let X3:R = outerPadding * 2
                let bandWidth:R = (X1 - X2 - X3) / dExtent
                return (left:outerPadding + r.0 + (bandWidth + padding) * R(dvIndex),
                        right:outerPadding + r.0 + (bandWidth + padding) * R(dvIndex) + bandWidth)
            } else {
                return nil
            }
        default:
            return nil
        }
    }
}

extension OrdinalRangeBandsScale:Equatable { }

public func ==<D, R>(lhs: OrdinalRangeBandsScale<D,R>, rhs: OrdinalRangeBandsScale<D,R>) -> Bool {
    if let lr = lhs.range {
        if let rr = rhs.range {
            if lr.0 != rr.0 || lr.1 != rr.1 { return false }
        } else { return false }
    } else { return false }
    if let ld = lhs.domain {
        if let rd = rhs.domain {
            if ld == rd { return true }
        }
    }
    return false
}


open class WeightedOrdinalRangeBandsScale<D : Equatable, R:SJFloatingPointType> : Scale<D,R> {

    open var padding:R = 0.0

    // weights should have same length as domain!
    // for the moment, let's make the type R to keep the compiler quiet
    open var weights:[R]

    fileprivate func cumWeight(_ i:Int) -> R {
        var cumWeight = R(0)
        for index in 0 ..< i {
            cumWeight = cumWeight + weights[index]
        }
        return cumWeight
    }

    public init(domain: [D], range: (R,R), weights:[R]) {
        self.weights = weights
        super.init(domain: domain, range: range)
    }

    open override func scale(_ dv:D) -> R? {

        switch (range, domain) {
        case (.some(let r), .some(let d)):
            if let dvIndex = d.index(of: dv) {
                let dExtent = cumWeight(d.count)
                let dCount = R(d.count)
                let dCumWeight = cumWeight(dvIndex)

                let X1:R = r.1 - r.0
                let X2:R = padding * (dCount - 1)
                let X3:R = outerPadding * 2
                let unitBandwidth:R = (X1 - X2 - X3) / dExtent
                let a = (unitBandwidth) * dCumWeight + padding * R(dvIndex)
                let weight = weights[dvIndex]
                let dBandwidth = weight * unitBandwidth
                return outerPadding + r.0 + a + dBandwidth / R(2)
            } else {
                return nil
            }
        default:
            return nil
        }
    }

    open func bandWidth(_ dv:D) -> R? {

        switch (range, domain) {
        case (.some(let r), .some(let d)):
            if let dvIndex = d.index(of: dv) {
                let dExtent = cumWeight(d.count)
                let dCount = R(d.count)

                let X1:R = r.1 - r.0
                let X2:R = padding * (dCount - 1)
                let X3:R = outerPadding * 2
                let unitBandwidth:R = (X1 - X2 - X3) / dExtent

                let weight = weights[dvIndex]
                return weight * unitBandwidth
            } else {
                return nil
            }
        default:
            return nil
        }
    }

    open func band(_ dv:D) -> (left:R,right:R)? {

        switch (range, domain) {
        case (.some(let r), .some(let d)):
            if let dvIndex = d.index(of: dv) {
                let dExtent = cumWeight(d.count)
                let dCount = R(d.count)
                let dCumWeight = cumWeight(dvIndex)

                let X1:R = r.1 - r.0
                let X2:R = padding * (dCount - 1)
                let X3:R = outerPadding * 2
                let unitBandwidth:R = (X1 - X2 - X3) / dExtent

                let a = (unitBandwidth) * dCumWeight + padding * R(dvIndex)
                let weight = weights[dvIndex]
                let bandWidth = weight * unitBandwidth
                return (left:outerPadding + r.0 + a,
                        right:outerPadding + r.0 + a + bandWidth)
            } else {
                return nil
            }
        default:
            return nil
        }
    }
}
