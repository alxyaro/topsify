// Created by Alex Yaro on 2023-04-02.

extension Comparable {

    func clamped(to range: ClosedRange<Self>) -> Self {
        if self < range.lowerBound {
            return range.lowerBound
        }
        if self > range.upperBound {
            return range.upperBound
        }
        return self
    }

    func clamped(to range: PartialRangeFrom<Self>) -> Self {
        if self < range.lowerBound {
            return range.lowerBound
        }
        return self
    }

    func clamped(to range: PartialRangeThrough<Self>) -> Self {
        if self > range.upperBound {
            return range.upperBound
        }
        return self
    }

    func clamped(min: Self? = nil, max: Self? = nil) -> Self {
        if let min, self < min {
            return min
        }
        if let max, self > max {
            return max
        }
        return self
    }
}

extension Comparable where Self == Int {

    func clamped(to range: Range<Self>) -> Self {
        return clamped(to: range.lowerBound...range.upperBound-1)
    }
}
