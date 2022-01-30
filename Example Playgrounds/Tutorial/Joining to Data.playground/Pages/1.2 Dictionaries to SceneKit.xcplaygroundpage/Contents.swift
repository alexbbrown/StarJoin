//:[Previous–Joining Tuples](@previous)
//:# Dictionaries to SceneKit Shapes
/*:
This one mixes it up - a dictionary instead of a tuple, and some funky donuts from `SceneKit`
 
![Three Donuts](donuts.png)

*/

import StarJoinSelector
import StarJoinSceneKitAdaptor
import SceneKit
import SpriteKit // for SKColor?
/*:
 Enable Scenekit for Playground
 */
var sceneView = SCNView(frame: CGRect(x: 0, y: 0, width: 640, height: 480))
sceneView.backgroundColor = .black
sceneView.autoenablesDefaultLighting = true
sceneView.allowsCameraControl = true

// Add a spritekit window to the Live View
import PlaygroundSupport
PlaygroundSupport.PlaygroundPage.current.liveView = sceneView

// Create the scene and add it to the view
var scene = SCNScene()
//scene.scaleMode = .resizeFill
sceneView.scene = scene
//: **Data from the internet**
//:
//: Let's use a table-an array of dictionaries–as our data model this time, and bind that.  This sort of data might be loaded off disk or as `JSON` from the internet, and is pretty common.
//: * note: you might have noticed that Starjoin likes data stored in arrays
var nodeArray = [
    ["x":-100, "y":100, "color":"Red", "size":50],
    ["x":0, "y":0, "color":"Orange", "size":50],
    ["x":100, "y":-50, "color":"Blue", "size":50],
]
//: We need a way to translate text colors to colors.
let colors = NSColorList(named:.init("Apple"))
func color(_ named:String) -> SKColor? {
    return colors!.color(withKey:.init(named))
}
//: **Selection** picks a root node and 'joins' it to the data

let mySelection = select(node:scene.rootNode)
    .select(all: scene.rootNode.childNodes)
    .join(nodeArray)

//: **enter** focuses on the new nodes we need,
//: **append** summons a new sprite, and
//: **attr** sets sprite properties using the **dictionary** data value `d`.
//: + Casting is often necessary for dictionaries; '`!`' is used here for brevity - `if let` patterns are also a good option
mySelection
    .enter()
    .append { (_, _) in
        var sphere = SCNSphere()
        var torus = SCNTorus(ringRadius: 1, pipeRadius: 0.35)
        return SCNNode(geometry: torus)
    }
    .attr("position") { (s, d, i) in
        SCNVector3(x:0.01 * CGFloat(d["x"] as! Int),
                   y:0.01 * CGFloat(d["y"] as! Int),
                   z: CGFloat(-2.0))
    }
    .attr("scale") { (s, d, i) in
        let size = 0.01 * CGFloat(d["size"] as! Int)
        return SCNVector3(x: size, y: size, z: size)
    }
    .attr("geometry.firstMaterial.diffuse.contents") { (s, d, i) in color(d["color"] as! String)
    }
//:   What's `(s, d, i)`?
//:   - `d` is whatever the current record is - a row from the data array
//:   - `s` is the sprite, which can be useful.
//:   - `i` is the index in the array this element is from.  Can be used to order elements if you don't want absolute positioning (more on this later)
//:
//: [Next–Joining Structs](@next)

