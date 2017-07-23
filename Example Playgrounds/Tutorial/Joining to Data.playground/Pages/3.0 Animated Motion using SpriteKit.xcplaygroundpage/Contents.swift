
// This example animates color and position - using the each accessors and SKAction (hack for now) was eg9

/*: [Previous-Update forever quickly](@previous)
 # Silky 'tweening using SpriteKit
 Instead of controlling every frame using StarJoin, we can use SpriteKit's high performance animation routines to fill in between explicit frames.
 - Callout(performance): All the code is back in the playground, but is fast because most of the heavy lifting is in SpriteKit.  It runs smoothly at 60 fps (or some high rate)
 */
// WHERE ARE THE SKACTION ANIMATION NODES? TODO
//: links
//: * [Apple's SKAction documentation](https://developer.apple.com/documentation/spritekit/skaction?language=objcn)

import StarJoinSelector
import StarJoinSpriteKitAdaptor
import SpriteKit

let scene:SKScene = SKScene()

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

// MARK: Selection

let rootNode = SingleSelection<SKNode>(node: scene)

var period:TimeInterval = 1

var runCounter = 0

func updatePlot() {

    let cellCount = 1 + runCounter % 10

    runCounter += 1

    // Generate new dataset, slightly larger
    let nodeArray = tableGenerator(xmax:Int(scene.size.width), ymax:Int(scene.size.height), size:40.0, count:cellCount)

    let mySelection = rootNode.select(all: scene.childNodes).join(nodeArray)

    // remove nodes which don't have data
    mySelection.exit().remove()

    // existing nodes go red
    mySelection.update().attr("color", toValue: SKColor.red)
        .each { (s, d, i)  in
            (s as! SKSpriteNode).size = CGSize(width:CGFloat(d.size),
                                               height:CGFloat(d.size))
    }

    // new nodes
    mySelection.enter()
        .append { (d, i) in SKSpriteNode()}
        // start white
        .attr("color",toValue: SKColor.white)
        // jump to start position and grow in
        .each { (s, d, i) in
            s!.position = CGPoint(x:CGFloat(d.x), y:CGFloat(d.y))
            (s as! SKSpriteNode).size = CGSize(width:CGFloat(1), height:CGFloat(1))
            s!.run(.scale(to:CGFloat(d.size), duration: period))
    }

    mySelection.update().each { (s, d, i) in
        s!.run(.move(to:CGPoint(x:CGFloat(d.x), y:CGFloat(d.y)), duration: period))

    }
}

//: Run this update repeatedly using SKActions

func periodically(atInterval interval:TimeInterval, count:Int, action: SKAction) {
    let action = SKAction.repeat(.group(
        [.wait(forDuration: interval),
         action]), count: count)
    scene.run(action)
}

periodically(atInterval:period, count: 200, action:.run(updatePlot))


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



