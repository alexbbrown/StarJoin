/*: [Previous-Joining Structs](@previous)
 # Towards animation - change over time
 This extends the Change over time to generate frames forever.

 - Callout(performance): This version moves some of the code into a the sources folder - where it gets precompiled.  Now it runs at about 3 fps
 */
//:  ![example](ss2.png)
import StarJoinSelector
import StarJoinSpriteKitAdaptor
import SpriteKit

let scene = SKScene()
//: **Generated data**
//:
//: The data generator has moved into the file `data.swift` for speed.
let nodeArray = nodeArrayGenerator(count:(min:5, max:15), xmax:1000, ymax:600, size:50)
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

//:

entered.append { (d, i) -> SKNode in
    return SKSpriteNode()
    }.each(updateNode)

//: We can schedule more action to happen later.  For a performance test, this code has been moved to the `sources/delegate.swift` file

// We need our own copy of the delegate - scene.delegate is weak
let sceneDelegate = SJDelegate()
scene.delegate = sceneDelegate

class SJDelegate:NSObject { }

extension SJDelegate:SKSceneDelegate {
    func update(_ currentTime: TimeInterval, for scene: SKScene) {

        let nodeArray2 = nodeArrayGenerator(count:(min:50, max:150), xmax:1000, ymax:600, size:20)

        // MARK: select & join second batch
        let mySelection2 = rootNode.select(all: scene.childNodes).join(nodeArray2)

        // MARK: exit old nodes and enter new ones (fail to update)

        // full enter/exit update example
        mySelection2.exit().remove()

        let entered2 = mySelection2.enter()

        //: We still need new nodes for extra data rows, but we can choose not to configure them immediately
        let appended2 = entered2.append { (_, _) in SKSpriteNode() }
        // TODO: check d3.js still use the enter/append/update selection sematics or if that's fixed.
        //: Instead grab all the nodes corresponding to updated data using the `update` selection–and configure your heart away!
        let updated2 = mySelection2.update()

        let merged2 = updated2.merge(with: appended2)

        // should append BE the enter operation?
        // how does enter affect the selection it owns?
        merged2.each(updateNode)
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
PlaygroundPage.current.needsIndefiniteExecution = true

// Create the scene and add it to the view
scene.size = CGSize(width:100, height:100)
scene.scaleMode = .resizeFill
sceneView.presentScene(scene)

//: [Next](@next)




