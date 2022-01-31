//
//  SKAxis.swift
//  StarJoinSpriteKitAdaptor
//
//  Created by alex on 7/20/17.
//  Copyright © 2017 Alex B Brown. All rights reserved.
//

//
//  SKAxis.swift
//  SpriteJoin
//
//  Created by alex on 23/08/2014.
//  Copyright (c) 2014 Alex B Brown. All rights reserved.
//
// SKAxis is a SpriteNode operator - it is 'called' on
// an SKNode and it generates an axis for the supplied
// scale.
//
// It can be mutated, but mutation only sets the (styling)
// parameters for the next application
//
// It is reasonable and safe to throw away the operator
// and build a new one as required (for the same axis)

import Swift
import Foundation
import SpriteKit
import StarJoinSelector

public enum AxisSide:String {
    case left
    case right
    case top
    case bottom
}

// for backward compatibility.
public class SKLinearAxis<DomainType:Hashable,RangeType:SJFloatingPointType>:SKAxis<DomainType,RangeType> {}

// TODO: make this an SKNode subclass, add action for animation
public class SKAxis<DomainType:Hashable,RangeType:SJFloatingPointType> {

    // configure
    public var lineColor:SKColor = SKColor.gray
    public var fontColor:SKColor = SKColor.white
    public var fontSize:CGFloat = 20
    public var lineWidth:CGFloat = 4
    public var tickLength:CGFloat? = 10
    public var gridLength:CGFloat?
    public var animationDuration:Double = 1
    public var niceTickCount:Int = 10
    public var tickFunction:(ScaleType) -> [DomainType] = { (s) in [] }

    public typealias DomainLabelFormatterType = (DomainType) -> String

    public var tickLabelFormatter:DomainLabelFormatterType?

    public var accessoryGenerator:((DomainType) -> SKNode)?

    public typealias ScaleType = Scale<DomainType,CGFloat>

    public var enterScale:ScaleType?

    var scale:ScaleType

    public var side:AxisSide

    /// :side: arranges subcomponents to fit one side of the plot.
    // caller is responsible for placement of the axis in the non axis direction
    public init(scale: ScaleType) {

        self.scale = scale
        self.side = AxisSide.bottom
        gridLength = nil
        enterScale = nil

        tickFunction = ({ (s) in s.ticks(CGFloat(self.niceTickCount)) } as (ScaleType) -> [DomainType])
    }

    public convenience init(scale: ScaleType, side:AxisSide) {
        self.init(scale:scale)
        self.side = side
    }


