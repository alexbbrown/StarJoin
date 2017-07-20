
// This example users the SKAxis component and animates growing axes.
// Note the use of oldscale to get entered scale components animating elegantly

// It chugs a little - that's the playground overhead.  In an app, it's fine.

/*: [Previous-Update forever quickly](@previous)
 # Building complex representation - Axes
  This demo shows an example of a complex feature built using StarJoin - the axis.  All the elements in the axis are created by mapping objects to Sprites.  Here it's packaged up into a new class - take a look at the source.
 */

import StarJoinSelector
import StarJoinSpriteKitAdaptor
import SpriteKit

let scene:SKScene = SKScene(size: .init(width: 640, height: 480))

// MARK: Enable SpriteKit for Playground

// MARK: Data Configuration

typealias TableRow = (x:Float, y:Float, color:NSColor.Name, size:Float)
let colors = NSColorList(named:.init("Apple"))!
func nodeGenerator(xmax: Int, ymax:Int, size:Float) -> TableRow {
    return (x:Float((0..<xmax).randomElement()),
            y:Float((0..<ymax).randomElement()),
            color: colors.allKeys.randomElement(),
            size:size)
}

func tableGenerator(xmax:Int, ymax:Int, size:Float, count:Int) -> [TableRow] {
    var nodeArray = [TableRow]()

    for _ in 1...count {
        nodeArray.append(nodeGenerator(xmax:xmax, ymax:ymax, size:size))
    }

    return nodeArray
}

/*: ## Layers organise your scene
 All the examples until this one have put all the sprites directly in the scene, as children of the SKScene node `scene`.  As your designs become more complex it's useful to wrap them up inside named nodes.  These can then be moved, scaled and hidden independently.
 */

//: ### Plot layer contains all the elements corresponding directly to your data, as before
//: create the plot layer as a `SKNode`, then add a single sprite to it, for good measure.
let plotNode = SKNode()
scene.addChild(plotNode)

//: just a junky sprite (why?)
let aSprite = SKSpriteNode()

aSprite.color = .red
aSprite.size = .init(width:10,height:10)

scene.addChild(aSprite)

//: create a layer for both of the axes, and a sublayer for each axis.
let axesNode = SKNode()
let xAxisNode = SKNode()
let yAxisNode = SKNode()
scene.addChild(axesNode)
axesNode.addChild(xAxisNode)
axesNode.addChild(yAxisNode)

// Scale Configuration

var margin:CGFloat = 100

var valueMax:Float = 100.0

let xScale = LinearScale<CGFloat>(domain: [0,100], range:(margin,scene.size.width-margin))

let yScale = LinearScale<CGFloat>(domain: [0,100], range:(margin,scene.size.height-margin))

// some magic perhaps
var oldXScale:LinearScale<CGFloat>? = nil
var oldYScale:LinearScale<CGFloat>? = nil

// MARK: Selection

let plot = SingleSelection<SKNode>(node: plotNode)

var period:TimeInterval = 1
var count = 200

var runCounter = 0

func updatePlot() {

    //: zoom forever
    valueMax *= 1.1

    let generationCount = 1 + runCounter % 5

    let cellCount = 10 * generationCount

    runCounter += 1

    let maxRange = valueMax

    let xScale = LinearScale<CGFloat>(
        domain:[0,CGFloat(maxRange)],
        range:(margin,scene.size.width-margin))


    let yScale = LinearScale<CGFloat>(
        domain:[0,CGFloat(maxRange)],
        range:(margin,scene.size.height-margin))


    // Generate new dataset, slightly larger
    let intMaxRange:Int = Int(maxRange)

    let nodeArray = tableGenerator(
        xmax: intMaxRange,
        ymax: intMaxRange,
        size: 40,
        count: cellCount)

    let mySelection = plot
        .selectAll(allChildrenSelector)
        .join(nodeArray)

    // remove nodes which don't have data
    //: * note: It must be your birthday, there's a whole new super cool selection operator - transition - which allows animations!
    mySelection
        .exit()
        .transition(duration: period)
        .attr("alpha", toValue:0)
        .remove()

    // existing nodes go red - or blue on purge cycles
    mySelection
        .update()
        .transition(duration: period)
        .attr("color") { (s, d, i) in
            if generationCount == 1 {
                return SKColor.blue
            } else {
                return SKColor.red
            }
    }
    //        .each { (s, d, i)  in
    //            (s as! SKSpriteNode).size = CGSize(width:CGFloat(d!.size),
    //                                               height:CGFloat(d!.size))
    //    }

    // new nodes
    mySelection.enter()
        .append { (s, d, i) in SKSpriteNode()}
        // start white
        .attr("color",toValue: SKColor.white)
        // jump to start position and grow in
        .each { (s, d, i) in
            s!.position = CGPoint(x: xScale.scale(CGFloat(d!.x))!,
                                  y: yScale.scale(CGFloat(d!.y))!)
            (s as! SKSpriteNode).size = CGSize(width:CGFloat(1), height:CGFloat(1))
            s!.run(.scale(to:CGFloat(d!.size), duration: period))
    }

    //    mySelection.update().each { (s, d, i) in
    //        s!.run(.move(to: CGPoint(
    //            x: xScale.scale(CGFloat(d!.x))!,
    //            y: yScale.scale(CGFloat(d!.y))!)
    //            , duration: period))
    //    }

    mySelection
        .update()
        .transition(duration: period)
        .attr("position") { (s, d, i) in
            CGPoint(x: xScale.scale(CGFloat(d!.x))!,
                    y: yScale.scale(CGFloat(d!.y))!)
    }

    // Update axes

    xAxisNode.position = CGPoint(x:0, y:yScale.scale(0.0)!)

    yAxisNode.position = CGPoint(x:xScale.scale(0.0)!, y:0)

    //lineNode.position =


    let xAxisSelection = SingleSelection<SKNode>(node: xAxisNode)

    let yAxisSelection = SingleSelection<SKNode>(node: yAxisNode)

    let xAxis = SKAxis<CGFloat,CGFloat>(scale: xScale, side: AxisSide.bottom)


    xAxis.enterScale = oldXScale

    xAxis.lineColor = .white
    xAxis.lineWidth = 1

    xAxisSelection.call(function:xAxis.make)

    let yAxis = SKAxis<CGFloat,CGFloat>(scale: yScale, side: AxisSide.left)

    yAxis.enterScale = oldYScale

    yAxis.lineColor = .white
    yAxis.lineWidth = 1

    yAxisSelection.call(function:yAxis.make)

    oldXScale = xScale
    oldYScale = yScale
    #if false

    #endif

}

//: Run this update repeatedly using SKActions

func periodically(atInterval interval:TimeInterval, count:Int, action: SKAction) {
    let action = SKAction.repeat(.group(
        [.wait(forDuration: interval),
         action]), count: count)
    scene.run(action)
}

periodically(atInterval:period, count:count, action:.run(updatePlot))


/*:
 ## Display boilerplate
 let's move the boring stuff down here now.
 */
let sceneView = SKView(frame: CGRect(x:0 , y:0, width: 640, height: 480))

// Add it to the Live View
import PlaygroundSupport
PlaygroundPage.current.liveView = sceneView
PlaygroundPage.current.needsIndefiniteExecution = true

// Create the scene and add it to the view
scene.scaleMode = .resizeFill
sceneView.presentScene(scene)





