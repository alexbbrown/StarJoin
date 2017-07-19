//: [Previous–Joining Tuples](@previous)
//:# Dictionaries to Sprites

import StarJoinSelector
import SpriteKit
import StarJoinSpriteKitAdaptor
import PlaygroundSupport
/*:
 Enable SpriteKit for Playground
 */
let sceneView = SKView(frame: CGRect(x:0 , y:0, width: 640, height: 480))

// Add it to the TimeLine
PlaygroundSupport.PlaygroundPage.current.liveView = sceneView

// Create the scene and add it to the view
let scene:SKScene = SKScene(size: CGSize(width:640, height:480))
scene.scaleMode = .resizeFill
sceneView.presentScene(scene)
//: **Data from the internet**
//:
//: Let's use a table-an array of dictionaries–as our data model this time, and bind that.  This sort of data might be loaded off disk or as Json from the internet, and is pretty common.
var nodeArray = [
    ["x":100, "y":100, "color":"Red", "size":50],
    ["x":200, "y":200, "color":"Orange", "size":50],
    ["x":300, "y":300, "color":"Blue", "size":50],
]
//: We need a way to translate text colors to colors.
let colors = NSColorList(named:.init("Apple"))
func color(_ named:String) -> SKColor? {
    return colors!.color(withKey:.init(named))
}
//: **Selection** picks a root node and 'joins' it to the data

let mySelection = select(node:scene as SKNode)
    .selectAll(allChildrenSelector)
    .join(nodeArray)

//: **enter** focuses on the new nodes we need,
//: **append** summons a new sprite, and
//: **attr** sets sprite properties using the **dictionary** data value `d`.
//: + Casting is often necessary for dictionaries; '`!`' is used here for brevity - `if let` patterns are also a good option
mySelection
    .enter()
    .append { (_, _, _) in SKSpriteNode() }
    .attr("position") { (s, d, i) in SKPoint(x:d!["x"] as! Int,y:d!["y"] as! Int) }
    .attr("size") { (s, d, i) in SKSize(width:d!["size"] as! Int,height:d!["size"] as! Int) }
    .attr("color") { (s, d, i) in color(d!["color"] as! String) }
//:   What's `(s, d, i)`?
//:   - `d` is whatever the current record is - a row from the data array
//:   - `s` is the sprite, which can be useful.
//:   - `i` is the index in the array this element is from.  Can be used to order elements if you don't want absolute positioning (more on this later)
//:
//: [Next–Joining Structs](@next)
