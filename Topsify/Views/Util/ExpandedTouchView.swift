// Created by Alex Yaro on 2023-03-31.

import UIKit

/// Wrapper view for modifying the boundary used for touch hit-testing.
final class ExpandedTouchView<WrappedView: UIView>: UIView {
    let wrappedView: WrappedView
    let expansion: UIEdgeInsets

    init(_ wrappedView: WrappedView, expandedBy expansion: UIEdgeInsets) {
        self.wrappedView = wrappedView
        self.expansion = expansion
        super.init(frame: .zero)

        addSubview(wrappedView)
        wrappedView.constrainEdgesToSuperview()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        bounds.expanded(by: expansion).contains(point)
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let result = wrappedView.hitTest(convert(point, to: wrappedView), with: event)
        if result != nil {
            return result
        }
        if self.point(inside: point, with: event) {
            return wrappedView
        }
        return nil
    }
}
