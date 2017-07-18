//:# Tuples to Sprites

import StarJoinSelector
import SpriteKit
import StarJoinSpriteKitAdaptor
import PlaygroundSupport

let example = #imageLiteral(resourceName: "screenshot.png")
/*:
 Enable SpriteKit for Playground

![Example Screenshot](screenshot.png "flurm")

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
//: Let's use tuples as the input data

var nodeArray = [
    (x:100, y:100, color:#colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1), size:50),
    (x:200, y:200, color:#colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1), size:50),
    (x:300, y:300, color:#colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1), size:50),
]

//: **Selection** picks a root node and 'joins' it to the data

let mySelection = select(node:scene as SKNode)
    .selectAll(allChildrenSelector)
    .join(nodeArray)

//: **Enter** summons and configures new sprites

mySelection
    .enter()
    .append { (s, d, i) in SKSpriteNode() }
    .attr("position") { (s, d, i) in SKPoint(x: d!.x, y: d!.y) }
    .attr("size") { (s, d, i) in SKSize(width: d!.size, height: d!.size) }
    .attr("color") { (s, d, i) in d!.color }

//: [Next–Joining Dictionaries](@next)
