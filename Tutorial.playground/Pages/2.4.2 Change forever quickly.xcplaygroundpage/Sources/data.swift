import SpriteKit

#if os(macOS)
public typealias TableRow = (x: Float, y: Float, color: NSColor.Name, size: Float)

public let colors = NSColorList(named:.init("Apple"))!

func nodeGenerator(xmax: Int, ymax:Int, size:Float) -> TableRow {
    return (x:Float((0..<xmax).randomElement()),
            y:Float((0..<ymax).randomElement()),
            color: colors.allKeys.randomElement(),
            size:size)
}

public func nodeArrayGenerator(count:(min:Int, max:Int), xmax: Int, ymax:Int, size:Float) -> [TableRow] {
    var nodeArray = [TableRow]()
    for _ in 1...(count.min..<(1+count.max)).randomElement() {
        nodeArray.append(nodeGenerator(xmax: xmax, ymax: ymax, size: size))
    }
    return nodeArray
}
#endif


