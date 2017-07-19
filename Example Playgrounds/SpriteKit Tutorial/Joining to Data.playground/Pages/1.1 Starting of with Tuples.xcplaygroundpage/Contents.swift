//:# Getting Started
/*:
 This series of tutorial / test cases starts somewhere very simple:

 **We'll show how easy it is to take a pinch of data, add a couple of rules, and draw something on the screen straight away.**

 Here are the ingredients we need
 */
import StarJoinSelector // a magic wand
import StarJoinSpriteKitAdaptor // some glue,
import SpriteKit        // & the paintbox
/*:
 After this page, each new one adds a little complexity - eventually you will have things flying around on the page.  *go ahead, skip to the end*.

 It's intended for a beginner to play around and an intermediate user to find inspiration as well as learning more advanced techniques.

 */
/*:
 ### Getting ready for race day
  We have a couple playground specific steps to let it know we are interested in displaying some graphics output.

  The `scene` object is the only bit of this we use later - keep an eye out.
 */

// Add a spritekit window to the Live View
import PlaygroundSupport // something else
let sceneView = SKView(frame: CGRect(x:0 , y:0, width: 640, height: 480))
PlaygroundPage.current.liveView = sceneView

// Create the scene and add it to the view
let scene:SKScene = SKScene(size: CGSize(width:640, height:480))
scene.scaleMode = .resizeFill
sceneView.presentScene(scene)
//: **An toy example of user data**
//:
//: Any app with UI is displaying data of some sort.  This is sometimes called the *model* (MVC).
//: For testing you will often want to just invent some data :  Starjoin can use most all types as input data - let's use tuples for the moment because they are easy.\
//:  * note: Starjoin likes data stored in arrays
var myDataItems = [
    (x:100, y:100, color:#colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1), size:50),
    (x:200, y:200, color:#colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1), size:50),
    (x:300, y:300, color:#colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1), size:50),
]
/*:
 **`Select`ion** is a key concept in StarJoin.  It means picking a UI element or set of elements that we are going to modify.
*/
let mySelection = select(node:scene as SKNode)
//: To begin with we are going to create and modify some very basic sprites in the scene.  Let's `select` `all` of them.  You'll get to understand the details of this statement later.
    .selectAll(allChildrenSelector)
//: In spritejoin you `join` data to your graphics elements:
    .join(myDataItems)
//: Nothing has been drawn yet - there's a little problem - there **are no children**.
//: the **`enter`** selection operator focuses on the new (missing) nodes we need:
mySelection
    .enter()
//: then **`append`** (selection mutation operator) summons a new sprite to stand in for each data item, and
    .append { (s, d, i) in SKSpriteNode() }
//: The `attr` method uses KVC to create a promise to write sprite properties - we can use `d` to access the fields from our data's tuple.
    .attr("position") { (s, d, i) in SKPoint(x: d!.x, y: d!.y) }
    .attr("size") { (s, d, i) in SKSize(width: d!.size, height: d!.size) }
    .attr("color") { (s, d, i) in d!.color }
/*:
 ## *That's all folks!*

 If you haven't done so already, open the *assistant editor* to view the result.  You should see three colored squares.

 Next have a play with the code above and see what you can make it do.
*/
//: [Next–Joining Dictionaries](@next)
