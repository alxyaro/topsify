// Created by Alex Yaro on 2023-06-19.

import UIKit

final class HorizontalGradientMaskView: UIView {
    private let gradientSize: CGFloat

    override var frame: CGRect {
        didSet {
            setNeedsDisplay()
        }
    }

    init(gradientSize: CGFloat) {
        self.gradientSize = gradientSize
        super.init(frame: .zero)
        backgroundColor = .clear
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }

        /// For debugging, a clearly visible color (when view is used as mask, color is irrelevant)
        let solidColor = UIColor.purple.cgColor

        guard let gradient = CGGradient(
            colorsSpace: CGColorSpaceCreateDeviceRGB(),
            colors: [solidColor, UIColor.clear.cgColor] as CFArray,
            locations: [0.0, 1.0]
        ) else { return }

        let leftGradientPos = gradientSize
        let rightGradientPos = bounds.width - gradientSize

        ctx.drawLinearGradient(
            gradient,
            start: .init(x: leftGradientPos, y: 0),
            end: .init(x: 0, y: 0),
            options: []
        )

        ctx.drawLinearGradient(
            gradient,
            start: .init(x: rightGradientPos, y: 0),
            end: .init(x: bounds.width, y: 0),
            options: []
        )

        ctx.beginPath()
        ctx.addRect(bounds.inset(by: .init(horizontal: gradientSize, vertical: 0)))
        ctx.setFillColor(solidColor)
        ctx.fillPath()
    }
}
