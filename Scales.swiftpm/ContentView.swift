import SwiftUI
import SpriteKit

struct ContentView: View {
    var scene = GameScene(fileNamed: "GameScene")!

    var body: some View {
        SpriteView(scene: scene)
    }
}
