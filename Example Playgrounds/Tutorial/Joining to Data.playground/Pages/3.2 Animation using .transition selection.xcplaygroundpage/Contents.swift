
// This example animates color and position -using scales and the transition selection was eg11

/*: [Previous-Update forever quickly](@previous)
 # Describe animation using selections
 The transition selection is a way to encapsulate `SpriteKit's` powerful animations behind the facade of the `attr` interface.  This improves reusability and avoids crossing API boundaries while you work.
 * Callout(New operators): look out for the `transition(withDelay:)` operator.  It makes `attr` calls chained after it animate over time.
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

// Scale Configuration

var margin:CGFloat = 100

let xScale = LinearScale<CGFloat>(domain: [0,100], range:(margin,scene.size.width-margin))

let yScale = LinearScale<CGFloat>(domain: [0,100], range:(margin,scene.size.height-margin))

// MARK: Selection

let rootNode = SingleSelection<SKNode>(node: scene)

var period:TimeInterval = 1

var runCounter = 0

func updatePlot() {

    let generationCount = 1 + runCounter % 5

    let cellCount = 1 + runCounter % 10
    
    runCounter += 1
    
    // Generate new dataset, slightly larger
    let nodeArray = tableGenerator(xmax:100, ymax:100, size:40.0, count:cellCount)
    
    let mySelection = rootNode.select(all: scene.childNodes).join(nodeArray)
    
    // remove nodes which don't have data
    //: * note: It must be your birthday, there's a whole new super cool selection operator - transition - which allows animations!
    mySelection
        .exit()
        .transition(duration: 0.5)
        .attr("alpha", toValue:0) // CGFloat?
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

    // new nodes
    mySelection.enter()
        .append { (d, i) in SKSpriteNode()}
        // start white
        .attr("color",toValue: SKColor.white)
        // jump to start position and grow in
        .each { (s, d, i) in
            s!.position = CGPoint(x: xScale.scale(CGFloat(d.x))!,
                                  y: yScale.scale(CGFloat(d.y))!)
            (s as! SKSpriteNode).size = CGSize(width:CGFloat(1), height:CGFloat(1))
            s!.run(.scale(to:CGFloat(d.size), duration: period))
            }
            
            mySelection
                .update()
                .transition(duration: period)
                .attr("position") { (s, d, i) in
                    CGPoint(x: xScale.scale(CGFloat(d.x))!,
                            y: yScale.scale(CGFloat(d.y))!)
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




