/*: [Previous-Joining Structs](@previous)
# Adding Complexity in Data and Nodes
 In the mutation example, when new data replaces old data, the `update` method is used to update all nodes - not just the ones that are added.

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
*/

let rootNode = SingleSelection<SKNode>(node: scene)

let mySelection = rootNode.selectAll(scene.childNodes).join(nodeArray)

/*:
 ## First selection
 The original data we draw uses the usual approach - `enter` and `append` all the data.
 */
let entered = mySelection.enter()

entered.append { (s, d, i) -> SKNode in
    return SKSpriteNode()
    }.each { (s, d, i) -> () in
        if let sprite = s as? SKSpriteNode {
            sprite.position = CGPoint(x: CGFloat(d!.x), y: CGFloat(d!.y))
            sprite.color = colors.color(withKey:d!.color) ?? .red
            sprite.size = CGSize(width: CGFloat(d!.size), height: CGFloat(d!.size))

        }
    }


// MARK: select & join second batch

let mySelection2 = rootNode.selectAll(scene.childNodes).join(nodeArray2)

// MARK: exit old nodes and enter new ones (fail to update)

// full enter/exit update example
mySelection2.exit().remove()

let entered2 = mySelection2.enter()

//: We still need new nodes for extra data rows, but we can choose not to configure them immediately
entered2.append { (_, _, _) in
    return SKSpriteNode()
}

// TODO: check d3.js still use the enter/append/update selection sematics or if that's fixed.
//: Instead grab all the nodes corresponding to updated data using the `update` selection–and configure your heart away!
let updated2 = mySelection2.update()

// should append BE the enter operation?
// how does enter affect the selection it owns?
updated2.each { (s, d, i) -> () in
        if let sprite = s as? SKSpriteNode {
            sprite.position = CGPoint(x: CGFloat(d!.x), y: CGFloat(d!.y))
            sprite.color = colors.color(withKey:d!.color) ?? .red
            sprite.size = CGSize(width: CGFloat(d!.size), height: CGFloat(d!.size))


        }
    }


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

//: [Next](@next)