    public func make(axisSelection:SingleSelection<SKNode>) -> () {

        let axisNode:SKNode = axisSelection.node

        // Draw the axis line

        // should select for the lineNode here?
        // or could append

        let line = SingleSelection(node: axisNode)

        let lineChildren = line.select(all: allChildrenNamedSelector(name: "line"))

        let lineJoin = lineChildren
            .join(["line"])

        let lineEnter = lineJoin.enter()

        let linePositionFn = {(lineNode:SKSpriteNode) -> () in
            let length = self.scale.range!.1 - self.scale.range!.0

            switch self.side {
            case .bottom, .top:
                lineNode.size = CGSize(width:length + self.lineWidth, height:self.lineWidth)
                lineNode.position = CGPoint(x:self.scale.range!.0 - self.lineWidth / 2, y:0)
                lineNode.anchorPoint = CGPoint(x:0,y:0.5)

            case .left, .right:
                lineNode.size = CGSize(width:self.lineWidth, height:length + self.lineWidth)
                lineNode.position = CGPoint(x:0, y:self.scale.range!.0 - self.lineWidth / 2)
                lineNode.anchorPoint = CGPoint(x:0.5,y:0)
            }
            lineNode.color = self.lineColor
        }


        //        let lineNodePositionFn =

        let appended = lineEnter.append{ (d,i) -> SKSpriteNode in
            let lineNode = SKSpriteNode()
            lineNode.name = "line"
            return lineNode
            }.each { (s,d,i) in if let lineNode = s as? SKSpriteNode { linePositionFn(lineNode) } }

        //let width:CGFloat = self.scale.scaleDistance(100.0)

        lineJoin
            .update()
            .merge(with: appended)
            .each { (s,d,i) in if let lineNode = s as? SKSpriteNode { linePositionFn(lineNode) } }

        // Draw the axis ticks

        var ticksNode:SKNode
        if let existingNode = axisNode.childNode(withName: "tickGroup") as? SKSpriteNode {
            ticksNode = existingNode
        } else {
            ticksNode = SKSpriteNode()
            ticksNode.name = "tickGroup"
            axisNode.addChild(ticksNode)
        }

        let ticks = SingleSelection(node: ticksNode)

        let niceTicks = self.tickFunction(self.scale)

        let tickSelectAll = ticks.select(all: allChildrenSelector)

        let tickJoin = tickSelectAll.join(niceTicks, keyFunction: { (d, i) in d })

        let enterTicks = tickJoin
            .enter()
            .append { (d, i) in SKSpriteNode() }

        enterTicks
            .each({ (s, d, i) -> () in

                if let tick = s as? SKSpriteNode {
                    if let tickLength = self.tickLength {
                        switch self.side {
                        case .bottom, .top:
                            tick.size = CGSize(width: self.lineWidth, height: tickLength)
                            tick.anchorPoint = CGPoint(x:0.5,y:1)
                        case .left:
                            tick.size = CGSize(width: tickLength, height: self.lineWidth)
                            tick.anchorPoint = CGPoint(x:1,y:0.5)
                        case .right:
                            tick.size = CGSize(width: tickLength, height: self.lineWidth)
                            tick.anchorPoint = CGPoint(x:0,y:0.5)
                        }
                    }

                    tick.color = self.lineColor

                }
            })

        var enterScale = self.scale

        if let realEnterScale = self.enterScale {
            enterScale = realEnterScale
        }

        enterTicks
            .attr("position") { (s, d, i) in
                switch self.side {
                case .bottom, .top:
                    if let x = enterScale.scale(d) as CGFloat? {
                        return CGPoint(x:x, y:0)
                    }
                case .left, .right:
                    if let y = enterScale.scale(d) as CGFloat? {
                        return CGPoint(x:0, y:y)
                    }
                }
                return nil
        }

        let appendedTicks = enterTicks
            .append2 { (s, d, i) in namedNode(node:SKLabelNode(),"label") }
            .each({ (s, d, i) in
                if let label = s as? SKLabelNode {

                    label.fontSize = self.fontSize
                    label.fontColor = self.fontColor
                    label.fontName = "HelveticaNeue"

                    if let accessoryGenerator = self.accessoryGenerator {
                        let accessoryNode = accessoryGenerator(d)
                        label.addChild(accessoryNode)
                    }

                    switch self.side {
                    case .bottom, .top:
                        label.verticalAlignmentMode = .top
                        label.horizontalAlignmentMode = .left
                    case .left:
                        label.horizontalAlignmentMode = .right
                        label.verticalAlignmentMode = .center

                    case .right:
                        label.horizontalAlignmentMode = .left
                        label.verticalAlignmentMode = .center
                    }
                    //
                }
            })
            .each({ (s, d, i) in // Positioning
                if let label = s as? SKLabelNode {
                    var tickLength:CGFloat = 0

                    if let l = self.tickLength {
                        tickLength = l
                    }

                    switch self.side {
                    case .bottom, .top:
                        label.position = CGPoint(x:0, y:-2*tickLength)

                    case .left:
                        label.position = CGPoint(x:-2*tickLength,y:0)

                    case .right:
                        label.position = CGPoint(x:+2*tickLength,y:0)
                    }
                    //
                }
            })

        if animationDuration > 0 && self.enterScale != nil {

            enterTicks
                .attr("alpha",toValue: CGFloat(0.0))
                .transition(duration: animationDuration)

            enterTicks
                .transition(duration: animationDuration)
                .attr("alpha",toValue: CGFloat(1.0))
        }

        let mergedTicks = tickJoin
            .update()
            .merge(with: enterTicks)

        mergedTicks
            .each({ (s, d, i) in
                if let s = s {
                    if let label = s.childNode(withName: "label") as? SKLabelNode {
                        if let tickLabelFormatter = self.tickLabelFormatter {
                            label.text = tickLabelFormatter(d)
                        } else {
                            label.text = "\(d)"
                        }
                    }
                }
            })


        let animatedTicks = mergedTicks
            .transition(duration: animationDuration)

        switch self.side {
        case .bottom, .top:
            animatedTicks
                .attr("position") { (s, d, i) in

                    if let x = self.scale.scale(d) {
                        return CGPoint(x:x, y:0)
                    }
                    return nil
            }

        case .left, .right:
            animatedTicks
                .attr("position") { (s, d, i) in

                    if let y = self.scale.scale(d) {
                        return CGPoint(x:0, y:y)
                    }
                    return nil
            }
        }

        let animatedExit = tickJoin.exit()
            .transition(duration: animationDuration)

        // scale lookups of exiting values on updated scales can be problematic for ordinals where the
        // value is no longer present.  Should fail gracefully in this case.
        animatedExit
            .attr("alpha",toValue: CGFloat(0.0))


        switch self.side {
        case .bottom, .top:
            animatedExit
                .attr("position") { (s, d, i) in
                    if let x = self.scale.scale(d) {
                        return CGPoint(x:x, y:0)
                    }
                    return nil
            }

        case .left, .right:
            animatedExit
                .attr("position") { (s, d, i) in
                    if let y = self.scale.scale(d) {
                        return CGPoint(x:0, y:y)
                    }
                    return nil
            }
        }

        animatedExit
            .remove()

        self.enterScale = scale.copy()


    }

}

