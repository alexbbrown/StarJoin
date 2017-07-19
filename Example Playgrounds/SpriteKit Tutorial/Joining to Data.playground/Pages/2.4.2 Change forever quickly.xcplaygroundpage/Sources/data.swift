import SpriteKit

public typealias TableRow = (x: Float, y: Float, color: NSColor.Name, size: Float)

public func rangeRandom(min:Int, max:Int) -> Int {
    return min + Int(arc4random_uniform(UInt32(max - min)))
}

public func rangeRandom<T>(ordinals: [T]) -> T {
    return ordinals[rangeRandom(min: 0, max: ordinals.count - 1)]
}

public let colors = NSColorList(named:.init("Apple"))!
func nodeGenerator1(xmax: Int, ymax:Int, size:Float) -> TableRow {
    return (x:Float(rangeRandom(min: 0, max: xmax)),
            y:Float(rangeRandom(min: 0, max: ymax)),
            color: rangeRandom(ordinals:colors.allKeys),
            size:size)
}

public func nodeArrayGenerator(count:(min:Int, max:Int), xmax: Int, ymax:Int, size:Float) -> [TableRow] {
    var nodeArray = [TableRow]()
    for _ in 1...rangeRandom(min: count.min, max: count.max) {
        nodeArray.append(nodeGenerator1(xmax: xmax, ymax: ymax, size: size))
    }
    return nodeArray
}
