/*:
 # Getting Started

 **We'll show how easy it is to take a pinch of data, add a couple of rules, and draw something on the screen straight away:**

![Screen shot of playground showing live view with 3 boxes](screenshot.png)

 Here are the ingredients we need:
 */
import StarJoinSelector // a magic brush
import StarJoinSpriteKitAdaptor // and
import SpriteKit        // a paintbox
/*:
 * Callout(Recommended settings): Set the Xcode Scheme to `StarJoinSpriteKitAdaptor`

 This page will be super simple, and each new one adds a little complexity - eventually you will have things flying around on the page.  *Take a peek if you like*.

 This series is intended for a beginner to play around and an intermediate user to find inspiration as well as learning more advanced techniques.

 */
/*:
 ### Getting ready for race day
  We have a couple playground specific steps to let it know we are interested in displaying some graphics output.

 * Callout(try this): It's time to show the *Live View* Assistant Editor - the two circles button at the top right.

 The live view shows you what you are drawing like so:
 */
import PlaygroundSupport
let sceneView = SKView(frame: CGRect(x: 0 , y: 0, width: 400, height: 400))
PlaygroundPage.current.liveView = sceneView
//:  The `scene` object is the only bit of this we use later - keep an eye out.  Here we add it to the view so it gets drawn:
let scene:SKScene = SKScene(size: CGSize(width:640, height:480))
scene.scaleMode = .resizeFill
sceneView.presentScene(scene)
/*: **An toy example of user data**
 Any app with UI is displaying data of some sort.  This is sometimes called the *model* in Apple's [Model-View-Controller](https://developer.apple.com/library/content/documentation/General/Conceptual/DevPedia-CocoaCore/MVC.html) design.\
 For testing you will often want to just invent some data :  Starjoin can use most all types as input data - let's use tuples for the moment because they are easy.
 * experiment: Feel free to edit the code and find out what happens!
*/
var myDataItems = [
    (x:100, y:100, color:#colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1), size:50),
    (x:200, y:200, color:#colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1), size:50),
    (x:300, y:300, color:#colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1), size:50),
]

/*:
 **`Select`ion** is a key concept in StarJoin.  It means picking a UI element or set of elements that we are going to create and modify.  We are going to add children to the scene, so we modify it:
*/
let mySelection = select(node:scene)
//: To begin with we are going to create and modify some basic sprites.  Let's `select` `all` of them.  You'll get to understand the details of this statement later.
    .select(all: allChildrenSelector)
//: In spritejoin you `join` data to your graphics elements, matching each data item to a sprite.  Even if they don't exist yet.
    .join(myDataItems)
//: the `enter` selection operator focuses on the new (missing) nodes we need to match the data we just joined:
mySelection
    .enter()
//: then **`append`** (selection mutation operator) summons a new sprite to stand in for each data item, and
    .append { (d, i) in SKSpriteNode() }
//: The `attr` method uses [KVC](https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/KeyValueCoding/) to create a promise to write sprite properties - we can use the `d` parameter to access the fields from our data's tuple.
//: * experiment: what happens if you change the constant 1 below?
    .attr("position") { (s, d, i) in CGPoint(x: d.x, y: d.y) }
    .attr("size") { (s, d, i) in CGSize(width: d.size, height: d.size) }
    .attr("color") { (s, d, i) in d.color }
/*:
 ## *That's all folks!*

 If you haven't done so already, open the *assistant editor* to view the result.  You should see three colored squares.

 * experiment: don't be shy - have a play with the code and data above and see what you can make it do.
*/
//: [Next–Joining Dictionaries](@next)
