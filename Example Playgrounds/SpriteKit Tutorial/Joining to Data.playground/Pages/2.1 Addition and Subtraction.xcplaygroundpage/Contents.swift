//: [Previous-Section 1](@previous)
/*: [Previous-Joining Structs](@previous)
# Evolving data by adding and removing
 This example demonstrates that programmatically generated data (it's random) works just as well as static data.

 Since can generate new and different data we use that to get two rounds of data - and demonstrate the process of **refreshing the data and nodes** - where *new nodes* get *new values*, but *existing nodes* ignore their new parameters (*that's a deliberate bug that's fixed in the next example*)

 While this is not a perfect
 use case of d3, it is a precursor to animation - where EXISTING nodes get
 their new values animated in over time.

*/
import StarJoinSelector
import SpriteKit
import StarJoinSpriteKitAdaptor
import PlaygroundSupport

let scene = SKScene()

//: **Generated data**
//:
//: The best kind of data is different each time!  Let's make some like that.  A tuple keeps it simple:
typealias TableRow = (x: Float, y: Float, color: NSColor.Name, size: Float)

func rangeRandom(min:Int, max:Int) -> Int {
    return min + Int(arc4random_uniform(UInt32(max - min)))
}

func rangeRandom<T>(ordinals: [T]) -> T {
    return ordinals[rangeRandom(min: 0, max: ordinals.count - 1)]
}

let colors = NSColorList(named:.init("Apple"))!
func nodeGenerator1(xmax: Int, ymax:Int, size:Float) -> TableRow {
    return (x:Float(rangeRandom(min: 0, max: xmax)),
            y:Float(rangeRandom(min: 0, max: ymax)),
            color: rangeRandom(ordinals:colors.allKeys),
            size:size)
}

var nodeArray = [TableRow]()

for _ in 1...rangeRandom(min: 5, max: 15) {
    nodeArray.append(nodeGenerator1(xmax: 1000, ymax: 600, size: 50))
}

var nodeArray2 = [TableRow]()

for _ in 1...rangeRandom(min: 50, max: 150) {
    nodeArray2.append(nodeGenerator1(xmax: 1000, ymax: 600, size: 20))
}
/*:
 ## Complex Selections
 In this example we perform multiple selections.
 * Callout(Ninja Tip):
 The root node's type is `SKSceneNode`, but since it's children might be any sort of `SKNode`, we need to insist-by templating:
*/

let rootNode = SingleSelection<SKNode>(node: scene)

let mySelection = rootNode.selectAll(allChildrenSelector).join(nodeArray)

/*:
 ## First selection
 The original data we draw uses the usual approach - `enter` and `append` all the data.
*/

let entered = mySelection.enter()

entered.append { (s, d, i) -> SKNode in
    return SKSpriteNode()
    }
//: * Callout(Ninja Tip): For more complex node configuration, `attr` can be replaced by `each` - which has no return value but expects `s` - the node - to be modified
entered.each { (s, d, i) -> () in
        if let sprite = s as? SKSpriteNode {
            sprite.position = CGPoint(x: CGFloat(d!.x), y: CGFloat(d!.y))
            sprite.color = colors.color(withKey:d!.color) ?? .red
            sprite.size = CGSize(width: CGFloat(d!.size), height: CGFloat(d!.size))

        }
    }


//: ## Updating your data
//: Updating data looks the same as adding your original data to begin with Run select again.  The original selection is forgotten, but the nodes are still there - for the moment.

let mySelection2 = rootNode.selectAll(scene.childNodes).join(nodeArray2)

//: Another select operator : `exit` selects only the nodes which no longer have data - and the `remove` modifier destroys them.  Later on we'll see how special effects can be added
//: * experiment: try making the second data set longer or shorter - what happens?
mySelection2.exit().remove()

let entered2 = mySelection2.enter()

entered2.append { (_, _, _) in
    return SKSpriteNode()
    }.each { (s, d, i) -> () in
        if let sprite = s as? SKSpriteNode {
            sprite.position = CGPoint(x: CGFloat(d!.x), y: CGFloat(d!.y))
            sprite.color = colors.color(withKey:d!.color) ?? .red
            sprite.size = CGSize(width: CGFloat(d!.size), height: CGFloat(d!.size))


        }
    }

//: [Next–Mutating existing nodes](@next)
/*:
 ## Display boilerplate
 let's move the boring stuff down here now.
 */
let sceneView = SKView(frame: CGRect(x:0 , y:0, width: 640, height: 480))

// Add it to the Live View
PlaygroundPage.current.liveView = sceneView
PlaygroundPage.current.needsIndefiniteExecution = true

// Create the scene and add it to the view
scene.size = CGSize(width:640, height:480)
scene.scaleMode = .resizeFill
sceneView.presentScene(scene)

//: [Next–Mutating existing nodes](@next)


