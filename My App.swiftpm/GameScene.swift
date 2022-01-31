//
//  GameScene.swift
//  SpriteJoinGame
//
//  Created by apple on 21/08/2014.
//  Copyright (c) 2014 apple. All rights reserved.
//

import SpriteKit
import StarJoinSelector
import StarJoinSpriteKitAdaptor

let arc4RandomMax = Double(0x100000000)
func Random01() -> Double
{
    Double.random(in: 0 ... 1.0)
}


func rangeRandom(minV:UInt32, maxV:UInt32) -> UInt32 {
    UInt32.random(in: minV ... maxV)
}

func rangeRandomOrdinals<T>(ordinals: [T]) -> T {
    ordinals.randomElement()!
}

class GameScene: SKScene {
    
    var valueMax:Float = 100.0
    
    // MARK: Enable SpriteKit for Playground
//    let colors = NSColorList(named:"Apple")

    let colors = ["red", "green", "blue", "yellow"]

    // This form uses tuples rather than dictionaries
    typealias TableRow = (x:Float, y:Float, color:String, size:Float)
    
    // nodeGenerator assumes minimum is 0
    func nodeGenerator(xmax: Int, ymax: Int, size: Float) -> TableRow {
        return (x: Float(Int.random(in: 0 ..< xmax)),
                y: Float(Int.random(in: 0 ..< ymax)),
                color: colors.randomElement()!,
                size:size)
    }
    
    func tableGenerator(_ xmax:Int, _ ymax:Int, size: Float, count: Int) -> [TableRow] {
        var nodeArray = [TableRow]()
        
        for _ in 1...count {
            nodeArray.append(
                nodeGenerator(xmax: xmax, ymax: ymax, size: size)
            )
        }
        
        return nodeArray
    }

    override func didMove(to view: SKView) {
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
        
        func repeatedlyExecute(_ block: @escaping (()->()), atInterval interval: TimeInterval, count:Int) {
            let action = SKAction.repeat(SKAction.group(
                [SKAction.wait(forDuration: interval),
                 SKAction.run(block)]),count:count)
            self.run(action)
        }
        
        let plotNode = SKNode()
        self.addChild(plotNode)
        
        let plot = SingleSelection<SKNode>(node: plotNode)
        
        // variables to control the 'animation'
        var period: TimeInterval = 1
        var count = 200
        var runCounter = 0
        
        // create a layer for the axes
        let axesNode = SKNode()
        let xAxisNode = SKNode()
        let yAxisNode = SKNode()
        self.add(child: axesNode)
        axesNode.add(child: xAxisNode)
        axesNode.add(child: yAxisNode)
        
        var oldXScale:LinearScale<CGFloat>? = nil
        var oldYScale:LinearScale<CGFloat>? = nil
        
        func updatePlot() {
            
            // scales
            
            valueMax *= 1.1
            
            let generationCount = 1 + runCounter % 3
            
            let cellCount = 10 * generationCount
            
            runCounter += 1
            
            let maxRange = valueMax
            
            let xScale = LinearScale<CGFloat>(domain:[0,CGFloat(maxRange)],
                                              range:(margin,width-margin))
            
            
            let yScale = LinearScale<CGFloat>(domain:[0,CGFloat(maxRange)],
                                              range:(margin,height-margin))
            
            // Generate new dataset, slightly larger
            
            let intMaxRange:Int = Int(maxRange)
            
            let nodeArray = tableGenerator(
                intMaxRange,
                intMaxRange,
                size: 40,
                count: cellCount
            )
            
            let mySelection = plot
                .select(all: allChildrenSelector).join(nodeArray)
            
            // kill dead nodes
            mySelection
                .exit()
                .transition(duration: period)
                .attr("alpha", toValue: 0)
                .remove()
            
            // existing nodes go red - or blue on purge cycles
            mySelection
                .update()
                .transition(duration: period)
                .attr("color") { _, _, _ -> SKColor in
                    if generationCount == 1 {
                        return .blue
                    } else {
                        return .red
                    }
            }
            
            // new nodes
            mySelection.enter()
                .append { _, _ in SKSpriteNode() }
                // start white
                .attr("color", toValue: SKColor.white)
                // jump to start position and grow in
                .each { (s, d, i) in
                    s!.position = CGPoint(
                        x: xScale.scale(CGFloat(d.x))!,
                        y: yScale.scale(CGFloat(d.y))!
                    )
                    (s as! SKSpriteNode).size = CGSize(
                        width: 1,
                        height: 1
                    )
                }
                .transition(duration: period)
                // grow in
                .attr("scale") { (s, d, i) in CGFloat(d.size) }
            
            
            mySelection
                .update()
                .transition(duration: period)
                .attr("position") { (s, d, i) in
                    NSValue(cgPoint: CGPoint(
                        x: xScale.scale(CGFloat(d.x))!,
                        y: yScale.scale(CGFloat(d.y))!
                    ))
            }
            
            // Update axes
            
            xAxisNode.position = CGPoint(x:0, y:yScale.scale(0.0)!)
            
            yAxisNode.position = CGPoint(x:xScale.scale(0.0)!, y:0)
            
            //lineNode.position =
            
            let xAxisSelection = SingleSelection<SKNode>(node: xAxisNode)
            
            let yAxisSelection = SingleSelection<SKNode>(node: yAxisNode)
            
            let xAxis = SKLinearAxis(scale: xScale, side: .bottom)
            
            xAxis.enterScale = oldXScale
            
            xAxis.lineColor = SKColor.white
            xAxis.lineWidth = 1
            
            xAxisSelection.call(xAxis.make)
            
            let yAxis = SKAxis<CGFloat, (scale: yScale, side: .left)
            
            yAxis.enterScale = oldYScale
            
            yAxis.lineColor = SKColor.white
            yAxis.lineWidth = 1
            
            yAxisSelection.call(function: yAxis.make)

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
