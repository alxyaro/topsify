// Created by Alex Yaro on 2022-04-06.

import Combine
import CombineCocoa
import UIKit

class AppButton: UIControl {
    typealias TapHandler = () -> Void

    let contentView: UIView
    var onTap: TapHandler?

    private let scaleOnTap: Bool
    private let expandedTouchBoundary: UIEdgeInsets

    override var isHighlighted: Bool {
        didSet {
            if oldValue != isHighlighted {
                UIView.animate(
                    withDuration: isHighlighted ? 0.04 : 0.2,
                    delay: 0,
                    options: isHighlighted ? [.curveEaseOut, .beginFromCurrentState] : [.curveEaseOut]
                ) { [unowned self] in
                    contentView.alpha = isHighlighted ? 0.55 : 1.0
                    let scale = isHighlighted && scaleOnTap ? 0.95 : 1
                    contentView.transform = CGAffineTransform(scaleX: scale, y: scale)
                }
            }
        }
    }
    
    init(
        contentView: UIView? = nil,
        scaleOnTap: Bool = true,
        expandedTouchBoundary: UIEdgeInsets = .zero,
        onTap: TapHandler? = nil
    ) {
        let contentView = contentView ?? UIView()
        self.contentView = contentView
        self.contentView.isUserInteractionEnabled = false
        self.scaleOnTap = scaleOnTap
        self.expandedTouchBoundary = expandedTouchBoundary
        self.onTap = onTap

        super.init(frame: .zero)
        
        super.addSubview(contentView)
        contentView.constrainEdgesToSuperview()

        addTarget(self, action: #selector(handleTap), for: .touchUpInside)
    }

    convenience init(
        icon: String,
        size: CGFloat,
        expandedTouchBoundary: UIEdgeInsets = .init(uniform: 8),
        contentMode: UIView.ContentMode = .center
    ) {
        let imageView = UIImageView(
            image: UIImage(
                systemName: icon,
                withConfiguration: UIImage.SymbolConfiguration(pointSize: size)
            )
        )
        imageView.setContentHuggingPriority(.required, for: .horizontal)
        imageView.setContentCompressionResistancePriority(.required, for: .horizontal)
        imageView.contentMode = contentMode
        self.init(contentView: imageView, expandedTouchBoundary: expandedTouchBoundary)
        tintColor = .primaryIcon
    }
    
    required init(coder: NSCoder) {
        fatalError()
    }

    @objc private func handleTap() {
        onTap?()
    }

    @available(*, unavailable, message: "Add subviews to contentView, not the button itself")
    override func addSubview(_ view: UIView) {
        super.addSubview(view)
    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        bounds.expanded(by: expandedTouchBoundary).contains(point)
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if self.point(inside: point, with: event) {
            return self
        }
        return nil
    }
}

extension AppButton {
    var tapPublisher: AnyPublisher<Void, Never> {
        controlEventPublisher(for: .touchUpInside)
    }
}
