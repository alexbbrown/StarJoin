// This example uses xScale and yScale to move data coordinates into view coordinates.  Size is still managed by view coordinates (useful since they are points).

// documentation
// https://developer.apple.com/library/ios/documentation/SpriteKit/Reference/SKAction_Ref/Reference/Reference.html#//apple_ref/occ/clm/SKAction/waitForDuration:
// https://developer.apple.com/library/ios/documentation/GraphicsAnimation/Conceptual/SpriteKit_PG/Actions/Actions.html#//apple_ref/doc/uid/TP40013043-CH4-SW1

import SpriteJoin
import SpriteKit
import SpriteJoinSpriteKit
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

func rangeRandom(_ min:Int, _ max:Int) -> Int {
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

func tableGenerator(xmax:Int, _ ymax:Int, _ size:Float, _ count:Int) -> [TableRow] {
    var nodeArray = [TableRow]()

    for i in 1...count {
        nodeArray.append(nodeGenerator(xmax, ymax, size))
    }

    return nodeArray
}

// Cyclic runner

func repeatedlyExecute(block: (()->()), atInterval interval:NSTimeInterval, count count:Int) {
    let action = SKAction.repeatAction(SKAction.group(
        [SKAction.waitForDuration(interval),
         SKAction.runBlock(block)]),count:count)
    scene.runAction(action)
}

// MARK: Selection

let rootNode = SingleSelection<SKNode>(node: scene)

var period:NSTimeInterval = 1
var count = 200

var runCounter = 0

var margin:CGFloat = 100

let xScale = LinearScale<CGFloat>(domain: [0,100], range:(margin,width-margin))

let yScale = LinearScale<CGFloat>(domain: [0,100], range:(margin,height-margin))

func updatePlot() {

    var cellCount = 1 + runCounter % 10

    runCounter++

    // Generate new dataset, slightly larger
    let nodeArray = tableGenerator(100,100,40,cellCount)

    let mySelection = rootNode.selectAll(scene.childNodes).join(nodeArray)

    // kill dead nodes
    mySelection.exit().remove()

    // existing nodes go red
    mySelection.update().setKeyedAttr("color",toValue:SKColor.redColor())
        .each { (s, d, i)  in
            (s as! SKSpriteNode).size = CGSizeMake(CGFloat(d!.size),
                                                   CGFloat(d!.size))
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
            s!.runAction(SKAction.scaleTo(CGFloat(d!.size), duration: period))
    }

    mySelection.update().each { (s, d, i) in
        s!.runAction(SKAction.moveTo(CGPointMake(xScale.scale(CGFloat(d!.x))!, yScale.scale(CGFloat(d!.y))!), duration: period))

    }
}


repeatedlyExecute({ _ in updatePlot() }, atInterval:period, count:count)




