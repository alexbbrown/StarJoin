//
//  Extent.swift
//  StarJoinSelector
//
//  Created by alex on 7/19/17.
//  Copyright © 2017 Alex B Brown. All rights reserved.
//

import Foundation

//
//  Extent.swift
//  SpriteJoin
//
//  Created by alex on 24/08/2014.
//  Copyright (c) 2014 Alex B Brown. All rights reserved.
//

import Foundation
import Swift

open class Extent<D:SJFloatingPointType> {

    open var domain:[D]

    public init(domain: [D]) {
        self.domain = domain
    }

    open func ticks(count:D = 10.0) -> [D] {
        return [0.0 as D]
    }
}

open class LinearExtent<D:SJFloatingPointType> : Extent<D> where D.Stride == D {

    public override init(domain: [D]) {
        super.init(domain: domain)
    }

    open override func ticks(count:D = 10.0) -> [D] {
        // nice code taken directly from d3

        let d:D = 0.0

        let span = domain[1] - domain[0]
        var step = d.pow(10.0, d.floor(d.log(span / count) / d.log(10.0)))
        let err = count / span * step

        // Filter ticks to get closer to the desired count.
        if err <= 0.15 { step = step * 10.0 }
        else if err <= 0.35 { step = step * 5.0 }
        else if err <= 0.75 { step = step * 2.0 }

        var ticks = [D]()

        //        let niceDomain = (start:domain[0], end:domain[1])

        let niceDomain = (
            start:d.ceil(domain[0] / step) * step,
            end:d.floor(domain[1] / step) * step + step * 0.5
        )

        for tick:D in stride(from:niceDomain.start, through: domain[1], by: step) {
            ticks.append(tick)
        }

        return ticks
    }


}

#if true


//#import "NSDate_ABLERound.h"
//
//@implementation NSDate (ABLERound)
//
//NSTimeInterval floorDate(unsigned long long date, unsigned long long period) {
//    return date - (date % period);
//}
//
//NSTimeInterval ceilDate(unsigned long long date, unsigned long long period) {
//    return ((date % period) == 0)
//        ? date
//        : (date + (period - (date % period)));
//}
//
//-(NSDate*)dateWithFloorForAlignment:(NSTimeInterval)period;
//{
//    return [NSDate dateWithTimeIntervalSinceReferenceDate:floorDate([self timeIntervalSinceReferenceDate],period)];
//}
//
//-(NSDate*)dateWithCeilingForAlignment:(NSTimeInterval)period;
//{
//    return [NSDate dateWithTimeIntervalSinceReferenceDate:ceilDate([self timeIntervalSinceReferenceDate],period)];
//}
//
//@end

public func ceilToInterval(_ timeInterval:TimeInterval, unit:TimeInterval, offset:TimeInterval = 0) -> TimeInterval {
    if (timeInterval + offset).truncatingRemainder(dividingBy: unit) == 0 {
        return timeInterval
    } else {
        return (timeInterval) + (unit - (timeInterval + offset).truncatingRemainder(dividingBy: unit))
    }
}

public func floorToInterval(_ timeInterval:TimeInterval, unit:TimeInterval, offset:TimeInterval = 0) -> TimeInterval {
    return timeInterval - (timeInterval + offset).truncatingRemainder(dividingBy: unit)
}

public func floorToInterval(_ date:Date, unit:TimeInterval, offset:TimeInterval = 0) -> Date {
    return Date(timeIntervalSinceReferenceDate: floorToInterval(date.timeIntervalSinceReferenceDate, unit: unit, offset:offset))
}

public func ceilToInterval(_ date:Date, unit:TimeInterval, offset:TimeInterval = 0) -> Date {
    return Date(timeIntervalSinceReferenceDate: ceilToInterval(date.timeIntervalSinceReferenceDate, unit: unit, offset:offset))
}

open class DateExtent<D:SJFloatingPointType> : LinearExtent<D> where D.Stride == D {

    public override init(domain: [D]) {
        super.init(domain: domain)
    }

    open override func ticks(count:D = 10.0) -> [D] {

        // get the first hour
        let firstDate = domain[0]
        let roundBy = D(4*3600)
        let roundedHour:D = firstDate + (roundBy - firstDate.truncatingRemainder(dividingBy:roundBy))

        let ticks = stride(from: roundedHour, through: domain[1], by: 14400)

        return Array(ticks)
    }
}

#endif

