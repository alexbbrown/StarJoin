
// This example uses xScale and yScale to move data coordinates into view coordinates.  Size is still managed by view coordinates (useful since they are points).  was eg10

/*: [Previous-Update forever quickly](@previous)
 # Silky 'tweening using SpriteKit
 Instead of controlling every frame using StarJoin, we can use SpriteKit's high performance animation routines to fill in between explicit frames.
 - Callout(performance): All the code is back in the playground, but is fast because most of the heavy lifting is in SpriteKit.  It runs smoothly at 60 fps (or some high rate)
 */

//: links
//: * [Apple's SKAction documentation](https://developer.apple.com/documentation/spritekit/skaction?language=objcn)

import StarJoinSelector
import StarJoinSpriteKitAdaptor
import SpriteKit

let scene:SKScene = SKScene(size: .init(width: 640, height: 480))

// MARK: Enable SpriteKit for Playground

// MARK: Data Configuration

typealias TableRow = (x:Float, y:Float, color:NSColor.Name, size:Float)

let range = 0..<10

range.last


//: * note:  `range.randomElement()` is found in this playground's Sources
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

// Scale Configuration

var margin:CGFloat = 100

extension CGFloat: SJFloatingPointType {
    public func pow(_ lhs: CGFloat, _ rhs: CGFloat) -> CGFloat {
        return CoreGraphics.pow(lhs, rhs)
    }
    public func ceil(_ x:CGFloat) -> CGFloat {
        return CoreGraphics.ceil(x)
    }
    public func floor(_ x:CGFloat) -> CGFloat {
        return CoreGraphics.floor(x)
    }
    public func log(_ x:CGFloat) -> CGFloat {
        return CoreGraphics.log(x)
    }
}

let xScale = LinearScale<CGFloat>(domain: [0,100], range:(margin,scene.size.width-margin))

let yScale = LinearScale<CGFloat>(domain: [0,100], range:(margin,scene.size.height-margin))

// MARK: Selection

let rootNode = SingleSelection<SKNode>(node: scene)

var period:TimeInterval = 1
var count = 200

var runCounter = 0

func updatePlot() {

    let cellCount = 1 + runCounter % 10

    runCounter += 1

    // Generate new dataset, slightly larger
    let nodeArray = tableGenerator(xmax:100, ymax:100, size:40.0, count:cellCount)

    let mySelection = rootNode.selectAll(scene.childNodes).join(nodeArray)

    // remove nodes which don't have data
    mySelection.exit().remove()

    // existing nodes go red
    mySelection.update().attr("color", toValue: SKColor.red)
        .each { (s, d, i)  in
            (s as! SKSpriteNode).size = CGSize(width:CGFloat(d!.size),
                                               height:CGFloat(d!.size))
    }

    // new nodes
    mySelection.enter()
        .append { (s, d, i) in SKSpriteNode()}
        // start white
        .attr("color",toValue: SKColor.white)
        // jump to start position and grow in
        .each { (s, d, i) in
            s!.position = CGPoint(x:xScale.scale(CGFloat(d!.x))!, y:yScale.scale(CGFloat(d!.y))!)
            (s as! SKSpriteNode).size = CGSize(width:CGFloat(1), height:CGFloat(1))
            s!.run(.scale(to:CGFloat(d!.size), duration: period))
    }

    mySelection.update().each { (s, d, i) in
        s!.run(.move(to: CGPoint(
            x: xScale.scale(CGFloat(d!.x))!,
            y: yScale.scale(CGFloat(d!.y))!)
            , duration: period))
    }
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




