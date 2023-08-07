// Created by Alex Yaro on 2023-08-06.

extension FloatingPoint {

    func pctInRange(_ range: ClosedRange<Self>) -> Self {
        let value = self - range.lowerBound
        let distance = range.upperBound - range.lowerBound
        return distance > 0 ? (value / distance).clamped(to: 0...1) : 0
    }
}
