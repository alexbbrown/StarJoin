/*:
 [Previous-Joining Dictionaries](@previous)
 # Structs to NSView (macOS)

 We can also join data to active controls - to generate UI for macOS Apps

 ![Screen shot of playground showing live view with 3 NSButtons with ladybirds](Screenshot.png)

 * Callout(Recommended settings): Set the Playground Settings Platform to macOS & Set the Scheme to `StarJoinNSViewAdaptor`
*/
import StarJoinSelector
import StarJoinNSViewAdaptor // Set your scheme to this
import AppKit
/*:
 Enable SpriteKit for Playground
 */
var sceneView = NSView(frame: CGRect(x:0 , y:0, width: 640, height: 480))
let scene = sceneView

// Add a AppKit View to the Live View
import PlaygroundSupport
PlaygroundSupport.PlaygroundPage.current.liveView = sceneView
//: **More Serious Data**
//:
//: This example uses an array of typed structs - we could easily use classes too.  You could even use any class in Cocoa or other APIs.
struct RowStruct {
    let position : CGPoint
    let color : NSColor
    let size : CGSize
}

var nodeArray = [
    RowStruct(position: CGPoint(x: 100, y: 100), color: .red, size: CGSize(width: 50, height: 50)),
    RowStruct(position: CGPoint(x: 200, y: 200), color: .green, size: CGSize(width: 50, height: 50)),
    RowStruct(position: CGPoint(x: 300, y: 300), color: .yellow, size: CGSize(width: 50, height: 50)),
]
//: **Selection** picks a root node and 'joins' it to the data

let mySelection = select(node:scene as NSView)
    .select(all: scene.childNodes)
    .join(nodeArray)

//: **enter** focuses on the new nodes we need,
//: **append** summons a new sprite, and
//: **attr** sets sprite properties using the **struct** data value `d`.  `s` is the sprite, which can be useful.
mySelection
    .enter()
    .append { (_, _) in NSButton() }
    .attr(#keyPath(NSButton.frame)) { (s, d, i) in CGRect(origin:d.position, size:d.size) }
    .attr(#keyPath(NSButton.title), toValue:"🐞")
    .attr("layer.cornerRadius") { (s, d, i) in d.size.width / 4 }

//: [Next–Section 2–evolving data](@next)

