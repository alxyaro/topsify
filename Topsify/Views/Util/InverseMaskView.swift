// Created by Alex Yaro on 2023-07-13.

import UIKit

final class InverseMaskView: UIView {
    private let sourceView: UIView
    private var sourceViewImage: UIImage?

    init(_ sourceView: UIView) {
        self.sourceView = sourceView
        super.init(frame: .zero)

        backgroundColor = .clear
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        if sourceViewImage == nil {
            let renderer = UIGraphicsImageRenderer(bounds: sourceView.bounds)
            sourceViewImage = renderer.image { rendererContext in
                sourceView.layer.render(in: rendererContext.cgContext)
            }
        }

        guard let context = UIGraphicsGetCurrentContext() else { return }

        context.saveGState()
        defer { context.restoreGState() }

        // 1. Fill the view with a black background:
        context.setFillColor(UIColor.black.cgColor)
        UIRectFill(bounds)

        // 2. Draw the source view, subtracting any non-transparent alpha pixels from the black bg:
        if let image = sourceViewImage {
            image.draw(in: rect, blendMode: .destinationOut, alpha: 1)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if bounds.size != sourceViewImage?.size {
            sourceView.frame = bounds
            sourceViewImage = nil
            setNeedsDisplay()
        }
    }
}
