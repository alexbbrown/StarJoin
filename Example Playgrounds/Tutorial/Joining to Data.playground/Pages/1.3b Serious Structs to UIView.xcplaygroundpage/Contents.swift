//: [Previous-Joining Dictionaries](@previous)
//:# Structs to UIView
//: * note: Set the Platform to iOS to run this playground
import StarJoinSelector
import StarJoinUIViewAdaptor
import UIKit
/*:
 Enable SpriteKit for Playground
 */
var sceneView = UIView(frame: CGRect(x:0 , y:0, width: 640, height: 480))
let scene = sceneView

// Add a UIKit View to the Live View
import PlaygroundSupport
PlaygroundSupport.PlaygroundPage.current.liveView = sceneView
//: **More Serious Data**
//:
//: This example uses an array of typed structs - we could easily use classes too.  You could even use any class in Cocoa or other APIs.
struct RowStruct {
    let position : CGPoint
    let color : UIColor
    let size : CGSize
}

var nodeArray = [
    RowStruct(position: CGPoint(x: 100, y: 100), color: .red, size: CGSize(width: 50, height: 50)),
    RowStruct(position: CGPoint(x: 200, y: 200), color: .green, size: CGSize(width: 50, height: 50)),
    RowStruct(position: CGPoint(x: 300, y: 300), color: .yellow, size: CGSize(width: 50, height: 50)),
]
//: **Selection** picks a root node and 'joins' it to the data

let mySelection = select(node:scene as UIView)
    .select(all: scene.childNodes)
    .join(nodeArray)

//: **enter** focuses on the new nodes we need,
//: **append** summons a new sprite, and
//: **attr** sets sprite properties using the **struct** data value `d`.  `s` is the sprite, which can be useful.
mySelection
    .enter()
    .append { (_, _) in UIButton(type:.system) }
    .attr("frame") { (s, d, i) in CGRect(origin:d.position, size:d.size) }
    .attr("backgroundColor") { (s, d, i) in d.color }
    .each { (s, d, i) in
        (s as? UIButton)?.setTitle("🐞", for: .normal) }
    .attr("showsTouchWhenHighlighted") { (s, d, i) in true }
    .attr("layer.cornerRadius") { (s, d, i) in d.size.width / 4 }

//: [Next–Section 2–evolving data](@next)

