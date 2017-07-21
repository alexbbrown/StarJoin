//: [Previous-Joining Dictionaries](@previous)
//:# Structs to Sprites
import StarJoinSelector
import StarJoinSpriteKitAdaptor
import SpriteKit
/*:
 Enable SpriteKit for Playground
 */
let sceneView = SKView(frame: CGRect(x:0 , y:0, width: 640, height: 480))

// Add a spritekit window to the Live View
import PlaygroundSupport
PlaygroundSupport.PlaygroundPage.current.liveView = sceneView

// Create the scene and add it to the view
let scene:SKScene = SKScene(size: CGSize(width:640, height:480))
scene.scaleMode = .resizeFill
sceneView.presentScene(scene)

//: **More Serious Data**
//:
//: This example uses an array of typed structs - we could easily use classes too.  You could even use any class in Cocoa or other APIs.
struct RowStruct {
    let position : CGPoint
    let color : SKColor
    let size : CGSize
}

var nodeArray = [
    RowStruct(position: CGPoint(x: 100, y: 100), color: .red, size: CGSize(width: 50, height: 50)),
    RowStruct(position: CGPoint(x: 200, y: 200), color: .green, size: CGSize(width: 50, height: 50)),
    RowStruct(position: CGPoint(x: 300, y: 300), color: .yellow, size: CGSize(width: 50, height: 50)),
]
//: **Selection** picks a root node and 'joins' it to the data

let mySelection = select(node:scene as SKNode)
    .selectAll(allChildrenSelector)
    .join(nodeArray)

//: **enter** focuses on the new nodes we need,
//: **append** summons a new sprite, and
//: **attr** sets sprite properties using the **struct** data value `d`.  `s` is the sprite, which can be useful.
mySelection
    .enter()
    .append { (_, _, _) in SKSpriteNode() }
    .attr("position") { (s, d, i) in NSValue(point:d!.position) }
    .attr("size") { (s, d, i) in NSValue(size:d!.size) }
    .attr("color") { (s, d, i) in d!.color }
//: [Next–Section 2–evolving data](@next)
