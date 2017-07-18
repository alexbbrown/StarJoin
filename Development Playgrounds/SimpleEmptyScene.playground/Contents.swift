//: A SpriteKit based Playground

// Expected: Open assistant editor - you should see a black box.

import PlaygroundSupport
import SpriteKit

// Load the SKScene from 'GameScene.sks'
let sceneView = SKView(frame: CGRect(x:0 , y:0, width: 640, height: 480))

let scene:SKScene = SKScene()

// Set the scale mode to scale to fit the window
scene.scaleMode = .aspectFill

// Present the scene
sceneView.presentScene(scene)

PlaygroundSupport.PlaygroundPage.current.liveView = sceneView
PlaygroundSupport.PlaygroundPage.current.needsIndefiniteExecution = true

scene.setValue(<#T##value: Any?##Any?#>, forKey: <#T##String#>)
scene.value(forKey: <#T##String#>)
