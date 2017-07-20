import Foundation

public extension CountableRange {
    /// return a random element of the range using arc4random
    func randomElement() -> Bound {
        return self.lowerBound.advanced(by: Int(arc4random_uniform(UInt32(self.lowerBound.distance(to: self.upperBound)))) as! Bound.Stride)
    }
}

public extension Array {
    /// return a random element of the array using arc4random
    func randomElement() -> Element {
        return self[indices.randomElement()]
    }
}
