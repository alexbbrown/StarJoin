//
//  Scales.swift
//  StarJoinSelector
//
//  Created by alex on 7/19/17.
//  Copyright © 2017 Alex B Brown. All rights reserved.
//

import Foundation

//
//  Scale.swift
//  SpriteJoin
//
//  Created by alex on 21/08/2014.
//  Copyright (c) 2014 Alex B Brown. All rights reserved.
//

import Foundation

open class Scale<D,R : SJFloatingPointType> {

    public final var range:(R,R)?
    open var domain:[D]?
    public final var outerPadding:R = R(0)

    public init() {

    }

    public init(domain: [D]?, range: (R,R)?) {
        self.domain = domain
        self.range = range
    }

    open func scale(_ dv:D) -> R? {
        return nil
    }

    open func scaleDistance(_ dv:D) -> R? {
        return nil
    }

    /// Return a set of nice domain values
    open func ticks(_ count:R = 10.0) -> [D] {
        return domain ?? []
    }

    open func copy() -> Scale {

        return Scale(domain: domain, range: range) // this seems very dodgy
    }
}

open class LinearScale<D:SJFloatingPointType> : Scale<D,D> where D.Stride == D {

    // Optimisation - let LinearScale always deal with a concrete tuple (optional)
    override open var domain:[D]? {
        didSet { domainPair = LinearScale.domainToDomainPair(domain) }
    }

    var domainPair:(D,D)?

    class func domainToDomainPair(_ domain:[D]?) -> (D,D)? {
        if let domain = domain {
            if domain.count == 2 {
                return (domain[0],domain[1])
            }
        }
        return nil
    }

    public override init(domain: [D]?, range: (D,D)?) {

        domainPair = LinearScale.domainToDomainPair(domain)

        super.init(domain: domain, range: range)

    }

    override open func copy() -> LinearScale {

        return LinearScale(domain: domain, range: range)
    }

    open func clone(_ rangeOffset:D) -> LinearScale<D>? {

        guard let range = range else { return nil }

        let newRange = (range.0 + rangeOffset, range.1 + rangeOffset)
        let newDomain = [invert(newRange.0)!, invert(newRange.1)!]

        return LinearScale<D>(domain: newDomain, range: newRange)
    }

    open override func scale(_ dv:D) -> D? {
        switch (range, domainPair) {
        case let (.some(r), .some(d)):
            return r.0 + ((dv - d.0) / (d.1 - d.0)) * (r.1 - r.0)
        default:
            return nil;
        }
    }

    open func invert(_ rv:D) -> D? {
        switch (range, domainPair) {
        case let (.some(r), .some(d)):
            return d.0 + ((rv - r.0) / (r.1 - r.0)) * (d.1 - d.0)
        default:
            return nil;
        }
    }

    open override func scaleDistance(_ dv:D) -> D? {
        switch (range, domainPair) {
        case let (.some(r), .some(d)):

            let zero = ((0 - d.0) / (d.1 - d.0)) * (r.1 - r.0)
            let end = ((dv - d.0) / (d.1 - d.0)) * (r.1 - r.0)

            return end - zero
        default:
            return nil;
        }
    }

    open override func ticks(_ count:D = 10.0) -> [D] {
        // nice code taken directly from d3
        if let domain = domain {
            return LinearExtent<D>(domain: domain).ticks(count: count)
        } else { return [] }

    }


}

extension LinearScale:Equatable { }

public func ==<D>(left: LinearScale<D>, right: LinearScale<D>) -> Bool {
    return (left.range?.0 == right.range?.0) && (left.range?.1 == right.range?.1)
        && (left.domain?[0] == right.domain?[0]) && (left.domain?[1] == right.domain?[1])
}

