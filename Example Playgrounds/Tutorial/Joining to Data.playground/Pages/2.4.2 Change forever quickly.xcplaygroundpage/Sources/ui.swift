import Foundation
import SpriteKit

#if os(macOS)
// The update function is in this file because the code in the sources directory of playgrounds is run at a much faster speed than that in the main view.  It would be even faster in an application
public func updateNode(s:SKNode?, d:TableRow?, i:Int) -> () {
    if let sprite = s as? SKSpriteNode {
        sprite.position = CGPoint(x: CGFloat(d!.x), y: CGFloat(d!.y))
        sprite.color = colors.color(withKey:d!.color) ?? .red
        sprite.size = CGSize(width: CGFloat(d!.size), height: CGFloat(d!.size))
    }
}
#endif
