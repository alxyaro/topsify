// Created by Alex Yaro on 2022-04-06.

import Combine
import CombineCocoa
import UIKit

class AppButton: UIControl {
    let contentView: UIView

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
        expandedTouchBoundary: UIEdgeInsets = .zero
    ) {
        let contentView = contentView ?? UIView()
        self.contentView = contentView
        self.contentView.isUserInteractionEnabled = false
        self.scaleOnTap = scaleOnTap
        self.expandedTouchBoundary = expandedTouchBoundary

        super.init(frame: .zero)
        
        super.addSubview(contentView)
        contentView.constrainEdgesToSuperview()
    }
    
    required init(coder: NSCoder) {
        fatalError()
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
