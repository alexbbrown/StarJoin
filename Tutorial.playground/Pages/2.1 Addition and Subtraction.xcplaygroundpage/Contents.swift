//:
/*: [Previous-Section 1](@previous) | [Previous-Joining Structs](@previous)
# Evolving data by adding and removing

 This example demonstrates that data doesn't need to be static.  We can generate and update it dynamically, and use that to update the nodes on screen multiple times.

 ![Screen shot of playground showing squares in different sizes and textures](screenshot.png)

 But it also contains a bug: some nodes already on screen don't properly get updated: You can see Large and Small boxes, even though the final version of the data is large.

 This issue is fixed in the next example which uses the `update` operator, and in the example after that we use this technique to create animate as the data changes.

 You will see two sizes of boxes: the small ones from the first batch

 There's no animation visible in this example.  See "Change over time".

 * Callout(Recommended settings): Set the Scheme to `StarJoinSpriteKitAdaptor`
*/
import StarJoinSelector
import StarJoinSpriteKitAdaptor
import SpriteKit
//: ### Set-up SpriteKit and the Playgrounds Live View
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
typealias TableRow = (x: Float, y: Float, texture: SKTexture, size: Float)
let colors = NSColorList(named:.init("Apple"))!

let textures = [#imageLiteral(resourceName: "wood1.jpg"), #imageLiteral(resourceName: "water1.jpg")].map(SKTexture.init(image:))

func nodeGenerator(xmax: Int, ymax:Int, size:Float) -> TableRow {
    return (x:Float((0..<xmax).randomElement()!),
            y:Float((0..<ymax).randomElement()!),
            texture: textures.randomElement()!,
            size:size)
}

var nodeArray = [TableRow]()

//: The first data set has size 60, and few nodes
for _ in 1...(5..<15).randomElement()! {
    nodeArray.append(nodeGenerator(xmax: 1000, ymax: 600, size: 60))
}

var nodeArray2 = [TableRow]()

//: The second data set has a larger size, but more nodes.
for _ in 1...(50..<150).randomElement()! {
    // Note: using _ here avoids very expensively updating the "Result" panel.
    _ = nodeArray2.append(nodeGenerator(xmax: 1000, ymax: 600, size: 20))
}
/*:
 ## Complex Selections
 In this example we perform multiple selections.
 * Callout(Ninja Tip):
 The root node's type is `SKSceneNode`, but since it's children might be any sort of `SKNode`, we need to insist-by templating:
*/

let rootNode = SingleSelection<SKNode>(node: scene)

let mySelection = rootNode.select(all: allChildrenSelector).join(nodeArray)

/*:
 ## First selection
 The original data we draw uses the usual approach - `enter` and `append` all the data.
*/

let entered = mySelection.enter()

entered
    .append { (d, i) in SKSpriteNode() }
//: * Callout(Ninja Tip): For more complex node configuration, `attr` can be replaced by `each` - which has no return value but expects `s` - the node - to be modified.  We need to cast `s` down to the type we expect.
    .each { (s, d, i) -> () in
        if let sprite = s as? SKSpriteNode {
            sprite.position = CGPoint(x: CGFloat(d.x), y: CGFloat(d.y))
            sprite.texture = d.texture
            sprite.size = CGSize(width: CGFloat(d.size), height: CGFloat(d.size))
        }
    }


//: ## Updating your data
//: Updating data looks the same as adding your original data to begin with Run select again.  The original selection is forgotten, but the nodes are still there - for the moment.

let mySelection2 = rootNode.select(all: scene.childNodes).join(nodeArray2)

//: Another select operator : `exit` selects only the nodes which no longer have data - and the `remove` modifier destroys them.  Later on we'll see how special effects can be added
//: * experiment: try making the second data set longer or shorter - what happens?
mySelection2.exit().remove()

let entered2 = mySelection2.enter()

entered2.append { (_, _) in
    return SKSpriteNode()
    }.each { (s, d, i) -> () in
        if let sprite = s as? SKSpriteNode {
            sprite.position = CGPoint(x: CGFloat(d.x), y: CGFloat(d.y))
            sprite.texture = d.texture
            sprite.size = CGSize(width: CGFloat(d.size), height: CGFloat(d.size))
        }
    }


//: [Next–Mutating existing nodes](@next)


