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
/*:
 ### Set up the canvas of SpriteKit
 */
let scene = SKScene()

let sceneView = SKView(frame: CGRect(x:0 , y:0, width: 640, height: 480))

// Add it to the Live View
import PlaygroundSupport
PlaygroundPage.current.liveView = sceneView

// Create the scene and add it to the view
scene.size = CGSize(width:640, height:480)
scene.scaleMode = .resizeFill
sceneView.presentScene(scene)
//: **Generated data**
//:
//: The best kind of data is different each time!  Let's make some like that.  A tuple keeps it simple:
typealias TableRow = (x: Float, y: Float, color: NSColor.Name, size: Float)

let colors = NSColorList(named:.init("Apple"))!

func nodeGenerator(xmax: Int, ymax:Int, size:Float) -> TableRow {
    return (x:Float((0..<xmax).randomElement()),
            y:Float((0..<ymax).randomElement()),
            colors.allKeys.randomElement(),
            size:size)
}

var nodeArray = [TableRow]()

//: The first data set has few members and large `size`.
for _ in 1...15 {
    _ = nodeArray.append(nodeGenerator(xmax: 640, ymax: 480, size: 50))
}
//: The second data set has more members, with smaller `size` and different positions.
var nodeArray2 = [TableRow]()

for _ in 1...150 {
    _ = nodeArray2.append(nodeGenerator(xmax: 640, ymax: 480, size: 20))
}
/*:
 ## Complex Selections

 In this example we use multiple operators to generate a set of selections, for the first and second data set.

 Each selection deals with a different aspect of the data arriving or departing.

 Look out for use of Single~ Join~ Enter~ Append~ and Update~ Selections below.
*/
let rootNode = SingleSelection<SKNode>(node: scene)

let mySelection = rootNode.select(all: scene.childNodes).join(nodeArray)
/*:
 ## First selection with the first data set
 The original data we draw uses the usual approach - `enter` and `append` all the data.
 */
let entered = mySelection.enter()

entered
    .append { (d, i) in SKSpriteNode() }
    .each { (s, d, i) -> () in
        if let sprite = s as? SKSpriteNode {
            sprite.position = CGPoint(x: CGFloat(d.x), y: CGFloat(d.y))
            sprite.color = colors.color(withKey:d.color) ?? .red
            sprite.size = CGSize(width: CGFloat(d.size), height: CGFloat(d.size))
        }
    }

/*:
  If you stopped the program here, you would see 15 or so red squares corresponding to the original data.

 * Callout(try this): try commenting out the rest of this playground to see the smaller set of data

 ![Screen shot of live view showing a few dots](FewDots.png)

 ## Second selection with the second, larger data set

 This 'selection' attempts to join the new data - 150 elements - to the existing nodes onscreen - just a few.
*/

let mySelection2 = rootNode.select(all: scene.childNodes).join(nodeArray2)

//: If there are *too many* elements onscreen, `Selection.remove` deletes the excess.  It's not doing anything in this example, because we have just added some nodes.  Try changing that!
mySelection2.exit().remove()


let entered2 = mySelection2.enter()
//: We still need new nodes for extra data rows, but we can choose not to configure them immediately
let appended2 = entered2
    .append { (_, _) in SKSpriteNode() }

// TODO: check d3.js still use the enter/append/update selection sematics or if that's fixed.
//: Instead grab all the nodes corresponding to updated data using the `update` selection–and configure your heart away!
let updated2 = mySelection2
    .update()

//: Going forward we want to deal with **all** the nodes: the new ones and the existing ones (but not the removed ones)
let merged2 = updated2
    .merge(with: appended2)

// should append BE the enter operation?
// how does enter affect the selection it owns?

/*:
 Finally, update all the nodes so the sprite properties match the new data.

 ![Screen shot of live view showing a few dots](ManyDots.png)
*/
merged2.each { (s, d, i) -> () in
        if let sprite = s as? SKSpriteNode {
            sprite.position = CGPoint(x: CGFloat(d.x), y: CGFloat(d.y))
            sprite.color = colors.color(withKey:d.color) ?? .red
            _ = sprite.size = CGSize(width: CGFloat(d.size), height: CGFloat(d.size))
        }
    }

//: [Next](@next)
