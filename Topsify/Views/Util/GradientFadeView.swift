// Created by Alex Yaro on 2023-06-11.

import UIKit

final class GradientFadeView: UIView {

    enum Direction {
        case up
        case down
    }

    enum Easing {
        case quadOut
        case quadInOut
        case cubicOut
        case cubicInOut

        func ease(_ x: CGFloat) -> CGFloat {
            switch self {
            case .quadOut:
                return 1 - pow(1 - x, 2)
            case .quadInOut:
                if x < 0.5 {
                    return 2 * pow(x, 2)
                } else {
                    return 1 - pow(-2 * x + 2, 2) / 2
                }
            case .cubicOut:
                return 1 - pow(1 - x, 3)
            case .cubicInOut:
                if x < 0.5 {
                    return 4 * pow(x, 3)
                } else {
                    return 1 - pow(-2 * x + 2, 3) / 2
                }
            }
        }
    }

    private let color: UIColor
    private let direction: Direction
    private let easing: Easing

    init(color: UIColor, direction: Direction, easing: Easing = .cubicInOut) {
        self.color = color
        self.direction = direction
        self.easing = easing

        super.init(frame: .zero)

        contentMode = .redraw
        backgroundColor = .clear
        isUserInteractionEnabled = false
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }

        let stops = Int(bounds.height / 10).clamped(to: 2...100)

        var colors = [CGColor]()
        var locations = [CGFloat]()

        colors.reserveCapacity(stops)
        locations.reserveCapacity(stops)

        for stop in 0..<stops {
            let pct = CGFloat(stop) / CGFloat(stops-1)
            let alpha = easing.ease(pct)

            colors.append(color.withAlphaComponent(alpha).cgColor)
            locations.append(pct)
        }

        guard let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors as CFArray, locations: locations) else {
            return
        }

        context.drawLinearGradient(
            gradient,
            start: CGPoint(x: bounds.midX, y: direction == .up ? 0 : bounds.maxY),
            end: CGPoint(x: bounds.midX, y: direction == .up ? bounds.maxY: 0),
            options: []
        )
    }
}
