/*: [Previous-Joining Structs](@previous)
# Evolving data by updating
 In this example, *mutation*, we improve upon the previous example: when new data replaces old data, the `update` method is used to update all nodes - not just the ones that are added.

 You should see just one size of elements on-screen.

 No animation is visible in this example

 * Callout(Recommended settings): Set the Scheme to `StarJoinSpriteKitAdaptor`
*/
import StarJoinSelector
import StarJoinSpriteKitAdaptor
import SpriteKit

let scene = SKScene()
//: **Generated data**
//:
//: The best kind of data is different each time!  Let's make some like that.  A tuple keeps it simple:
typealias TableRow = (x: Float, y: Float, color: NSColor.Name, size: Float)

let colors = NSColorList(named:.init("Apple"))!
func nodeGenerator(xmax: Int, ymax:Int, size:Float) -> TableRow {
    return (x:Float((0..<xmax).randomElement()),
            y:Float((0..<ymax).randomElement()),
            color: colors.allKeys.randomElement(),
            size:size)
}

var nodeArray = [TableRow]()

for _ in 1...(5..<15).randomElement() {
    _ = nodeArray.append(nodeGenerator(xmax: 1000, ymax: 600, size: 50))
}

var nodeArray2 = [TableRow]()

for _ in 1...(50..<150).randomElement() {
    _ = nodeArray2.append(nodeGenerator(xmax: 1000, ymax: 600, size: 20))
}
/*:
 ## Complex Selections
 In this example we perform multiple selections.
*/

let rootNode = SingleSelection<SKNode>(node: scene)

let mySelection = rootNode.select(all: scene.childNodes).join(nodeArray)

/*:
 ## First selection
 The original data we draw uses the usual approach - `enter` and `append` all the data.
 */
let entered = mySelection.enter()

entered.append { (d, i) in SKSpriteNode() }.each { (s, d, i) -> () in
        if let sprite = s as? SKSpriteNode {
            sprite.position = CGPoint(x: CGFloat(d.x), y: CGFloat(d.y))
            sprite.color = colors.color(withKey:d.color) ?? .red
            sprite.size = CGSize(width: CGFloat(d.size), height: CGFloat(d.size))

        }
    }


// MARK: select & join second batch

let mySelection2 = rootNode.select(all: scene.childNodes).join(nodeArray2)

// MARK: exit old nodes and enter new ones (fail to update)

// full enter/exit update example
mySelection2.exit().remove()

let entered2 = mySelection2.enter()

//: We still need new nodes for extra data rows, but we can choose not to configure them immediately
entered2.append { (_, _) in SKSpriteNode() }

// TODO: check d3.js still use the enter/append/update selection sematics or if that's fixed.
//: Instead grab all the nodes corresponding to updated data using the `update` selection–and configure your heart away!
let updated2 = mySelection2.update()

// should append BE the enter operation?
// how does enter affect the selection it owns?
updated2.each { (s, d, i) -> () in
        if let sprite = s as? SKSpriteNode {
            sprite.position = CGPoint(x: CGFloat(d.x), y: CGFloat(d.y))
            sprite.color = colors.color(withKey:d.color) ?? .red
            sprite.size = CGSize(width: CGFloat(d.size), height: CGFloat(d.size))
        }
    }
/*:
 ## Display boilerplate
 let's move the boring stuff down here now.
 */
let sceneView = SKView(frame: CGRect(x:0 , y:0, width: 640, height: 480))

// Add it to the Live View
import PlaygroundSupport
PlaygroundPage.current.liveView = sceneView

// Create the scene and add it to the view
scene.size = CGSize(width:640, height:480)
scene.scaleMode = .resizeFill
sceneView.presentScene(scene)
//: [Next](@next)
