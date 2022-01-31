//
//  GameScene.swift
//  SpriteJoinGame
//
//  Created by apple on 21/08/2014.
//  Copyright (c) 2014 apple. All rights reserved.
//

import SpriteKit
import SpriteJoin
import SpriteJoinSpriteKit
import SpriteKit

let arc4RandomMax = Double(0x100000000)
func Random01() -> Double
{
    var randDouble = Double(arc4random())
    return randDouble / arc4RandomMax
}


func rangeRandom(minV:UInt32, _ maxV:UInt32) -> UInt32 {
    return minV + UInt32(arc4random_uniform(min(UInt32.max, maxV - minV)))
}

func rangeRandomOrdinals<T>(ordinals: [T]) -> T {
    var count = ordinals.count
    return ordinals[Int(rangeRandom(UInt32(0), UInt32(count - 1)))]
}

class GameScene: SKScene {

    var valueMax:Float = 100.0

    // MARK: Enable SpriteKit for Playground
    let colors = NSColorList(named:"Apple")!

    // This form uses tuples rather than dictionaries
    typealias TableRow = (x:Float, y:Float, color:String, size:Float)

    // nodeGenerator assumes minimum is 0
    func nodeGenerator(xmax:Int, ymax:Int, size:Float) -> TableRow {
        // Note: this will crash eventually when INT maxes out. don't worry (or fix it)
        return (x:Float(rangeRandom(0, UInt32(xmax))),
                y:Float(rangeRandom(0, UInt32(ymax))),
                color:rangeRandomOrdinals(colors.allKeys),
                size:size)
    }

    func tableGenerator(xmax:Int, ymax:Int, size:Float, count:Int) -> [TableRow] {
        var nodeArray = [TableRow]()

        for i in 1...count {
            nodeArray.append(nodeGenerator(xmax, ymax: ymax, size: size))
        }

        return nodeArray
    }



    override func didMoveToView(view: SKView) {
        /* Setup your scene here */

        let width = self.size.width
        let height = self.size.height

        let margin:CGFloat = 100

        let xScale = LinearScale<CGFloat>(domain: [0,CGFloat(valueMax)],
                                          range: (margin,width-margin))


        let yScale = LinearScale<CGFloat>(domain:[0,CGFloat(valueMax)],
                                          range:(margin,height-margin))

        // Create the SpriteKit View
        let spriteView:SKView = view

        // MARK: Data Configuration

        // Cyclic runner

        func repeatedlyExecute(block: (()->()), atInterval interval:NSTimeInterval, count:Int) {
            let action = SKAction.repeatAction(SKAction.group(
                [SKAction.waitForDuration(interval),
                 SKAction.runBlock(block)]),count:count)
            self.runAction(action)
        }

        let plotNode = SKNode()
        self.addChild(plotNode)

        let plot = SingleSelection<SKNode>(node: plotNode)

        // variables to control the 'animation'
        var period:NSTimeInterval = 1
        var count = 200
        var runCounter = 0

        // create a layer for the axes
        let axesNode = SKNode()
        let xAxisNode = SKNode()
        let yAxisNode = SKNode()
        self.addChildNode(axesNode)
        axesNode.addChildNode(xAxisNode)
        axesNode.addChildNode(yAxisNode)

        var oldXScale:LinearScale<CGFloat>? = nil
        var oldYScale:LinearScale<CGFloat>? = nil

        func updatePlot() {

            // scales

            self.valueMax *= 1.1

            let generationCount = 1 + runCounter % 3

            let cellCount = 10 * generationCount

            runCounter++

            let maxRange = self.valueMax

            let xScale = LinearScale<CGFloat>(domain:[0,CGFloat(maxRange)],
                                              range:(margin,width-margin))


            let yScale = LinearScale<CGFloat>(domain:[0,CGFloat(maxRange)],
                                              range:(margin,height-margin))

            // Generate new dataset, slightly larger

            let intMaxRange:Int = Int(maxRange)

            let nodeArray = self.tableGenerator(intMaxRange,ymax: intMaxRange,size: 40,count: cellCount)

            let mySelection = plot.selectAll(allChildrenSelector).join(nodeArray)

            // kill dead nodes
            mySelection
                .exit()
                .transition(duration: period)
                .setKeyedAttr("alpha",toValue: 0)
                .remove()

            // existing nodes go red - or blue on purge cycles
            mySelection
                .update()
                .transition(duration: period)
                .setKeyedAttr("color") { _ in
                    if generationCount == 1 {
                        return SKColor.blueColor()
                    } else {
                        return SKColor.redColor()
                    }
                }

            // new nodes
            mySelection.enter()
                .append { _ in SKSpriteNode()}
            // start white
                .setKeyedAttr("color",toValue: SKColor.whiteColor())
            // jump to start position and grow in
                .each { (s, d, i) in
                    s!.position = CGPointMake(xScale.scale(CGFloat(d!.x))!, yScale.scale(CGFloat(d!.y))!)
                    (s as! SKSpriteNode).size = CGSizeMake(CGFloat(1), CGFloat(1))
                }
                .transition(duration: period)
            // grow in
                .setKeyedAttr("scale") { (s, d, i) in CGFloat(d!.size) }


            mySelection
                .update()
                .transition(duration: period)
                .setKeyedAttr("position") { (s, d, i) in
                    SKPoint(x:xScale.scale(CGFloat(d!.x))!, y:yScale.scale(CGFloat(d!.y))!)
                }

            // Update axes

            xAxisNode.position = CGPoint(x:0, y:yScale.scale(0.0)!)

            yAxisNode.position = CGPoint(x:xScale.scale(0.0)!, y:0)

            //lineNode.position =

            let xAxisSelection = SingleSelection<SKNode>(node: xAxisNode)

            let yAxisSelection = SingleSelection<SKNode>(node: yAxisNode)

            let xAxis = SKAxis<CGFloat,CGFloat>(scale: xScale, side: .bottom)

            xAxis.enterScale = oldXScale

            xAxis.lineColor = NSColor.whiteColor()
            xAxis.lineWidth = 1

            xAxisSelection.call(xAxis.make)

            let yAxis = SKAxis<CGFloat,CGFloat>(scale: yScale, side: .left)

            yAxis.enterScale = oldYScale

            yAxis.lineColor = NSColor.whiteColor()
            yAxis.lineWidth = 1

            yAxisSelection.call(yAxis.make)

            oldXScale = xScale
            oldYScale = yScale
        }

        repeatedlyExecute(updatePlot, atInterval:period, count:count)
    }

    override func mouseDown(theEvent: NSEvent) {
        /* Called when a mouse click occurs */

        let location = theEvent.locationInNode(self)

        valueMax = 100.0

        //        let sprite = SKSpriteNode(imageNamed:"Spaceship")
        //        sprite.position = location;
        //        sprite.setScale(0.5)
        //
        //        let action = SKAction.rotateByAngle(CGFloat(M_PI), duration:1)
        //        sprite.runAction(SKAction.repeatActionForever(action))
        //
        //        self.addChild(sprite)
    }

    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
