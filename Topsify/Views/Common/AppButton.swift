// Created by Alex Yaro on 2022-04-06.

import Combine
import CombineCocoa
import UIKit

class AppButton: UIControl {
    private let wrapperView = UIView()

    let contentView: UIView
    let scaleOnTap: Bool
    typealias TapHandler = () -> Void
    var onTap: TapHandler?

    override var isHighlighted: Bool {
        didSet {
            if oldValue != isHighlighted {
                UIView.animate(
                    withDuration: isHighlighted ? 0.04 : 0.2,
                    delay: 0,
                    options: isHighlighted ? [.curveEaseOut, .beginFromCurrentState] : [.curveEaseOut]
                ) { [unowned self] in
                    wrapperView.alpha = isHighlighted ? 0.55 : 1.0
                    let scale = isHighlighted && scaleOnTap ? 0.95 : 1
                    wrapperView.transform = CGAffineTransform(scaleX: scale, y: scale)
                }
            }
        }
    }
    
    init(contentView: UIView? = nil, scaleOnTap: Bool = true, onTap: TapHandler? = nil) {
        let contentView = contentView ?? UIView()
        
        self.wrapperView.isUserInteractionEnabled = false
        self.contentView = contentView
        self.scaleOnTap = scaleOnTap
        self.onTap = onTap

        super.init(frame: .zero)
        
        super.addSubview(wrapperView)
        wrapperView.constrainEdgesToSuperview()
        
        wrapperView.addSubview(contentView)
        contentView.constrainEdgesToSuperview()

        addTarget(self, action: #selector(handleTap), for: .touchUpInside)
    }

    convenience init(icon: String, size: CGFloat, contentMode: UIView.ContentMode = .center) {
        let imageView = UIImageView(
            image: UIImage(
                systemName: icon,
                withConfiguration: UIImage.SymbolConfiguration(pointSize: size)
            )
        )
        imageView.setContentHuggingPriority(.required, for: .horizontal)
        imageView.setContentCompressionResistancePriority(.required, for: .horizontal)
        imageView.contentMode = contentMode
        self.init(contentView: imageView)
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
}

extension AppButton {
    var tapPublisher: AnyPublisher<Void, Never> {
        controlEventPublisher(for: .touchUpInside)
    }
}
