//: [Previous](@previous)
//:# Structs to Sprites
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

//: **Data Configuration**
//:
//: This example uses an array of dictionaries–as the input data

struct RowStruct {
    var position : CGPoint
    var color : SKColor
    var size : CGSize
}

var nodeArray = [
    RowStruct(position: CGPoint(x: 100, y: 100), color: .redColor(), size: CGSize(width: 50, height: 50)),
    RowStruct(position: CGPoint(x: 200, y: 200), color: .greenColor(), size: CGSize(width: 50, height: 50)),
    RowStruct(position: CGPoint(x: 300, y: 300), color: .yellowColor(), size: CGSize(width: 50, height: 50)),
]

//: **Selection** picks a root node and 'joins' it to the data

let mySelection = select(node:scene as SKNode)
    .selectAll(allChildrenSelector)
    .join(nodeArray)

//: **Enter** summons and configures new sprites

//mySelection
//    .enter()
//    .append { (s, d, i) in SKSpriteNode() }
//    .attr("position") { (s, d, i) in SKPoint(x: d!.x, y: d!.y) }
//    .attr("size") { (s, d, i) in SKSize(width: d!.size, height: d!.size) }
//    .attr("color") { (s, d, i) in d!.color }



mySelection
    .enter()
    .append { (_, _, _) in SKSpriteNode() }
    .attr("position") { (s, d, i) in NSValue(point:d!.position) }
    .attr("size") { (s, d, i) in NSValue(size:d!.size) }
    .setKeyedAttr("color") { (s, d, i) in d!.color }
//: [Next](@next)
