// Created by Alex Yaro on 2023-06-23.

import UIKit

protocol TransitionPanGestureHandlerDelegate: AnyObject {
    func shouldBeginTransition(_ handler: TransitionPanGestureHandler) -> Bool
    func beginTransition(_ handler: TransitionPanGestureHandler) -> Void
    func completionPanDistance(_ handler: TransitionPanGestureHandler) -> CGFloat
}

final class TransitionPanGestureHandler {

    enum CompletionDirection {
        case up
        case down
        case left
        case right
    }

    private let gestureRecognizer: UIPanGestureRecognizer
    private let direction: CompletionDirection
    private weak var delegate: TransitionPanGestureHandlerDelegate?

    private var currentCompletionPanDistance: CGFloat = 0
    private(set) var interactionController: UIPercentDrivenInteractiveTransition?

    init(
        gestureRecognizer: UIPanGestureRecognizer,
        direction: CompletionDirection,
        delegate: TransitionPanGestureHandlerDelegate
    ) {
        self.gestureRecognizer = gestureRecognizer
        self.direction = direction
        self.delegate = delegate
        gestureRecognizer.addTarget(self, action: #selector(handleGesture))
    }

    @objc private func handleGesture() {
        switch gestureRecognizer.state {
        case .possible:
            break
        case .began:
            if let controller = interactionController {
                controller.cancel()
            }
            guard let delegate, delegate.shouldBeginTransition(self) else { return }

            interactionController = .init()
            currentCompletionPanDistance = delegate.completionPanDistance(self)

            delegate.beginTransition(self)
        case .changed:
            let percentComplete = (translation() / max(1, currentCompletionPanDistance)).clamped(to: 0...1)
            interactionController?.update(percentComplete)
        case .ended, .cancelled, .failed: fallthrough
        @unknown default:
            if let controller = interactionController {
                var shouldFinish = controller.percentComplete >= 0.5
                let velocity = velocity()
                if abs(velocity) > 500 {
                    shouldFinish = velocity > 0
                }

                if shouldFinish {
                    controller.finish()
                } else {
                    controller.cancel()
                }
            }
            interactionController = nil
        }
    }

    private func translation() -> CGFloat {
        let translation = gestureRecognizer.translation(in: gestureRecognizer.view)
        switch direction {
        case .up:
            return -translation.y
        case .down:
            return translation.y
        case .left:
            return -translation.x
        case .right:
            return translation.x
        }
    }

    private func velocity() -> CGFloat {
        let velocity = gestureRecognizer.velocity(in: gestureRecognizer.view)
        switch direction {
        case .up:
            return -velocity.y
        case .down:
            return velocity.y
        case .left:
            return -velocity.x
        case .right:
            return velocity.x
        }
    }
}
