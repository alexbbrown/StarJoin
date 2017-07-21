// Playground - noun: a place where people can play

// This example users the SKAxis component and animates growing axes.
// Note the use of oldscale to get entered scale components animating elegantly

// It chugs a little - that's the playground overhead.  In an app, it's fine.

// documentation
// https://developer.apple.com/library/ios/documentation/SpriteKit/Reference/SKAction_Ref/Reference/Reference.html#//apple_ref/occ/clm/SKAction/waitForDuration:
// https://developer.apple.com/library/ios/documentation/GraphicsAnimation/Conceptual/SpriteKit_PG/Actions/Actions.html#//apple_ref/doc/uid/TP40013043-CH4-SW1

import SpriteJoin
import SpriteJoinSpriteKit
import SpriteKit
import XCPlayground

// MARK: Enable SpriteKit for Playground
let colors = NSColorList(named:"Apple")!

let width:CGFloat = 1024
let height:CGFloat = 768

// Create the SpriteKit View
let spriteView:SKView = SKView(frame: CGRectMake(0, 0, width, height))

// Add it to the TimeLine
XCPShowView("Live View", view:spriteView)

// Create the scene and add it to the view
let scene:SKScene = SKScene(size: CGSizeMake(width, height))
spriteView.presentScene(scene)


// MARK: Data Configuration

// This form uses tuples rather than dictionaries

typealias TableRow = (x:Float, y:Float, color:String, size:Float)

func rangeRandom(min:Int, _ max:Int) -> Int {
    return min + Int(arc4random_uniform(UInt32(max - min)))
}

func rangeRandomOrdinals<T>(ordinals: [T]) -> T {
    var count = ordinals.count
    return ordinals[rangeRandom(0, count - 1)]
}

// nodeGenerator assumes minimum is 0
func nodeGenerator(xmax:Int, _ ymax:Int, _ size:Float) -> TableRow {
    return (x:Float(rangeRandom(0, xmax)),
            y:Float(rangeRandom(0, ymax)),
            color:rangeRandomOrdinals(colors.allKeys) as String,
            size:size)
}

func tableGenerator(xmax xmax:Int, ymax:Int, size:Float, count:Int) -> [TableRow] {
    var nodeArray = [TableRow]()

    for i in 1...count {
        nodeArray.append(nodeGenerator(xmax, ymax, size))
    }

    return nodeArray
}

// Cyclic runner

func repeatedlyExecute(block: (()->()), atInterval interval:NSTimeInterval, count:Int) {
    let action = SKAction.repeatAction(SKAction.group(
        [SKAction.waitForDuration(interval),
         SKAction.runBlock(block)]),count:count)
    scene.runAction(action)
}

// MARK: Selection



// create a layer for the plot
let plotNode = SKNode()
scene.addChildNode(plotNode)

// just a junky sprite
let aSprite = SKSpriteNode()

aSprite.color = SKColor.redColor()
aSprite.size = CGSize(width:10,height:10)

scene.addChild(aSprite)


let plot = SingleSelection<SKNode>(node: plotNode)


// variables to control the 'animation'
var period:NSTimeInterval = 1
var count = 200
var runCounter = 0

var margin:CGFloat = 100

var valueMax:Float = 100.0

/* Setup your scene here */



let xScale = LinearScale<CGFloat>(domain: [0,CGFloat(valueMax)],
                                  range: (margin,width-margin))


let yScale = LinearScale<CGFloat>(domain:[0,CGFloat(valueMax)],
                                  range:(margin,height-margin))

// MARK: Data Configuration

// create a layer for the axes
let axesNode = SKNode()
let xAxisNode = SKNode()
let yAxisNode = SKNode()
scene.addChildNode(axesNode)
axesNode.addChildNode(xAxisNode)
axesNode.addChildNode(yAxisNode)

var oldXScale:LinearScale<CGFloat>? = nil
var oldYScale:LinearScale<CGFloat>? = nil

func updatePlot() {

    // scales

    valueMax *= 1.1

    let generationCount = 1 + runCounter % 3

    let cellCount = 10 * generationCount

    runCounter++

    let maxRange = valueMax

    let xScale = LinearScale<CGFloat>(domain:[0,CGFloat(maxRange)],
                                      range:(margin,width-margin))


    let yScale = LinearScale<CGFloat>(domain:[0,CGFloat(maxRange)],
                                      range:(margin,height-margin))

    // Generate new dataset, slightly larger

    let intMaxRange:Int = Int(maxRange)

    let nodeArray = tableGenerator(xmax: intMaxRange,ymax: intMaxRange,size: 40,count: cellCount)

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
            NSValue(point:CGPointMake(xScale.scale(CGFloat(d!.x))!, yScale.scale(CGFloat(d!.y))!))
    }

    // Update axes

    xAxisNode.position = CGPoint(x:0, y:yScale.scale(0.0)!)

    yAxisNode.position = CGPoint(x:xScale.scale(0.0)!, y:0)

    //lineNode.position =

    let xAxisSelection = SingleSelection<SKNode>(node: xAxisNode)

    let yAxisSelection = SingleSelection<SKNode>(node: yAxisNode)

    let xAxis = SKAxis<CGFloat,CGFloat>(scale: xScale, side: AxisSide.bottom)

    xAxis.enterScale = oldXScale

    xAxis.lineColor = NSColor.whiteColor()
    xAxis.lineWidth = 1

    xAxisSelection.call(xAxis.make)

    let yAxis = SKAxis<CGFloat,CGFloat>(scale: yScale, side: AxisSide.left)

    yAxis.enterScale = oldYScale

    yAxis.lineColor = NSColor.whiteColor()
    yAxis.lineWidth = 1

    yAxisSelection.call(yAxis.make)

    oldXScale = xScale
    oldYScale = yScale
}

repeatedlyExecute(updatePlot, atInterval:period, count:count)


