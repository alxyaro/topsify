// Created by Alex Yaro on 2023-06-11.

import UIKit

final class CubicGradientView: UIView {
    private let color: UIColor

    init(color: UIColor) {
        self.color = color

        super.init(frame: .zero)

        contentMode = .redraw
        backgroundColor = .clear
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

        let stops = Int(rect.height / 10).clamped(to: 2...100)

        var colors = [CGColor]()
        var locations = [CGFloat]()

        colors.reserveCapacity(stops)
        locations.reserveCapacity(stops)

        for stop in 1...stops {
            let pct = CGFloat(stop) / CGFloat(stops)
            let alpha = ease(pct)

            colors.append(color.withAlphaComponent(alpha).cgColor)
            locations.append(pct)
        }

        guard let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors as CFArray, locations: locations) else {
            return
        }

        context.drawLinearGradient(gradient, start: CGPoint(x: bounds.midX, y: 0), end: CGPoint(x: bounds.midX, y: bounds.maxY), options: [])
    }

    private func ease(_ x: CGFloat) -> CGFloat {
        if x < 0.5 {
            return 4 * pow(x, 3)
        } else {
            return 1 - pow(-2 * x + 2, 3) / 2
        }
    }
}
